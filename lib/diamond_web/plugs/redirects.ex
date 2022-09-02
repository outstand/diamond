defmodule DiamondWeb.Plugs.Redirects do
  use Plug.Router

  require Logger
  import Plug.Conn, only: [put_status: 2, halt: 1]

  plug :match
  plug :dispatch

  match _, host: "www." do
    host =
      String.replace_leading(conn.host, "www.", "")

    uri =
      URI.new!("https://" <> host)
      |> struct!(path: path(conn.path_info))
      |> put_query_string(conn.query_string)
      |> URI.to_string()

    conn
    |> put_status(:moved_permanently)
    |> redirect(external: uri)
    |> halt()
  end

  # Catch all
  match _ do
    conn
  end

  defp redirect(conn, opts) when is_list(opts) do
    status = conn.status || 302
    url  = url(opts)

    Logger.log(:info, fn ->
      [
        "DiamondWeb.Plugs.Redirects is redirecting to ",
        url,
        " with status ",
        Integer.to_string(status)
      ]
    end)

    conn
    |> Phoenix.Controller.redirect(opts)
  end

  defp url(opts) do
    cond do
      to = opts[:to] -> to
      external = opts[:external] -> external
      true -> raise ArgumentError, "expected :to or :external option in redirect/2"
    end
  end

  defp put_query_string(uri, ""), do: uri
  defp put_query_string(uri = %URI{}, qs) do
    struct!(uri, query: qs)
  end

  defp path([]), do: "/"
  defp path(segments = [_|_]), do: "/" <> Enum.join(segments, "/")
end
