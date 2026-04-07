const LANGUAGES = {
  python: { label: "Python", prism: "python" },
  excel: { label: "Excel", prism: "none" },
  vba: { label: "VBA", prism: "basic" },
  powerquery: { label: "PowerQuery", prism: "javascript" },
  markdown: { label: "Markdown", prism: "markdown" },
  javascript: { label: "JavaScript", prism: "javascript" },
  json: { label: "JSON", prism: "json" },
  html: { label: "HTML", prism: "markup" },
  css: { label: "CSS", prism: "css" },
  txt: { label: "TXT", prism: "none" }
};

const LANGUAGE_ORDER = [
  "python", "excel", "vba", "powerquery", "markdown",
  "javascript", "json", "html", "css", "txt"
];

const PAGE_SIZE = 10;

const state = {
  items: [],
  currentLang: "all",
  keyword: "",
  currentPage: 1,
  loadedCode: new Map()
};

const categoryBar = document.getElementById("categoryBar");
const searchInput = document.getElementById("searchInput");
const cardList = document.getElementById("cardList");
const emptyState = document.getElementById("emptyState");
const resultInfo = document.getElementById("resultInfo");
const pageInfo = document.getElementById("pageInfo");
const prevBtn = document.getElementById("prevBtn");
const nextBtn = document.getElementById("nextBtn");

