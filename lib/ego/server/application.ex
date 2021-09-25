defmodule Ego.Server.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  use Application
  require Logger

  def start(_type, opts \\ []) do
    load_config(opts[:server])

    children = [
      {Cachex, name: :ego}
    ]

    children =
      if opts[:server] do
        children ++
          [
            {Phoenix.PubSub, name: Ego.Server.PubSub},
            Ego.Server.Endpoint,
            {Ego.Server.AssetsWatcher, dirs: Ego.FileSystem.assets_paths(), name: :asset_watcher},
            {Ego.Server.ContentWatcher,
             dirs: [Ego.FileSystem.source_path("/content")], name: :content_watcher}
          ]
      else
        children
      end

    opts = [strategy: :one_for_one, name: Ego.Server.Supervisor]
    rs = Supervisor.start_link(children, opts)

    "content"
    |> Ego.FileSystem.source_path()
    |> Ego.Store.init()

    rs
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Ego.Server.Endpoint.config_change(changed, removed)
    :ok
  end

  def load_config(dev) do
    case Ego.Config.load() do
      {:ok, site_config} ->
        Application.put_env(:ego, :site_config, site_config)

        unless dev do
          config =
            Application.get_env(:ego, :config, [])
            |> Keyword.put(:base_url, site_config["base_url"])

          Application.put_env(:ego, :config, config)
        end

      {:error, message} ->
        Logger.error(message)
    end
  end
end
