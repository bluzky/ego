defmodule Ego.MixProject do
  use Mix.Project

  @elixir_requirement "~> 1.13"
  @app_elixir_version "1.13.2"
  @version "0.5.2"

  def project do
    [
      app: :ego,
      version: @version,
      elixir: @elixir_requirement,
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: with_lock(target_deps(Mix.target()) ++ deps()),
      escript: escript(),
      docs: docs(),
      name: "Ego",
      description: description(),
      elixirc_paths: elixirc_paths(Mix.env()),
      source_url: "https://github.com/bluzky/ego",
      package: package(),
      default_release: :ego,
      releases: releases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      # mod: {Ego.Application, []},
      extra_applications:
        [:logger, :runtime_tools, :os_mon, :inets, :ssl, :xmerl] ++
          extra_applications(Mix.target()),
      env: Application.get_all_env(:ego)
    ]
  end

  defp extra_applications(:app), do: [:wx]
  defp extra_applications(_), do: []

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

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

  defp escript do
    [
      main_module: EgoCLI,
      app: nil
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.5"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:cachex, "~> 3.4"},
      {:slugify, "~> 1.3"},
      {:solid, github: "bluzky/solid", branch: "ego"},
      # {:solid, path: "../solid"},
      {:yaml_elixir, "~> 2.8"},
      {:earmark, ">= 1.4.20"},
      {:makeup, "~> 1.0"},
      {:ex_doc, "~> 0.21", only: :docs},
      {:makeup_elixir, ">= 0.0.0"},
      {:file_system, "~> 0.2"},
      {:unzip, "~> 0.6"},
      {:zstream, "~> 0.6.0"}
      # {:dart_sass, "~> 0.1"}
    ]
  end

  defp target_deps(:app), do: [{:app_builder, path: "app_builder"}]
  defp target_deps(_), do: []

  @lock (with {:ok, contents} <- File.read("mix.lock"),
              {:ok, quoted} <- Code.string_to_quoted(contents, warn_on_unnecessary_quotes: false),
              {%{} = lock, _binding} <- Code.eval_quoted(quoted, []) do
           for {dep, hex} when elem(hex, 0) == :hex <- lock,
               do: {dep, elem(hex, 2)},
               into: %{}
         else
           _ -> %{}
         end)

  defp with_lock(deps) do
    for dep <- deps do
      name = elem(dep, 0)
      put_elem(dep, 1, @lock[name] || elem(dep, 1))
    end
  end

  ## Releases

  defp releases do
    [
      ego: [
        include_executables_for: [:unix],
        include_erts: false,
        rel_templates_path: "rel/server",
        steps: [:assemble, &remove_cookie/1]
      ],
      mac_app: [
        include_executables_for: [:unix],
        include_erts: false,
        rel_templates_path: "rel/app",
        steps: [:assemble, &remove_cookie/1, &standalone_erlang_elixir/1, &build_mac_app/1]
      ],
      mac_app_dmg: [
        include_executables_for: [:unix],
        include_erts: false,
        rel_templates_path: "rel/app",
        steps: [:assemble, &remove_cookie/1, &standalone_erlang_elixir/1, &build_mac_app_dmg/1]
      ]
    ]
  end

  defp remove_cookie(release) do
    File.rm!(Path.join(release.path, "releases/COOKIE"))
    release
  end

  defp standalone_erlang_elixir(release) do
    Code.require_file("rel/app/standalone.exs")

    release
    |> Standalone.copy_erlang()
    |> Standalone.copy_elixir(@app_elixir_version)
  end

  @app_options [
    name: "Livebook",
    version: @version,
    logo_path: "rel/app/mac-icon.png",
    url_schemes: ["livebook"],
    additional_paths: ["/rel/vendor/bin", "/rel/vendor/elixir/bin"],
    document_types: [
      %{name: "LiveMarkdown", role: "Editor", extensions: ["livemd"]}
    ]
  ]

  defp build_mac_app(release) do
    AppBuilder.build_mac_app(release, @app_options)
  end

  defp build_mac_app_dmg(release) do
    options =
      [
        codesign: [
          identity: System.fetch_env!("CODESIGN_IDENTITY")
        ],
        notarize: [
          team_id: System.fetch_env!("NOTARIZE_TEAM_ID"),
          apple_id: System.fetch_env!("NOTARIZE_APPLE_ID"),
          password: System.fetch_env!("NOTARIZE_PASSWORD")
        ]
      ] ++ @app_options

    AppBuilder.build_mac_app_dmg(release, options)
  end
end
