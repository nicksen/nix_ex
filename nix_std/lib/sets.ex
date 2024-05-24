defmodule Sets do
  @moduledoc """
  Sets are collections of elements with no duplicate elements.

  The data representing a set as used by this module is to be regarded as opaque by other modules.
  In abstract terms, the representation is a composite type of existing Erlang terms. See note on
  [data types](https://www.erlang.org/doc/system/data_types#no_user_types). Any code assuming
  knowledge of the format is running on thin ice.

  This module provides the same interface as the `Ordsets` module but with an undefined
  representation. One difference is that while this module considers two elements as different if
  they do not match (`===`), `Ordsets` considers two elements as different if and only if they do
  not compare equal (`==`).

  Erlang/OTP 24.0 introduced a new internal representation for sets which is more performant.
  Developers can use this new representation by passing the `{:version, 2}` flag to `new/1` and
  `from_list/2`, such as `#{inspect(__MODULE__)}.new(version: 2)`. This new representation will
  become the default in future Erlang/OTP versions. Functions that work on two sets, such as
  `union/2` and similar, will work with sets of different versions. In such cases, there is no
  guarantee about the version of the returned set. Explicit conversion from the old version to the
  new one can be done with:

  ```elixir
  old_set
  |> #{inspect(__MODULE__)}.to_list()
  |> #{inspect(__MODULE__)}.from_list(version: 2)
  ```

  ## Compatibility

  The following functions in this module also exist and provide the same functionality in the
  `GbSets` and `Ordsets` modules. That is, by only changing the module name for each call, you can
  try out different set representations.

  * `put/2`
  * `delete/2`
  * `filter/2`
  * `filter_map/2`
  * `fold/3`
  * `from_list/1`
  * `intersection/1`
  * `intersection/2`
  * `contains?/2`
  * `empty?/1`
  * `equals?/2`
  * `set?/1`
  * `subset?/2`
  * `map/2`
  * `new/0`
  * `size/1`
  * `subtract/2`
  * `to_list/1`
  * `union/1`
  * `union/2`

  > #### Note {: .info }
  >
  > While the three set implementations offer the same functionality with respect to the
  > aforementioned functions, their overall behavior may differ. As mentioned, this module
  > considers elements as different if and only if they do not match (`===`), while both `Ordsets`
  > and `GbSets` consider elements as different if and only if they do not compare equal (`==`).
  >
  > _Example_
  >
  > ```elixir
  > iex> #{inspect(__MODULE__)}.contains?(#{inspect(__MODULE__)}.from_list([1]), 1.0)
  > false
  >
  > iex> Ordsets.contains?(Ordsets.from_list([1]), 1.0)
  > true
  >
  > iex> GbSets.contains?(GbSets.from_list([1]), 1.0)
  > true
  > ```

  ## See Also

  `GbSets`, `Ordsets`
  """

  ## types

  @typedoc "As returned by `new/0`."
  @opaque t(element) :: :sets.set(element)

  @type t :: t(any)

  ## api

  @doc "Returns a new empty set."
  @spec new() :: t
  defdelegate new(), to: :sets

  @doc "Returns a new empty set at the given version."
  @spec new([{:version, 1..2}]) :: t
  defdelegate new(opts), to: :sets

  @doc "Returns a set of the elements in `list`."
  @spec from_list([element]) :: t(element) when element: term
  defdelegate from_list(list), to: :sets

  @doc "Returns a set of the elements in `list` at the given version."
  @spec from_list([element], [{:version, 1..2}]) :: t(element) when element: term
  defdelegate from_list(list, opts), to: :sets

  @doc """
  Returns `true` if `set` appears to be a set of elements, otherwise `false`.

  Note that the test is shallow and will return `true` for any term that coincides with the
  possible representations of a set.
  """
  @spec set?(set) :: boolean when set: term
  defdelegate set?(set), to: :sets, as: :is_set

  @doc "Returns the number of elements in `set`."
  @spec size(t) :: non_neg_integer
  defdelegate size(set), to: :sets

  @doc "Returns `true` if `set` is an empty set, otherwise `false`."
  @spec empty?(t) :: boolean
  defdelegate empty?(set), to: :sets, as: :is_empty

  @doc """
  Returns `true` if `left` and `right` are equal, that is when every element of one set is also a
  member of the respective other set, otherwise `false`.
  """
  @spec equals?(t, t) :: boolean
  defdelegate equals?(left, right), to: :sets, as: :is_equal

  @doc """
  Returns the elements of `set` as a list. The order of the returned elements is undefined.
  """
  @spec to_list(t(element)) :: [element] when element: term
  defdelegate to_list(set), to: :sets

  @doc "Returns `true` if `element` is an element of `set`, otherwise `false`."
  @spec contains?(t(element), element) :: boolean when element: term
  def contains?(set, element), do: :sets.is_element(element, set)

  @doc "Returns a new set formed from `set` with `element` inserted."
  @spec put(t(element), element) :: t(element) when element: term
  def put(set, element), do: :sets.add_element(element, set)

  @doc "Returns `set`, but with `element` removed."
  @spec delete(t(element), element) :: t(element) when element: term
  def delete(set, element), do: :sets.del_element(element, set)

  @doc "Returns the merged (union) set of `left` and `right`."
  @spec union(t(element), t(element)) :: t(element) when element: term
  defdelegate union(left, right), to: :sets

  @doc "Returns the merged (union) set of the list of sets."
  @spec union([t(element)]) :: t(element) when element: term
  defdelegate union(set_list), to: :sets

  @doc "Returns the intersection of `left` and `right`."
  @spec intersection(t(element), t(element)) :: t(element) when element: term
  defdelegate intersection(left, right), to: :sets

  @doc "Returns the intersection of the non-empty list of sets."
  @spec intersection([t(element), ...]) :: t(element) when element: term
  defdelegate intersection(set_list), to: :sets

  @doc """
  Returns `true` if `left` and `right` are disjoint (have no elements in common), otherwise
  `false`.
  """
  @spec disjoint?(t(element), t(element)) :: boolean when element: term
  defdelegate disjoint?(left, right), to: :sets, as: :is_disjoint

  @doc "Returns only the elements of `left` that are not also elements of `right`."
  @spec subtract(t(element), t(element)) :: t(element) when element: term
  defdelegate subtract(left, right), to: :sets

  @doc """
  Returns `true` when every element of `left` is also a member of `right`, otherwise `false`.
  """
  @spec subset?(t(element), t(element)) :: boolean when element: term
  defdelegate subset?(left, right), to: :sets, as: :is_subset

  @doc """
  Folds `fun` over every element in `set` and returns the final value of the accumulator. The
  evaluation order is undefined.
  """
  @spec fold(t(element), acc, (element, acc -> acc)) :: acc when element: term, acc: term
  def fold(set, acc, fun), do: :sets.fold(fun, acc, set)

  @doc "Filters elements in `set` with boolean function `pred`."
  @spec filter(t(element), (element -> boolean)) :: t(element) when element: term
  def filter(set, pred), do: :sets.filter(pred, set)

  @doc "Maps elements in `set` with mapping function `fun`."
  @spec map(t(element), (element -> mapped)) :: t(mapped) when element: term, mapped: term
  def map(set, fun), do: :sets.map(fun, set)

  @doc "Filters and maps elements in `set` with function `fun`."
  @spec filter_map(t(element), (element -> boolean | {true, mapped})) :: t(element | mapped)
        when element: term, mapped: term
  def filter_map(set, fun), do: :sets.filtermap(fun, set)
end
