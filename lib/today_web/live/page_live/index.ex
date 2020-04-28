defmodule TodayWeb.PageLive.Index do
  use Phoenix.LiveView

  alias Today.{Content, UserManager.Guardian}
  alias TodayWeb.PageView

  @page 1
  @per_page 5
  @limit 5

  def render(assigns), do: PageView.render("index.html", assigns)

  def mount(conn, session, socket) do
    {:ok, assign(socket, current_user: fetch_current_user(session), conn: conn)}
  end

  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> assign(selected: %{tag: params["tag"], user: params["user"], date: params["date"]})
     |> update_action("append")
     |> assign_posts()}
  end

  def handle_event("select", %{"select_tag" => %{"tag" => tag}}, socket) do
    prompt_tag =
      case tag do
        "" -> nil
        _ -> tag
      end

    {:noreply,
     socket |> update_action("replace") |> update_selected(%{tag: prompt_tag}) |> assign_posts()}
  end

  def handle_event("search", %{"user" => user}, socket) do
    {:noreply,
     socket |> update_action("replace") |> update_selected(%{user: user}) |> assign_posts()}
  end

  def handle_event("search", %{"date" => date}, socket) do
    {:noreply,
     socket |> update_action("replace") |> update_selected(%{date: date}) |> assign_posts()}
  end

  def handle_event("search", %{"tag" => tag}, socket) do
    {:noreply,
     socket |> update_action("replace") |> update_selected(%{tag: tag}) |> assign_posts()}
  end

  def handle_event("cancel_date", _, socket) do
    {:noreply, socket |> delete_selected(:date) |> assign_posts()}
  end

  def handle_event("cancel_user", _, socket) do
    {:noreply, socket |> delete_selected(:user) |> assign_posts()}
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply,
     socket
       |> update_selected(%{
         page: assigns.selected.page + 1,
         action: "append",
         per_page: @per_page,
         limit: @limit
       })
       |> assign_posts()
    }
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

  defp update_action(socket, type) do
    values = %{action: type, page: @page, per_page: @per_page, limit: @limit}
    update(socket, :selected, fn selected -> Map.merge(selected, values) end)
  end

  defp update_selected(socket, value) do
    update(socket, :selected, fn selected -> Map.merge(selected, value) end)
  end

  defp delete_selected(socket, value) do
    update(socket, :selected, fn selected -> Map.delete(selected, value) end)
  end

  def handle_event("delete", %{"id" => id, "per-page" => per_page, "page" => page}, socket) do
    with post <- Content.get_post!(id),
         {:ok, _post} <- Content.delete_post(post) do
      new_page = String.to_integer(page)
      new_per_page = String.to_integer(per_page)

      new_limit =
        cond do
          socket.assigns.selected.limit == @limit -> new_page * new_per_page
          socket.assigns.selected.limit == new_page * new_per_page -> new_page * new_per_page
          true -> socket.assigns.selected.limit
        end

      {:noreply,
       socket
       |> update_selected(%{action: "replace", limit: new_limit, per_page: 0, page: 0})
       |> assign_posts()
       |> put_flash(:info, "Post was deleted!")}
    else
      # :error -> {:noreply, socket |> put_flash(:error, "post was ton deleted!")}
      _ -> {:noreply, socket |> put_flash(:error, "Post was not deleted!")}
    end
  end

  defp assign_posts(%{assigns: assigns} = socket) do
    query_params =
      case assigns.live_action do
        :index ->
          remove_nil(assigns.selected)

        :posts ->
          Map.merge(remove_nil(assigns.selected), %{
            user: assigns.current_user.username
          })
      end

    posts = Content.list_posts(query_params)
    assign(socket, posts: posts)
  end

  def remove_nil(collection) do
    for {k, v} <- collection, v != nil, into: %{}, do: {k, v}
  end
end
