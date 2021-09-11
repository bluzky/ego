# General application configuration
use Mix.Config

# Configures the endpoint
config :ego, Ego.Server.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "9CTOEJqsnBARTWcyQQZ4A7hrzjXCbOwwXeeiYOMUAooXikm0Y8og/7vfFdlnDn2z",
  render_errors: [view: Ego.Server.ErrorView, accepts: ~w(html), layout: false],
  pubsub_server: Ego.Server.PubSub,
  live_view: [signing_salt: "Lq9NSY1g"],
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
server: true,
  watchers: []

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

config :ego, :config,
  source_dir: "priv/",
  output_dir: "public/",
  server: true