function escapeHtml(text) {
  return text
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

function normalizeText(text) {
  return (text || "").toLowerCase().trim();
}

function getPrismLanguage(lang) {
  return LANGUAGES[lang]?.prism || "none";
}

function buildCategoryButtons() {
  const keys = ["all", ...LANGUAGE_ORDER];
  categoryBar.innerHTML = keys.map((key) => {
    const label = key === "all" ? "全部" : (LANGUAGES[key]?.label || key);
    const activeClass = key === state.currentLang ? "active" : "";
    return `<button class="category-btn ${activeClass}" data-lang="${key}">${label}</button>`;
  }).join("");

  categoryBar.querySelectorAll(".category-btn").forEach((btn) => {
    btn.addEventListener("click", () => {
      state.currentLang = btn.dataset.lang;
      state.currentPage = 1;
      buildCategoryButtons();
      render();
    });
  });
}

async function loadAllIndexes() {
  const rootRes = await fetch("index.json", { cache: "no-store" });
  if (!rootRes.ok) {
    throw new Error("无法读取根目录 index.json");
  }
  const categories = await rootRes.json();

  const allItems = [];
  for (const category of categories) {
    const lang = normalizeText(category.language);
    const indexPath = category.index;
    const res = await fetch(indexPath, { cache: "no-store" });
    if (!res.ok) {
      console.warn(`跳过无法读取的分类索引: ${indexPath}`);
      continue;
    }
    const records = await res.json();
    const folder = indexPath.split("/")[0];

    for (const record of records) {
      if (!record || !record.file) continue;
      allItems.push({
        title: record.title || "未命名记录",
        desc: record.desc || "",
        language: lang,
        file: record.file,
        path: `${folder}/${record.file}`
      });
    }
  }
  state.items = allItems;
}

function getFilteredItems() {
  const keyword = normalizeText(state.keyword);
  return state.items.filter((item) => {
    const langMatch = state.currentLang === "all" || item.language === state.currentLang;
    if (!langMatch) return false;
    if (!keyword) return true;
    const haystack = `${item.title} ${item.desc}`.toLowerCase();
    return haystack.includes(keyword);
  });
}

function paginate(items) {
  const totalPages = Math.max(1, Math.ceil(items.length / PAGE_SIZE));
  const currentPage = Math.min(state.currentPage, totalPages);
  state.currentPage = currentPage;
  const start = (currentPage - 1) * PAGE_SIZE;
  const pageItems = items.slice(start, start + PAGE_SIZE);
  return { totalPages, currentPage, pageItems };
}

function render() {
  const filtered = getFilteredItems();
  const { totalPages, currentPage, pageItems } = paginate(filtered);

  resultInfo.textContent = `共 ${state.items.length} 条记录，当前匹配 ${filtered.length} 条`;
  pageInfo.textContent = `第 ${currentPage} / ${totalPages} 页`;
  prevBtn.disabled = currentPage <= 1;
  nextBtn.disabled = currentPage >= totalPages;

  if (pageItems.length === 0) {
    cardList.innerHTML = "";
    emptyState.classList.remove("hidden");
    return;
  }

  emptyState.classList.add("hidden");
  cardList.innerHTML = pageItems.map((item, index) => {
    const itemId = `item-${currentPage}-${index}`;
    const langLabel = LANGUAGES[item.language]?.label || item.language;
    return `
      <article class="card" data-path="${item.path}">
        <div class="card-head">
          <div>
            <h2 class="card-title">${escapeHtml(item.title)}</h2>
            <p class="card-desc">${escapeHtml(item.desc)}</p>
          </div>
        </div>
        <div class="card-meta">
          <span class="badge">${escapeHtml(langLabel)}</span>
          <span class="badge">${escapeHtml(item.file)}</span>
        </div>
        <div class="card-actions">
          <button class="action-btn toggle-btn" data-target="${itemId}" data-path="${item.path}" data-lang="${item.language}">展开代码</button>
          <button class="action-btn copy-btn" data-path="${item.path}">复制代码</button>
        </div>
        <div id="${itemId}" class="code-wrap hidden">
          <pre><code class="language-${getPrismLanguage(item.language)}"></code></pre>
        </div>
      </article>
    `;
  }).join("");

  bindCardEvents();
}

async function fetchCode(path) {
  if (state.loadedCode.has(path)) {
    return state.loadedCode.get(path);
  }
  const res = await fetch(path, { cache: "no-store" });
  if (!res.ok) {
    throw new Error(`无法读取代码文件: ${path}`);
  }
  const code = await res.text();
  state.loadedCode.set(path, code);
  return code;
}

async function handleToggle(button) {
  const targetId = button.dataset.target;
  const path = button.dataset.path;
  const lang = button.dataset.lang;
  const wrap = document.getElementById(targetId);
  const codeEl = wrap.querySelector("code");

  if (!wrap.classList.contains("hidden")) {
    wrap.classList.add("hidden");
    button.textContent = "展开代码";
    return;
  }

  button.disabled = true;
  button.textContent = "加载中…";
  try {
    const code = await fetchCode(path);
    codeEl.textContent = code;
    codeEl.className = `language-${getPrismLanguage(lang)}`;
    if (window.Prism && getPrismLanguage(lang) !== "none") {
      Prism.highlightElement(codeEl);
    }
    wrap.classList.remove("hidden");
    button.textContent = "收起代码";
  } catch (error) {
    codeEl.textContent = `加载失败：${error.message}`;
    wrap.classList.remove("hidden");
    button.textContent = "收起代码";
  } finally {
    button.disabled = false;
  }
}

async function handleCopy(button) {
  const path = button.dataset.path;
  const oldText = button.textContent;
  button.disabled = true;
  try {
    const code = await fetchCode(path);
    await navigator.clipboard.writeText(code);
    button.textContent = "已复制";
  } catch (error) {
    button.textContent = "复制失败";
    console.error(error);
  } finally {
    setTimeout(() => {
      button.textContent = oldText;
      button.disabled = false;
    }, 1200);
  }
}

function bindCardEvents() {
  document.querySelectorAll(".toggle-btn").forEach((btn) => {
    btn.addEventListener("click", () => handleToggle(btn));
  });
  document.querySelectorAll(".copy-btn").forEach((btn) => {
    btn.addEventListener("click", () => handleCopy(btn));
  });
}

searchInput.addEventListener("input", (event) => {
  state.keyword = event.target.value;
  state.currentPage = 1;
  render();
});

prevBtn.addEventListener("click", () => {
  if (state.currentPage > 1) {
    state.currentPage -= 1;
    render();
    window.scrollTo({ top: 0, behavior: "smooth" });
  }
});

nextBtn.addEventListener("click", () => {
  state.currentPage += 1;
  render();
  window.scrollTo({ top: 0, behavior: "smooth" });
});

async function init() {
  try {
    buildCategoryButtons();
    await loadAllIndexes();
    render();
  } catch (error) {
    resultInfo.textContent = `初始化失败：${error.message}`;
    cardList.innerHTML = "";
    emptyState.textContent = "请检查根目录 index.json、各分类目录 index.json 以及 GitHub Pages 的文件路径。";
    emptyState.classList.remove("hidden");
    console.error(error);
  }
}

init();
