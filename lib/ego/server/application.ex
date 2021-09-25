defmodule Ego.Server.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  use Application
  require Logger

  def start(_type, opts \\ []) do
    load_config()

    children = [{Cachex, name: :ego}]

    children =
      if opts[:server] do
        children ++
          [
            {Phoenix.PubSub, name: Ego.Server.PubSub},
            Ego.Server.Endpoint
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
    load_config()
    Ego.Server.Endpoint.config_change(changed, removed)
    :ok
  end

  def load_config() do
    case Ego.Config.load() do
      {:ok, site_config} -> Application.put_env(:ego, :site_config, site_config)
      {:error, message} -> Logger.error(message)
    end
  end
end
