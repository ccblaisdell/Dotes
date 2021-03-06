defmodule Dotes.Mixfile do
  use Mix.Project

  def project do
    [app: :dotes,
     version: "0.0.1",
     elixir: "~> 1.6",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {Dotes, []},
     applications: [:phoenix, :phoenix_html, :cowboy, :logger,
                    :phoenix_ecto, :postgrex, :httpoison,
                    :dota, :tzdata]]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:phoenix, "~> 1.3.0"},
     {:postgrex, "~> 0.11.2"},
     {:phoenix_ecto, "~> 3.0"},
     {:phoenix_html, "~> 2.6"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:phoenix_pubsub, "~> 1.0"},
     {:scrivener_ecto, "~> 1.0"},
     {:cowboy, "~> 1.0"},
     {:timex, "~> 3.0.4"},
     {:poison, "~> 3.0", override: true},
     {:dota, git: "https://github.com/ccblaisdell/dota-elixir.git", tag: "v0.0.17"}]
     # {:dota, path: "../dota"}]
  end
  
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
