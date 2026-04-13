// Builds listing widget
// Renders into #builds-app

;(function() {
  const mount = document.getElementById("builds-app")
  if (!mount) return

  const api = mount.dataset.api
  const RACE_BG = {terran: "bg-race-terran", protoss: "bg-race-protoss", zerg: "bg-race-zerg"}
  const RACE_LETTER = {terran: "T", protoss: "P", zerg: "Z"}

  let allBuilds = []
  let matchupFilter = null

  function renderFilters() {
    const matchups = ["TvZ", "TvP", "PvZ", "TvT", "PvP", "ZvZ"]
    return `
      <div class="flex flex-wrap gap-1 mb-6">
        <button data-matchup="" class="btn btn-xs ${!matchupFilter ? "btn-primary" : "btn-ghost"}">All</button>
        ${matchups.map(m => `<button data-matchup="${m}" class="btn btn-xs ${matchupFilter === m ? "btn-primary" : "btn-ghost"}">${m}</button>`).join("")}
      </div>
    `
  }

  function renderBuild(b) {
    const letter = RACE_LETTER[b.race] || "?"
    return `
      <div class="glass-card rounded-box p-5 glow-blue">
        <div class="flex items-center justify-between mb-3">
          <div class="flex items-center gap-2.5">
            <span class="${RACE_BG[b.race] || "bg-base-content"} w-7 h-7 rounded-lg flex items-center justify-center text-xs font-black text-base-100">${letter}</span>
            <span class="font-semibold text-sm">${b.name}</span>
          </div>
          <span class="px-2 py-0.5 rounded text-[10px] font-semibold bg-primary/10 text-primary/70">${b.matchup}</span>
        </div>
        ${b.description ? `<p class="text-xs text-base-content/40 leading-relaxed mb-4">${b.description}</p>` : ""}
        <div class="flex items-center gap-4 text-[11px] text-base-content/30">
          <span class="font-medium">${b.games} games</span>
          <span class="font-semibold ${b.winrate >= 55 ? "text-success" : b.winrate >= 50 ? "text-base-content/50" : "text-error"}">${b.winrate}% winrate</span>
        </div>
      </div>
    `
  }

  function render() {
    const filtered = matchupFilter
      ? allBuilds.filter(b => b.matchup === matchupFilter)
      : allBuilds

    mount.innerHTML = renderFilters() + (
      filtered.length > 0
        ? `<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">${filtered.map(renderBuild).join("")}</div>`
        : `<p class="text-sm text-base-content/30">No builds found.</p>`
    )

    mount.querySelectorAll("[data-matchup]").forEach(btn => {
      btn.addEventListener("click", () => {
        matchupFilter = btn.dataset.matchup || null
        render()
      })
    })
  }

  async function load() {
    try {
      const res = await fetch(`${api}/api/builds?per_page=200`)
      const json = await res.json()
      allBuilds = json.data || []
      render()
    } catch (e) {
      mount.innerHTML = `<p class="text-sm text-base-content/20">Could not load builds.</p>`
    }
  }

  load()
})()
