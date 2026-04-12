defmodule Broodwar.Tournaments.Tournament do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tournaments" do
    field :name, :string
    field :short_name, :string
    field :type, :string
    field :year, :integer
    field :season, :integer

    timestamps()
  end

  @required_fields [:name]
  @optional_fields [:short_name, :type, :year, :season]

  @doc false
  def changeset(tournament, attrs) do
    tournament
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
