defmodule TodayWeb.TagLive.Edit do
  use Phoenix.LiveView

  alias TodayWeb.Router.Helpers, as: Routes
  alias Today.Content

  def render(assigns), do: Phoenix.View.render(TodayWeb.TagView, "form.html", assigns)

  def mount(_params, %{"id" => id}, socket) do
    tag = Content.get_tag!(id)

    {:ok,
     assign(socket, %{
       tag: tag,
       changeset: Content.change_tag(tag)
     })}
  end

  def handle_event("validate", %{"tag" => params}, socket) do
    changeset =
      socket.assigns.tag
      |> Content.change_tag(params)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"tag" => tag_params}, socket) do
    case Content.update_tag(socket.assigns.tag, tag_params) do
      {:ok, _tag} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tag updated successfully.")
         |> redirect(to: Routes.tag_path(socket, :index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
