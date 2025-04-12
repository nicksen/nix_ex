defmodule Nix.Std.Predicate do
  @moduledoc """
  Utilities to manage predicates (functions that returns a bool).
  """

  ## types

  @type t(value) :: (value -> as_boolean(term))
  @type t :: t(any)

  @doc """
  Create a predicate that tests `left` and `right`.

  ## Example

      iex> pred = and_then(&(&1 > 0), &(&1 > 1))
      ...> pred.(2)
      true

      iex> pred = and_then(&(&1 > 0), &(&1 > 1))
      ...> pred.(1)
      false
  """
  @spec and_then(left, right) :: combined
        when left: t(value), right: t(value), combined: t(value), value: term
  def and_then(left, right) when is_function(left, 1) and is_function(right, 1) do
    fn value -> left.(value) && right.(value) end
  end

  @doc """
  Create a predicate that tests `left` or `right`.

  ## Example

      iex> pred = or_is(&(&1 > 0), &(&1 < 0))
      ...> pred.(-1)
      true

      iex> pred = or_is(&(&1 > 0), &(&1 < 0))
      ...> pred.(0)
      false
  """
  @spec or_is(left, right) :: combined
        when left: t(value), right: t(value), combined: t(value), value: term
  def or_is(left, right) when is_function(left, 1) and is_function(right, 1) do
    fn value -> left.(value) || right.(value) end
  end

  @doc """
  Create a predicate that inverts the result of `pred`.

  ## Example

      iex> pred = invert(&(&1 > 0))
      ...> pred.(1)
      false

      iex> pred = invert(&(&1 > 0))
      ...> pred.(-1)
      true
  """
  @spec invert(pred) :: inverted when pred: t(value), inverted: t(value), value: term
  def invert(pred) when is_function(pred, 1) do
    fn value -> !pred.(value) end
  end
end
