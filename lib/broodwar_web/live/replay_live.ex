defmodule BroodwarWeb.ReplayLive do
  use BroodwarWeb, :live_view

  @max_file_size 10_000_000

  @impl true
  def mount(_params, _session, socket) do
    saved_replays = Broodwar.Replays.list_replays()

    {:ok,
     socket
     |> assign(:page_title, "Replays")
     |> assign(:replay, nil)
     |> assign(:error, nil)
     |> assign(:parsing, false)
     |> assign(:saved_replays, saved_replays)
     |> allow_upload(:replay_file,
       accept: :any,
       max_entries: 1,
       max_file_size: @max_file_size,
       auto_upload: true
     )}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("parse", _params, socket) do
    socket = assign(socket, parsing: true, error: nil, replay: nil)

    results =
      consume_uploaded_entries(socket, :replay_file, fn %{path: path}, _entry ->
        {:ok, Broodwar.Replays.parse_replay_file(path)}
      end)

    socket =
      case results do
        [{:ok, replay}] ->
          assign(socket, replay: replay, parsing: false)

        [{:error, reason}] ->
          assign(socket, error: reason, parsing: false)

        [] ->
          assign(socket, error: "No file selected", parsing: false)
      end

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
        <%!-- Upload Section --%>
        <div class="mb-8">
          <h1 class="text-2xl font-bold mb-2">Replay Analyzer</h1>
          <p class="text-base-content/50 text-sm">
            Upload a StarCraft: Brood War replay file (.rep) to see build orders, APM, and match details.
          </p>
        </div>

        <form id="upload-form" phx-submit="parse" phx-change="validate">
          <div class="bg-base-100 rounded-box border border-base-content/5 p-6 mb-6">
            <div
              class="border-2 border-dashed border-base-content/10 rounded-lg p-8 text-center hover:border-primary/30 transition-colors"
              phx-drop-target={@uploads.replay_file.ref}
            >
              <.live_file_input upload={@uploads.replay_file} class="hidden" />

              <%= if @uploads.replay_file.entries == [] do %>
                <div class="flex flex-col items-center gap-3">
                  <.icon name="hero-arrow-up-tray" class="size-8 text-base-content/30" />
                  <div>
                    <label for={@uploads.replay_file.ref} class="text-primary cursor-pointer hover:text-primary/80 font-medium">
                      Choose a .rep file
                    </label>
                    <span class="text-base-content/40 text-sm"> or drag and drop</span>
                  </div>
                  <p class="text-xs text-base-content/30">Max 10 MB. All replay formats supported (1.08+).</p>
                </div>
              <% else %>
                <%= for entry <- @uploads.replay_file.entries do %>
                  <div class="flex items-center justify-center gap-3">
                    <.icon name="hero-document" class="size-5 text-primary" />
                    <span class="font-medium text-sm">{entry.client_name}</span>
                    <span class="text-xs text-base-content/40">({format_bytes(entry.client_size)})</span>
                    <%= if entry.progress > 0 and entry.progress < 100 do %>
                      <span class="text-xs text-primary">{entry.progress}%</span>
                    <% end %>
                  </div>
                  <%= for err <- upload_errors(@uploads.replay_file, entry) do %>
                    <p class="text-error text-sm mt-2">{upload_error_to_string(err)}</p>
                  <% end %>
                <% end %>
              <% end %>
            </div>

            <%= if @uploads.replay_file.entries != [] do %>
              <div class="mt-4 flex justify-end">
                <button type="submit" class="btn btn-primary" disabled={@parsing}>
                  <%= if @parsing do %>
                    <span class="loading loading-spinner loading-sm"></span>
                    Parsing...
                  <% else %>
                    <.icon name="hero-play-micro" class="size-4" />
                    Analyze Replay
                  <% end %>
                </button>
              </div>
            <% end %>
          </div>
        </form>

        <%= if @error do %>
          <div class="bg-error/10 border border-error/20 rounded-box p-4 mb-6">
            <p class="text-error text-sm">
              <.icon name="hero-exclamation-triangle-micro" class="size-4 inline mr-1" />
              {@error}
            </p>
          </div>
        <% end %>

        <%!-- Results --%>
        <%= if @replay do %>
          <.replay_results replay={@replay} />
        <% end %>

        <%!-- Saved Replays --%>
        <%= if @saved_replays != [] do %>
          <div class="mt-10">
            <h2 class="text-lg font-semibold mb-4">Saved Replays ({length(@saved_replays)})</h2>
            <div class="space-y-2">
              <%= for replay <- @saved_replays do %>
                <% pd = replay.parsed_data || %{} %>
                <% header = pd["header"] || %{} %>
                <% players = header["players"] || [] %>
                <.link navigate={~p"/replays/#{replay.id}"} class="match-card bg-base-100 rounded-box border border-base-content/5 px-4 py-3 flex items-center gap-4 cursor-pointer block">
                  <div class="flex-1 min-w-0">
                    <div class="flex items-center gap-2">
                      <span class="font-medium text-sm">{header["map_name"] || "Unknown Map"}</span>
                      <span class="text-xs text-base-content/30">{format_duration(header["duration_secs"])}</span>
                    </div>
                    <div class="flex items-center gap-2 mt-0.5">
                      <%= for p <- Enum.take(players, 2) do %>
                        <span class="text-xs">
                          <span class={["font-bold", race_color(p["race_code"])]}>{p["race_code"]}</span>
                          <span class="text-base-content/50">{p["name"]}</span>
                        </span>
                        <span :if={p != List.last(Enum.take(players, 2))} class="text-xs text-base-content/20">vs</span>
                      <% end %>
                    </div>
                  </div>
                  <div class="text-xs text-base-content/30 shrink-0">
                    {format_duration(replay.duration)}
                  </div>
                </.link>
              <% end %>
            </div>
          </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end

  # -- Result components --

  attr :replay, :map, required: true

  defp replay_results(assigns) do
    ~H"""
    <div class="space-y-6">
      <%!-- Header Info --%>
      <div class="bg-base-100 rounded-box border border-base-content/5 card-accent-top overflow-hidden">
        <div class="p-5">
          <div class="flex items-start justify-between mb-4">
            <div>
              <h2 class="text-lg font-bold">{@replay["header"]["map_name"]}</h2>
              <p class="text-sm text-base-content/40">
                {format_duration(@replay["header"]["duration_secs"])}
                · {format_game_type(@replay["header"]["game_type"])}
                · {format_speed(@replay["header"]["game_speed"])}
              </p>
            </div>
            <span class="badge badge-sm badge-ghost">{@replay["command_count"]} commands</span>
          </div>

          <%!-- Players --%>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <%= for {player, apm} <- players_with_apm(@replay) do %>
              <div class="flex items-center gap-3 bg-base-200/50 rounded-lg p-3">
                <span class={["text-sm font-bold w-5 text-center", race_color(player["race_code"])]}>
                  {player["race_code"]}
                </span>
                <div class="flex-1 min-w-0">
                  <p class="font-medium text-sm truncate">{player["name"]}</p>
                  <p class="text-xs text-base-content/40">{format_player_type(player["player_type"])}</p>
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
      </div>

      <%!-- Build Order --%>
      <%= if @replay["build_order"] != [] do %>
        <div class="bg-base-100 rounded-box border border-base-content/5 card-accent-top">
          <div class="p-5">
            <div class="flex items-center justify-between mb-4">
              <h3 class="font-semibold">Build Order</h3>
              <span class="text-xs text-base-content/40">{length(@replay["build_order"])} entries</span>
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
                  <%= for entry <- Enum.take(@replay["build_order"], 50) do %>
                    <tr class="hover:bg-base-200/50">
                      <td class="font-mono text-xs text-base-content/50">
                        {format_game_time(entry["real_seconds"])}
                      </td>
                      <td>
                        <span class={["text-xs font-bold", player_color(entry["player_id"], @replay)]}>
                          {player_race_code(entry["player_id"], @replay)}
                        </span>
                      </td>
                      <td class="text-sm">{entry["action"]}</td>
                    </tr>
                  <% end %>
                  <%= if length(@replay["build_order"]) > 50 do %>
                    <tr>
                      <td colspan="3" class="text-center text-xs text-base-content/30 py-2">
                        ... and {length(@replay["build_order"]) - 50} more entries
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
    """
  end

  # -- Helpers --

  defp players_with_apm(replay) do
    players = replay["header"]["players"] || []
    apms = replay["player_apm"] || []

    Enum.map(players, fn player ->
      apm = Enum.find(apms, fn a -> a["player_id"] == player["player_id"] end)
      {player, apm}
    end)
  end

  defp player_race_code(player_id, replay) do
    player = Enum.find(replay["header"]["players"] || [], fn p -> p["player_id"] == player_id end)
    if player, do: player["race_code"], else: "?"
  end

  defp player_color(player_id, replay) do
    code = player_race_code(player_id, replay)
    race_color(code)
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

  defp format_game_type(:melee), do: "Melee"
  defp format_game_type(:one_on_one), do: "1v1"
  defp format_game_type(:use_map_settings), do: "UMS"
  defp format_game_type(:top_vs_bottom), do: "TvB"
  defp format_game_type(:free_for_all), do: "FFA"
  defp format_game_type(other) when is_atom(other), do: other |> Atom.to_string() |> String.replace("_", " ") |> String.capitalize()
  defp format_game_type(other) when is_binary(other), do: other
  defp format_game_type(_), do: "—"

  defp format_speed(:fastest), do: "Fastest"
  defp format_speed(:faster), do: "Faster"
  defp format_speed(:fast), do: "Fast"
  defp format_speed(:normal), do: "Normal"
  defp format_speed(other) when is_atom(other), do: other |> Atom.to_string() |> String.capitalize()
  defp format_speed(other) when is_binary(other), do: other
  defp format_speed(_), do: "—"

  defp format_player_type(:human), do: "Human"
  defp format_player_type(:computer), do: "Computer"
  defp format_player_type(other) when is_atom(other), do: other |> Atom.to_string() |> String.capitalize()
  defp format_player_type(_), do: "—"

  defp format_bytes(bytes) when bytes < 1024, do: "#{bytes} B"
  defp format_bytes(bytes), do: "#{Float.round(bytes / 1024, 1)} KB"

  defp upload_error_to_string(:too_large), do: "File is too large (max 10 MB)"
  defp upload_error_to_string(:not_accepted), do: "Only .rep files are accepted"
  defp upload_error_to_string(:too_many_files), do: "Only one file at a time"
  defp upload_error_to_string(err), do: "Upload error: #{inspect(err)}"
end
