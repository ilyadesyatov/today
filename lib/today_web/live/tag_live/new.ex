defmodule TodayWeb.TagLive.New do
  use Phoenix.LiveView

  alias TodayWeb.Router.Helpers, as: Routes
  alias Today.Content

  def render(assigns), do: Phoenix.View.render(TodayWeb.TagView, "form.html", assigns)

  def mount(_params, _session, socket) do
    changeset = Content.change_tag(%Content.Tag{})
    {:ok, assign(socket, changeset: changeset)}
  end

  def handle_event("validate", %{"tag" => tag_params}, socket) do
    changeset =
      %Content.Tag{}
      |> Content.change_tag(tag_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"tag" => tag_params}, socket) do
    case Content.create_tag(tag_params) do
      {:ok, _tag} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tag created")
         |> redirect(to: Routes.tag_path(socket, :index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
