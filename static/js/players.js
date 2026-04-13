// Players listing widget
// Renders into #players-app

;(function() {
  const mount = document.getElementById("players-app")
  if (!mount) return

  const api = mount.dataset.api
  const RACE_COLORS = {terran: "text-race-terran", protoss: "text-race-protoss", zerg: "text-race-zerg"}
  const RACE_BG = {terran: "bg-race-terran", protoss: "bg-race-protoss", zerg: "bg-race-zerg"}
  const RACE_LETTER = {terran: "T", protoss: "P", zerg: "Z"}

  let allPlayers = []
  let raceFilter = null
  let search = ""

  function renderFilters() {
    const races = ["terran", "protoss", "zerg"]
    return `
      <div class="flex flex-wrap items-center gap-3 mb-6">
        <input type="search" id="player-search" placeholder="Search players..." class="input input-sm w-48 bg-base-300/60 border-primary/10 text-sm" value="${search}" />
        <div class="flex gap-1">
          <button data-race="" class="btn btn-xs ${!raceFilter ? "btn-primary" : "btn-ghost"}">All</button>
          ${races.map(r => `<button data-race="${r}" class="btn btn-xs ${raceFilter === r ? "btn-primary" : "btn-ghost"}">${r[0].toUpperCase()}</button>`).join("")}
        </div>
      </div>
    `
  }

  function renderPlayer(p) {
    const letter = RACE_LETTER[p.race] || "?"
    return `
      <div class="glass-card rounded-box p-4 glow-blue flex items-center gap-4">
        <span class="${RACE_BG[p.race] || "bg-base-content"} w-8 h-8 rounded-lg flex items-center justify-center text-xs font-black text-base-100">${letter}</span>
        <div class="flex-1 min-w-0">
          <div class="font-semibold text-sm truncate">${p.name}</div>
          <div class="text-[11px] text-base-content/30">${p.country || ""} ${p.team ? "· " + p.team : ""}</div>
        </div>
        <span class="text-xs font-stats text-base-content/40">${p.rating || ""}</span>
      </div>
    `
  }

  function render() {
    let filtered = allPlayers

    if (raceFilter) {
      filtered = filtered.filter(p => p.race === raceFilter)
    }
    if (search) {
      const q = search.toLowerCase()
      filtered = filtered.filter(p => p.name.toLowerCase().includes(q))
    }

    mount.innerHTML = renderFilters() + (
      filtered.length > 0
        ? `<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">${filtered.map(renderPlayer).join("")}</div>`
        : `<p class="text-sm text-base-content/30">No players found.</p>`
    )

    // Rebind events
    mount.querySelectorAll("[data-race]").forEach(btn => {
      btn.addEventListener("click", () => {
        raceFilter = btn.dataset.race || null
        render()
      })
    })

    const searchInput = mount.querySelector("#player-search")
    if (searchInput) {
      searchInput.addEventListener("input", (e) => {
        search = e.target.value
        render()
      })
      searchInput.focus()
      searchInput.setSelectionRange(search.length, search.length)
    }
  }

  async function load() {
    try {
      const res = await fetch(`${api}/api/players?per_page=200`)
      const json = await res.json()
      allPlayers = json.data || []
      render()
    } catch (e) {
      mount.innerHTML = `<p class="text-sm text-base-content/20">Could not load players.</p>`
    }
  }

  load()
})()
