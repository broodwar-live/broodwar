defmodule BroodwarWeb.BuildDetailLive do
  use BroodwarWeb, :live_view

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    build = Broodwar.BuildsContext.get_build!(id)

    {:ok,
     socket
     |> assign(:page_title, build.name)
     |> assign(:page_description, gettext("%{name} — build order details, timing, and pro replay evidence on broodwar.live.", name: build.name))
     |> assign(:breadcrumbs, [{gettext("Builds"), "/builds"}, {build.name, "/builds/#{id}"}])
     |> assign(:build, build)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
        <div class="bg-base-100 rounded-box border border-base-content/5 card-accent-top p-6">
          <div class="flex items-center gap-3 mb-4">
            <span class={[
              "w-8 h-8 rounded flex items-center justify-center text-sm font-bold text-base-100",
              race_bg(@build.race)
            ]}>
              {@build.race}
            </span>
            <div>
              <h1 class="text-xl font-bold">{@build.name}</h1>
              <span class="badge badge-sm badge-ghost">{@build.matchup}</span>
            </div>
          </div>

          <p class="text-base-content/60 leading-relaxed mb-6">{@build.description}</p>

          <div class="flex items-center gap-6 text-sm border-t border-base-content/5 pt-4">
            <div>
              <span class="text-base-content/40">Games</span>
              <span class="ml-2 font-mono font-medium">{@build.games}</span>
            </div>
            <%= if @build.winrate do %>
              <div>
                <span class="text-base-content/40">Winrate</span>
                <span class={[
                  "ml-2 font-mono font-medium",
                  @build.winrate >= 55 && "text-success",
                  @build.winrate < 55 && @build.winrate >= 50 && "text-base-content",
                  @build.winrate < 50 && "text-error"
                ]}>
                  {@build.winrate}%
                </span>
              </div>
            <% end %>
            <div>
              <span class="text-base-content/40">Upvotes</span>
              <span class="ml-2 font-mono font-medium">{@build.upvotes}</span>
            </div>
          </div>

          <%= if @build.tags != [] do %>
            <div class="flex flex-wrap gap-1.5 mt-4">
              <%= for tag <- @build.tags do %>
                <span class="badge badge-sm badge-ghost">{tag}</span>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp race_bg("T"), do: "bg-race-terran"
  defp race_bg("P"), do: "bg-race-protoss"
  defp race_bg("Z"), do: "bg-race-zerg"
  defp race_bg(_), do: "bg-base-content"
end
