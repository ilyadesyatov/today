defmodule Today.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :body, :text
      add :user_id, references(:users, on_delete: :nothing)
      add :tag_id, references(:tags, on_delete: :nothing)
      timestamps()
    end

    create index(:posts, [:user_id])
    create index(:posts, [:tag_id])
  end
end
