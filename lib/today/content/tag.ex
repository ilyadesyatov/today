defmodule Today.Content.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :name, :string
    has_many :posts, Today.Content.Post, foreign_key: :tag_id
    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name])
    |> validate_format(:name, ~r/^[a-z0-9_\.]*$/,
      message: "only letters, numbers, points, and underscores please!"
    )
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
