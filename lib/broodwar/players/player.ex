defmodule Broodwar.Players.Player do
  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field :name, :string
    field :aliases, {:array, :string}, default: []
    field :race, :string
    field :country, :string
    field :rating, :integer

    timestamps()
  end

  @required_fields [:name]
  @optional_fields [:aliases, :race, :country, :rating]
  @valid_races ~w(T P Z R)

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:race, @valid_races)
    |> unique_constraint(:name)
  end
end
