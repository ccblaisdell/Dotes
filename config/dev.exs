use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :dotes, DotesWeb.Endpoint,
  http: [port: System.get_env("PORT") || 4000],
  debug_errors: true,
  code_reloader: true,
  cache_static_lookup: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
                   cd: Path.expand("../assets", __DIR__)]]

# Watch static and templates for browser reloading.
config :dotes, DotesWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif)$},
      ~r{web/dotes_web/views/.*(ex)$},
      ~r{web/dotes_web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Configure your database
config :dotes, Dotes.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "dotes",
  password: "",
  database: "dotes_dev",
  size: 10 # The amount of database connections in the pool
