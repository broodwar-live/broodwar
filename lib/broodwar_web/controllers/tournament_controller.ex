defmodule BroodwarWeb.TournamentController do
  use BroodwarWeb, :controller

  alias Broodwar.Tournaments

  def index(conn, _params) do
    series_list = Tournaments.list_series()
    champion_counts = Tournaments.champion_counts()

    conn
    |> assign(:page_title, "Tournaments")
    |> assign(:page_description, gettext("Complete history of competitive StarCraft: Brood War leagues — ASL, BSL, and more."))
    |> render(:index,
      series_list: series_list,
      champion_counts: champion_counts
    )
  end

  def show(conn, %{"slug" => slug}) do
    seasons = Tournaments.list_by_series(String.upcase(slug))

    if seasons == [] do
      conn |> put_status(:not_found) |> put_view(BroodwarWeb.ErrorHTML) |> render(:"404")
    else
      short_name = String.upcase(slug)

      conn
      |> assign(:page_title, short_name)
      |> assign(:page_description, gettext("%{name} — season history, brackets, and results.", name: short_name))
      |> assign(:breadcrumbs, [{"Tournaments", "/tournaments"}, {short_name, "/tournaments/#{slug}"}])
      |> render(:show,
        short_name: short_name,
        seasons: seasons
      )
    end
  end

  def season(conn, %{"slug" => slug, "season" => season_str}) do
    case Integer.parse(season_str) do
      {season_num, _} ->
        case Tournaments.get_season(String.upcase(slug), season_num) do
          nil ->
            conn |> put_status(:not_found) |> put_view(BroodwarWeb.ErrorHTML) |> render(:"404")

          tournament ->
            short_name = String.upcase(slug)
            title = "#{short_name} Season #{season_num}"

            conn
            |> assign(:page_title, title)
            |> assign(:page_description, gettext("%{title} — brackets, match results, and champion.", title: title))
            |> assign(:breadcrumbs, [{"Tournaments", "/tournaments"}, {short_name, "/tournaments/#{slug}"}, {"Season #{season_num}", "/tournaments/#{slug}/#{season_str}"}])
            |> render(:season, tournament: tournament)
        end

      _ ->
        conn |> put_status(:not_found) |> put_view(BroodwarWeb.ErrorHTML) |> render(:"404")
    end
  end
end
