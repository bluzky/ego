defmodule Ego.MixProject do
  use Mix.Project

  def project do
    [
      app: :ego,
      version: "0.1.0",
      elixir: "~> 1.12",
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Ego.Server.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      # {:solid, github: "bluzky/solid", branch: "custom"}
      {:phoenix, "~> 1.5.8"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:cachex, "~> 3.4"},
      {:solid, path: "../solid"},
      {:yaml_elixir, "~> 2.8"},
      {:earmark, ">= 1.4.15"},
      {:makeup, "~> 1.0"},
      {:ex_doc, "~> 0.21", only: :docs},
      {:makeup_elixir, ">= 0.0.0"}
    ]
  end
end
