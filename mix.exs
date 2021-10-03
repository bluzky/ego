defmodule Ego.MixProject do
  use Mix.Project

  def project do
    [
      app: :ego,
      version: "0.1.0",
      elixir: "~> 1.12",
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      "assets.deploy": [
        "esbuild default --minify",
        "sass default --no-source-map --style=compressed",
        "phx.digest"
      ],
      escript: [main_module: Ego.CLI, app: nil],
      docs: docs(),
      name: "Ego",
      description: description(),
      source_url: "https://github.com/bluzky/ego",
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      # mod: {Ego.Server.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp docs() do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end

  defp package() do
    [
      maintainers: ["Dung Nguyen"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/bluzky/ego"}
    ]
  end

  defp description() do
    """
    Static site generator for every one
    """
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.5", runtime: false},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:cachex, "~> 3.4"},
      {:slugify, "~> 1.3"},
      {:solid, github: "bluzky/solid", branch: "ego"},
      # {:solid, path: "../solid"},
      {:yaml_elixir, "~> 2.8"},
      {:earmark, ">= 1.4.15"},
      {:makeup, "~> 1.0"},
      {:ex_doc, "~> 0.21", only: :docs},
      {:makeup_elixir, ">= 0.0.0"},
      {:file_system, "~> 0.2"},
      {:unzip, "~> 0.6"},
      {:zstream, "~> 0.6.0"}
      # {:dart_sass, "~> 0.1"}
    ]
  end
end
