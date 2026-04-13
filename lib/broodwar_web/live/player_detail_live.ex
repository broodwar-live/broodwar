defmodule BroodwarWeb.PlayerDetailLive do
  use BroodwarWeb, :live_view

  alias Broodwar.Players
  alias Broodwar.Players.Player

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    player = Players.get_player!(id)
    tournament_matches = Players.get_tournament_matches(player.name)
    stats = Players.compute_stats(tournament_matches)

    {:ok,
     socket
     |> assign(:page_title, player.name)
     |> assign(:page_description, gettext("%{name} — %{race} player profile, match history, and career stats on broodwar.live.", name: player.name, race: Player.race_name(player.race)))
     |> assign(:breadcrumbs, [{gettext("Players"), "/players"}, {player.name, "/players/#{id}"}])
     |> assign(:player, player)
     |> assign(:tournament_matches, tournament_matches)
     |> assign(:stats, stats)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <%!-- Player Header --%>
      <section class="relative overflow-hidden asl-gradient-bg">
        <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-10 pb-10">
          <div class="flex items-start gap-6">
            <%!-- Photo --%>
            <div :if={@player.image_url} class="w-28 h-28 rounded-2xl overflow-hidden shrink-0 border-2 border-primary/20 shadow-xl shadow-primary/10">
              <img src={@player.image_url} alt={@player.name} class="w-full h-full object-cover" />
            </div>
            <div :if={!@player.image_url} class={[
              "w-28 h-28 rounded-2xl flex items-center justify-center text-4xl font-black text-base-100 shrink-0",
              race_bg(@player.race)
            ]}>
              {String.first(@player.name)}
            </div>

            <div class="flex-1 min-w-0">
              <div class="flex items-center gap-3 mb-1">
                <h1 class="font-display text-3xl tracking-tight">{@player.name}</h1>
                <span class={["text-sm font-bold", race_color(@player.race)]}>{Player.race_name(@player.race)}</span>
                <span :if={@player.status == "inactive"} class="px-2 py-0.5 rounded text-[10px] font-semibold bg-base-content/10 text-base-content/40">
                  {gettext("Retired")}
                </span>
              </div>

              <%!-- Real name --%>
              <div class="text-base-content/40 text-sm">
                <span :if={@player.real_name}>{@player.real_name}</span>
                <span :if={@player.real_name_ko} class="ml-1 text-base-content/25">({@player.real_name_ko})</span>
              </div>

              <%!-- Meta --%>
              <div class="flex items-center flex-wrap gap-x-4 gap-y-1 mt-3 text-xs text-base-content/30">
                <span :if={Player.age(@player)}>{flag_emoji(@player.country)} {Player.age(@player)} {gettext("years old")}</span>
                <span :if={@player.birth_date}>{gettext("Born")} {@player.birth_date}</span>
                <span :if={@player.team}>{@player.team}</span>
                <span :if={@player.liquipedia_data["nicknames"]}>{@player.liquipedia_data["nicknames"]}</span>
              </div>
            </div>

            <%!-- Rating --%>
            <div :if={@player.rating} class="text-right shrink-0 hidden sm:block">
              <div class="text-3xl font-stats font-bold">{@player.rating}</div>
              <div class="text-[10px] text-base-content/25 uppercase tracking-wider">{gettext("Rating")}</div>
            </div>
          </div>
        </div>
        <div class="absolute bottom-0 left-0 right-0 h-12 bg-gradient-to-t from-base-200 to-transparent"></div>
      </section>

      <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-16">
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 -mt-2">
          <%!-- Main Content --%>
          <div class="lg:col-span-2 space-y-6">
            <%!-- Stats Overview --%>
            <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
              <div class="glass-card-elevated rounded-box p-4 text-center">
                <div class="text-xl font-stats font-bold">{@stats.total}</div>
                <div class="text-[10px] text-base-content/25 uppercase tracking-wider mt-0.5">{gettext("Matches")}</div>
              </div>
              <div class="glass-card-elevated rounded-box p-4 text-center">
                <div class="text-xl font-stats font-bold text-success">{@stats.wins}</div>
                <div class="text-[10px] text-base-content/25 uppercase tracking-wider mt-0.5">{gettext("Wins")}</div>
              </div>
              <div class="glass-card-elevated rounded-box p-4 text-center">
                <div class="text-xl font-stats font-bold text-error">{@stats.losses}</div>
                <div class="text-[10px] text-base-content/25 uppercase tracking-wider mt-0.5">{gettext("Losses")}</div>
              </div>
              <div class="glass-card-elevated rounded-box p-4 text-center">
                <div class={["text-xl font-stats font-bold", if(@stats.winrate >= 50, do: "text-success", else: "text-error")]}>{@stats.winrate}%</div>
                <div class="text-[10px] text-base-content/25 uppercase tracking-wider mt-0.5">{gettext("winrate")}</div>
              </div>
            </div>

            <%!-- Tournament Match History --%>
            <div class="glass-card-elevated rounded-box p-6">
              <h2 class="text-sm font-semibold mb-4">
                {gettext("Match History")}
                <span class="text-base-content/30 font-stats">({length(@tournament_matches)})</span>
              </h2>

              <%= if @tournament_matches == [] do %>
                <p class="text-sm text-base-content/30 text-center py-8">{gettext("No tournament matches recorded.")}</p>
              <% else %>
                <div class="space-y-1">
                  <div :for={m <- @tournament_matches} class="flex items-center gap-3 py-2 text-sm border-b border-base-content/3 last:border-0">
                    <%!-- Result indicator --%>
                    <span class={[
                      "w-1.5 h-1.5 rounded-full shrink-0",
                      m.result == :win && "bg-success",
                      m.result == :loss && "bg-error",
                      m.result == :unknown && "bg-base-content/15"
                    ]} />

                    <%!-- Tournament --%>
                    <span class="text-[10px] text-primary/40 font-medium w-16 shrink-0">
                      <.link navigate={"/tournaments/#{m.tournament_slug}/#{m.season}"} class="hover:text-primary transition-colors">
                        {m.tournament}
                      </.link>
                    </span>

                    <%!-- Opponent + Score --%>
                    <div class="flex-1 flex items-center gap-2 min-w-0">
                      <span class={[
                        "font-semibold truncate",
                        m.result == :win && "text-base-content",
                        m.result == :loss && "text-base-content/40",
                        m.result == :unknown && "text-base-content/50"
                      ]}>
                        {m.result == :win && "def." || m.result == :loss && "lost to" || "vs"}
                      </span>
                      <span class="truncate">{m.opponent}</span>
                    </div>

                    <%!-- Score --%>
                    <span class="font-stats text-xs text-base-content/40 shrink-0">{m.my_score}-{m.opp_score}</span>

                    <%!-- Map dots --%>
                    <div class="hidden sm:flex items-center gap-0.5 shrink-0">
                      <span
                        :for={map <- m.maps}
                        class={[
                          "w-1.5 h-1.5 rounded-full",
                          map["winner"] == 1 && "bg-primary/50",
                          map["winner"] == 2 && "bg-secondary/50"
                        ]}
                        title={map["map"]}
                      />
                    </div>

                    <%!-- Date --%>
                    <span class="text-[10px] text-base-content/20 w-20 text-right shrink-0 hidden sm:block">{m.date}</span>
                  </div>
                </div>
              <% end %>
            </div>
          </div>

          <%!-- Sidebar --%>
          <div class="space-y-4">
            <%!-- Player Info --%>
            <div class="glass-card-elevated rounded-box p-5">
              <h3 class="text-sm font-semibold mb-4">{gettext("Details")}</h3>
              <dl class="space-y-3">
                <div class="flex justify-between text-sm">
                  <dt class="text-base-content/40">{gettext("Race")}</dt>
                  <dd class={["font-semibold", race_color(@player.race)]}>{Player.race_name(@player.race)}</dd>
                </div>
                <div :if={@player.country} class="flex justify-between text-sm">
                  <dt class="text-base-content/40">{gettext("Country")}</dt>
                  <dd>{flag_emoji(@player.country)} {country_name(@player.country)}</dd>
                </div>
                <div :if={@player.birth_date} class="flex justify-between text-sm">
                  <dt class="text-base-content/40">{gettext("Born")}</dt>
                  <dd class="font-stats">{@player.birth_date}</dd>
                </div>
                <div :if={Player.age(@player)} class="flex justify-between text-sm">
                  <dt class="text-base-content/40">{gettext("Age")}</dt>
                  <dd class="font-stats">{Player.age(@player)}</dd>
                </div>
                <div :if={@player.team} class="flex justify-between text-sm">
                  <dt class="text-base-content/40">{gettext("Team")}</dt>
                  <dd>{@player.team}</dd>
                </div>
                <div :if={@player.aliases != []} class="flex justify-between text-sm gap-4">
                  <dt class="text-base-content/40 shrink-0">{gettext("Aliases")}</dt>
                  <dd class="text-right text-xs text-base-content/50">{Enum.join(@player.aliases, ", ")}</dd>
                </div>
                <div :if={@player.liquipedia_page} class="flex justify-between text-sm">
                  <dt class="text-base-content/40">Liquipedia</dt>
                  <dd>
                    <a href={"https://liquipedia.net/starcraft/#{@player.liquipedia_page}"} target="_blank" rel="noopener" class="text-primary hover:text-primary/80 text-xs transition-colors">
                      {gettext("View")} &rarr;
                    </a>
                  </dd>
                </div>
              </dl>
            </div>

            <%!-- Social Links --%>
            <div :if={has_socials?(@player)} class="glass-card-elevated rounded-box p-5">
              <h3 class="text-sm font-semibold mb-4">{gettext("Links")}</h3>
              <div class="space-y-2">
                <a :if={@player.liquipedia_data["afreeca"]} href={"https://play.sooplive.co.kr/#{@player.liquipedia_data["afreeca"]}"} target="_blank" rel="noopener" class="flex items-center gap-2 text-sm text-base-content/40 hover:text-primary transition-colors">
                  <span class="w-4 text-center">S</span> SOOP
                </a>
                <a :if={@player.liquipedia_data["youtube"]} href={"https://youtube.com/#{@player.liquipedia_data["youtube"]}"} target="_blank" rel="noopener" class="flex items-center gap-2 text-sm text-base-content/40 hover:text-primary transition-colors">
                  <span class="w-4 text-center">Y</span> YouTube
                </a>
                <a :if={@player.liquipedia_data["twitter"]} href={"https://twitter.com/#{@player.liquipedia_data["twitter"]}"} target="_blank" rel="noopener" class="flex items-center gap-2 text-sm text-base-content/40 hover:text-primary transition-colors">
                  <span class="w-4 text-center">X</span> {@player.liquipedia_data["twitter"]}
                </a>
              </div>
            </div>

            <%!-- Head-to-Head --%>
            <div :if={@stats.vs_stats != []} class="glass-card-elevated rounded-box p-5">
              <h3 class="text-sm font-semibold mb-4">{gettext("Head-to-Head")}</h3>
              <div class="space-y-2">
                <div :for={vs <- Enum.take(@stats.vs_stats, 8)} class="flex items-center justify-between text-sm">
                  <span class="text-base-content/60 truncate">{vs.opponent}</span>
                  <span class="font-stats text-xs shrink-0">
                    <span class="text-success">{vs.wins}W</span>
                    <span class="text-base-content/20 mx-0.5">-</span>
                    <span class="text-error">{vs.losses}L</span>
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </Layouts.app>
    """
  end

  defp has_socials?(player) do
    data = player.liquipedia_data || %{}
    data["afreeca"] || data["youtube"] || data["twitter"]
  end

  defp race_color("T"), do: "text-race-terran"
  defp race_color("P"), do: "text-race-protoss"
  defp race_color("Z"), do: "text-race-zerg"
  defp race_color(_), do: "text-base-content"

  defp race_bg("T"), do: "bg-race-terran"
  defp race_bg("P"), do: "bg-race-protoss"
  defp race_bg("Z"), do: "bg-race-zerg"
  defp race_bg(_), do: "bg-base-content"

  defp flag_emoji("KR"), do: "\u{1F1F0}\u{1F1F7}"
  defp flag_emoji("US"), do: "\u{1F1FA}\u{1F1F8}"
  defp flag_emoji("PL"), do: "\u{1F1F5}\u{1F1F1}"
  defp flag_emoji("CA"), do: "\u{1F1E8}\u{1F1E6}"
  defp flag_emoji("RU"), do: "\u{1F1F7}\u{1F1FA}"
  defp flag_emoji("UA"), do: "\u{1F1FA}\u{1F1E6}"
  defp flag_emoji("CZ"), do: "\u{1F1E8}\u{1F1FF}"
  defp flag_emoji("HU"), do: "\u{1F1ED}\u{1F1FA}"
  defp flag_emoji("DE"), do: "\u{1F1E9}\u{1F1EA}"
  defp flag_emoji("CN"), do: "\u{1F1E8}\u{1F1F3}"
  defp flag_emoji("PE"), do: "\u{1F1F5}\u{1F1EA}"
  defp flag_emoji("MX"), do: "\u{1F1F2}\u{1F1FD}"
  defp flag_emoji(_), do: ""

  defp country_name("KR"), do: "South Korea"
  defp country_name("US"), do: "United States"
  defp country_name("PL"), do: "Poland"
  defp country_name("CA"), do: "Canada"
  defp country_name("RU"), do: "Russia"
  defp country_name("UA"), do: "Ukraine"
  defp country_name("CZ"), do: "Czech Republic"
  defp country_name("HU"), do: "Hungary"
  defp country_name("DE"), do: "Germany"
  defp country_name("CN"), do: "China"
  defp country_name("PE"), do: "Peru"
  defp country_name("MX"), do: "Mexico"
  defp country_name(code), do: code || ""
end
