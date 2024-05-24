defmodule GbTrees do
  @moduledoc """
  General balanced trees.

  This module provides Prof. Arne Andersson's General Balanced Trees. These have no storage
  overhead compared to unbalanced binary trees, and their performance is better than AVL trees.

  This module considers two keys as different if and only if they do not compare equal (`==`).

  ## Data Structure

  Trees and iterators are built using opaque data structures that should not be pattern-matched
  from outside this module.

  There is no attempt to balance trees after deletions. As deletions do not increase the height of
  a tree, this should be OK.

  The original balance condition `h(T) <= ceil(c * log(|T|))` has been changed to the similar
  (but not quite equivalent) condition `2 ^ h(T) <= |T| ^ c`. This should also be OK.

  ## See Also

  `:dict`, `GbSets`
  """
end
