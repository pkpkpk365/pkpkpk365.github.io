async function loadGames() {
  const list = document.getElementById("gameList");
  const input = document.getElementById("searchInput");

  const res = await fetch("./games.json");
  const games = await res.json();

  function render(data) {
    list.innerHTML = "";
    data.forEach(g => {
      const path = `./${g.folder}/index.html`;
      const icon = `./${g.folder}/icon.png`;

      const card = document.createElement("div");
      card.className = "card";

      card.innerHTML = `
        <img class="icon" src="${icon}" onerror="this.src='./default.png'"/>
        <h3>${g.name}</h3>
        <p>${g.description}</p>
        <a href="${path}">进入</a>
      `;
      list.appendChild(card);
    });
  }

  render(games);

  input.addEventListener("input", () => {
    const k = input.value.toLowerCase();
    render(games.filter(g => g.name.toLowerCase().includes(k)));
  });
}

loadGames();
