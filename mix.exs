defmodule Dotes.Mixfile do
  use Mix.Project

  def project do
    [app: :dotes,
     version: "0.0.1",
     elixir: "~> 1.1",
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
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:phoenix, "~> 1.1"},
     {:postgrex, "~> 0.11.0"},
     {:phoenix_ecto, "~> 2.0"},
     {:phoenix_html, "~> 2.3"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:scrivener, "~> 1.0"},
     {:cowboy, "~> 1.0"},
     {:timex, "~> 0.19"},
    #  {:dota, git: "https://github.com/ccblaisdell/dota-elixir.git", tag: "v0.0.14"}]
     {:dota, path: "../dota"}]
  end
end
