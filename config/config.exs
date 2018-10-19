# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :train2,
  ecto_repos: [Train2.Repo]

# Configures the endpoint
config :train2, Train2Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "XrUbCt0U6nhn69ujudMlgh3G2Kilw9K30jwFLZANX+JEZeL5AvICuN1n6DF7A25P",
  render_errors: [view: Train2Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Train2.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
