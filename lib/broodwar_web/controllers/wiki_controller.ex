defmodule BroodwarWeb.WikiController do
  use BroodwarWeb, :controller

  alias Broodwar.Wiki.Data

  def index(conn, _params) do
    render(conn, :index, races: Data.races())
  end

  def race(conn, %{"slug" => slug}) do
    case Data.race(slug) do
      nil ->
        conn |> put_status(:not_found) |> put_view(BroodwarWeb.ErrorHTML) |> render(:"404")

      race ->
        units = Data.units_for_race(slug)
        buildings = Data.buildings_for_race(slug)
        abilities = Data.abilities_for_race(slug)
        render(conn, :race, race: race, units: units, buildings: buildings, abilities: abilities)
    end
  end

  def unit(conn, %{"slug" => slug}) do
    case Data.unit(slug) do
      nil ->
        conn |> put_status(:not_found) |> put_view(BroodwarWeb.ErrorHTML) |> render(:"404")

      unit ->
        race = Data.race(unit.race)
        built_from = Data.building(unit.built_from) || Data.unit(unit.built_from)
        abilities = Data.abilities_for_unit(slug)
        render(conn, :unit, unit: unit, race: race, built_from: built_from, abilities: abilities)
    end
  end

  def building(conn, %{"slug" => slug}) do
    case Data.building(slug) do
      nil ->
        conn |> put_status(:not_found) |> put_view(BroodwarWeb.ErrorHTML) |> render(:"404")

      building ->
        race = Data.race(building.race)
        produced_units = Enum.map(building.produces, &Data.unit/1) |> Enum.reject(&is_nil/1)
        render(conn, :building, building: building, race: race, produced_units: produced_units)
    end
  end

  def abilities(conn, _params) do
    races = Data.races()

    abilities_by_race =
      Enum.map(races, fn race ->
        {race, Data.abilities_for_race(race.slug)}
      end)

    render(conn, :abilities, abilities_by_race: abilities_by_race)
  end

  def ability(conn, %{"slug" => slug}) do
    case Data.ability(slug) do
      nil ->
        conn |> put_status(:not_found) |> put_view(BroodwarWeb.ErrorHTML) |> render(:"404")

      ability ->
        race = Data.race(ability.race)
        caster = Data.unit(ability.caster)
        render(conn, :ability, ability: ability, race: race, caster: caster)
    end
  end

  def maps(conn, _params) do
    maps = Data.wiki_maps()
    render(conn, :maps, maps: maps)
  end

  def map(conn, %{"slug" => slug}) do
    case Data.wiki_map(slug) do
      nil ->
        conn |> put_status(:not_found) |> put_view(BroodwarWeb.ErrorHTML) |> render(:"404")

      map ->
        render(conn, :map, map: map)
    end
  end
end
