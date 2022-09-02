defmodule DiamondWeb.Plugs.Static do
  @behaviour Plug
  @allowed_methods ~w(GET HEAD)

  alias Plug.Conn

  @impl Plug
  def init(opts) do
    plug_static_opts =
      opts
      |> Keyword.delete(:only)
      |> Keyword.delete(:only_matching)

    %{
      at: opts |> Keyword.fetch!(:at) |> Plug.Router.Utils.split(),
      endpoint: Keyword.fetch!(opts, :endpoint),
      only: Keyword.get(opts, :only, []),
      only_matching: Keyword.get(opts, :only_matching, []),
      plug_static: Plug.Static.init(plug_static_opts)
    }
  end

  @impl Plug
  def call(
        conn = %Conn{method: meth},
        %{at: at, endpoint: endpoint, only: only, only_matching: only_matching, plug_static: plug_static} = _opts
      )
      when meth in @allowed_methods do
    only =
      DiamondWeb.StaticDigest.generate_only_rules(
        endpoint,
        only
      )

    segments = subset(at, conn.path_info)

    if allowed?({only, only_matching}, segments) do
      Plug.Static.call(conn, plug_static)
    else
      conn
    end
  end

  defp allowed?(_only_rules, []), do: false
  defp allowed?({[], []}, _list), do: true

  defp allowed?({full, prefix}, [h | _]) do
    h in full or (prefix != [] and match?({0, _}, :binary.match(h, prefix)))
  end

  defp subset([h | expected], [h | actual]), do: subset(expected, actual)
  defp subset([], actual), do: actual
  defp subset(_, _), do: []
end
