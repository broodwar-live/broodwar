defmodule BroodwarWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use BroodwarWeb, :html

  embed_templates "layouts/*"

  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="min-h-screen flex flex-col">
      <header class="bg-base-300/60 backdrop-blur-xl border-b border-primary/5 sticky top-0 z-50">
        <nav class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="flex items-center justify-between h-16">
            <%!-- Logo / Brand --%>
            <a href="/" class="group hover:opacity-80 transition-opacity">
              <.brandmark size="sm" />
            </a>

            <%!-- Navigation Links --%>
            <div class="hidden lg:flex items-center gap-0.5">
              <.nav_link href="/" label={gettext("Home")} />
              <.nav_link href="/players" label={gettext("Players")} />
              <.nav_link href="/matches" label={gettext("Matches")} />
              <.nav_link href="/replays" label={gettext("Replays")} />
              <.nav_link href="/builds" label={gettext("Builds")} />
              <.nav_link href="/wiki" label={gettext("Wiki")} />
            </div>

            <%!-- Right side --%>
            <div class="flex items-center gap-2">
              <.locale_toggle />
              <.theme_toggle />
            </div>
          </div>
        </nav>
      </header>

      <main class="flex-1">
        {render_slot(@inner_block)}
      </main>

      <footer class="border-t border-primary/5 bg-base-300/40">
        <%!-- Main footer content --%>
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-14 pb-8">
          <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-10 lg:gap-8">
            <%!-- Brand column --%>
            <div class="col-span-2 sm:col-span-3 lg:col-span-2">
              <.brandmark size="sm" />
              <p class="mt-3 text-sm text-base-content/35 leading-relaxed max-w-xs">
                {gettext("The Home of Competitive Brood War")}
              </p>
              <div class="mt-5 flex items-center gap-3">
                <a href="https://github.com/broodwar-live" target="_blank" rel="noopener" class="text-base-content/25 hover:text-base-content/60 transition-colors">
                  <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0 0 24 12c0-6.63-5.37-12-12-12z"/></svg>
                </a>
                <a href="https://discord.gg/broodwar" target="_blank" rel="noopener" class="text-base-content/25 hover:text-base-content/60 transition-colors">
                  <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M20.317 4.37a19.791 19.791 0 0 0-4.885-1.515.074.074 0 0 0-.079.037c-.21.375-.444.864-.608 1.25a18.27 18.27 0 0 0-5.487 0 12.64 12.64 0 0 0-.617-1.25.077.077 0 0 0-.079-.037A19.736 19.736 0 0 0 3.677 4.37a.07.07 0 0 0-.032.027C.533 9.046-.32 13.58.099 18.057a.082.082 0 0 0 .031.057 19.9 19.9 0 0 0 5.993 3.03.078.078 0 0 0 .084-.028c.462-.63.874-1.295 1.226-1.994a.076.076 0 0 0-.041-.106 13.107 13.107 0 0 1-1.872-.892.077.077 0 0 1-.008-.128 10.2 10.2 0 0 0 .372-.292.074.074 0 0 1 .077-.01c3.928 1.793 8.18 1.793 12.062 0a.074.074 0 0 1 .078.01c.12.098.246.198.373.292a.077.077 0 0 1-.006.127 12.299 12.299 0 0 1-1.873.892.077.077 0 0 0-.041.107c.36.698.772 1.362 1.225 1.993a.076.076 0 0 0 .084.028 19.839 19.839 0 0 0 6.002-3.03.077.077 0 0 0 .032-.054c.5-5.177-.838-9.674-3.549-13.66a.061.061 0 0 0-.031-.03z"/></svg>
                </a>
              </div>
            </div>

            <%!-- Platform --%>
            <div>
              <h4 class="text-xs font-semibold text-base-content/50 uppercase tracking-wider mb-4">{gettext("Platform")}</h4>
              <ul class="space-y-2.5">
                <li><a href="/players" class="text-sm text-base-content/30 hover:text-base-content/60 transition-colors">{gettext("Players")}</a></li>
                <li><a href="/matches" class="text-sm text-base-content/30 hover:text-base-content/60 transition-colors">{gettext("Matches")}</a></li>
                <li><a href="/replays" class="text-sm text-base-content/30 hover:text-base-content/60 transition-colors">{gettext("Replays")}</a></li>
                <li><a href="/builds" class="text-sm text-base-content/30 hover:text-base-content/60 transition-colors">{gettext("Builds")}</a></li>
                <li><a href="/streams" class="text-sm text-base-content/30 hover:text-base-content/60 transition-colors">{gettext("Live Streams")}</a></li>
              </ul>
            </div>

            <%!-- Wiki --%>
            <div>
              <h4 class="text-xs font-semibold text-base-content/50 uppercase tracking-wider mb-4">{gettext("Wiki")}</h4>
              <ul class="space-y-2.5">
                <li><a href="/wiki/races/terran" class="text-sm text-base-content/30 hover:text-base-content/60 transition-colors">{gettext("Terran")}</a></li>
                <li><a href="/wiki/races/protoss" class="text-sm text-base-content/30 hover:text-base-content/60 transition-colors">{gettext("Protoss")}</a></li>
                <li><a href="/wiki/races/zerg" class="text-sm text-base-content/30 hover:text-base-content/60 transition-colors">{gettext("Zerg")}</a></li>
                <li><a href="/wiki/abilities" class="text-sm text-base-content/30 hover:text-base-content/60 transition-colors">{gettext("Abilities")}</a></li>
                <li><a href="/wiki/maps" class="text-sm text-base-content/30 hover:text-base-content/60 transition-colors">{gettext("Maps")}</a></li>
              </ul>
            </div>

            <%!-- Tournaments --%>
            <div>
              <h4 class="text-xs font-semibold text-base-content/50 uppercase tracking-wider mb-4">{gettext("Tournaments")}</h4>
              <ul class="space-y-2.5">
                <li><a href="/tournaments" class="text-sm text-base-content/30 hover:text-base-content/60 transition-colors">ASL</a></li>
                <li><a href="/tournaments" class="text-sm text-base-content/30 hover:text-base-content/60 transition-colors">BSL</a></li>
                <li><a href="/balance" class="text-sm text-base-content/30 hover:text-base-content/60 transition-colors">{gettext("Balance")}</a></li>
                <li><a href="/tournaments" class="text-sm text-base-content/30 hover:text-base-content/60 transition-colors">{gettext("Rankings")}</a></li>
              </ul>
            </div>

            <%!-- Community --%>
            <div>
              <h4 class="text-xs font-semibold text-base-content/50 uppercase tracking-wider mb-4">{gettext("Community")}</h4>
              <ul class="space-y-2.5">
                <li><a href="https://github.com/broodwar-live" target="_blank" rel="noopener" class="text-sm text-base-content/30 hover:text-base-content/60 transition-colors">GitHub</a></li>
                <li><a href="https://discord.gg/broodwar" target="_blank" rel="noopener" class="text-sm text-base-content/30 hover:text-base-content/60 transition-colors">Discord</a></li>
                <li><a href="/api" class="text-sm text-base-content/30 hover:text-base-content/60 transition-colors">API</a></li>
                <li><a href="https://github.com/broodwar-live/broodwar/issues" target="_blank" rel="noopener" class="text-sm text-base-content/30 hover:text-base-content/60 transition-colors">{gettext("Report a Bug")}</a></li>
              </ul>
            </div>
          </div>
        </div>

        <%!-- Bottom bar --%>
        <div class="border-t border-primary/5">
          <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-5">
            <div class="flex flex-col sm:flex-row items-center justify-between gap-4">
              <div class="flex items-center gap-4 text-[11px] text-base-content/20">
                <span>&copy; 2026 broodwar.live</span>
                <span>&middot;</span>
                <span>{gettext("Open source community project")}</span>
              </div>
              <p class="text-[11px] text-base-content/15 text-center sm:text-right max-w-lg leading-relaxed">
                {gettext("Not affiliated with Blizzard Entertainment or Microsoft. StarCraft and Brood War are trademarks of Blizzard Entertainment, Inc.")}
              </p>
            </div>
          </div>
        </div>
      </footer>
    </div>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Renders the broodwar.live typographic brandmark.
  """
  attr :size, :string, default: "sm", values: ~w(xs sm md lg xl)
  attr :muted, :boolean, default: false

  def brandmark(assigns) do
    size_class =
      case assigns.size do
        "xs" -> "text-xs"
        "sm" -> "text-sm"
        "md" -> "text-lg"
        "lg" -> "text-2xl"
        "xl" -> "text-4xl"
      end

    assigns = assign(assigns, :size_class, size_class)

    ~H"""
    <span class={["brandmark", @size_class, @muted && "brandmark-muted"]}>
      <span class="brandmark-word">BROODWAR</span>
      <span class="brandmark-live-box"><span>LIVE</span></span>
    </span>
    """
  end

  attr :href, :string, required: true
  attr :label, :string, required: true

  defp nav_link(assigns) do
    ~H"""
    <a
      href={@href}
      class="px-3 py-1.5 text-[13px] font-medium text-base-content/50 hover:text-base-content rounded-lg hover:bg-primary/5 transition-all duration-150"
    >
      {@label}
    </a>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  def locale_toggle(assigns) do
    locale = Gettext.get_locale(BroodwarWeb.Gettext)
    assigns = assign(assigns, :locale, locale)

    ~H"""
    <div class="flex items-center border border-primary/10 bg-base-300/60 rounded-lg p-0.5 gap-0.5">
      <a
        href={"?locale=en"}
        data-phx-link="redirect"
        data-phx-link-state="push"
        class={[
          "relative px-2.5 py-1 text-xs font-medium rounded-md transition-all duration-150",
          @locale == "en" && "bg-primary/15 text-primary shadow-sm",
          @locale != "en" && "text-base-content/35 hover:text-base-content/60"
        ]}
      >
        English
      </a>
      <a
        href={"?locale=ko"}
        data-phx-link="redirect"
        data-phx-link-state="push"
        class={[
          "relative px-2.5 py-1 text-xs font-medium rounded-md transition-all duration-150",
          @locale == "ko" && "bg-primary/15 text-primary shadow-sm",
          @locale != "ko" && "text-base-content/35 hover:text-base-content/60"
        ]}
      >
        한국어
      </a>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="flex items-center border border-primary/10 bg-base-300/60 rounded-lg p-0.5 relative gap-0.5">
      <button
        class="relative flex p-1.5 cursor-pointer rounded-md hover:bg-primary/10 transition-colors"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-3.5 opacity-50 hover:opacity-90" />
      </button>

      <button
        class="relative flex p-1.5 cursor-pointer rounded-md hover:bg-primary/10 transition-colors"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-3.5 opacity-50 hover:opacity-90" />
      </button>

      <button
        class="relative flex p-1.5 cursor-pointer rounded-md hover:bg-primary/10 transition-colors"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-3.5 opacity-50 hover:opacity-90" />
      </button>
    </div>
    """
  end
end
