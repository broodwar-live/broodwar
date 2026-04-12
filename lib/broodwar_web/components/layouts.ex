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
            <a href="/" class="flex items-center gap-3 group">
              <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-primary to-secondary flex items-center justify-center shadow-lg shadow-primary/20 group-hover:shadow-primary/30 transition-shadow">
                <span class="text-white font-black text-xs tracking-tighter">BW</span>
              </div>
              <span class="font-bold text-base-content tracking-tight text-sm">
                broodwar<span class="text-gradient-asl">.live</span>
              </span>
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
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
          <div class="flex flex-col sm:flex-row items-center justify-between gap-6">
            <div class="flex flex-col sm:flex-row items-center gap-3">
              <div class="flex items-center gap-2.5">
                <div class="w-6 h-6 rounded bg-gradient-to-br from-primary to-secondary flex items-center justify-center">
                  <span class="text-white font-black text-[8px] tracking-tighter">BW</span>
                </div>
                <span class="font-semibold text-sm text-base-content/50">
                  broodwar<span class="text-primary/40">.live</span>
                </span>
              </div>
              <span class="text-base-content/20 hidden sm:inline">&middot;</span>
              <span class="text-xs text-base-content/30">{gettext("Open source community project")}</span>
            </div>
            <p class="text-[11px] text-base-content/20 text-center sm:text-right max-w-md leading-relaxed">
              {gettext("Not affiliated with Blizzard Entertainment or Microsoft. StarCraft and Brood War are trademarks of Blizzard Entertainment, Inc.")}
            </p>
          </div>
        </div>
      </footer>
    </div>

    <.flash_group flash={@flash} />
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
