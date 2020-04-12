defmodule TodayWeb.RegistrationController do
  use TodayWeb, :controller

  alias Today.{UserManager, UserManager.User, UserManager.Guardian}

  def new(conn, _) do
    changeset = UserManager.change_user(%User{})
    maybe_user = Guardian.Plug.current_resource(conn)

    if maybe_user do
      redirect(conn, to: "/protected")
    else
      render(conn, "new.html",
        changeset: changeset,
        action: Routes.registration_path(conn, :register)
      )
    end
  end

  def register(conn, %{"user" => user}) do
    UserManager.create_user(user)
    |> register_reply(conn)
  end

  defp register_reply({:ok, _user}, conn) do
    conn
    |> put_flash(:info, "New User created!")
    |> redirect(to: "/login")
  end

  defp register_reply({:error, reason}, conn) do
    conn
    |> put_flash(
      :error,
      reason.errors
      |> Enum.map(fn {error_name, {error, _}} -> to_string(error_name) <> " " <> error end)
      |> Enum.join(", ")
    )
    |> new(%{})
  end
end

# defmodule TodayWeb.RegistrationController do
#  use TodayWeb, :controller
#
##  alias TodayWeb.User
#  alias Today.{UserManager, UserManager.User, UserManager.Guardian}
#
#  def new(conn, %{"user" => user_params}) do
#    changeset = User.changeset(%User{}, user_params)
#
#    case Repo.insert(changeset) do
#      {:ok, user} ->
#        conn
#        |> put_status(:created)
#        |> put_resp_header("location", user_path(conn, :show, user))
#        |> render("success.json", user: user)
#      {:error, changeset} ->
#        conn
#        |> put_status(:unprocessable_entity)
#        |> render(Today.ChangesetView, "error.json", changeset: changeset)
#    end
#  end
# end
