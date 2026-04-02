const state = {
  allSnippets: [],
  filteredSnippets: [],
};

const els = {
  searchInput: document.getElementById('searchInput'),
  langFilter: document.getElementById('langFilter'),
  categoryFilter: document.getElementById('categoryFilter'),
  sortSelect: document.getElementById('sortSelect'),
  clearFiltersBtn: document.getElementById('clearFiltersBtn'),
  statsText: document.getElementById('statsText'),
  snippetList: document.getElementById('snippetList'),
  pinnedList: document.getElementById('pinnedList'),
  pinnedSection: document.getElementById('pinnedSection'),
  template: document.getElementById('snippetTemplate'),
  themeToggle: document.getElementById('themeToggle'),
  prismLightTheme: document.getElementById('prism-light-theme'),
  prismDarkTheme: document.getElementById('prism-dark-theme')
};

function setTheme(theme) {
  const isDark = theme === 'dark';
  document.body.classList.toggle('dark', isDark);
  els.prismDarkTheme.disabled = !isDark;
  els.prismLightTheme.disabled = isDark;
  localStorage.setItem('codebook-theme', theme);
  els.themeToggle.textContent = isDark ? '☀️ 浅色模式' : '🌙 深色模式';
}

function initTheme() {
  const stored = localStorage.getItem('codebook-theme');
  if (stored) {
    setTheme(stored);
    return;
  }
  const prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
  setTheme(prefersDark ? 'dark' : 'light');
}

function uniqueSortedValues(items, key) {
  return [...new Set(items.map(item => item[key]).filter(Boolean))].sort((a, b) => String(a).localeCompare(String(b), 'zh-CN'));
}

function populateSelect(selectEl, values, defaultLabel) {
  selectEl.innerHTML = '';
  const defaultOption = document.createElement('option');
  defaultOption.value = '';
  defaultOption.textContent = defaultLabel;
  selectEl.appendChild(defaultOption);

  values.forEach(value => {
    const option = document.createElement('option');
    option.value = value;
    option.textContent = value;
    selectEl.appendChild(option);
  });
}

function normalizeText(value) {
  return String(value || '').toLowerCase();
}

function compareDate(a, b) {
  const ad = new Date(a || '1970-01-01').getTime();
  const bd = new Date(b || '1970-01-01').getTime();
  return ad - bd;
}

function sortSnippets(items) {
  const mode = els.sortSelect.value;
  const cloned = [...items];

  if (mode === 'updated_desc') cloned.sort((a, b) => compareDate(b.updated, a.updated));
  if (mode === 'updated_asc') cloned.sort((a, b) => compareDate(a.updated, b.updated));
  if (mode === 'title_asc') cloned.sort((a, b) => String(a.title).localeCompare(String(b.title), 'zh-CN'));
  if (mode === 'title_desc') cloned.sort((a, b) => String(b.title).localeCompare(String(a.title), 'zh-CN'));

  return cloned;
}

function getPrismLanguage(language) {
  const map = {
    python: 'python',
    javascript: 'javascript',
    js: 'javascript',
    html: 'markup',
    xml: 'markup',
    css: 'css',
    json: 'json',
    sql: 'sql',
    bash: 'bash',
    sh: 'bash',
    shell: 'bash',
    vba: 'basic',
    basic: 'basic',
    powerquery: 'sql',
    pq: 'sql'
  };
  return map[normalizeText(language)] || 'markup';
}

function escapeHtml(str) {
  return String(str)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');
}

async function safeFetchText(filePath) {
  try {
    const res = await fetch(filePath);
    if (!res.ok) return `// 代码文件读取失败：${filePath}`;
    return await res.text();
  } catch (err) {
    return `// 代码文件读取失败：${filePath}\n// ${err.message}`;
  }
}

function formatMeta(item) {
  const parts = [];
  if (item.language) parts.push(`语言：${item.language}`);
  if (item.category) parts.push(`分类：${item.category}`);
  if (item.updated) parts.push(`更新：${item.updated}`);
  return parts.join(' ｜ ');
}

function createTag(text) {
  const span = document.createElement('span');
  span.className = 'tag';
  span.textContent = text;
  return span;
}

