defmodule DiamondWeb.Plugs.HealthCheck do
  @behaviour Plug

  import Plug.Conn, only: [halt: 1]
  import Phoenix.Controller, only: [json: 2]

  @impl Plug
  def init(_opts), do: nil

  @impl Plug
  def call(%Plug.Conn{path_info: ["health_check"]} = conn, _opts) do
    conn
    |> json(%{status: "ok"})
    |> halt()
  end

  def call(conn, _opts) do
    conn
  end
end
