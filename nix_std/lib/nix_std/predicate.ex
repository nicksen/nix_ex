defmodule Nix.Std.Predicate do
  @moduledoc """
  Utilities to manage predicates (functions that returns a bool).
  """

  ## types

  @type t(value) :: (value -> boolean)
  @type t :: t(any)

  @doc """
  Create a predicate that tests both `x` and `y`.

  ## Example

      iex> pred = and_then(&(&1 > 0), &(&1 > 1))
      ...> pred.(2)
      true

      iex> pred = and_then(&(&1 > 0), &(&1 > 1))
      ...> pred.(1)
      false
  """
  @spec and_then(t(value), t(value)) :: t(value) when value: term
  def and_then(x, y) when is_function(x, 1) and is_function(y, 1) do
    fn value -> x.(value) and y.(value) end
  end
end
