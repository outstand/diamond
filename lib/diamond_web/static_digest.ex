defmodule DiamondWeb.StaticDigest do
  @moduledoc """
  This module contains utilities for working with static assets
  that have been digested (`mix phx.digest`).
  """

  @doc """
  Generate 'only rules' for digested static assets based on existing
  rules from the user.
  """
  def generate_only_rules(endpoint, only)
      when is_list(only) do
    latest = endpoint.config(:cache_static_manifest_latest, %{})

    digest_only =
      only
      |> Stream.filter(fn x -> Map.has_key?(latest, x) end)
      |> Enum.map(fn x -> Map.get(latest, x) end)

    only ++ digest_only
  end
end
