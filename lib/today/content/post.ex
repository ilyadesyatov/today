defmodule Today.Content.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    belongs_to :user, Today.UserManager.User
    belongs_to :tag, Today.Content.Tag
    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:body, :tag_id])
    |> validate_required([:body, :tag_id])
  end
end
