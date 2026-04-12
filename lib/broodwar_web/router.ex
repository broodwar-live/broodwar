defmodule BroodwarWeb.Router do
  use BroodwarWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BroodwarWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug BroodwarWeb.Plugs.Locale
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BroodwarWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/replays", ReplayLive
    live "/replays/:id", ReplayDetailLive
    live "/players", PlayersLive
    live "/players/:id", PlayerDetailLive
    live "/matches", MatchesLive
    live "/matches/:id", MatchDetailLive
    live "/builds", BuildsLive
    live "/builds/:id", BuildDetailLive
    live "/balance", BalanceLive

    get "/wiki", WikiController, :index
    get "/wiki/races/:slug", WikiController, :race
    get "/wiki/units/:slug", WikiController, :unit
    get "/wiki/buildings/:slug", WikiController, :building
    get "/wiki/abilities", WikiController, :abilities
    get "/wiki/abilities/:slug", WikiController, :ability
    get "/wiki/maps", WikiController, :maps
    get "/wiki/maps/:slug", WikiController, :map
  end

  # Other scopes may use custom stacks.
  # scope "/api", BroodwarWeb do
  #   pipe_through :api
  # end
end
