defmodule BroodwarWeb.MatchDetailLive do
  use BroodwarWeb, :live_view

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    match = Broodwar.Matches.get_match!(id)

    {:ok,
     socket
     |> assign(:page_title, "#{match.player_a.name} vs #{match.player_b.name}")
     |> assign(:page_description, gettext("%{player_a} vs %{player_b} — match details and game analysis on broodwar.live.", player_a: match.player_a.name, player_b: match.player_b.name))
     |> assign(:breadcrumbs, [{gettext("Matches"), "/matches"}, {"#{match.player_a.name} vs #{match.player_b.name}", "/matches/#{id}"}])
     |> assign(:match, match)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
        <div class="bg-base-100 rounded-box border border-base-content/5 card-accent-top p-6">
          <%!-- Tournament + Round --%>
          <div class="text-center mb-6">
            <span class="text-xs text-base-content/40 uppercase tracking-wide">
              {@match.tournament && @match.tournament.name} · {@match.round}
            </span>
          </div>

          <%!-- Players + Score --%>
          <div class="flex items-center justify-center gap-6 mb-6">
            <div class="text-right flex-1">
              <.link navigate={~p"/players/#{@match.player_a.id}"} class="hover:text-primary transition-colors">
                <div class="text-xl font-bold">{@match.player_a.name}</div>
              </.link>
              <span class={["text-sm font-bold", race_color(@match.race_a)]}>{race_name(@match.race_a)}</span>
            </div>

            <div class="flex items-center gap-3 shrink-0">
              <span class={["text-3xl font-mono font-bold", winner?(:a) && "text-secondary", !winner?(:a) && "text-base-content/30"]}>{@match.score_a}</span>
              <span class="text-base-content/20 text-xl">:</span>
              <span class={["text-3xl font-mono font-bold", winner?(:b) && "text-secondary", !winner?(:b) && "text-base-content/30"]}>{@match.score_b}</span>
            </div>

            <div class="flex-1">
              <.link navigate={~p"/players/#{@match.player_b.id}"} class="hover:text-primary transition-colors">
                <div class="text-xl font-bold">{@match.player_b.name}</div>
              </.link>
              <span class={["text-sm font-bold", race_color(@match.race_b)]}>{race_name(@match.race_b)}</span>
            </div>
          </div>

          <%!-- Details --%>
          <div class="grid grid-cols-2 sm:grid-cols-4 gap-4 text-center border-t border-base-content/5 pt-5">
            <div>
              <div class="text-xs text-base-content/40 mb-1">Date</div>
              <div class="text-sm font-medium">{format_date(@match.played_at)}</div>
            </div>
            <div>
              <div class="text-xs text-base-content/40 mb-1">Map</div>
              <div class="text-sm font-medium">{@match.map && @match.map.name || "—"}</div>
            </div>
            <div>
              <div class="text-xs text-base-content/40 mb-1">Matchup</div>
              <div class="text-sm font-medium">{@match.race_a}v{@match.race_b}</div>
            </div>
            <div>
              <div class="text-xs text-base-content/40 mb-1">Source</div>
              <div class="text-sm font-medium">{@match.source || "—"}</div>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp winner?(:a), do: true
  defp winner?(:b), do: false

  defp race_color("T"), do: "text-race-terran"
  defp race_color("P"), do: "text-race-protoss"
  defp race_color("Z"), do: "text-race-zerg"
  defp race_color(_), do: "text-base-content"

  defp race_name("T"), do: "Terran"
  defp race_name("P"), do: "Protoss"
  defp race_name("Z"), do: "Zerg"
  defp race_name(_), do: "Unknown"

  defp format_date(nil), do: "—"
  defp format_date(dt), do: Calendar.strftime(dt, "%b %d, %Y")
end
