defmodule GbSets do
  @moduledoc """
  Sets represented by general balanced trees.

  This module provides ordered sets using Prof. Arne Andersson's General Balanced Trees. Ordered
  sets can be much more efficient than using ordered lists, for larger sets, but depends on the
  application.

  The data representing a set as used by this module is to be regarded as opaque by other
  modules. In abstract terms, the representation is a composite type of existing Erlang terms.
  See note on [data types](https://www.erlang.org/doc/system/data_types#no_user_types). Any code
  assuming knowledge of the format is running on thin ice.

  This module considers two elements as different if and only if they do not compare equal (`==`).

  ## Complexity Note

  The complexity on set operations is bounded by either _O(|S|)_ or _O(|T| log(|S|))_*, where S is
  the largest given set, depending on which is fastest for any particular function call. For
  operating on sets of almost equal size, this implementation is about 3 times slower than using
  ordered-list sets directly. For sets of very different sizes, however, this solution can be
  arbitrarily much faster; in practical cases, often 10-100 times. This implementation is
  particularly suited for accumulating elements a few at a time, building up a large set (>
  100-200 elements), and repeatedly testing for membership in the current set.

  As with normal tree structures, lookup (membership testing), insertion, and deletion have
  logarithmic complexity.

  ## See Also

  `GbTrees`, `Ordsets`, `Sets`
  """

  ## types

  @typedoc "A general balanced set."
  @opaque t(element) :: :gb_sets.set(element)

  @type t :: t(any)

  @typedoc "A general balanced set iterator."
  @opaque iter(element) :: :gb_sets.iter(element)

  @type iter :: iter(any)

  ## api

  @doc "Returns a new empty set."
  @spec empty() :: t
  defdelegate empty(), to: :gb_sets

  @doc "Returns a new empty set."
  @spec new() :: t
  defdelegate new(), to: :gb_sets

  @doc "Returns `true` if `set` is an empty set, otherwise `false`."
  @spec empty?(t) :: boolean
  defdelegate empty?(set), to: :gb_sets, as: :is_empty

  @doc "Returns the number of elements in `set`."
  @spec size(t) :: non_neg_integer
  defdelegate size(set), to: :gb_sets
end
