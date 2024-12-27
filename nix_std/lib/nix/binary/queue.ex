defmodule Nix.Binary.Queue do
  @moduledoc """
  """
  alias Nix.Binary

  ## struct

  @enforce_keys [:data, :size]
  defstruct data: :queue.new(), size: 0

  ## types

  @opaque t :: %__MODULE__{data: :queue.queue(binary)}

  ## api

  @doc """
  Creates a new empty binary queue

  ## Examples

      iex> new()
      Nix.Binary.Queue.new([])
  """
  @spec new() :: t
  def new do
    %__MODULE__{data: :queue.new(), size: 0}
  end

  @doc """
  Creates a new binary queue from an enumerable or binary

  ## Examples

      iex> new(<<10, 11>>)
      Nix.Binary.Queue.new([<<10, 11>>])

      iex> new(["a", "b"])
      Nix.Binary.Queue.new(["a", "b"])
  """
  @spec new(binary) :: t
  @spec new(Enumerable.t()) :: t

  def new(data) when is_binary(data) do
    %__MODULE__{data: :queue.from_list([data]), size: byte_size(data)}
  end

  def new(%__MODULE__{} = queue) do
    queue
  end

  def new(enum) do
    {list, size} =
      for data <- enum, reduce: {[], 0} do
        {acc, n} -> {[data | acc], n + byte_size(data)}
      end

    queue =
      list
      |> Enum.reverse()
      |> :queue.from_list()

    %__MODULE__{data: queue, size: size}
  end

  @doc """
  Push binary data on the queue and returns a new queue

  ## Examples

      iex> push(new(), <<23, 75>>)
      Nix.Binary.Queue.new(<<23, 75>>)
  """
  @spec push(t, binary) :: t
  def push(%__MODULE__{data: queue, size: size}, data) do
    %__MODULE__{data: :queue.in(data, queue), size: size + byte_size(data)}
  end

  @doc """
  Pulls a single byte from the queue. Returns a tuple of the byte and the new queue

  ## Examples

      iex> q = new(<<23, 75>>)
      Nix.Binary.Queue.new([<<23, 75>>])
      ...> pull(q)
      {<<23>>, Nix.Binary.Queue.new([<<75>>])}
  """
  @spec pull(t) :: {binary, t}
  def pull(%__MODULE__{} = queue) do
    pull(queue, 1)
  end

  @doc """
  Pull `num` bytes from the `queue`. Returns a tuple of the bytes pulled and a new queue

  ## Examples

      iex> q = new(<<23, 75, 17>>)
      Nix.Binary.Queue.new([<<23, 75, 17>>])
      ...> pull(q, 2)
      {<<23, 75>>, Nix.Binary.Queue.new([<<17>>])}
  """
  @spec pull(t, non_neg_integer) :: {binary, t}
  def pull(%__MODULE__{data: data, size: size}, num) do
    qpull(<<>>, num, size, data)
  end

  @doc """
  Returns the amount of bytes on the queue

  ## Examples

      iex> q = new(<<25, 75, 17>>)
      Nix.Binary.Queue.new(<<25, 75, 17>>)
      iex> size(q)
      3
  """
  @spec size(t) :: non_neg_integer
  def size(%__MODULE__{size: size}) do
    size
  end

  @doc """
  Checks wether the queue is empty or not

  ## Examples

      iex> q = new()
      Nix.Binary.Queue.new([])
      iex> is_empty(q)
      true

      iex> q = new(<<23, 75, 17>>)
      Nix.Binary.Queue.new([<<23, 75, 17>>])
      iex> is_empty(q)
      false
  """
  @spec is_empty(t) :: boolean
  def is_empty(%__MODULE__{size: size, data: queue}) do
    size == 0 && :queue.is_empty(queue)
  end

  @doc """
  Converts `queue` to a list

  ## Examples

      iex> to_list(new(<<1, 2, 3>>))
      [<<1, 2, 3>>]

      iex> q = new(<<23, 75>>)
      Nix.Binary.Queue.new([<<23, 75>>])
      ...> q = push(q, <<17>>)
      Nix.Binary.Queue.new([<<23, 75>>, <<17>>])
      ...> to_list(q)
      [<<23, 75>>, <<17>>]
  """
  @spec to_list(t) :: [binary]
  def to_list(%__MODULE__{data: queue}) do
    :queue.to_list(queue)
  end

  ## priv

  defp qpull(acc, 0, size, queue) do
    {acc, %__MODULE__{data: queue, size: size}}
  end

  defp qpull(acc, _amount, 0, queue) do
    {acc, %__MODULE__{data: queue, size: 0}}
  end

  defp qpull(acc, amount, size, queue) do
    {element, popped_queue} = :queue.out(queue)
    qpull(acc, amount, size, popped_queue, element)
  end

  defp qpull(acc, amount, _size, queue, :empty) do
    qpull(acc, amount, 0, queue)
  end

  defp qpull(acc, amount, size, queue, {:value, data}) when amount == byte_size(data) do
    qpull(
      Binary.append(acc, data),
      0,
      :erlang.max(0, size - byte_size(data)),
      queue
    )
  end

  defp qpull(acc, amount, size, queue, {:value, data}) when amount > byte_size(data) do
    data_size = byte_size(data)

    qpull(
      Binary.append(acc, data),
      amount - data_size,
      :erlang.max(0, size - data_size),
      queue
    )
  end

  defp qpull(acc, amount, size, queue, {:value, data}) when amount < byte_size(data) do
    {first, rest} = Binary.split_at(data, amount)

    qpull(
      Binary.append(acc, first),
      0,
      :erlang.max(0, size - amount),
      :queue.in_r(rest, queue)
    )
  end

  ##

  ## Inspect impl

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(queue, opts) do
      opts = %Inspect.Opts{opts | charlists: :as_lists}
      concat([inspect(@for), ".new(", Inspect.List.inspect(@for.to_list(queue), opts), ")"])
    end
  end
end
