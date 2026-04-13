// Matches listing widget
// Renders into #matches-app and #recent-matches

;(function() {
  const mount = document.getElementById("matches-app") || document.getElementById("recent-matches")
  if (!mount) return

  const api = mount.dataset.api
  const isHome = mount.id === "recent-matches"
  const RACE_COLORS = {terran: "text-race-terran", protoss: "text-race-protoss", zerg: "text-race-zerg"}
  const RACE_LETTER = {terran: "T", protoss: "P", zerg: "Z"}

  function renderMatch(m) {
    const pa = m.player_a || {}
    const pb = m.player_b || {}
    const winner = m.score_a > m.score_b ? "a" : "b"
    const tournament = m.tournament ? m.tournament.short_name || m.tournament.name : ""
    const mapName = m.map ? m.map.name : ""
    const date = m.played_at ? new Date(m.played_at).toLocaleDateString("en", {month: "short", day: "numeric"}) : ""

    return `
      <div class="glass-card rounded-box px-4 py-3 flex items-center gap-4 glow-blue">
        <div class="hidden sm:block w-32 shrink-0">
          <span class="text-[11px] text-primary/50 font-medium">${tournament}</span>
        </div>
        <div class="flex-1 flex items-center justify-center gap-3 min-w-0">
          <div class="flex items-center gap-2 flex-1 justify-end min-w-0">
            <span class="font-semibold text-sm truncate ${winner === "a" ? "text-base-content" : "text-base-content/40"}">${pa.name || "?"}</span>
            <span class="text-[10px] font-bold badge-race shrink-0 ${RACE_COLORS[m.race_a] || ""}">${RACE_LETTER[m.race_a] || "?"}</span>
          </div>
          <div class="flex items-center gap-1.5 shrink-0 font-stats text-sm">
            <span class="font-bold ${winner === "a" ? "text-primary" : "text-base-content/30"}">${m.score_a}</span>
            <span class="text-base-content/15">:</span>
            <span class="font-bold ${winner === "b" ? "text-primary" : "text-base-content/30"}">${m.score_b}</span>
          </div>
          <div class="flex items-center gap-2 flex-1 min-w-0">
            <span class="text-[10px] font-bold badge-race shrink-0 ${RACE_COLORS[m.race_b] || ""}">${RACE_LETTER[m.race_b] || "?"}</span>
            <span class="font-semibold text-sm truncate ${winner === "b" ? "text-base-content" : "text-base-content/40"}">${pb.name || "?"}</span>
          </div>
        </div>
        <div class="hidden sm:flex items-center gap-4 shrink-0">
          <span class="text-[11px] text-base-content/25 w-20 text-right">${mapName}</span>
          <span class="text-[11px] text-base-content/20 w-12 text-right">${date}</span>
        </div>
      </div>
    `
  }

  async function load() {
    try {
      const limit = isHome ? 5 : 50
      const res = await fetch(`${api}/api/matches?per_page=${limit}`)
      const json = await res.json()
      const matches = json.data || []

      if (matches.length === 0) {
        mount.innerHTML = `<p class="text-sm text-base-content/30">No matches recorded.</p>`
        return
      }

      mount.innerHTML = `<div class="space-y-2">${matches.map(renderMatch).join("")}</div>`
    } catch (e) {
      mount.innerHTML = `<p class="text-sm text-base-content/20">Could not load matches.</p>`
    }
  }

  load()
})()
