# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :checker,
  ecto_repos: [Checker.Repo]

# Configures the endpoint
config :checker, CheckerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "oWXv0wRVT5uypmJzgnDPtytwVblcr2QIar2oT8BcpB38neFDe7xO1JnuxKufBC2F",
  render_errors: [view: CheckerWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Checker.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :ueberauth, Ueberauth,
  providers: [
    facebook: {Ueberauth.Strategy.Facebook, []}
  ]

config :ueberauth, Ueberauth.Strategy.Facebook.OAuth,
  client_id: System.get_env("FACEBOOK_CLIENT_ID"),
  client_secret: System.get_env("FACEBOOK_CLIENT_SECRET")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
