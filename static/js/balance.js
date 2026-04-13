// Balance stats widget
// Renders into #balance-app

;(function() {
  const mount = document.getElementById("balance-app")
  if (!mount) return

  const api = mount.dataset.api

  function renderBar(stat) {
    return `
      <div>
        <div class="flex items-center justify-between text-xs mb-1.5">
          <span class="text-base-content/60 font-semibold text-[11px]">${stat.matchup}</span>
          <span class="text-base-content/30 font-stats text-[11px]">${stat.pct_a}% — ${stat.pct_b}%</span>
        </div>
        <div class="flex h-1.5 rounded-full overflow-hidden bg-base-content/5">
          <div class="bg-gradient-to-r from-primary to-primary/70 rounded-l-full" style="width: ${stat.pct_a}%"></div>
          <div class="bg-gradient-to-r from-secondary/70 to-secondary rounded-r-full" style="width: ${stat.pct_b}%"></div>
        </div>
        <div class="flex justify-between text-[10px] text-base-content/20 mt-1">
          <span>${stat.total} games</span>
        </div>
      </div>
    `
  }

  async function load() {
    try {
      const res = await fetch(`${api}/api/balance`)
      const json = await res.json()
      const stats = json.data || []

      if (stats.length === 0) {
        mount.innerHTML = `<p class="text-sm text-base-content/30">No balance data available.</p>`
        return
      }

      mount.innerHTML = `
        <div class="glass-card rounded-box p-6 max-w-xl">
          <div class="space-y-5">${stats.map(renderBar).join("")}</div>
        </div>
      `
    } catch (e) {
      mount.innerHTML = `<p class="text-sm text-base-content/20">Could not load balance stats.</p>`
    }
  }

  load()
})()
