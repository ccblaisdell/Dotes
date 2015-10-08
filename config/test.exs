use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :dotes, Dotes.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :dotes, Dotes.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "dotes",
  password: "",
  database: "dotes_test",
  pool: Ecto.Adapters.SQL.Sandbox