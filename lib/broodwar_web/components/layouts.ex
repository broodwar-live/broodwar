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
      <header class="bg-base-300/80 backdrop-blur-md border-b border-base-content/5 sticky top-0 z-50">
        <nav class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="flex items-center justify-between h-14">
            <%!-- Logo / Brand --%>
            <a href="/" class="flex items-center gap-2.5 group">
              <div class="w-7 h-7 rounded bg-primary/15 border border-primary/30 flex items-center justify-center group-hover:bg-primary/25 transition-colors">
                <span class="text-primary font-bold text-xs">BW</span>
              </div>
              <span class="font-semibold text-base-content tracking-tight text-sm">
                broodwar<span class="text-primary">.live</span>
              </span>
            </a>

            <%!-- Navigation Links --%>
            <div class="hidden md:flex items-center gap-1">
              <.nav_link href="/" label="Home" icon="hero-home-micro" />
              <.nav_link href="/players" label="Players" icon="hero-user-group-micro" />
              <.nav_link href="/matches" label="Matches" icon="hero-trophy-micro" />
              <.nav_link href="/replays" label="Replays" icon="hero-play-circle-micro" />
              <.nav_link href="/builds" label="Builds" icon="hero-queue-list-micro" />
              <.nav_link href="/balance" label="Balance" icon="hero-chart-bar-micro" />
            </div>

            <%!-- Right side --%>
            <div class="flex items-center gap-3">
              <.theme_toggle />
            </div>
          </div>
        </nav>
      </header>

      <main class="flex-1">
        {render_slot(@inner_block)}
      </main>

      <footer class="border-t border-base-content/5 bg-base-300/50">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div class="flex flex-col sm:flex-row items-center justify-between gap-4">
            <div class="flex items-center gap-2 text-sm text-base-content/40">
              <span class="font-medium">broodwar<span class="text-primary/60">.live</span></span>
              <span>&middot;</span>
              <span>Open source community project</span>
            </div>
            <p class="text-xs text-base-content/30 text-center sm:text-right max-w-md">
              Not affiliated with Blizzard Entertainment or Microsoft.
              StarCraft and Brood War are trademarks of Blizzard Entertainment, Inc.
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
  attr :icon, :string, required: true

  defp nav_link(assigns) do
    ~H"""
    <a
      href={@href}
      class="flex items-center gap-1.5 px-3 py-1.5 text-sm text-base-content/60 hover:text-base-content hover:bg-base-content/5 rounded-lg transition-colors"
    >
      <.icon name={@icon} class="size-3.5" />
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

  @doc """
  Provides dark vs light theme toggle.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="flex items-center border border-base-content/10 bg-base-200 rounded-full p-0.5 relative">
      <div class="absolute w-1/3 h-[calc(100%-4px)] rounded-full bg-base-content/10 left-0.5 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-[calc(66.66%-2px)] transition-[left] duration-200" />

      <button
        class="relative flex p-1.5 cursor-pointer"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-3.5 opacity-60 hover:opacity-100" />
      </button>

      <button
        class="relative flex p-1.5 cursor-pointer"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-3.5 opacity-60 hover:opacity-100" />
      </button>

      <button
        class="relative flex p-1.5 cursor-pointer"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-3.5 opacity-60 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