function renderSnippetCard(item, index, listType = 'main') {
  const fragment = els.template.content.cloneNode(true);
  const card = fragment.querySelector('.snippet-card');
  const titleEl = fragment.querySelector('.snippet-title');
  const metaLineEl = fragment.querySelector('.meta-line');
  const descEl = fragment.querySelector('.snippet-desc');
  const tagsEl = fragment.querySelector('.tags');
  const extraMetaEl = fragment.querySelector('.extra-meta');
  const codeEl = fragment.querySelector('code');
  const copyBtn = fragment.querySelector('.action-copy');
  const toggleBtn = fragment.querySelector('.action-toggle');

  titleEl.textContent = item.title || '未命名代码';
  metaLineEl.textContent = formatMeta(item);
  descEl.textContent = item.description || '暂无说明。';

  const tags = [];
  if (item.pinned) tags.push('常用');
  (item.tags || []).forEach(tag => tags.push(tag));
  tags.forEach(tag => tagsEl.appendChild(createTag(tag)));

  const extraParts = [];
  if (item.source) extraParts.push(`来源：${item.source}`);
  if (item.file) extraParts.push(`文件：${item.file}`);
  extraMetaEl.textContent = extraParts.join(' ｜ ');

  const prismLanguage = getPrismLanguage(item.language);
  codeEl.className = `language-${prismLanguage}`;
  codeEl.innerHTML = escapeHtml(item.code);

  copyBtn.addEventListener('click', async () => {
    try {
      await navigator.clipboard.writeText(item.code || '');
      const original = copyBtn.textContent;
      copyBtn.textContent = '已复制';
      copyBtn.classList.add('copy-success');
      setTimeout(() => {
        copyBtn.textContent = original;
        copyBtn.classList.remove('copy-success');
      }, 1400);
    } catch {
      alert('复制失败，请手动复制。');
    }
  });

  toggleBtn.addEventListener('click', () => {
    card.classList.toggle('collapsed');
    toggleBtn.textContent = card.classList.contains('collapsed') ? '展开' : '折叠';
  });

  if (listType === 'pinned') {
    card.classList.add('pinned-card');
  }

  Prism.highlightElement(codeEl);
  return fragment;
}

function renderEmpty(container, text) {
  container.innerHTML = `<div class="empty-state">${text}</div>`;
}

function renderLists(items) {
  const pinned = items.filter(item => item.pinned);
  const normal = items;

  els.snippetList.innerHTML = '';
  els.pinnedList.innerHTML = '';

  if (pinned.length) {
    els.pinnedSection.classList.remove('hidden');
    pinned.forEach((item, index) => els.pinnedList.appendChild(renderSnippetCard(item, index, 'pinned')));
  } else {
    els.pinnedSection.classList.add('hidden');
  }

  if (!normal.length) {
    renderEmpty(els.snippetList, '没有找到匹配内容。你不是没有代码，而是你的筛选条件太严了。');
  } else {
    normal.forEach((item, index) => els.snippetList.appendChild(renderSnippetCard(item, index, 'main')));
  }

  els.statsText.textContent = `共 ${state.allSnippets.length} 条代码，当前显示 ${items.length} 条。`;
}

function applyFilters() {
  const keyword = normalizeText(els.searchInput.value.trim());
  const language = els.langFilter.value;
  const category = els.categoryFilter.value;

  let result = state.allSnippets.filter(item => {
    const textBucket = [
      item.title,
      item.description,
      item.language,
      item.category,
      item.source,
      ...(item.tags || [])
    ].join(' ').toLowerCase();

    const matchKeyword = !keyword || textBucket.includes(keyword);
    const matchLanguage = !language || item.language === language;
    const matchCategory = !category || item.category === category;

    return matchKeyword && matchLanguage && matchCategory;
  });

  result = sortSnippets(result);
  state.filteredSnippets = result;
  renderLists(result);
}

async function loadSnippets() {
  const res = await fetch('./snippets.json');
  if (!res.ok) throw new Error('读取 snippets.json 失败');

  const rawList = await res.json();

  const list = await Promise.all(
    rawList.map(async item => ({
      ...item,
      code: await safeFetchText(item.file)
    }))
  );

  state.allSnippets = list;
  populateSelect(els.langFilter, uniqueSortedValues(list, 'language'), '全部语言');
  populateSelect(els.categoryFilter, uniqueSortedValues(list, 'category'), '全部分类');
  applyFilters();
}

function bindEvents() {
  els.searchInput.addEventListener('input', applyFilters);
  els.langFilter.addEventListener('change', applyFilters);
  els.categoryFilter.addEventListener('change', applyFilters);
  els.sortSelect.addEventListener('change', applyFilters);
  els.clearFiltersBtn.addEventListener('click', () => {
    els.searchInput.value = '';
    els.langFilter.value = '';
    els.categoryFilter.value = '';
    els.sortSelect.value = 'updated_desc';
    applyFilters();
  });
  els.themeToggle.addEventListener('click', () => {
    const nextTheme = document.body.classList.contains('dark') ? 'light' : 'dark';
    setTheme(nextTheme);
  });
}

(async function init() {
  initTheme();
  bindEvents();

  try {
    await loadSnippets();
  } catch (err) {
    renderEmpty(els.snippetList, `页面加载失败：${err.message}`);
    els.statsText.textContent = '加载失败';
  }
})();
