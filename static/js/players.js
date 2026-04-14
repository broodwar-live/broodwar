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

  let selectedPlayer = null

  function renderPlayer(p) {
    const letter = RACE_LETTER[p.race] || "?"
    const selected = selectedPlayer && selectedPlayer.id === p.id
    return `
      <div class="glass-card rounded-box p-4 glow-blue flex items-center gap-4 cursor-pointer ${selected ? "ring-1 ring-primary" : ""}" data-player-id="${p.id}">
        <span class="${RACE_BG[p.race] || "bg-base-content"} w-8 h-8 rounded-lg flex items-center justify-center text-xs font-black text-base-100">${letter}</span>
        <div class="flex-1 min-w-0">
          <div class="font-semibold text-sm truncate">${p.name}</div>
          <div class="text-[11px] text-base-content/30">${p.country || ""} ${p.team ? "· " + p.team : ""}</div>
        </div>
        <span class="text-xs font-stats text-base-content/40">${p.rating || ""}</span>
      </div>
    `
  }

  function renderPlayerDetail(p, stats) {
    if (!stats) return ""
    const t = stats.tournament || {}
    const r = stats.replays || {}
    const skill = r.skill_profile

    const openingsHtml = (r.openings || []).slice(0, 5).map(o =>
      `<span class="px-2 py-0.5 rounded text-[10px] bg-base-300/60">${o.name} <b>${o.count}</b></span>`
    ).join("")

    const muHtml = (r.matchup_winrates || []).map(m =>
      `<span class="text-[11px]">${m.matchup}: <b class="${m.winrate >= 55 ? "text-success" : m.winrate >= 50 ? "" : "text-error"}">${m.winrate}%</b> (${m.total})</span>`
    ).join(" · ")

    return `
      <div class="glass-card rounded-box p-6 mt-4 col-span-full">
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-semibold">${p.name}</h3>
          <button class="btn btn-xs btn-ghost" data-close-detail>✕</button>
        </div>
        ${skill ? `
          <div class="flex gap-4 mb-4 text-sm">
            <span>Skill: <b class="text-primary">${skill.tier}</b> (${Math.round(skill.skill_score)})</span>
            <span>EAPM: <b>${Math.round(skill.eapm)}</b></span>
            <span>Efficiency: <b>${Math.round(skill.efficiency * 100)}%</b></span>
          </div>
        ` : ""}
        ${t.total ? `
          <div class="text-sm mb-3">
            Tournament: <b>${t.wins}W-${t.losses}L</b> (${t.winrate}%)
            ${t.titles && t.titles.length ? ` · Titles: ${t.titles.join(", ")}` : ""}
          </div>
        ` : ""}
        ${r.replay_count ? `<div class="text-[11px] text-base-content/40 mb-2">${r.replay_count} replays analyzed</div>` : ""}
        ${openingsHtml ? `<div class="flex flex-wrap gap-1 mb-3">${openingsHtml}</div>` : ""}
        ${muHtml ? `<div class="mb-2">${muHtml}</div>` : ""}
      </div>
    `
  }

  let playerStats = null

  function render() {
    let filtered = allPlayers

    if (raceFilter) {
      filtered = filtered.filter(p => p.race === raceFilter)
    }
    if (search) {
      const q = search.toLowerCase()
      filtered = filtered.filter(p => p.name.toLowerCase().includes(q))
    }

    const cardsHtml = filtered.length > 0
      ? filtered.map(p => {
          let html = renderPlayer(p)
          if (selectedPlayer && selectedPlayer.id === p.id) {
            html += renderPlayerDetail(p, playerStats)
          }
          return html
        }).join("")
      : `<p class="text-sm text-base-content/30">No players found.</p>`

    mount.innerHTML = renderFilters() +
      `<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">${cardsHtml}</div>`

    // Rebind events
    mount.querySelectorAll("[data-race]").forEach(btn => {
      btn.addEventListener("click", () => {
        raceFilter = btn.dataset.race || null
        selectedPlayer = null
        playerStats = null
        render()
      })
    })

    mount.querySelectorAll("[data-player-id]").forEach(el => {
      el.addEventListener("click", () => selectPlayer(parseInt(el.dataset.playerId)))
    })

    mount.querySelectorAll("[data-close-detail]").forEach(btn => {
      btn.addEventListener("click", (e) => {
        e.stopPropagation()
        selectedPlayer = null
        playerStats = null
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

  async function selectPlayer(id) {
    const p = allPlayers.find(p => p.id === id)
    if (!p) return
    selectedPlayer = p
    playerStats = null
    render()

    try {
      const res = await fetch(`${api}/api/players/${id}/stats`)
      const json = await res.json()
      playerStats = json.data || {}
      render()
    } catch (e) {
      console.warn("Failed to load player stats:", e)
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
    mount.setAttribute("aria-busy", "false")
  }

  load()
})()
