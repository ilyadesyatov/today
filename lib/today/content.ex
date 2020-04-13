defmodule Today.Content do
  @moduledoc """
  The Content context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Today.Repo

  alias Today.Content.{Post, Tag}
  alias Today.UserManager.User

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts(params) do
    tags =
      (Map.has_key?(params, :tag) && [Map.get(params, :tag)]) ||
        from(tag in Tag, select: tag.name) |> Repo.all()

    users =
      (Map.has_key?(params, :user) && [Map.get(params, :user)]) ||
        from(u in User, select: u.username) |> Repo.all()

    start_at = Map.get(params, :date, "1800-01-01") |> Date.from_iso8601!()
    end_at = Map.get(params, :date, "2200-01-01") |> Date.from_iso8601!()

    Repo.all(
      from(p in Post,
        join: t in "tags",
        on: p.tag_id == t.id,
        join: u in "users",
        on: p.user_id == u.id,
        where:
          t.name in ^tags and u.username in ^users and
            fragment("?::date", p.inserted_at) >= ^start_at and
            fragment("?::date", p.inserted_at) <= ^end_at,
        order_by: [desc: p.inserted_at],
        preload: [:user, :tag]
      )
    )
  end

  def list_posts do
    Repo.all(
      from(p in Post,
        join: t in "tags",
        on: p.tag_id == t.id,
        join: u in "users",
        on: p.user_id == u.id,
        order_by: [desc: p.inserted_at],
        preload: [:user, :tag]
      )
    )
  end

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def user_list_posts(user, params) do
    tags =
      (Map.has_key?(params, :tag) && [Map.get(params, :tag)]) ||
        from(tag in Tag, select: tag.name) |> Repo.all()

    start_at = Map.get(params, :date, "1800-01-01") |> Date.from_iso8601!()
    end_at = Map.get(params, :date, "2200-01-01") |> Date.from_iso8601!()

    Repo.all(
      from(p in Post,
        join: t in assoc(p, :tag),
        on: p.tag_id == t.id,
        where:
          p.user_id == ^user.id and t.name in ^tags and
            fragment("?::date", p.inserted_at) >= ^start_at and
            fragment("?::date", p.inserted_at) <= ^end_at,
        order_by: [desc: p.inserted_at],
        preload: [:user, :tag]
      )
    )
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id) |> Repo.preload([:user])

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a post by user.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_post(user, attrs \\ %{}) do
    updated_attrs = Map.merge(attrs, %{"tag_id" => String.to_integer(attrs["tag_id"])})

    Ecto.build_assoc(
      user,
      :posts,
      Map.new(updated_attrs, fn {k, v} -> {String.to_atom(k), v} end)
    )
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{source: %Post{}}

  """
  def change_post(%Post{} = post) do
    Post.changeset(post, %{})
  end

  @doc """
  Returns the list of tags.

  ## Examples

      iex> list_tags()
      [%Tag{}, ...]

  """
  def list_tags do
    Repo.all(Tag)
  end

  @doc """
  Gets a single tag.

  Raises `Ecto.NoResultsError` if the Tag does not exist.

  ## Examples

      iex> get_tag!(123)
      %Tag{}

      iex> get_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tag!(id), do: Repo.get!(Tag, id)

  @doc """
  Creates a tag.

  ## Examples

      iex> create_tag(%{field: value})
      {:ok, %Tag{}}

      iex> create_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tag(attrs \\ %{}) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tag.

  ## Examples

      iex> update_tag(tag, %{field: new_value})
      {:ok, %Tag{}}

      iex> update_tag(tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tag(%Tag{} = tag, attrs) do
    tag
    |> Tag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tag.

  ## Examples

      iex> delete_tag(tag)
      {:ok, %Tag{}}

      iex> delete_tag(tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tag(%Tag{} = tag) do
    Repo.delete(tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tag changes.

  ## Examples

      iex> change_tag(tag)
      %Ecto.Changeset{source: %Tag{}}

  """
  def change_tag(tag, attrs \\ %{}) do
    Tag.changeset(tag, attrs)
  end
end
