defmodule TodayWeb.PageLive.Post do
  use Phoenix.LiveComponent

  alias TodayWeb.PageView

  def render(assigns) do
    PageView.render("post.html", assigns)
  end

  def mount(socket) do
    {:ok, socket}
  end
end
