defmodule Nix.DeepConvert do
  @moduledoc false

  @doc """
  Recursively (deep) convert a keyword list to map.

  Exclusions can be provided for key names whose value should not be converted.

  ## Examples

      iex> to_map(a: 1, b: 2)
      %{a: 1, b: 2}

      iex> to_map(a: [b: 2], c: [d: 3, e: 4, e: 5])
      %{a: %{b: 2}, c: %{d: 3, e: 5}}
  """
  @spec to_map(keyword, exclusions :: [atom]) :: map
  def to_map(kwlist, exclusions \\ [])

  def to_map([], _exclusions), do: %{}
  def to_map(list, exclusions), do: convert(list, exclusions)

  ## priv

  defp convert([{_key, _value} | _rest] = list, exclusions), do: Map.new(list, &to_map_element(&1, exclusions))

  defp convert(term, _exclusions), do: term

  defp to_map_element({key, value} = item, exclusions) do
    if key in exclusions do
      item
    else
      {key, convert(value, exclusions)}
    end
  end
end
