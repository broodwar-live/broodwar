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
    `
  }

  function renderResult(data) {
    const header = data.parsed_data?.header || {}
    const players = header.players || []
    const buildOrder = data.parsed_data?.build_order || []
    const mapName = header.map_name || "Unknown Map"
    const duration = header.duration_secs ? `${Math.floor(header.duration_secs / 60)}:${String(Math.floor(header.duration_secs % 60)).padStart(2, "0")}` : "?"

    const playerRows = players.map(p => `
      <div class="flex items-center gap-3">
        <span class="text-[10px] font-bold badge-race ${RACE_COLORS[RACE_NAMES[p.race]?.toLowerCase()] || ""}">${p.race || "?"}</span>
        <span class="font-semibold text-sm">${p.name}</span>
      </div>
    `).join("")

    const boRows = buildOrder.slice(0, 20).map(entry => `
      <tr>
        <td class="font-stats text-xs text-base-content/40">${Math.floor((entry.frame || 0) / 15.17)}s</td>
        <td class="text-xs">P${entry.player_id}</td>
        <td class="text-xs">${entry.action || entry.name || "—"}</td>
      </tr>
    `).join("")

    return `
      <div class="glass-card rounded-box p-6">
        <h3 class="text-lg font-semibold mb-1">${mapName}</h3>
        <p class="text-xs text-base-content/40 mb-4">Duration: ${duration}</p>
        <div class="flex gap-6 mb-6">${playerRows}</div>

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

  init()
})()
