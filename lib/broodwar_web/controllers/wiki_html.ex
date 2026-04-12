defmodule BroodwarWeb.WikiHTML do
  use BroodwarWeb, :html

  embed_templates "wiki_html/*"

  def race_color("terran"), do: "text-race-terran"
  def race_color("protoss"), do: "text-race-protoss"
  def race_color("zerg"), do: "text-race-zerg"
  def race_color(_), do: "text-base-content"

  def race_bg("terran"), do: "bg-race-terran"
  def race_bg("protoss"), do: "bg-race-protoss"
  def race_bg("zerg"), do: "bg-race-zerg"
  def race_bg(_), do: "bg-base-content"

  def race_border("terran"), do: "border-race-terran/30"
  def race_border("protoss"), do: "border-race-protoss/30"
  def race_border("zerg"), do: "border-race-zerg/30"
  def race_border(_), do: "border-base-content/10"

  def race_bg_subtle("terran"), do: "bg-race-terran/5"
  def race_bg_subtle("protoss"), do: "bg-race-protoss/5"
  def race_bg_subtle("zerg"), do: "bg-race-zerg/5"
  def race_bg_subtle(_), do: "bg-base-content/5"

  def unit_type_label(:ground), do: "Ground"
  def unit_type_label(:air), do: "Air"
  def unit_type_label(_), do: "Unit"

  attr :stat, :string, required: true
  attr :value, :any, required: true

  def stat_row(assigns) do
    ~H"""
    <div class="flex items-center justify-between text-sm">
      <dt class="flex items-center gap-1.5 text-base-content/50">
        <img src={stat_icon(@stat)} alt={@stat} class="w-4 h-4 inline-block" />
        <span>{stat_label(@stat)}</span>
      </dt>
      <dd class="font-mono">{@value}</dd>
    </div>
    """
  end

  defp stat_icon("minerals"), do: "/images/wiki/stats/minerals.png"
  defp stat_icon("gas"), do: "/images/wiki/stats/gas.png"
  defp stat_icon("supply"), do: "/images/wiki/stats/supply.png"
  defp stat_icon("hp"), do: "/images/wiki/stats/hp.png"
  defp stat_icon("shields"), do: "/images/wiki/stats/shields.png"
  defp stat_icon("armor"), do: "/images/wiki/stats/armor.png"
  defp stat_icon("damage"), do: "/images/wiki/stats/damage.png"
  defp stat_icon("energy"), do: "/images/wiki/stats/energy.gif"
  defp stat_icon(_), do: ""

  defp stat_label("minerals"), do: "Minerals"
  defp stat_label("gas"), do: "Gas"
  defp stat_label("supply"), do: "Supply"
  defp stat_label("hp"), do: "HP"
  defp stat_label("shields"), do: "Shields"
  defp stat_label("armor"), do: "Armor"
  defp stat_label("damage"), do: "Damage"
  defp stat_label("energy"), do: "Energy"
  defp stat_label(other), do: other

  def tileset_color("Jungle World"), do: "text-success"
  def tileset_color("Space Platform"), do: "text-info"
  def tileset_color("Desert"), do: "text-warning"
  def tileset_color("Badlands"), do: "text-error"
  def tileset_color("Twilight"), do: "text-primary"
  def tileset_color("Ice"), do: "text-info"
  def tileset_color(_), do: "text-base-content/60"

  def players_label(2), do: "1v1"
  def players_label(3), do: "3-way"
  def players_label(4), do: "4-player"
  def players_label(n), do: "#{n}-player"

  attr :race, :map, required: true

  def race_card(assigns) do
    ~H"""
    <a
      href={"/wiki/races/#{@race.slug}"}
      class={[
        "group rounded-box border p-6 transition-colors hover:border-primary/30",
        "bg-base-100 border-base-content/5"
      ]}
    >
      <div class="flex items-center gap-3 mb-3">
        <div class={[
          "w-10 h-10 rounded-lg flex items-center justify-center text-lg font-bold text-base-100",
          race_bg(@race.slug)
        ]}>
          {@race.letter}
        </div>
        <h3 class="text-lg font-semibold group-hover:text-primary transition-colors">{@race.name}</h3>
      </div>
      <p class="text-sm text-base-content/50 leading-relaxed">{@race.tagline}</p>
    </a>
    """
  end
end
