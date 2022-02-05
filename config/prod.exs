# General application configuration
import Config

# Configures the endpoint
config :ego, EgoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "9CTOEJqsnBARTWcyQQZ4A7hrzjXCbOwwXeeiYOMUAooXikm0Y8og/7vfFdlnDn2z",
  render_errors: [view: EgoWeb.ErrorView, accepts: ~w(html), layout: false],
  pubsub_server: EgoWeb.PubSub,
  live_view: [signing_salt: "Lq9NSY1g"],
  http: [port: 4000],
  check_origin: false,
  server: true
