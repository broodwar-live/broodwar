defmodule BroodwarWeb.ReplayDetailLive do
  use BroodwarWeb, :live_view

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    replay = Broodwar.Replays.get_replay!(id)
    pd = replay.parsed_data || %{}
    header = pd["header"] || %{}
    timeline = pd["timeline"] || []
    max_idx = max(length(timeline) - 1, 0)

    {:ok,
     socket
     |> assign(:page_title, header["map_name"] || "Replay")
     |> assign(:replay, replay)
     |> assign(:parsed, pd)
     |> assign(:timeline, timeline)
     |> assign(:timeline_idx, max_idx)
     |> assign(:max_idx, max_idx)}
  end

  @impl true
  def handle_event("seek", %{"position" => pos}, socket) do
    idx = pos |> String.to_integer() |> max(0) |> min(socket.assigns.max_idx)
    {:noreply, assign(socket, :timeline_idx, idx)}
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
              <%= for {player, apm} <- players_with_apm(players, player_apm) do %>
                <div class="bg-base-200/50 rounded-lg px-3 py-2 text-center">
                  <span class={["text-xs font-bold", race_color(player["race_code"])]}>{player["race_code"]}</span>
                  <span class="text-sm font-medium ml-1">{player["name"]}</span>
                  <%= if apm do %>
                    <div class="text-xs text-base-content/40 font-mono">{apm["apm"]} APM</div>
                  <% end %>
                </div>
              <% end %>
            </div>
          </div>
        </div>

        <%!-- Timeline Scrubber --%>
        <%= if @max_idx > 0 do %>
          <div class="bg-base-100 rounded-box border border-base-content/5 p-5 mb-4">
            <div class="flex items-center gap-4 mb-3">
              <span class="text-xs text-base-content/40 w-12 font-mono">
                {format_game_time(snap && snap["real_seconds"])}
              </span>
              <div class="flex-1">
                <input
                  type="range"
                  min="0"
                  max={@max_idx}
                  value={@timeline_idx}
                  phx-change="seek"
                  name="position"
                  class="range range-primary range-sm w-full"
                />
              </div>
              <span class="text-xs text-base-content/40 w-12 font-mono text-right">
                {format_duration(header["duration_secs"])}
              </span>
            </div>
            <div class="text-xs text-base-content/30 text-center">
              Build action {@timeline_idx} of {@max_idx}
            </div>
          </div>

          <%!-- State at current position --%>
          <%= if snap do %>
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 mb-4">
              <%= for ps <- snap["players"] || [] do %>
                <% player = Enum.find(players, fn p -> p["player_id"] == ps["player_id"] end) %>
                <div class="bg-base-100 rounded-box border border-base-content/5 p-5">
                  <%!-- Player header --%>
                  <div class="flex items-center gap-2 mb-4">
                    <span class={["text-sm font-bold", race_color(player && player["race_code"])]}>
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
                        class={[
                          "h-full rounded-full transition-all",
                          supply_pct(ps) > 90 && "bg-error" || "bg-primary/70"
                        ]}
                        style={"width: #{supply_pct(ps)}%"}
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
end
