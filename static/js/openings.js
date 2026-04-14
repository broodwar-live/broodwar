// Opening classification browser widget
// Renders into #openings-app
// Fetches GET /api/openings with race/matchup filters

;(function() {
  const mount = document.getElementById("openings-app")
  if (!mount) return

  const api = mount.dataset.api
  const RACE_BG = {T: "bg-race-terran", P: "bg-race-protoss", Z: "bg-race-zerg"}

  let allOpenings = []
  let raceFilter = null
  let matchupFilter = null

  function renderFilters() {
    const races = ["T", "P", "Z"]
    const matchups = ["TvZ", "PvT", "PvZ", "TvT", "PvP", "ZvZ"]
    return `
      <div class="flex flex-wrap items-center gap-3 mb-6">
        <div class="flex gap-1">
          <button data-race="" class="btn btn-xs ${!raceFilter ? "btn-primary" : "btn-ghost"}">All</button>
          ${races.map(r => `<button data-race="${r}" class="btn btn-xs ${raceFilter === r ? "btn-primary" : "btn-ghost"}">${r}</button>`).join("")}
        </div>
        <div class="flex gap-1">
          <button data-mu="" class="btn btn-xs ${!matchupFilter ? "btn-primary" : "btn-ghost"}">All MU</button>
          ${matchups.map(m => `<button data-mu="${m}" class="btn btn-xs ${matchupFilter === m ? "btn-primary" : "btn-ghost"}">${m}</button>`).join("")}
        </div>
      </div>
    `
  }

  function renderOpening(o) {
    const wr = o.winrate || 0
    const wrClass = wr >= 55 ? "text-success" : wr >= 50 ? "text-base-content/50" : "text-error"
    const muTags = Object.entries(o.matchups || {})
      .sort((a, b) => b[1] - a[1])
      .slice(0, 3)
      .map(([mu, n]) => `<span class="px-1.5 py-0.5 rounded text-[9px] bg-base-300/60">${mu} ${n}</span>`)
      .join("")

    return `
      <div class="glass-card rounded-box p-5 glow-blue">
        <div class="flex items-center justify-between mb-3">
          <div class="flex items-center gap-2.5">
            <span class="${RACE_BG[o.race] || "bg-base-content"} w-7 h-7 rounded-lg flex items-center justify-center text-xs font-black text-base-100">${o.race}</span>
            <span class="font-semibold text-sm">${o.name}</span>
          </div>
          <span class="text-[10px] text-base-content/30 font-mono">${o.tag}</span>
        </div>
        <div class="flex items-center gap-4 text-[11px] text-base-content/30 mb-2">
          <span class="font-medium">${o.games} games</span>
          <span class="font-semibold ${wrClass}">${wr}% winrate</span>
        </div>
        <div class="flex flex-wrap gap-1">${muTags}</div>
      </div>
    `
  }

  function render() {
    let filtered = allOpenings
    if (raceFilter) filtered = filtered.filter(o => o.race === raceFilter)

    mount.innerHTML = renderFilters() + (
      filtered.length > 0
        ? `<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">${filtered.map(renderOpening).join("")}</div>`
        : `<p class="text-sm text-base-content/30">No openings found.</p>`
    )

    mount.querySelectorAll("[data-race]").forEach(btn => {
      btn.addEventListener("click", () => {
        raceFilter = btn.dataset.race || null
        render()
      })
    })
    mount.querySelectorAll("[data-mu]").forEach(btn => {
      btn.addEventListener("click", () => {
        matchupFilter = btn.dataset.mu || null
        load()
      })
    })
  }

  async function load() {
    try {
      const params = new URLSearchParams()
      if (matchupFilter) params.set("matchup", matchupFilter)
      const url = `${api}/api/openings${params.toString() ? "?" + params : ""}`
      const res = await fetch(url)
      const json = await res.json()
      allOpenings = json.data || []
      render()
    } catch (e) {
      mount.innerHTML = `<p class="text-sm text-base-content/20">Could not load openings.</p>`
    }
    mount.setAttribute("aria-busy", "false")
  }

  load()
})()
