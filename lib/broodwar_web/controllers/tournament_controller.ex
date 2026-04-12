defmodule BroodwarWeb.TournamentController do
  use BroodwarWeb, :controller

  alias Broodwar.Tournaments

  def index(conn, _params) do
    series_list = Tournaments.list_series()
    champion_counts = Tournaments.champion_counts()

    render(conn, :index,
      series_list: series_list,
      champion_counts: champion_counts
    )
  end

  def show(conn, %{"slug" => slug}) do
    seasons = Tournaments.list_by_series(String.upcase(slug))

    if seasons == [] do
      conn |> put_status(:not_found) |> put_view(BroodwarWeb.ErrorHTML) |> render(:"404")
    else
      render(conn, :show,
        short_name: String.upcase(slug),
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
            render(conn, :season, tournament: tournament)
        end

      _ ->
        conn |> put_status(:not_found) |> put_view(BroodwarWeb.ErrorHTML) |> render(:"404")
    end
  end
end
