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
  check_origin: false,
  server: true
