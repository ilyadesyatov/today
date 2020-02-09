defmodule TodayWeb.SessionHelpers do
  use Phoenix.HTML
  alias Today.UserManager.Guardian

  def current_user(conn) do
    Guardian.Plug.current_resource(conn)
  end

  def current_user?(conn, user) do
    user == current_user(conn)
  end

  def logged_in?(conn) do
    Guardian.Plug.authenticated?(conn)
  end
end
