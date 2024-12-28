defmodule PriorityQueue do
  @moduledoc """
  Library for working with priority queues.

  Implemented on [general balanced trees](https://www.erlang.org/doc/apps/stdlib/gb_trees.html).
  They have no storage overhead compared to unbalanced binary trees, and their performance is
  better than AVL trees.

  ## Data Structure

  Trees and iterators are built using opaque data structures that should not be pattern-matched
  from outside this module.

  There is no attempt to balance trees after deletions. As deletions do not increase the height
  of a tree, this should be OK.

  The original balance condition `h(T) <= ceil(c * log(|T|))` has been changed to the similar
  (but not quite equivalent) condition `2 ^ h(T) <= |T| ^ c`. This should also be OK.

  ## Examples

      iex> new()
      ...> |> insert("item1", 2)
      ...> |> insert("item2", 1)
      ...> |> insert("item3", 1)
      ...> |> top()
      #PriorityQueue<[{2, "item1"}]>

      iex> new()
      ...> |> insert("item1", 2)
      ...> |> insert("item2", 3)
      ...> |> insert("item3", 1)
      ...> |> top()
      #PriorityQueue<[{2, "item1"}, {3, "item2"}]>

      iex> new()
      ...> |> insert("item1", 2)
      ...> |> insert("item2", 3)
      ...> |> insert("item3", 1)
      ...> |> top()
      ...> |> top()
      ...> |> insert("item4", 2)
      #PriorityQueue<[{2, "item4"}, {3, "item2"}]>
  """

  ## struct

  @enforce_keys [:data]
  defstruct @enforce_keys

  ## types

  @opaque t(key, value) :: %__MODULE__{data: :gb_trees.tree(key, value)}
  @type t :: t(any, any)

  ## api

  @doc """
  Returns a new empty queue.
  """
  @spec new() :: t(none, none)
  def new do
    %__MODULE__{data: :gb_trees.empty()}
  end

  @doc """
  Check if `queue` is empty.
  """
  @spec empty?(queue :: t) :: boolean
  def empty?(queue)

  def empty?(%__MODULE__{data: tree}) do
    :gb_trees.is_empty(tree)
  end

  @doc """
  Return number of elements in `queue`.
  """
  @spec size(queue :: t) :: non_neg_integer
  def size(queue)

  def size(%__MODULE__{data: tree}) do
    :gb_trees.size(tree)
  end

  @doc """
  Add a new `element` with `priority` to `queue`.
  """
  @spec insert(queue, element, priority) :: t(priority, element)
        when queue: t(priority, element), priority: term, element: term
  def insert(queue, element, priority)

  def insert(%__MODULE__{data: tree} = queue, key, value) do
    %{queue | data: :gb_trees.enter(value, key, tree)}
  end

  @doc """
  Remove element from `queue` with the higest priority.

  ## Examples

      iex> new()
      ...> |> insert("item", 4)
      ...> |> top()
      #PriorityQueue<[]>
  """
  @spec top(queue :: t) :: t
  def top(queue)

  def top(%__MODULE__{data: tree} = queue) do
    {_priority, _element, new_tree} = :gb_trees.take_smallest(tree)
    %{queue | data: new_tree}
  end

  @doc """
  Get the element with the highest priority from `queue`.

  ## Examples

      iex> new()
      ...> |> insert("item", 4)
      ...> |> peek()
      "item"
  """
  @spec peek(queue :: t(key, value)) :: value when key: term, value: term
  def peek(queue)

  def peek(%__MODULE__{data: tree}) do
    {_priority, element, _new_tree} = :gb_trees.take_smallest(tree)
    element
  end

  @doc """
  Converts the `queue` to a list.

  ## Examples

      iex> new()
      ...> |> insert("I4", 4)
      ...> |> insert("I1", 1)
      ...> |> to_list()
      [{1, "I1"}, {4, "I4"}]

      iex> new()
      ...> |> insert("I1", 1)
      ...> |> insert("I4", 4)
      ...> |> to_list()
      [{1, "I1"}, {4, "I4"}]
  """
  @spec to_list(queue :: t(key, value)) :: [{key, value}] when key: term, value: term
  def to_list(queue)

  def to_list(%__MODULE__{data: tree}) do
    :gb_trees.to_list(tree)
  end

  ## Inspect impl

  defimpl Inspect do
    def inspect(queue, opts) do
      formatted = Inspect.List.inspect(@for.to_list(queue), opts)
      Inspect.Algebra.concat(["#", inspect(@for), "<", formatted, ">"])
    end
  end
end
