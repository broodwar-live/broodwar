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
    {:noreply, socket |> assign(:timeline_idx, idx) |> push_bo_scroll(idx)}
  end

  @impl true
  def handle_event("keyseek", %{"key" => "ArrowRight"}, socket) do
    idx = min(socket.assigns.timeline_idx + 1, socket.assigns.max_idx)
    {:noreply, socket |> assign(:timeline_idx, idx) |> push_bo_scroll(idx)}
  end

  def handle_event("keyseek", %{"key" => "ArrowLeft"}, socket) do
    idx = max(socket.assigns.timeline_idx - 1, 0)
    {:noreply, socket |> assign(:timeline_idx, idx) |> push_bo_scroll(idx)}
  end

  def handle_event("keyseek", _params, socket), do: {:noreply, socket}

  @impl true
  def handle_event("seek_time", %{"pct" => pct_str}, socket) do
    pct = String.to_float(pct_str) |> max(0.0) |> min(1.0)
    target_idx = round(pct * socket.assigns.max_idx) |> max(0) |> min(socket.assigns.max_idx)
    {:noreply, socket |> assign(:timeline_idx, target_idx) |> push_bo_scroll(target_idx)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="replay-app" phx-window-keydown="keyseek" class="h-screen flex flex-col overflow-hidden bg-base-200">
      <%!-- Reuse the app header --%>
      <header class="bg-base-300/80 backdrop-blur-md border-b border-base-content/5 shrink-0 z-50">
        <nav class="max-w-full mx-auto px-4">
          <div class="flex items-center justify-between h-12">
            <a href="/" class="flex items-center gap-2 group">
              <div class="w-6 h-6 rounded bg-primary/15 border border-primary/30 flex items-center justify-center group-hover:bg-primary/25 transition-colors">
                <span class="text-primary font-bold text-[10px]">BW</span>
              </div>
              <span class="font-semibold text-base-content tracking-tight text-xs">
                broodwar<span class="text-primary">.live</span>
              </span>
            </a>
            <Layouts.flash_group flash={@flash} />
          </div>
        </nav>
      </header>

      <% header = @parsed["header"] || %{} %>
      <% players = header["players"] || [] %>
      <% player_apm = @parsed["player_apm"] || [] %>
      <% snap = Enum.at(@timeline, @timeline_idx) %>
      <% current_pct = if @max_idx > 0, do: @timeline_idx / @max_idx * 100, else: 0 %>
      <% bar_count = length(@waveform) %>
      <% sorted_active = MapSet.to_list(@active_player_ids) |> Enum.sort() |> Enum.take(2) %>
      <% p1_color = @player_colors[Enum.at(sorted_active, 0)] || "#0C48CC" %>
      <% p2_color = @player_colors[Enum.at(sorted_active, 1)] || "#F40404" %>
      <% p1 = Enum.find(players, fn p -> p["player_id"] == Enum.at(sorted_active, 0) end) %>
      <% p2 = Enum.find(players, fn p -> p["player_id"] == Enum.at(sorted_active, 1) end) %>
      <% build_order = @parsed["build_order"] || [] %>

      <%!-- Compact match info bar --%>
      <div class="shrink-0 border-b border-base-content/5 bg-base-100 px-4 py-2">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-3">
            <a href="/replays" class="text-base-content/30 hover:text-base-content/60 transition-colors">
              <.icon name="hero-arrow-left-micro" class="size-4" />
            </a>
            <span class="font-semibold text-sm">{header["map_name"] || "Unknown Map"}</span>
            <span class="text-xs text-base-content/30">
              {format_duration(header["duration_secs"])} · {format_atom(header["game_speed"])} · {@parsed["command_count"] || 0} cmds
            </span>
          </div>
          <div class="flex items-center gap-2">
            <%= for {player, apm} <- players_with_apm(players, player_apm), MapSet.member?(@active_player_ids, player["player_id"]) do %>
              <div class="flex items-center gap-1.5 px-2 py-0.5 rounded" style={"background: #{player["color_hex"]}12; border-left: 2px solid #{player["color_hex"]}"}>
                <span class="text-[10px] font-bold" style={"color: #{player["color_hex"]}"}>{player["race_code"]}</span>
                <span class="text-xs font-medium">{player["name"]}</span>
                <%= if apm do %>
                  <span class="text-[10px] text-base-content/30 font-mono">{apm["apm"]}</span>
                <% end %>
              </div>
            <% end %>
          </div>
        </div>
      </div>

      <%!-- Main content area — fills remaining space --%>
      <div class="flex-1 flex overflow-hidden">
        <%!-- Build Order (full width, scrollable) with floating state cards --%>
        <div class="flex-1 bg-base-100 flex flex-col overflow-hidden relative">
          <div class="shrink-0 px-3 py-1.5 border-b border-base-content/5 flex items-center justify-between">
            <div class="flex items-center gap-3">
              <span class="text-xs font-semibold text-base-content/60">Build Order</span>
              <span class="text-[10px] text-base-content/30">{length(build_order)} actions</span>
            </div>
            <span class="text-[10px] font-mono text-base-content/30">{format_game_time(snap && snap["real_seconds"])}</span>
          </div>
          <div id="bo-scroll" phx-hook="BoScroll" class="flex-1 overflow-y-auto px-3 py-1" style="scrollbar-width: thin;">
            <%= for {block_time, entries} <- group_by_time(build_order, 30) do %>
              <div id={"bo-t-#{trunc(block_time)}"} class="flex gap-0 mb-px">
                <%!-- Time gutter --%>
                <div class="w-10 shrink-0 pt-1">
                  <span class="text-[10px] font-mono text-base-content/20">{format_game_time(block_time)}</span>
                </div>
                <%!-- Two-column entries --%>
                <div class="flex-1 grid grid-cols-2 gap-x-2">
                  <div class="flex flex-col border-r border-base-content/5 pr-2">
                    <%= for entry <- Enum.filter(entries, fn e -> e["player_id"] == Enum.at(sorted_active, 0) end) do %>
                      <.bo_entry entry={entry} color={@player_colors[entry["player_id"]] || "#CCC"} current={entry_is_current?(entry, @timeline_idx, build_order)} />
                    <% end %>
                  </div>
                  <div class="flex flex-col pl-1">
                    <%= for entry <- Enum.filter(entries, fn e -> e["player_id"] == Enum.at(sorted_active, 1) end) do %>
                      <.bo_entry entry={entry} color={@player_colors[entry["player_id"]] || "#CCC"} current={entry_is_current?(entry, @timeline_idx, build_order)} />
                    <% end %>
                  </div>
                </div>
              </div>
            <% end %>
          </div>
        </div>

        <%!-- Right: Floating state cards overlaid on build order --%>
        <div class="absolute top-0 right-0 w-56 p-2 flex flex-col gap-1.5 z-10 pointer-events-none">
          <%= if snap do %>
            <%= for ps <- snap["players"] || [], MapSet.member?(@active_player_ids, ps["player_id"]) do %>
              <% player = Enum.find(players, fn p -> p["player_id"] == ps["player_id"] end) %>
              <% pcolor = @player_colors[ps["player_id"]] || "#CCC" %>
              <div class="pointer-events-auto rounded-lg p-2 text-[10px] shadow-lg backdrop-blur-md" style={"background: color-mix(in oklch, #{pcolor} 6%, oklch(14% 0.03 255) 94%); border: 1px solid #{pcolor}30"}>
                <div class="flex items-center justify-between mb-1">
                  <div class="flex items-center gap-1">
                    <span class="font-bold" style={"color: #{pcolor}"}>{player && player["race_code"]}</span>
                    <span class="font-medium text-xs">{player && player["name"]}</span>
                  </div>
                  <span class="font-mono text-base-content/30">{ps["supply_used"]}/{ps["supply_max"]}</span>
                </div>
                <div class="flex items-center gap-2 mb-1 font-mono">
                  <span class="text-blue-400">{ps["minerals_invested"]}<span class="text-blue-400/40">m</span></span>
                  <span class="text-green-400">{ps["gas_invested"]}<span class="text-green-400/40">g</span></span>
                </div>

                <%= if ps["units"] != [] do %>
                  <div class="flex flex-wrap gap-px mb-0.5">
                    <%= for u <- ps["units"] do %>
                      <span class="bg-base-content/5 rounded px-1 py-px font-mono">{u["name"]} <span style={"color: #{pcolor}"}>x{u["count"]}</span></span>
                    <% end %>
                  </div>
                <% end %>

                <%= if ps["buildings"] != [] do %>
                  <div class="flex flex-wrap gap-px mb-0.5">
                    <%= for b <- ps["buildings"] do %>
                      <span class="bg-base-content/5 rounded px-1 py-px font-mono opacity-60">{b["name"]} x{b["count"]}</span>
                    <% end %>
                  </div>
                <% end %>

                <%= if ps["techs"] != [] or ps["upgrades"] != [] do %>
                  <div class="flex flex-wrap gap-px">
                    <%= for t <- ps["techs"] do %>
                      <span class="rounded px-1 py-px font-mono text-accent">{t["name"]}</span>
                    <% end %>
                    <%= for u <- ps["upgrades"] do %>
                      <span class="rounded px-1 py-px font-mono text-warning">{u["name"]} {u["level"]}</span>
                    <% end %>
                  </div>
                <% end %>
              </div>
            <% end %>
          <% end %>
        </div>
      </div>

      <%!-- Bottom waveform bar --%>
      <%= if @max_idx > 0 and @waveform != [] do %>
        <div id="waveform-bar" phx-hook="WaveformBar" class="shrink-0 bg-base-300 border-t border-base-content/10">
          <div class="relative">
            <%!-- Player names overlaid --%>
            <%= if p1 do %>
              <div class="absolute top-0.5 left-2 z-10 text-[9px] font-bold opacity-60" style={"color: #{p1_color}"}>
                {p1["race_code"]} {p1["name"]}
              </div>
            <% end %>
            <%= if p2 do %>
              <div class="absolute bottom-0.5 left-2 z-10 text-[9px] font-bold opacity-60" style={"color: #{p2_color}"}>
                {p2["race_code"]} {p2["name"]}
              </div>
            <% end %>

            <div id="apm-waveform" phx-hook="WaveformClick" class="cursor-pointer select-none" style="height: 48px;">
              <svg viewBox={"0 0 #{bar_count} 100"} preserveAspectRatio="none" class="w-full h-full" style="display: block;">
                <%= for {bar, i} <- Enum.with_index(@waveform) do %>
                  <% played = (i / max(bar_count - 1, 1) * 100) <= current_pct %>
                  <rect x={i} y={50 - bar.p1_height} width="0.8" height={bar.p1_height} rx="0.15" fill={p1_color} opacity={if(played, do: "0.9", else: "0.15")} />
                <% end %>
                <%= for {bar, i} <- Enum.with_index(@waveform) do %>
                  <% played = (i / max(bar_count - 1, 1) * 100) <= current_pct %>
                  <rect x={i} y="50" width="0.8" height={bar.p2_height} rx="0.15" fill={p2_color} opacity={if(played, do: "0.9", else: "0.15")} />
                <% end %>
                <rect x="0" y="49.85" width={bar_count} height="0.3" fill="currentColor" opacity="0.05" />
                <rect x={current_pct / 100 * bar_count} y="0" width="0.4" height="100" fill="white" opacity="0.6" />
              </svg>
            </div>
          </div>
          <div class="flex items-center justify-between px-3 pb-1">
            <span class="text-[10px] font-mono text-base-content/40">{format_game_time(snap && snap["real_seconds"])}</span>
            <span class="text-[10px] font-mono text-base-content/40">{format_duration(header["duration_secs"])}</span>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  defp push_bo_scroll(socket, idx) do
    timeline = socket.assigns.timeline
    case Enum.at(timeline, idx) do
      %{"real_seconds" => secs} ->
        block_time = Float.floor(secs / 30) * 30 |> trunc()
        push_event(socket, "scroll_bo", %{block_id: "bo-t-#{block_time}"})
      _ ->
        socket
    end
  end

  defp players_with_apm(players, apms) do
    Enum.map(players, fn player ->
      apm = Enum.find(apms, fn a -> a["player_id"] == player["player_id"] end)
      {player, apm}
    end)
  end

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

  # -- Build order timeline helpers --

  attr :entry, :map, required: true
  attr :color, :string, required: true
  attr :current, :boolean, default: false

  defp bo_entry(assigns) do
    ~H"""
    <div class={[
      "flex items-center gap-1.5 py-0.5 px-1.5 rounded text-xs",
      @current && "bg-base-content/5"
    ]}>
      <span class="shrink-0 w-4 h-4 rounded flex items-center justify-center" style={"background: #{@color}20; color: #{@color}"}>
        <.bo_icon action={@entry["action"]} />
      </span>
      <span class="truncate" style={if(@current, do: "color: #{@color}", else: "")}>{@entry["name"]}</span>
    </div>
    """
  end

  attr :action, :string, required: true

  defp bo_icon(assigns) do
    ~H"""
    <%= cond do %>
      <% String.starts_with?(@action, "Build") -> %>
        <.icon name="hero-home-micro" class="size-2.5" />
      <% String.starts_with?(@action, "Research") -> %>
        <.icon name="hero-beaker-micro" class="size-2.5" />
      <% String.starts_with?(@action, "Upgrade") -> %>
        <.icon name="hero-arrow-trending-up-micro" class="size-2.5" />
      <% String.starts_with?(@action, "Morph") -> %>
        <.icon name="hero-arrows-right-left-micro" class="size-2.5" />
      <% true -> %>
        <.icon name="hero-cube-micro" class="size-2.5" />
    <% end %>
    """
  end

  defp group_by_time(build_order, interval_secs) do
    build_order
    |> Enum.group_by(fn entry ->
      secs = entry["real_seconds"] || 0
      Float.floor(secs / interval_secs) * interval_secs
    end)
    |> Enum.sort_by(fn {time, _} -> time end)
  end

  defp entry_is_current?(entry, timeline_idx, build_order) do
    case Enum.at(build_order, max(timeline_idx - 1, 0)) do
      nil -> false
      current -> current["frame"] == entry["frame"] and current["player_id"] == entry["player_id"] and current["action"] == entry["action"]
    end
  end

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
