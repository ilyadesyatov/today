defmodule TodayWeb.Router do
  use TodayWeb, :router
  import Phoenix.LiveView.Router
  import Phoenix.LiveDashboard.Router
  import Plug.BasicAuth

  pipeline :admins_only do
    plug :basic_auth, username: "admin", password: System.get_env("LIVE_DASHBOARD_PASSWORD")
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {TodayWeb.LayoutView, :root}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Our pipeline implements "maybe" authenticated. We'll use the `:ensure_auth` below for when we need to make sure someone is logged in.
  pipeline :auth do
    plug Today.UserManager.Pipeline
  end

  # We use ensure_auth to fail if there is no one logged in
  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  scope "/", TodayWeb do
    pipe_through [:browser, :auth, :ensure_auth]

    get "/protected", PageController, :protected
    resources "/posts", PostController, except: [:show, :index]
    resources "/tags", TagController

    live "/posts", PageLive.Index, :posts
    live "/posts-auto-scroll", PageLive.IndexAutoScroll
  end

  scope "/" do
    pipe_through [:browser, :admins_only]
    live_dashboard "/dashboard"
  end

  scope "/", TodayWeb do
    pipe_through [:browser, :auth]

    get "/login", SessionController, :new
    post "/login", SessionController, :login
    get "/logout", SessionController, :logout

    get "/registration", RegistrationController, :new
    post "/registration", RegistrationController, :register

    resources "/posts", PostController, only: [:show]

    live "/", PageLive.Index, :index
  end
end
