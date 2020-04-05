defmodule TodayWeb.PageLive.Index do
  use Phoenix.LiveView
  use Agent
  alias Today.Content
  alias TodayWeb.PageView

  def render(assigns) do
    PageView.render("index.html", assigns)
  end

  def mount(conn, _session, socket) do
    all_posts = init_state(%{all_posts: Content.list_posts})
    {:ok, assign(socket, all_posts: all_posts, conn: conn)}
  end

  def handle_params(params, _url, socket) do
    posts = Content.list_posts(params)
    {:noreply, socket |> assign(posts: posts, selected_tag: params["tag"])}
  end

  def handle_params(_params, _url, socket) do
    posts = Content.list_posts
    {:noreply, socket |> assign(posts: posts) }
  end

  def handle_event("select", %{"select_tag" => %{"tag" => ""}}, socket) do
    {:noreply, assign(socket, posts: get_state(:all_posts))}
  end

  def handle_event("select", %{"select_tag" => %{"tag" => tag}}, socket) do
    selected_posts = Enum.filter(get_state(:all_posts), fn post -> post.tag.name == tag end)
    {:noreply, assign(socket, selected_tag: tag, posts: selected_posts)}
  end

  defp init_state(state) do
    Agent.start_link(fn -> state end, name: ComponentState)
  end

  defp get_state(attr) do
    Agent.get(ComponentState, &Map.get(&1, attr))
  end
end
