# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :elixir_anki, ecto_repos: [ElixirAnki.Repo]

# Configures the endpoint
config :elixir_anki, ElixirAnkiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "V8xqgwn8AAaxj2JLQ7G4fy5S7+coHUi6qTeiYzbhOZKqhGZTA0NR8SfhYwOYb3Q1",
  render_errors: [view: ElixirAnkiWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ElixirAnki.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :ex_admin,
  repo: ElixirAnki.Repo,
  module: ElixirAnkiWeb,
  modules: [
    ElixirAnkiWeb.ExAdmin.Dashboard,
    ElixirAnkiWeb.ExAdmin.HighSchooler,
    ElixirAnkiWeb.ExAdmin.Like,
    ElixirAnkiWeb.ExAdmin.Friend,
    ElixirAnkiWeb.ExAdmin.DateRange
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :xain, :after_callback, {Phoenix.HTML, :raw}
