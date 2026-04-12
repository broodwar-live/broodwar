defmodule BroodwarWeb.TournamentHTML do
  use BroodwarWeb, :html

  embed_templates "tournament_html/*"

  def t(entry, field) do
    locale = Gettext.get_locale(BroodwarWeb.Gettext)
    ko_field = :"#{field}_ko"

    if locale == "ko" && Map.has_key?(entry, ko_field) do
      Map.get(entry, ko_field) || Map.get(entry, field)
    else
      Map.get(entry, field)
    end
  end

  def status_badge(:live) do
    {"bg-error/15 text-error border-error/20", gettext("LIVE")}
  end

  def status_badge(:active) do
    {"bg-success/15 text-success border-success/20", gettext("Active")}
  end

  def status_badge(:retired) do
    {"bg-base-content/10 text-base-content/40 border-base-content/10", gettext("Retired")}
  end

  def status_badge(:completed) do
    {"bg-base-content/5 text-base-content/30 border-base-content/5", ""}
  end

  def season_label(season) do
    "S#{season.season}"
  end

  def format_prize(nil), do: "—"
  def format_prize(""), do: "—"

  def format_prize(amount) when is_binary(amount) do
    digits = String.replace(amount, ~r/[^\d]/, "")

    formatted =
      digits
      |> String.reverse()
      |> String.replace(~r/(\d{3})(?=\d)/, "\\1,")
      |> String.reverse()

    "₩#{formatted}"
  end

  def format_prize(amount), do: "#{amount}"

  @doc """
  Extracts bracket matches from the full match list and organizes them
  into rounds for visualization. Assumes standard 8-player single elimination.
  """
  def extract_bracket(matches) do
    bracket_matches =
      matches
      |> Enum.filter(fn m ->
        ctx = m["context"] || ""
        String.contains?(ctx, "Playoffs") or String.contains?(ctx, "Bracket") or
          String.contains?(ctx, "Quarterfinal") or String.contains?(ctx, "Semifinal") or
          String.contains?(ctx, "Finals (Bo")
      end)

    # For ASL-style brackets: first 4 = QF, next 2 = SF, last 1 = Finals
    case length(bracket_matches) do
      n when n >= 7 ->
        [
          %{name: "Quarterfinals", matches: Enum.slice(bracket_matches, 0, 4)},
          %{name: "Semifinals", matches: Enum.slice(bracket_matches, 4, 2)},
          %{name: "Finals", matches: Enum.slice(bracket_matches, 6, 1)}
        ]

      n when n >= 3 ->
        [
          %{name: "Semifinals", matches: Enum.slice(bracket_matches, 0, n - 1)},
          %{name: "Finals", matches: Enum.slice(bracket_matches, n - 1, 1)}
        ]

      n when n >= 1 ->
        [%{name: "Finals", matches: bracket_matches}]

      _ ->
        []
    end
  end

  attr :rounds, :list, required: true

  def bracket(assigns) do
    ~H"""
    <div class="bracket">
      <div :for={{round, round_idx} <- Enum.with_index(@rounds)} class="bracket-round">
        <div class="bracket-round-title">{round.name}</div>
        <div class="flex-1 flex flex-col justify-around">
          <div :for={match <- round.matches} class="bracket-match relative">
            <% p1_won = match["winner"] == match["opponent1"] %>
            <% p2_won = match["winner"] == match["opponent2"] %>
            <% [s1, s2] = String.split(match["score"] || "0-0", "-") %>

            <div class={["bracket-player", p1_won && "winner"]}>
              <span class="bracket-name">{match["opponent1"]}</span>
              <span class="bracket-score">{s1}</span>
            </div>
            <div class={["bracket-player", p2_won && "winner"]}>
              <span class="bracket-name">{match["opponent2"]}</span>
              <span class="bracket-score">{s2}</span>
            </div>

            <%!-- Connector line to next round --%>
            <div :if={round_idx < length(@rounds) - 1} class="bracket-connector bracket-connector-line absolute right-[-16px] top-1/2 w-4 border-t border-primary/15"></div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
