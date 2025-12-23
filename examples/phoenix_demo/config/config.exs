import Config

config :phoenix_demo, PhoenixDemoWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: PhoenixDemoWeb.ErrorHTML],
    layout: false
  ],
  pubsub_server: PhoenixDemo.PubSub,
  live_view: [signing_salt: "phoenix_demo_salt"]

config :phoenix_demo, :generators, context_app: false

config :phoenix_demo, PhoenixDemoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "phoenix_demo_secret_key_base_for_development_only_change_in_production",
  watchers: []

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime

