defmodule DiamondWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :diamond

  plug DiamondWeb.Plugs.HealthCheck

  # Note: this check happens at compile time
  if Mix.env() in [:dev, :prod] do
    plug RemoteIp, headers: ["fly-client-ip"]
    plug Plug.SSL, hsts: true, rewrite_on: [
      :x_forwarded_host,
      :x_forwarded_port,
      :x_forwarded_proto
    ]
  end

  # Handle redirects
  plug DiamondWeb.Plugs.Redirects

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_diamond_key",
    signing_salt: "RB/8SVQF"
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # Handle CORS requests early before Plug.Static
  plug DiamondWeb.Plugs.CORS

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug DiamondWeb.Plugs.Static,
    at: "/",
    from: :diamond,
    gzip: true,
    endpoint: __MODULE__,
    only: ~w(assets fonts images favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  if Mix.env() in [:dev, :prod] do
    plug DiamondWeb.Plugs.PlugAttack
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug DiamondWeb.Router
end
