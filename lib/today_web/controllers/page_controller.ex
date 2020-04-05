defmodule TodayWeb.PageController do
  use TodayWeb, :controller
  alias Today.Content

  def protected(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    render(conn, "protected.html", current_user: user)
  end
end
