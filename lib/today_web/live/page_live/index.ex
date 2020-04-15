defmodule TodayWeb.PageLive.Index do
  use Phoenix.LiveView
  alias Today.{Content, UserManager.Guardian}
  alias TodayWeb.PageView

  def render(assigns), do: PageView.render("index.html", assigns)

  def mount(conn, session, socket),
    do: {:ok, assign(socket, current_user: fetch_current_user(session), conn: conn)}

  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> assign(selected: %{tag: params["tag"], user: params["user"], date: params["date"]})
     |> assign_posts()}
  end

  def handle_event("select", %{"select_tag" => %{"tag" => tag}}, socket) do
    prompt_tag =
      case tag do
        "" -> nil
        _ -> tag
      end

    {:noreply, socket |> update_selected(%{tag: prompt_tag}) |> assign_posts()}
  end

  def handle_event("search", %{"user" => user}, socket) do
    {:noreply, socket |> update_selected(%{user: user}) |> assign_posts()}
  end

  def handle_event("search", %{"date" => date}, socket) do
    {:noreply, socket |> update_selected(%{date: date}) |> assign_posts()}
  end

  def handle_event("search", %{"tag" => tag}, socket) do
    {:noreply, socket |> update_selected(%{tag: tag}) |> assign_posts()}
  end

  def handle_event("cancel_date", _, socket) do
    {:noreply, socket |> delete_selected(:date) |> assign_posts()}
  end

  def handle_event("cancel_user", _, socket) do
    {:noreply, socket |> delete_selected(:user) |> assign_posts()}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    with post <- Content.get_post!(id),
         {:ok, _post} <- Content.delete_post(post) do
      {:noreply, socket |> put_flash(:info, "Post was deleted!") |> assign_posts()}
    else
      # :error -> {:noreply, socket |> put_flash(:error, "post was ton deleted!")}
      _ -> {:noreply, socket |> put_flash(:error, "Post was not deleted!")}
    end
  end

  defp fetch_current_user(session) do
    with {:ok, token} <- Map.fetch(session, "guardian_default_token"),
         {:ok, %Today.UserManager.User{} = user, _} <- Guardian.resource_from_token(token) do
      user
    else
      # :error -> redirect to login path
      _ -> nil
    end
  end

  defp update_selected(socket, value) do
    update(socket, :selected, fn selected -> Map.merge(selected, value) end)
  end

  defp delete_selected(socket, value) do
    update(socket, :selected, fn selected -> Map.delete(selected, value) end)
  end

  defp assign_posts(socket) do
    query_params =
      case socket.assigns.live_action do
        :index ->
          remove_nil(socket.assigns.selected)

        :posts ->
          Map.merge(remove_nil(socket.assigns.selected), %{
            user: socket.assigns.current_user.username
          })
      end

    assign(socket, posts: Content.list_posts(query_params))
  end

  def remove_nil(collection) do
    for {k, v} <- collection, v != nil, into: %{}, do: {k, v}
  end
end
