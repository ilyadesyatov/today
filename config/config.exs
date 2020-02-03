# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :today,
  ecto_repos: [Today.Repo]

# Configures the endpoint
config :today, TodayWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "JLJalDeSeQWa/2uyn2UCvz2GE39C69tPIcxBqQ21Jg8+4LI7tROiXLOVfdLicwCS",
  render_errors: [view: TodayWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Today.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :today, Today.UserManager.Guardian,
       issuer: "today",
       secret_key: "1Ev9uEisbb9UEyS5WPtG6DXE4Xd2QnRroq26LPx1FVHsLn6PQFNTTp5mkbkaG2EJ"


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
