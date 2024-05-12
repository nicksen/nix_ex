defmodule Nix.DeepMerge do
  @moduledoc """
  Recursively (deeply) merge data structures (usually `Map` and `Keyword`).
  """

  alias Nix.DeepMerge.Resolver

  ## guards

  defguardp is_mergable(term) when is_map(term) or is_list(term)

  ## api

  @doc """
  Deep merges two maps or keyword lists, `original` and `override`.

  In more detail, if two conflicting values are maps or keyword lists themselves then they will
  be merged recursively. This is an extension in that sense to what `Map.merge/2` and
  `Keyword.merge/2` do, as it doesn't just override values but tries to merge them.

  It does not merge structs or structs with maps. If you want your structs to be merged, use the
  `#{inspect(Resolver)}` protocol and consider implementing/deriving it.

  ## Examples

      iex> merge(%{a: 1, b: [x: 10, y: 9]}, %{b: [y: 20, z: 30], c: 4})
      %{a: 1, b: [x: 10, y: 20, z: 30], c: 4}

      iex> merge(%{a: 1, b: %{x: 10, y: 9}}, %{b: %{y: 20, z: 30}, c: 4})
      %{a: 1, b: %{x: 10, y: 20, z: 30}, c: 4}

      iex> merge([a: 1, b: [x: 10, y: 9]], [b: [y: 20, z: 30], c: 4])
      [a: 1, b: [x: 10, y: 20, z: 30], c: 4]

      iex> merge(%{a: 1, b: 2}, %{b: 3, c: 4})
      %{a: 1, b: 3, c: 4}

      iex> merge(%{a: 1, b: %{x: 10, y: 9}}, %{b: 5, c: 4})
      %{a: 1, b: 5, c: 4}

      iex> merge([a: [b: [c: 1, d: 2], e: [24]]], [a: [b: [f: 3], e: [42, 100]]])
      [a: [b: [c: 1, d: 2, f: 3], e: [42, 100]]]

      iex> merge(%{a: 1, b: 5}, %{b: %{x: 10, y: 9}, c: 4})
      %{a: 1, b: %{x: 10, y: 9}, c: 4}

      iex> merge(%{a: [b: %{c: [d: "foo", e: 2]}]}, %{a: [b: %{c: [d: "bar"]}]})
      %{a: [b: %{c: [d: "bar", e: 2]}]}
  """
  @spec merge(map | keyword, map | keyword) :: map | keyword
  def merge(original, override) when is_mergable(original) and is_mergable(override) do
    standard_resolve(nil, original, override)
  end

  ## priv

  defp standard_resolve(_key, original, override) do
    Resolver.resolve(original, override, &standard_resolve/3)
  end
end
