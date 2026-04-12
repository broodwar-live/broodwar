defmodule BroodwarWeb.ReplayDetailLive do
  use BroodwarWeb, :live_view

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    replay = Broodwar.Replays.get_replay!(id)
    pd = replay.parsed_data || %{}
    header = pd["header"] || %{}
    timeline = pd["timeline"] || []
    build_order = pd["build_order"] || []
    max_idx = max(length(timeline) - 1, 0)

    # Only show players who actually issued build commands (not observers)
    active_player_ids =
      build_order
      |> Enum.map(& &1["player_id"])
      |> Enum.uniq()
      |> MapSet.new()

    # Build APM waveform data: group samples by time, pick the two active players
    apm_samples = pd["apm_timeline"] || []
    duration_secs = header["duration_secs"] || 1
    all_players = header["players"] || []
    active_list = MapSet.to_list(active_player_ids) |> Enum.sort() |> Enum.take(2)
    waveform = build_waveform(apm_samples, active_list, duration_secs)

    # Map player_id → color_hex for active players
    player_colors =
      all_players
      |> Enum.filter(fn p -> MapSet.member?(active_player_ids, p["player_id"]) end)
      |> Enum.into(%{}, fn p -> {p["player_id"], p["color_hex"] || "#CCCCCC"} end)

    {:ok,
     socket
     |> assign(:page_title, header["map_name"] || "Replay")
     |> assign(:replay, replay)
     |> assign(:parsed, pd)
     |> assign(:timeline, timeline)
     |> assign(:timeline_idx, max_idx)
     |> assign(:max_idx, max_idx)
     |> assign(:active_player_ids, active_player_ids)
     |> assign(:waveform, waveform)
     |> assign(:duration_secs, duration_secs)
     |> assign(:player_colors, player_colors)}
  end

  @impl true
  def handle_event("seek", %{"position" => pos}, socket) do
    idx = pos |> String.to_integer() |> max(0) |> min(socket.assigns.max_idx)
    {:noreply, assign(socket, :timeline_idx, idx)}
  end

  @impl true
  def handle_event("seek_time", %{"pct" => pct_str}, socket) do
    pct = String.to_float(pct_str) |> max(0.0) |> min(1.0)
    # Find the timeline index closest to this percentage of the game
    target_idx = round(pct * socket.assigns.max_idx) |> max(0) |> min(socket.assigns.max_idx)
    {:noreply, assign(socket, :timeline_idx, target_idx)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
        <% header = @parsed["header"] || %{} %>
        <% players = header["players"] || [] %>
        <% player_apm = @parsed["player_apm"] || [] %>
        <% snap = Enum.at(@timeline, @timeline_idx) %>

        <%!-- Header --%>
        <div class="bg-base-100 rounded-box border border-base-content/5 card-accent-top p-5 mb-4">
          <div class="flex items-start justify-between">
            <div>
              <h1 class="text-xl font-bold">{header["map_name"] || "Unknown Map"}</h1>
              <p class="text-sm text-base-content/40">
                {format_duration(header["duration_secs"])}
                · {format_atom(header["game_type"])}
                · {format_atom(header["game_speed"])}
                · {@parsed["command_count"] || 0} commands
              </p>
            </div>
            <div class="flex gap-2">
              <%= for {player, apm} <- players_with_apm(players, player_apm), MapSet.member?(@active_player_ids, player["player_id"]) do %>
                <div class="rounded-lg px-3 py-2 text-center" style={"background: #{player["color_hex"]}15; border-left: 3px solid #{player["color_hex"]}"}>
                  <span class="text-xs font-bold" style={"color: #{player["color_hex"]}"}>{player["race_code"]}</span>
                  <span class="text-sm font-medium ml-1">{player["name"]}</span>
                  <%= if apm do %>
                    <div class="text-xs text-base-content/40 font-mono">{apm["apm"]} APM</div>
                  <% end %>
                </div>
              <% end %>
            </div>
          </div>
        </div>

        <%!-- APM Waveform Timeline --%>
        <%= if @max_idx > 0 and @waveform != [] do %>
          <% current_pct = if @max_idx > 0, do: @timeline_idx / @max_idx * 100, else: 0 %>
          <% bar_count = length(@waveform) %>

          <div class="bg-base-100 rounded-box border border-base-content/5 p-5 mb-4">
            <%!-- Player legend --%>
            <div class="flex items-center justify-between mb-3">
              <span class="text-xs text-base-content/40 font-mono">
                {format_game_time(snap && snap["real_seconds"])}
              </span>
              <div class="flex items-center gap-4 text-xs">
                <%= for pid <- MapSet.to_list(@active_player_ids) |> Enum.sort() |> Enum.take(2) do %>
                  <% player = Enum.find(players, fn p -> p["player_id"] == pid end) %>
                  <% color = @player_colors[pid] || "#CCC" %>
                  <%= if player do %>
                    <span class="flex items-center gap-1.5">
                      <span class="w-2 h-2 rounded-sm" style={"background: #{color}"}></span>
                      <span class="font-bold" style={"color: #{color}"}>{player["race_code"]}</span>
                      <span class="text-base-content/50">{player["name"]}</span>
                    </span>
                  <% end %>
                <% end %>
              </div>
              <span class="text-xs text-base-content/40 font-mono">
                {format_duration(header["duration_secs"])}
              </span>
            </div>

            <%!-- SVG Waveform --%>
            <div
              id="apm-waveform"
              phx-click="seek_waveform"
              phx-hook="WaveformClick"
              class="relative cursor-pointer select-none"
              style="height: 120px;"
            >
              <svg
                viewBox={"0 0 #{bar_count} 100"}
                preserveAspectRatio="none"
                class="w-full h-full"
                style="display: block;"
              >
                <% sorted_active = MapSet.to_list(@active_player_ids) |> Enum.sort() |> Enum.take(2) %>
                <% p1_color = @player_colors[Enum.at(sorted_active, 0)] || "#0C48CC" %>
                <% p2_color = @player_colors[Enum.at(sorted_active, 1)] || "#F40404" %>

                <%!-- Player 1 bars (upward from center) --%>
                <%= for {bar, i} <- Enum.with_index(@waveform) do %>
                  <% played = (i / max(bar_count - 1, 1) * 100) <= current_pct %>
                  <rect
                    x={i}
                    y={50 - bar.p1_height}
                    width="0.8"
                    height={bar.p1_height}
                    rx="0.2"
                    fill={p1_color}
                    opacity={if(played, do: "1", else: "0.25")}
                  />
                <% end %>

                <%!-- Player 2 bars (downward from center) --%>
                <%= for {bar, i} <- Enum.with_index(@waveform) do %>
                  <% played = (i / max(bar_count - 1, 1) * 100) <= current_pct %>
                  <rect
                    x={i}
                    y="50"
                    width="0.8"
                    height={bar.p2_height}
                    rx="0.2"
                    fill={p2_color}
                    opacity={if(played, do: "1", else: "0.25")}
                  />
                <% end %>

                <%!-- Center line --%>
                <line x1="0" y1="50" x2={bar_count} y2="50" stroke="currentColor" stroke-opacity="0.1" stroke-width="0.3" />

                <%!-- Playhead --%>
                <line
                  x1={current_pct / 100 * bar_count}
                  y1="0"
                  x2={current_pct / 100 * bar_count}
                  y2="100"
                  stroke="currentColor"
                  stroke-opacity="0.5"
                  stroke-width="0.5"
                />
              </svg>
            </div>

            <div class="flex items-center justify-between mt-2">
              <span class="text-[10px] text-base-content/30">APM</span>
              <span class="text-[10px] text-base-content/30">
                Build action {@timeline_idx} of {@max_idx}
              </span>
            </div>
          </div>

          <%!-- State at current position --%>
          <%= if snap do %>
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 mb-4">
              <%= for ps <- snap["players"] || [], MapSet.member?(@active_player_ids, ps["player_id"]) do %>
                <% player = Enum.find(players, fn p -> p["player_id"] == ps["player_id"] end) %>
                <% pcolor = @player_colors[ps["player_id"]] || "#CCC" %>
                <div class="bg-base-100 rounded-box border border-base-content/5 p-5" style={"border-top: 3px solid #{pcolor}"}>
                  <%!-- Player header --%>
                  <div class="flex items-center gap-2 mb-4">
                    <span class="text-sm font-bold" style={"color: #{pcolor}"}>
                      {player && player["race_code"]}
                    </span>
                    <span class="font-medium text-sm">{player && player["name"]}</span>
                  </div>

                  <%!-- Resources invested --%>
                  <div class="grid grid-cols-2 gap-3 mb-4">
                    <div class="bg-base-200/50 rounded-lg p-2.5">
                      <div class="text-[10px] text-blue-400/60 uppercase tracking-wide mb-0.5">Minerals</div>
                      <div class="text-lg font-mono font-bold text-blue-400">{ps["minerals_invested"]}</div>
                    </div>
                    <div class="bg-base-200/50 rounded-lg p-2.5">
                      <div class="text-[10px] text-green-400/60 uppercase tracking-wide mb-0.5">Gas</div>
                      <div class="text-lg font-mono font-bold text-green-400">{ps["gas_invested"]}</div>
                    </div>
                  </div>

                  <%!-- Supply --%>
                  <div class="mb-4">
                    <div class="flex items-center justify-between text-xs mb-1">
                      <span class="text-base-content/40">Supply</span>
                      <span class="font-mono">{ps["supply_used"]}/{ps["supply_max"]}</span>
                    </div>
                    <div class="h-1.5 bg-base-300 rounded-full overflow-hidden">
                      <div
                        class="h-full rounded-full transition-all"
                        style={"width: #{supply_pct(ps)}%; background: #{if supply_pct(ps) > 90, do: "#F40404", else: pcolor}"}
                      ></div>
                    </div>
                  </div>

                  <%!-- Units --%>
                  <%= if ps["units"] != [] do %>
                    <div class="mb-3">
                      <div class="text-[10px] text-base-content/40 uppercase tracking-wide mb-1.5">Units</div>
                      <div class="flex flex-wrap gap-1.5">
                        <%= for u <- ps["units"] do %>
                          <span class="badge badge-sm badge-ghost font-mono">
                            {u["name"]} <span class="text-primary ml-1">×{u["count"]}</span>
                          </span>
                        <% end %>
                      </div>
                    </div>
                  <% end %>

                  <%!-- Buildings --%>
                  <%= if ps["buildings"] != [] do %>
                    <div class="mb-3">
                      <div class="text-[10px] text-base-content/40 uppercase tracking-wide mb-1.5">Buildings</div>
                      <div class="flex flex-wrap gap-1.5">
                        <%= for b <- ps["buildings"] do %>
                          <span class="badge badge-sm badge-ghost font-mono">
                            {b["name"]} <span class="text-secondary ml-1">×{b["count"]}</span>
                          </span>
                        <% end %>
                      </div>
                    </div>
                  <% end %>

                  <%!-- Tech & Upgrades --%>
                  <%= if ps["techs"] != [] or ps["upgrades"] != [] do %>
                    <div>
                      <div class="text-[10px] text-base-content/40 uppercase tracking-wide mb-1.5">Tech</div>
                      <div class="flex flex-wrap gap-1.5">
                        <%= for t <- ps["techs"] do %>
                          <span class="badge badge-sm badge-accent badge-outline">{t["name"]}</span>
                        <% end %>
                        <%= for u <- ps["upgrades"] do %>
                          <span class="badge badge-sm badge-warning badge-outline">
                            {u["name"]} Lv{u["level"]}
                          </span>
                        <% end %>
                      </div>
                    </div>
                  <% end %>
                </div>
              <% end %>
            </div>
          <% end %>
        <% end %>

        <%!-- Build Order Table --%>
        <% build_order = @parsed["build_order"] || [] %>
        <%= if build_order != [] do %>
          <div class="bg-base-100 rounded-box border border-base-content/5 card-accent-top">
            <div class="p-5">
              <div class="flex items-center justify-between mb-4">
                <h2 class="font-semibold">Build Order</h2>
                <span class="text-xs text-base-content/40">{length(build_order)} entries</span>
              </div>
              <div class="overflow-x-auto max-h-96">
                <table class="table table-sm">
                  <thead class="sticky top-0 bg-base-100">
                    <tr class="text-xs text-base-content/40">
                      <th class="w-16">Time</th>
                      <th class="w-10">Player</th>
                      <th>Action</th>
                    </tr>
                  </thead>
                  <tbody>
                    <%= for {entry, idx} <- Enum.with_index(Enum.take(build_order, 100)) do %>
                      <tr class={[
                        "hover:bg-base-200/50",
                        idx == @timeline_idx - 1 && "bg-primary/10 border-l-2 border-primary"
                      ]}>
                        <td class="font-mono text-xs text-base-content/50">
                          {format_game_time(entry["real_seconds"])}
                        </td>
                        <td>
                          <span class={["text-xs font-bold", player_color(entry["player_id"], players)]}>
                            {player_race(entry["player_id"], players)}
                          </span>
                        </td>
                        <td class="text-sm">{entry["action"]}</td>
                      </tr>
                    <% end %>
                    <%= if length(build_order) > 100 do %>
                      <tr>
                        <td colspan="3" class="text-center text-xs text-base-content/30 py-2">
                          ... and {length(build_order) - 100} more entries
                        </td>
                      </tr>
                    <% end %>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end

  defp players_with_apm(players, apms) do
    Enum.map(players, fn player ->
      apm = Enum.find(apms, fn a -> a["player_id"] == player["player_id"] end)
      {player, apm}
    end)
  end

  defp supply_pct(ps) do
    used = ps["supply_used"] || 0
    maxs = ps["supply_max"] || 1
    if maxs > 0, do: min(round(used / maxs * 100), 100), else: 0
  end

  defp player_race(player_id, players) do
    case Enum.find(players, fn p -> p["player_id"] == player_id end) do
      %{"race_code" => code} -> code
      _ -> "?"
    end
  end

  defp player_color(player_id, players), do: race_color(player_race(player_id, players))

  defp race_color("T"), do: "text-race-terran"
  defp race_color("P"), do: "text-race-protoss"
  defp race_color("Z"), do: "text-race-zerg"
  defp race_color(_), do: "text-base-content"

  defp format_duration(secs) when is_number(secs) do
    mins = trunc(secs / 60)
    remaining = trunc(secs - mins * 60)
    "#{mins}:#{String.pad_leading(Integer.to_string(remaining), 2, "0")}"
  end

  defp format_duration(_), do: "—"

  defp format_game_time(secs) when is_number(secs) do
    mins = trunc(secs / 60)
    remaining = trunc(secs - mins * 60)
    "#{mins}:#{String.pad_leading(Integer.to_string(remaining), 2, "0")}"
  end

  defp format_game_time(_), do: "0:00"

  defp format_atom(val) when is_atom(val),
    do: val |> Atom.to_string() |> String.replace("_", " ") |> String.capitalize()

  defp format_atom(val) when is_binary(val), do: val
  defp format_atom(_), do: "—"

  # Build the waveform bars from APM samples.
  # Returns a list of %{p1_height: 0-48, p2_height: 0-48} for SVG rendering.
  defp build_waveform(apm_samples, active_players, duration_secs) when duration_secs > 0 do
    [p1_id, p2_id] =
      case active_players do
        [a, b] -> [a, b]
        [a] -> [a, nil]
        _ -> [nil, nil]
      end

    # Group samples by time bucket (each sample is already at a fixed interval)
    # Get unique time points
    times =
      apm_samples
      |> Enum.map(& &1["real_seconds"])
      |> Enum.uniq()
      |> Enum.sort()

    # Find max APM for normalization
    max_apm =
      apm_samples
      |> Enum.filter(fn s -> s["player_id"] in active_players end)
      |> Enum.map(& &1["apm"])
      |> Enum.max(fn -> 1 end)
      |> max(1)

    Enum.map(times, fn t ->
      samples_at_t = Enum.filter(apm_samples, fn s -> s["real_seconds"] == t end)

      p1_apm =
        case Enum.find(samples_at_t, fn s -> s["player_id"] == p1_id end) do
          %{"apm" => v} -> v
          _ -> 0
        end

      p2_apm =
        case Enum.find(samples_at_t, fn s -> s["player_id"] == p2_id end) do
          %{"apm" => v} -> v
          _ -> 0
        end

      # Normalize to 0-48 (leaving 2px gap at center)
      %{
        p1_height: max(round(p1_apm / max_apm * 48), 1),
        p2_height: max(round(p2_apm / max_apm * 48), 1)
      }
    end)
  end

  defp build_waveform(_, _, _), do: []
end
