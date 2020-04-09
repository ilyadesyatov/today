defmodule TodayWeb.PageController do
  use TodayWeb, :controller
  alias Today.Content
  import Phoenix.LiveView.Controller

  def index(conn, params) do
    live_render(conn, TodayWeb.PageLive.Index)
  end

  def protected(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    render(conn, "protected.html", current_user: user)
  end
end
