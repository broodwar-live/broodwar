defmodule BroodwarWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use BroodwarWeb, :html

  embed_templates "page_html/*"

  # -- Race helpers --

  defp race_color("T"), do: "text-race-terran"
  defp race_color("P"), do: "text-race-protoss"
  defp race_color("Z"), do: "text-race-zerg"
  defp race_color(_), do: "text-base-content"

  defp race_bg("T"), do: "bg-race-terran"
  defp race_bg("P"), do: "bg-race-protoss"
  defp race_bg("Z"), do: "bg-race-zerg"
  defp race_bg(_), do: "bg-base-content"

  # -- Stream Card --

  attr :name, :string, required: true
  attr :race, :string, required: true
  attr :viewers, :string, required: true
  attr :title, :string, required: true

  defp stream_card(assigns) do
    ~H"""
    <div class="glass-card rounded-box overflow-hidden group cursor-pointer glow-blue">
      <%!-- Thumbnail placeholder --%>
      <div class="aspect-video bg-base-300/50 relative">
        <div class="absolute inset-0 flex items-center justify-center">
          <.icon name="hero-play-micro" class="size-8 text-base-content/10 group-hover:text-primary/30 transition-colors" />
        </div>
        <div class="absolute top-2.5 left-2.5 badge-live flex items-center gap-1.5 px-2 py-0.5 rounded text-[10px]">
          <span class="w-1.5 h-1.5 rounded-full bg-white animate-live-pulse"></span>
          {gettext("LIVE")}
        </div>
        <div class="absolute bottom-2 right-2 px-2 py-0.5 rounded bg-base-300/80 backdrop-blur-sm text-[10px] text-base-content/60 font-medium">
          {@viewers} {gettext("viewers")}
        </div>
      </div>
      <div class="p-3">
        <div class="flex items-center gap-2">
          <span class={["text-xs font-bold badge-race", race_color(@race)]}>{@race}</span>
          <span class="font-semibold text-sm">{@name}</span>
        </div>
        <p class="text-xs text-base-content/40 mt-0.5 truncate">{@title}</p>
      </div>
    </div>
    """
  end

  # -- Match Row --

  attr :tournament, :string, required: true
  attr :player_a, :string, required: true
  attr :race_a, :string, required: true
  attr :score_a, :integer, required: true
  attr :player_b, :string, required: true
  attr :race_b, :string, required: true
  attr :score_b, :integer, required: true
  attr :map, :string, required: true
  attr :date, :string, required: true

  defp match_row(assigns) do
    assigns = assign(assigns, :winner, if(assigns.score_a > assigns.score_b, do: :a, else: :b))

    ~H"""
    <div class="glass-card rounded-box px-4 py-3 flex items-center gap-4 cursor-pointer glow-blue">
      <%!-- Tournament --%>
      <div class="hidden sm:block w-32 shrink-0">
        <span class="text-[11px] text-primary/50 font-medium">{@tournament}</span>
      </div>

      <%!-- Match result --%>
      <div class="flex-1 flex items-center justify-center gap-3 min-w-0">
        <%!-- Player A --%>
        <div class="flex items-center gap-2 flex-1 justify-end min-w-0">
          <span class={[
            "font-semibold text-sm truncate",
            @winner == :a && "text-base-content",
            @winner != :a && "text-base-content/40"
          ]}>
            {@player_a}
          </span>
          <span class={["text-[10px] font-bold badge-race shrink-0", race_color(@race_a)]}>{@race_a}</span>
        </div>

        <%!-- Score --%>
        <div class="flex items-center gap-1.5 shrink-0 font-stats text-sm">
          <span class={[
            "font-bold",
            @winner == :a && "text-primary",
            @winner != :a && "text-base-content/30"
          ]}>
            {@score_a}
          </span>
          <span class="text-base-content/15">:</span>
          <span class={[
            "font-bold",
            @winner == :b && "text-primary",
            @winner != :b && "text-base-content/30"
          ]}>
            {@score_b}
          </span>
        </div>

        <%!-- Player B --%>
        <div class="flex items-center gap-2 flex-1 min-w-0">
          <span class={["text-[10px] font-bold badge-race shrink-0", race_color(@race_b)]}>{@race_b}</span>
          <span class={[
            "font-semibold text-sm truncate",
            @winner == :b && "text-base-content",
            @winner != :b && "text-base-content/40"
          ]}>
            {@player_b}
          </span>
        </div>
      </div>

      <%!-- Map + Date --%>
      <div class="hidden sm:flex items-center gap-4 shrink-0">
        <span class="text-[11px] text-base-content/25 w-20 text-right">{@map}</span>
        <span class="text-[11px] text-base-content/20 w-12 text-right">{@date}</span>
      </div>
    </div>
    """
  end

  # -- Balance Bar --

  attr :matchup, :string, required: true
  attr :left, :integer, required: true
  attr :right, :integer, required: true

  defp balance_bar(assigns) do
    ~H"""
    <div>
      <div class="flex items-center justify-between text-xs mb-1.5">
        <span class="text-base-content/60 font-semibold text-[11px]">{@matchup}</span>
        <span class="text-base-content/30 font-stats text-[11px]">{@left}% — {@right}%</span>
      </div>
      <div class="flex h-1.5 rounded-full overflow-hidden bg-base-content/5">
        <div class="bg-gradient-to-r from-primary to-primary/70 rounded-l-full" style={"width: #{@left}%"}></div>
        <div class="bg-gradient-to-r from-secondary/70 to-secondary rounded-r-full" style={"width: #{@right}%"}></div>
      </div>
    </div>
    """
  end

  # -- Player Rank --

  attr :rank, :integer, required: true
  attr :name, :string, required: true
  attr :race, :string, required: true
  attr :rating, :integer, required: true

  defp player_rank(assigns) do
    ~H"""
    <div class="flex items-center gap-3">
      <span class={[
        "w-5 text-center text-xs font-bold",
        @rank == 1 && "text-secondary",
        @rank == 2 && "text-base-content/50",
        @rank == 3 && "text-base-content/35",
        @rank > 3 && "text-base-content/20"
      ]}>
        {@rank}
      </span>
      <span class={["text-[10px] font-bold w-4 badge-race", race_color(@race)]}>{@race}</span>
      <span class="flex-1 text-sm font-semibold">{@name}</span>
      <span class="text-[11px] text-base-content/30 font-mono">{@rating}</span>
    </div>
    """
  end

  # -- Upcoming Match --

  attr :tournament, :string, required: true
  attr :round, :string, required: true
  attr :player_a, :string, required: true
  attr :race_a, :string, required: true
  attr :player_b, :string, required: true
  attr :race_b, :string, required: true
  attr :time, :string, required: true

  defp upcoming_match(assigns) do
    ~H"""
    <div class="flex flex-col gap-1.5">
      <span class="text-[10px] text-primary/40 uppercase tracking-widest font-semibold">{@tournament} {@round}</span>
      <div class="flex items-center gap-2 text-sm">
        <span class={["text-[10px] font-bold badge-race", race_color(@race_a)]}>{@race_a}</span>
        <span class="font-semibold">{@player_a}</span>
        <span class="text-base-content/15 text-xs">{gettext("vs")}</span>
        <span class="font-semibold">{@player_b}</span>
        <span class={["text-[10px] font-bold badge-race", race_color(@race_b)]}>{@race_b}</span>
      </div>
      <span class="text-[11px] text-base-content/30">{@time}</span>
    </div>
    """
  end

  # -- Build Card --

  attr :name, :string, required: true
  attr :race, :string, required: true
  attr :matchup, :string, required: true
  attr :description, :string, required: true
  attr :games, :integer, required: true
  attr :winrate, :integer, required: true

  defp build_card(assigns) do
    ~H"""
    <div class="glass-card rounded-box p-5 cursor-pointer glow-blue">
      <div class="flex items-center justify-between mb-3">
        <div class="flex items-center gap-2.5">
          <span class={[
            "w-7 h-7 rounded-lg flex items-center justify-center text-xs font-black text-base-100",
            race_bg(@race)
          ]}>
            {@race}
          </span>
          <span class="font-semibold text-sm">{@name}</span>
        </div>
        <span class="px-2 py-0.5 rounded text-[10px] font-semibold bg-primary/10 text-primary/70">{@matchup}</span>
      </div>
      <p class="text-xs text-base-content/40 leading-relaxed mb-4">{@description}</p>
      <div class="flex items-center gap-4 text-[11px] text-base-content/30">
        <span class="font-medium">{@games} {gettext("games")}</span>
        <span class={[
          "font-semibold",
          @winrate >= 55 && "text-success",
          @winrate < 55 && @winrate >= 50 && "text-base-content/50",
          @winrate < 50 && "text-error"
        ]}>
          {@winrate}% {gettext("winrate")}
        </span>
      </div>
    </div>
    """
  end
end
