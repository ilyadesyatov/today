defmodule TodayWeb.TagController do
  use TodayWeb, :controller
  alias Today.Content
  import Phoenix.LiveView.Controller

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    tags = Content.custom_list_tags()
    changeset = Content.change_tag(%Content.Tag{})
    render(conn, "index.html", tags: tags, changeset: changeset, current_user: user)
  end

  def new(conn, _params) do
    live_render(conn, TodayWeb.TagLive.New)
  end

  def show(conn, %{"id" => id}) do
    tag = Content.get_tag!(id)
    render(conn, "show.html", tag: tag)
  end

  def edit(conn, params) do
    live_render(conn, TodayWeb.TagLive.Edit, session: params)
  end

  def delete(conn, %{"id" => id}) do
    tag = Content.get_tag!(id)
    {:ok, _tag} = Content.delete_tag(tag)

    conn
    |> put_flash(:info, "Tag deleted successfully.")
    |> redirect(to: Routes.tag_path(conn, :index))
  end
end
