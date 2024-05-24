defmodule Ordsets do
  @moduledoc """
  Functions for manipulating sets as ordered lists.

  Sets are collections of elements with no duplicate elements. An `#{inspect(__MODULE__)}` is a
  representation of a set, where an ordered list is used to store the elements of the set. An
  ordered list is more efficient than an unordered list. Elements are ordered according to the
  _Erlang term order_.

  This module provides the same interface as the `Sets` module but with a defined representation.
  One difference is that while `Sets` considers two elements as different if they do not match
  (`===`), this module considers two elements as different if and only if they do not compare
  equal (`==`).

  ## See Also

  `GbSets`, `Sets`
  """
end
