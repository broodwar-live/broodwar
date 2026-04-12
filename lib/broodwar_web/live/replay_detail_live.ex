defmodule BroodwarWeb.ReplayDetailLive do
  use BroodwarWeb, :live_view

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    replay = Broodwar.Replays.get_replay!(id)
    pd = replay.parsed_data || %{}
    header = pd["header"] || %{}

    {:ok,
     socket
     |> assign(:page_title, header["map_name"] || "Replay")
     |> assign(:replay, replay)
     |> assign(:parsed, pd)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
        <% header = @parsed["header"] || %{} %>
        <% players = header["players"] || [] %>
        <% build_order = @parsed["build_order"] || [] %>
        <% player_apm = @parsed["player_apm"] || [] %>

        <%!-- Header --%>
        <div class="bg-base-100 rounded-box border border-base-content/5 card-accent-top p-6 mb-6">
          <div class="flex items-start justify-between mb-4">
            <div>
              <h1 class="text-xl font-bold">{header["map_name"] || "Unknown Map"}</h1>
              <p class="text-sm text-base-content/40">
                {format_duration(header["duration_secs"])}
                · {format_atom(header["game_type"])}
                · {format_atom(header["game_speed"])}
              </p>
            </div>
            <div class="text-right">
              <span class="badge badge-sm badge-ghost">{@parsed["command_count"] || 0} commands</span>
            </div>
          </div>

          <%!-- Players --%>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <%= for {player, apm} <- players_with_apm(players, player_apm) do %>
              <div class="flex items-center gap-3 bg-base-200/50 rounded-lg p-3">
                <span class={["text-sm font-bold w-5 text-center", race_color(player["race_code"])]}>
                  {player["race_code"]}
                </span>
                <div class="flex-1 min-w-0">
                  <p class="font-medium text-sm truncate">{player["name"]}</p>
                  <p class="text-xs text-base-content/40">{format_atom(player["player_type"])}</p>
                </div>
                <%= if apm do %>
                  <div class="text-right shrink-0">
                    <p class="text-sm font-mono font-medium">{apm["apm"]} <span class="text-base-content/40 text-xs">APM</span></p>
                    <p class="text-xs font-mono text-base-content/40">{apm["eapm"]} EAPM</p>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
        </div>

        <%!-- Build Order --%>
        <%= if build_order != [] do %>
          <div class="bg-base-100 rounded-box border border-base-content/5 card-accent-top">
            <div class="p-5">
              <div class="flex items-center justify-between mb-4">
                <h2 class="font-semibold">Build Order</h2>
                <span class="text-xs text-base-content/40">{length(build_order)} entries</span>
              </div>

              <div class="overflow-x-auto">
                <table class="table table-sm">
                  <thead>
                    <tr class="text-xs text-base-content/40">
                      <th class="w-16">Time</th>
                      <th class="w-10">Player</th>
                      <th>Action</th>
                    </tr>
                  </thead>
                  <tbody>
                    <%= for entry <- Enum.take(build_order, 80) do %>
                      <tr class="hover:bg-base-200/50">
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
                    <%= if length(build_order) > 80 do %>
                      <tr>
                        <td colspan="3" class="text-center text-xs text-base-content/30 py-2">
                          ... and {length(build_order) - 80} more entries
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

  defp player_race(player_id, players) do
    case Enum.find(players, fn p -> p["player_id"] == player_id end) do
      %{"race_code" => code} -> code
      _ -> "?"
    end
  end

  defp player_color(player_id, players) do
    race_color(player_race(player_id, players))
  end

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

  defp format_game_time(_), do: "—"

  defp format_atom(val) when is_atom(val), do: val |> Atom.to_string() |> String.replace("_", " ") |> String.capitalize()
  defp format_atom(val) when is_binary(val), do: val
  defp format_atom(_), do: "—"
end
