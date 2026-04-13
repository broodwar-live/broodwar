defmodule BroodwarWeb.WikiController do
  use BroodwarWeb, :controller

  alias Broodwar.Wiki.Data

  def index(conn, _params) do
    conn
    |> assign(:page_title, "Wiki")
    |> assign(:page_description, gettext("Reference guide to StarCraft: Brood War races, units, buildings, abilities, and maps."))
    |> render(:index, races: Data.races())
  end

  def race(conn, %{"slug" => slug}) do
    case Data.race(slug) do
      nil ->
        conn |> put_status(:not_found) |> put_view(BroodwarWeb.ErrorHTML) |> render(:"404")

      race ->
        units = Data.units_for_race(slug)
        buildings = Data.buildings_for_race(slug)
        abilities = Data.abilities_for_race(slug)

        conn
        |> assign(:page_title, race.name)
        |> assign(:page_description, gettext("%{name} — units, buildings, abilities, and strategy guide on broodwar.live.", name: race.name))
        |> assign(:breadcrumbs, [{"Wiki", "/wiki"}, {race.name, "/wiki/races/#{slug}"}])
        |> render(:race, race: race, units: units, buildings: buildings, abilities: abilities)
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

        conn
        |> assign(:page_title, unit.name)
        |> assign(:page_description, gettext("%{unit} — %{race} unit stats, abilities, and production info.", unit: unit.name, race: race.name))
        |> assign(:breadcrumbs, [{"Wiki", "/wiki"}, {race.name, "/wiki/races/#{unit.race}"}, {unit.name, "/wiki/units/#{slug}"}])
        |> render(:unit, unit: unit, race: race, built_from: built_from, abilities: abilities)
    end
  end

  def building(conn, %{"slug" => slug}) do
    case Data.building(slug) do
      nil ->
        conn |> put_status(:not_found) |> put_view(BroodwarWeb.ErrorHTML) |> render(:"404")

      building ->
        race = Data.race(building.race)
        produced_units = Enum.map(building.produces, &Data.unit/1) |> Enum.reject(&is_nil/1)

        conn
        |> assign(:page_title, building.name)
        |> assign(:page_description, gettext("%{building} — %{race} building stats and produced units.", building: building.name, race: race.name))
        |> assign(:breadcrumbs, [{"Wiki", "/wiki"}, {race.name, "/wiki/races/#{building.race}"}, {building.name, "/wiki/buildings/#{slug}"}])
        |> render(:building, building: building, race: race, produced_units: produced_units)
    end
  end

  def abilities(conn, _params) do
    races = Data.races()

    abilities_by_race =
      Enum.map(races, fn race ->
        {race, Data.abilities_for_race(race.slug)}
      end)

    conn
    |> assign(:page_title, "Abilities")
    |> assign(:page_description, gettext("Complete list of StarCraft: Brood War unit abilities by race."))
    |> assign(:breadcrumbs, [{"Wiki", "/wiki"}, {"Abilities", "/wiki/abilities"}])
    |> render(:abilities, abilities_by_race: abilities_by_race)
  end

  def ability(conn, %{"slug" => slug}) do
    case Data.ability(slug) do
      nil ->
        conn |> put_status(:not_found) |> put_view(BroodwarWeb.ErrorHTML) |> render(:"404")

      ability ->
        race = Data.race(ability.race)
        caster = Data.unit(ability.caster)

        conn
        |> assign(:page_title, ability.name)
        |> assign(:page_description, gettext("%{ability} — %{race} ability details and caster info.", ability: ability.name, race: race.name))
        |> assign(:breadcrumbs, [{"Wiki", "/wiki"}, {"Abilities", "/wiki/abilities"}, {ability.name, "/wiki/abilities/#{slug}"}])
        |> render(:ability, ability: ability, race: race, caster: caster)
    end
  end

  def maps(conn, _params) do
    maps = Data.wiki_maps()

    conn
    |> assign(:page_title, "Maps")
    |> assign(:page_description, gettext("Competitive StarCraft: Brood War map pool — layouts, start positions, and tournament history."))
    |> assign(:breadcrumbs, [{"Wiki", "/wiki"}, {"Maps", "/wiki/maps"}])
    |> render(:maps, maps: maps)
  end

  def map(conn, %{"slug" => slug}) do
    case Data.wiki_map(slug) do
      nil ->
        conn |> put_status(:not_found) |> put_view(BroodwarWeb.ErrorHTML) |> render(:"404")

      map ->
        conn
        |> assign(:page_title, map.name)
        |> assign(:page_description, gettext("%{name} — map details, dimensions, and tournament usage history.", name: map.name))
        |> assign(:breadcrumbs, [{"Wiki", "/wiki"}, {"Maps", "/wiki/maps"}, {map.name, "/wiki/maps/#{slug}"}])
        |> render(:map, map: map)
    end
  end
end
