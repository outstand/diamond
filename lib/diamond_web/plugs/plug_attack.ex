defmodule DiamondWeb.Plugs.PlugAttack do
  use PlugAttack

  rule "allow local", conn do
    allow conn.remote_ip == {127, 0, 0, 1}
  end

  rule "throttle by ip", conn do
    throttle conn.remote_ip,
      period: 60_000, limit: 30,
      storage: {PlugAttack.Storage.Ets, DiamondWeb.Plugs.PlugAttack.Storage} 
  end

  import Plug.Conn

  def block_action(conn, {:throttle, data}, opts) do
    conn
    |> add_throttling_headers(data)
    |> block_action(false, opts)
  end

  def block_action(conn, _data, _opts) do
    conn
    |> send_resp(:too_many_requests, "Retry later\n")
    |> halt
  end

  defp add_throttling_headers(conn, data) do
    expires_at = div(data[:expires_at], 1_000)
    now = System.system_time(:second)
    retry_after = max(expires_at - now, 0)

    conn
    |> put_resp_header("Retry-After", to_string(retry_after))
    |> put_resp_header("x-ratelimit-reset", to_string(retry_after))
  end
end
