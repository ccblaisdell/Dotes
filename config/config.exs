# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Load system env vars from application.config, only used for development
# This cannot be in dev.exs because we need the environment in this file
if Mix.env == :dev do
  file = Path.join(__DIR__, "application.config")

  case File.read(file) do
    {:ok, contents} ->
      String.split(contents, "\n", trim: true)
      |> Enum.each(fn line ->
           [key, value] = String.split(line, "=")
           System.put_env(key, value)
         end)
    {:error, _} -> nil
  end
end

# Configures the endpoint
config :dotes, Dotes.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "qiZYvU2SL6L+CM/uiOeigy816Ix3x4J9vnBPHH6GKexCxh077szCh+hjSpzCxICL",
  render_errors: [accepts: ["html"]],
  pubsub: [name: Dotes.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

config :dotes, ecto_repos: [Dotes.Repo]
