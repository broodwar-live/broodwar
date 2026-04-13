// Live streams widget
// Renders into #live-streams (home page) or #streams-app (/streams)

;(function() {
  const mount = document.getElementById("live-streams") || document.getElementById("streams-app")
  if (!mount) return

  const api = mount.dataset.api

  const RACE_COLORS = {terran: "text-race-terran", protoss: "text-race-protoss", zerg: "text-race-zerg"}
  const RACE_LETTER = {terran: "T", protoss: "P", zerg: "Z"}

  function renderStream(s) {
    const playerName = s.player ? s.player.name : s.channel_id
    const race = s.player ? s.player.race : null
    const raceBadge = race
      ? `<span class="text-[10px] font-bold badge-race ${RACE_COLORS[race] || ""}">${RACE_LETTER[race] || ""}</span>`
      : ""

    return `
      <div class="glass-card rounded-box overflow-hidden group cursor-pointer glow-blue">
        <div class="aspect-video bg-base-300/50 relative">
          <div class="absolute inset-0 flex items-center justify-center">
            <svg class="size-8 text-base-content/10 group-hover:text-primary/30 transition-colors" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M5.25 5.653c0-.856.917-1.398 1.667-.986l11.54 6.347a1.125 1.125 0 0 1 0 1.972l-11.54 6.347a1.125 1.125 0 0 1-1.667-.986V5.653Z" /></svg>
          </div>
          ${s.is_live ? `<div class="absolute top-2.5 left-2.5 badge-live flex items-center gap-1.5 px-2 py-0.5 rounded text-[10px]"><span class="w-1.5 h-1.5 rounded-full bg-white animate-live-pulse"></span>LIVE</div>` : ""}
          <div class="absolute bottom-2 right-2 px-2 py-0.5 rounded bg-base-300/80 backdrop-blur-sm text-[10px] text-base-content/60 font-medium">
            ${s.viewer_count} viewers
          </div>
        </div>
        <div class="p-3">
          <div class="flex items-center gap-2">
            ${raceBadge}
            <span class="font-semibold text-sm">${playerName}</span>
          </div>
          ${s.title ? `<p class="text-xs text-base-content/40 mt-0.5 truncate">${s.title}</p>` : ""}
        </div>
      </div>
    `
  }

  async function load() {
    try {
      const res = await fetch(`${api}/api/streams`)
      const json = await res.json()
      const streams = json.data || []

      if (streams.length === 0) {
        mount.innerHTML = `<p class="text-sm text-base-content/30">No streams online.</p>`
        return
      }

      const live = streams.filter(s => s.is_live)
      const display = live.length > 0 ? live : streams.slice(0, 4)

      mount.innerHTML = `<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">${display.map(renderStream).join("")}</div>`
    } catch (e) {
      mount.innerHTML = `<p class="text-sm text-base-content/20">Could not load streams.</p>`
    }
  }

  load()
  // Poll every 60 seconds
  setInterval(load, 60000)
})()
