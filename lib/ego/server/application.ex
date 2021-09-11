defmodule Ego.Server.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the PubSub system
      {Phoenix.PubSub, name: Ego.Server.PubSub},
      # Start the Endpoint (http/https)
      Ego.Server.Endpoint,
      {Cachex, name: :ego}
      # Start a worker by calling: Ego.Server.Worker.start_link(arg)
      # {Ego.Server.Worker, arg}
    ]

    opts = [strategy: :one_for_one, name: Ego.Server.Supervisor]
    rs = Supervisor.start_link(children, opts)

    Task.start(fn ->
      "content"
      |> Ego.FileSystem.source_path()
      |> Ego.DocumentStore.init()
    end)

    rs
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Ego.Server.Endpoint.config_change(changed, removed)
    :ok
  end
end
