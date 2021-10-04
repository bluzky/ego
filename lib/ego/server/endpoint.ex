defmodule Ego.Server.Endpoint do
  use Phoenix.Endpoint, otp_app: :ego

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_blogee_key",
    signing_salt: "4eNw3InT"
  ]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.

  # output_dir =
  #   Application.get_env(:ego, :config)
  #   |> Keyword.get(:output_dir)

  # plug(Plug.Static,
  #   at: "/",
  #   from: output_dir,
  #   gzip: false
  # )

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug(Phoenix.CodeReloader)
  end

  plug(Plug.RequestId)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)
  plug(Plug.Session, @session_options)
  plug(Ego.Server.Router)
end
