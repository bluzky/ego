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
  watchers: [
    # node: [
    #   "node_modules/webpack/bin/webpack.js",
    #   "--mode",
    #   "development",
    #   "--watch-stdin",
    #   cd: Path.expand("../assets", __DIR__)
    # ]
    sass: {
      DartSass,
      :install_and_run,
      [:default, ~w(--embed-source-map --source-map-urls=absolute --watch)]
    }
  ]

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
  server: true,
  base_url: "http://localhost:4000"

config :solid, :custom_filters, Ego.Template.Filters

config :dart_sass,
  version: "1.36.0",
  default: [
    args: ~w(priv/assets/scss/style.scss public/css/style.css)
  ]
