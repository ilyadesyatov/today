defmodule TodayWeb.PageController do
  use TodayWeb, :controller
  alias Today.Content

  def index(conn, _params) do
    posts = Content.list_posts()
    render(conn, "index.html", posts: posts)
  end

  def protected(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    render(conn, "protected.html", current_user: user)
  end
end
