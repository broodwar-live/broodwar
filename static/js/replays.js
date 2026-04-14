// Replay upload and analysis widget
// Renders into #replays-app

;(function() {
  const mount = document.getElementById("replays-app")
  if (!mount) return

  const api = mount.dataset.api
  const RACE_COLORS = {terran: "text-race-terran", protoss: "text-race-protoss", zerg: "text-race-zerg"}
  const RACE_NAMES = {T: "Terran", P: "Protoss", Z: "Zerg"}

  function renderUploadForm() {
    return `
      <div class="glass-card rounded-box p-8 max-w-xl">
        <h2 class="text-lg font-semibold mb-2">Upload a Replay</h2>
        <p class="text-sm text-base-content/40 mb-6">Drop a .rep file to get instant build order breakdowns, APM curves, and match details.</p>
        <div id="replay-drop" class="border-2 border-dashed border-primary/20 rounded-lg p-8 text-center cursor-pointer hover:border-primary/40 transition-colors">
          <p class="text-sm text-base-content/40">Click or drag a .rep file here</p>
          <input type="file" id="replay-file" accept=".rep" class="hidden" />
        </div>
        <div id="replay-status" class="mt-4 hidden">
          <p class="text-sm text-base-content/50">Uploading and parsing...</p>
        </div>
        <div id="replay-error" class="mt-4 hidden">
          <p class="text-sm text-error"></p>
        </div>
      </div>
      <div id="replay-result" class="mt-8"></div>
      <h2 class="text-xl font-display mt-12 mb-4">Recent Replays</h2>
      <div id="replay-list"></div>
    `
  }

  function renderResult(data) {
    const pd = data.parsed_data || {}
    const header = pd.header || {}
    const players = header.players || []
    const buildOrder = pd.build_order || []
    const metadata = pd.metadata || {}
    const classifications = pd.classifications || []
    const skillProfiles = pd.skill_profiles || []
    const phases = pd.phases?.phases || []
    const mapName = metadata.map_name || header.map_name || "Unknown Map"
    const matchup = metadata.matchup?.code || ""
    const winner = metadata.result?.player_name
    const duration = header.duration_secs ? `${Math.floor(header.duration_secs / 60)}:${String(Math.floor(header.duration_secs % 60)).padStart(2, "0")}` : "?"

    const playerRows = players.map((p, i) => {
      const cls = classifications[i]
      const skill = skillProfiles[i]
      const isWinner = winner && p.name === winner
      return `
        <div class="flex items-center gap-3">
          <span class="text-[10px] font-bold badge-race ${RACE_COLORS[RACE_NAMES[p.race_code]?.toLowerCase()] || ""}">${p.race_code || "?"}</span>
          <div>
            <span class="font-semibold text-sm">${p.name}</span>
            ${isWinner ? '<span class="ml-1 text-[10px] text-success font-bold">W</span>' : ""}
            ${cls ? `<span class="ml-2 text-[10px] text-primary/60">${cls.name}</span>` : ""}
            ${skill ? `<span class="ml-2 text-[10px] text-base-content/30">${skill.tier} (${Math.round(skill.skill_score)})</span>` : ""}
          </div>
        </div>
      `
    }).join("")

    const phaseRows = phases.map(p => `
      <span class="px-2 py-0.5 rounded text-[10px] bg-base-300/60">${p.phase} ${Math.floor(p.start_seconds)}s</span>
    `).join("")

    const boRows = buildOrder.slice(0, 20).map(entry => `
      <tr>
        <td class="font-stats text-xs text-base-content/40">${Math.floor((entry.frame || 0) / 23.81)}s</td>
        <td class="text-xs">P${entry.player_id}</td>
        <td class="text-xs">${entry.name || entry.action || "—"}</td>
      </tr>
    `).join("")

    return `
      <div class="glass-card rounded-box p-6">
        <div class="flex items-center gap-3 mb-1">
          ${matchup ? `<span class="text-sm font-bold text-primary">${matchup}</span>` : ""}
          <h3 class="text-lg font-semibold">${mapName}</h3>
        </div>
        <p class="text-xs text-base-content/40 mb-4">Duration: ${duration}</p>
        <div class="flex flex-col gap-2 mb-6">${playerRows}</div>

        ${phases.length > 0 ? `
          <div class="flex flex-wrap gap-1 mb-4">${phaseRows}</div>
        ` : ""}

        ${buildOrder.length > 0 ? `
          <h4 class="text-sm font-semibold mb-2">Build Order</h4>
          <div class="overflow-x-auto">
            <table class="table table-zebra text-xs">
              <thead><tr><th>Time</th><th>Player</th><th>Action</th></tr></thead>
              <tbody>${boRows}</tbody>
            </table>
          </div>
        ` : ""}
      </div>
    `
  }

  function init() {
    mount.innerHTML = renderUploadForm()

    const dropZone = document.getElementById("replay-drop")
    const fileInput = document.getElementById("replay-file")
    const status = document.getElementById("replay-status")
    const errorEl = document.getElementById("replay-error")
    const resultEl = document.getElementById("replay-result")

    dropZone.addEventListener("click", () => fileInput.click())

    dropZone.addEventListener("dragover", (e) => {
      e.preventDefault()
      dropZone.classList.add("border-primary/60")
    })

    dropZone.addEventListener("dragleave", () => {
      dropZone.classList.remove("border-primary/60")
    })

    dropZone.addEventListener("drop", (e) => {
      e.preventDefault()
      dropZone.classList.remove("border-primary/60")
      if (e.dataTransfer.files.length > 0) upload(e.dataTransfer.files[0])
    })

    fileInput.addEventListener("change", () => {
      if (fileInput.files.length > 0) upload(fileInput.files[0])
    })

    async function upload(file) {
      status.classList.remove("hidden")
      errorEl.classList.add("hidden")
      resultEl.innerHTML = ""

      const formData = new FormData()
      formData.append("replay[file]", file)

      try {
        const res = await fetch(`${api}/api/replays`, {method: "POST", body: formData})

        if (!res.ok) {
          const err = await res.json().catch(() => ({}))
          throw new Error(err.error?.message || `Upload failed (${res.status})`)
        }

        const json = await res.json()
        status.classList.add("hidden")
        resultEl.innerHTML = renderResult(json.data)
      } catch (e) {
        status.classList.add("hidden")
        errorEl.classList.remove("hidden")
        errorEl.querySelector("p").textContent = e.message
      }
    }
  }

  function renderReplayListItem(r) {
    const mu = r.matchup || ""
    const pA = r.player_a ? r.player_a.name : "?"
    const pB = r.player_b ? r.player_b.name : "?"
    const map = r.map ? r.map.name : "Unknown"
    const dur = r.duration ? `${Math.floor(r.duration / 60)}:${String(r.duration % 60).padStart(2, "0")}` : ""

    return `
      <div class="glass-card rounded-box p-4 flex items-center gap-4">
        ${mu ? `<span class="text-xs font-bold text-primary min-w-[2.5rem]">${mu}</span>` : `<span class="min-w-[2.5rem]"></span>`}
        <div class="flex-1 min-w-0">
          <div class="text-sm font-semibold truncate">${pA} vs ${pB}</div>
          <div class="text-[11px] text-base-content/30">${map} · ${dur}</div>
        </div>
        <div class="flex gap-1">
          ${r.race_a ? `<span class="text-[10px] font-bold ${RACE_COLORS[RACE_NAMES[r.race_a]?.toLowerCase()] || ""}">${r.race_a}</span>` : ""}
          <span class="text-[10px] text-base-content/20">v</span>
          ${r.race_b ? `<span class="text-[10px] font-bold ${RACE_COLORS[RACE_NAMES[r.race_b]?.toLowerCase()] || ""}">${r.race_b}</span>` : ""}
        </div>
      </div>
    `
  }

  async function loadRecentReplays() {
    const listEl = document.getElementById("replay-list")
    if (!listEl) return
    try {
      const res = await fetch(`${api}/api/replays?per_page=20`)
      const json = await res.json()
      const replays = json.data || []
      if (replays.length > 0) {
        listEl.innerHTML = `<div class="flex flex-col gap-2">${replays.map(renderReplayListItem).join("")}</div>`
      } else {
        listEl.innerHTML = `<p class="text-sm text-base-content/30">No replays yet.</p>`
      }
    } catch (e) {
      listEl.innerHTML = `<p class="text-sm text-base-content/20">Could not load replays.</p>`
    }
  }

  init()
  loadRecentReplays()
  mount.setAttribute("aria-busy", "false")
})()
