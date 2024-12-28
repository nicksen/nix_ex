defmodule Nix.Binary.Queue do
  @moduledoc """
  Queue for binary data.

  It resembles a pipeline: data is pushed on one end and pulled from the other. The order by
  which bytes are pushed in is the same by which they are pulled out.

  Internally, this queue implementation optimizes on the amount of copying of binary data in
  memory. Copying possibly occurs when binary data is pulled from the queue.

  ## Examples

      iex> new(<<5, 208, 224, 23, 85>>)
      #Nix.Binary.Queue<[<<5, 208, 224, 23, 85>>]>

      iex> q = new()
      ...> q = push(q, <<5, 208, 224, 23, 85>>)
      ...> {data, q} = pull(q, 4)
      iex> data
      <<5, 208, 224, 23>>
      iex> q
      #Nix.Binary.Queue<[<<85>>]>

      iex> new()
      ...> |> push(<<5, 208, 224, 23, 85>>)
      ...> |> push(<<82, 203>>)
      #Nix.Binary.Queue<[<<5, 208, 224, 23, 85>>, <<82, 203>>]>
  """

  alias Nix.Binary

  ## struct

  @enforce_keys [:data, :size]
  defstruct @enforce_keys

  ## types

  @opaque t :: %__MODULE__{}

  ## api

  @doc """
  Creates a new empty binary queue.

  ## Examples

      iex> new()
      #Nix.Binary.Queue<[]>
  """
  @spec new() :: t
  def new do
    new([])
  end

  @doc """
  Creates a new binary queue from initial `data`.

  ## Examples

      iex> new(<<10, 11>>)
      #Nix.Binary.Queue<[<<10, 11>>]>

      iex> new(["a", "bc"])
      #Nix.Binary.Queue<[<<97>>, <<98, 99>>]>

      iex> q = new(["a", "b", "c"])
      #Nix.Binary.Queue<[<<97>>, <<98>>, <<99>>]>
      iex> new(q)
      #Nix.Binary.Queue<[<<97>>, <<98>>, <<99>>]>
  """
  @spec new(data) :: t when data: binary | Enumerable.t()
  def new(data)

  def new(%__MODULE__{} = queue) do
    queue
  end

  def new(data) when is_binary(data) do
    new([data])
  end

  def new(enum) do
    {queue, size} =
      for data <- enum, reduce: {:queue.new(), 0} do
        {acc, n} -> {:queue.in(data, acc), n + byte_size(data)}
      end

    %__MODULE__{data: queue, size: size}
  end

  @doc """
  Push binary `data` on the `queue` and returns a new queue.

  ## Examples

      iex> push(new(), <<23, 75>>)
      #Nix.Binary.Queue<[<<23, 75>>]>

      iex> push(new(<<23, 75>>), <<17>>)
      #Nix.Binary.Queue<[<<23, 75>>, <<17>>]>
  """
  @spec push(queue, data) :: t when queue: t, data: binary
  def push(%__MODULE__{data: queue, size: size}, data) do
    %__MODULE__{data: :queue.in(data, queue), size: size + byte_size(data)}
  end

  @doc """
  Pulls a single byte from the `queue`. Returns a tuple of the byte and the new queue.

  ## Examples

      iex> q = new(<<23, 75>>)
      #Nix.Binary.Queue<[<<23, 75>>]>
      iex> {data, q} = pull(q)
      iex> data
      <<23>>
      iex> q
      #Nix.Binary.Queue<[<<75>>]>
  """
  @spec pull(queue) :: {binary, t} when queue: t
  def pull(%__MODULE__{} = queue) do
    pull(queue, 1)
  end

  @doc """
  Pull `num` bytes from the `queue`. Returns a tuple of the bytes pulled and a new queue.

  ## Examples

      iex> q = new(<<23, 75, 17>>)
      #Nix.Binary.Queue<[<<23, 75, 17>>]>
      iex> p = pull(q, 2)
      iex> elem(p, 0)
      <<23, 75>>
      iex> elem(p, 1)
      #Nix.Binary.Queue<[<<17>>]>

      iex> q = new(<<23>>)
      #Nix.Binary.Queue<[<<23>>]>
      iex> q = push(q, <<75, 17>>)
      #Nix.Binary.Queue<[<<23>>, <<75, 17>>]>
      iex> p = pull(q, 2)
      iex> elem(p, 0)
      <<23, 75>>
      iex> elem(p, 1)
      #Nix.Binary.Queue<[<<17>>]>

      iex> q = new(<<23, 75, 17>>)
      #Nix.Binary.Queue<[<<23, 75, 17>>]>
      iex> p = pull(q, 10)
      iex> elem(p, 0)
      <<23, 75, 17>>
      iex> elem(p, 1)
      #Nix.Binary.Queue<[]>
  """
  @spec pull(queue, num) :: {binary, t} when queue: t, num: non_neg_integer
  def pull(%__MODULE__{data: data, size: size}, num) do
    qpull(<<>>, num, size, data)
  end

  @doc """
  Returns the number of bytes on the `queue`.

  ## Examples

      iex> q = new(<<25, 75, 17>>)
      #Nix.Binary.Queue<[<<25, 75, 17>>]>
      iex> size(q)
      3

      iex> q = new(<<25, 75, 17>>)
      #Nix.Binary.Queue<[<<25, 75, 17>>]>
      iex> q = push(q, <<0>>)
      #Nix.Binary.Queue<[<<25, 75, 17>>, <<0>>]>
      iex> size(q)
      4
  """
  @spec size(queue) :: non_neg_integer when queue: t
  def size(%__MODULE__{size: size}) do
    size
  end

  @doc """
  Returns `true` if `queue` is empty, otherwise `false`.

  ## Examples

      iex> q = new()
      #Nix.Binary.Queue<[]>
      iex> empty?(q)
      true

      iex> q = new(<<23, 75, 17>>)
      #Nix.Binary.Queue<[<<23, 75, 17>>]>
      iex> empty?(q)
      false
  """
  @spec empty?(queue) :: boolean when queue: t
  def empty?(%__MODULE__{data: queue, size: size}) do
    size == 0 && :queue.is_empty(queue)
  end

  @doc """
  Converts `queue` to a list.

  ## Examples

      iex> to_list(new(<<1, 2, 3>>))
      [<<1, 2, 3>>]

      iex> q = new(<<23, 75>>)
      #Nix.Binary.Queue<[<<23, 75>>]>
      iex> q = push(q, <<17>>)
      #Nix.Binary.Queue<[<<23, 75>>, <<17>>]>
      iex> to_list(q)
      [<<23, 75>>, <<17>>]
  """
  @spec to_list(queue) :: [binary] when queue: t
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

  ## Enumerable impl

  defimpl Enumerable do
    def count(queue) do
      {:ok, @for.size(queue)}
    end

    def member?(_queue, _item) do
      {:error, __MODULE__}
    end

    def slice(queue) do
      size = @for.size(queue)
      {:ok, size, &@for.to_list/1}
    end

    def reduce(_queue, {:halt, acc}, _fun), do: {:halted, acc}
    def reduce(queue, {:suspend, acc}, fun), do: {:suspended, acc, &reduce(queue, &1, fun)}

    def reduce(queue, {:cont, acc}, fun) do
      if @for.empty?(queue) do
        {:done, acc}
      else
        {item, new_queue} = @for.pull(queue)
        reduce(new_queue, fun.(item, acc), fun)
      end
    end
  end

  ## Collectable impl

  defimpl Collectable do
    def into(%@for{} = queue) do
      fun = fn
        q, {:cont, x} -> @for.push(q, x)
        q, :done -> q
        _q, :halt -> :ok
      end

      {queue, fun}
    end
  end

  ## Inspect impl

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(queue, opts) do
      opts = %Inspect.Opts{opts | binaries: :as_binaries, charlists: :as_lists}
      formatted = Inspect.List.inspect(@for.to_list(queue), opts)
      concat(["#", inspect(@for), "<", formatted, ">"])
      # concat([inspect(@for), ".new(", Inspect.List.inspect(@for.to_list(queue), opts), ")"])
    end
  end
end
