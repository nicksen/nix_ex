defmodule Nix.Binary do
  @moduledoc """
  Functions to operate on binaries

  Wrappers for erlangs `:binary` functions that try to mimic `String` behavior but on byets, and
  some very simple functions that are here just to make piping operations on binaries easier.
  """

  @doc """
  Convert list of bytes into binary
  """
  @spec from_list([byte]) :: binary
  def from_list(list) when is_list(list) do
    :binary.list_to_bin(list)
  end

  @doc """
  Converts binary to to a list of bytes
  """
  @spec to_list(binary) :: [byte]
  def to_list(bin) when is_binary(bin) do
    :binary.bin_to_list(bin)
  end

  @doc """
  Returns the first byte of the binary
  """
  @spec first(binary) :: byte
  def first(bin) when is_binary(bin) do
    :binary.first(bin)
  end

  @doc """
  Returns the last byte of the binary
  """
  @spec last(binary) :: byte
  def last(bin) when is_binary(bin) do
    :binary.last(bin)
  end

  @doc """
  Create a binary with the binary content repeated `n` times
  """
  @spec copy(binary, non_neg_integer) :: binary
  def copy(bin, n) when is_binary(bin) and is_integer(n) do
    :binary.copy(bin, n)
  end

  @doc """
  Reverse bytes order in the binary
  """
  @spec reverse(binary) :: binary
  def reverse(bin) when is_binary(bin), do: bin_reverse(bin, <<>>)

  @doc """
  Returns the byte at the given `index` in the `binary`. Indexing starts at 0.

  Position can be negative to make it relative to the end of the binary. Returns `nil` if position
  is outside the binary (following `Enum` and `String` behavior)

  ## Examples

      iex> at(<<1, 2, 3>>, 1)
      2

      iex> at(<<1, 2, 3>>, -1)
      3

      iex> at(<<1, 2, 3>>, 3)
      nil
  """
  @spec at(binary, integer) :: byte | nil
  def at(bin, index)

  def at(bin, index)
      when is_binary(bin) and is_integer(index) and (index >= byte_size(bin) or index < byte_size(bin) * -1),
      do: nil

  def at(bin, index) when is_binary(bin) and is_integer(index) and index < 0 do
    at(bin, byte_size(bin) + index)
  end

  def at(bin, index) when is_binary(bin) and is_integer(index) do
    :binary.at(bin, index)
  end

  @doc """
  Split binary into list of binaries based on `pattern`.

  `pattern` can be a binary or a byte. It mimics erlangs `:binary.split/3` split behavior rather
  than `String.split/3`, and only splits once by default. `global: true` option can be provided
  to split on all occurences.

  ## Examples

      iex> split(<<1, 2, 3, 2, 3>>, <<3, 2>>)
      [<<1, 2>>, <<3>>]

      iex> split(<<1, 2, 3, 2, 3>>, 2)
      [<<1>>, <<3, 2, 3>>]

      iex> split(<<1, 2, 3, 2, 3>>, 2, global: true)
      [<<1>>, <<3>>, <<3>>]
  """
  @spec split(binary, binary | byte, keyword) :: [binary]
  def split(bin, pattern, opts \\ [])

  def split(bin, pattern, opts) when is_binary(bin) and is_integer(pattern) and pattern in 0..255 do
    split(bin, <<pattern>>, opts)
  end

  def split(bin, pattern, opts) when is_binary(bin) and is_binary(pattern) do
    global = Keyword.get(opts, :global, false)
    split_opts = (global && [:global]) || []
    :binary.split(bin, pattern, split_opts)
  end

  @doc """
  Splits a binary into two at the specified `index` as a tuple.

  When `index` is negative it is counted from the end of the binary.

  ## Examples

      iex> split_at(<<1, 2, 3>>, 1)
      {<<1>>, <<2, 3>>}

      iex> split_at(<<1, 2, 3, 4>>, -1)
      {<<1, 2, 3>>, <<4>>}

      iex> split_at(<<1, 2, 3>>, 10)
      {<<1, 2, 3>>, <<>>}
  """
  @spec split_at(binary, integer) :: {binary, binary}
  def split_at(bin, index)

  def split_at(bin, index) when is_binary(bin) and is_integer(index) and index >= byte_size(bin), do: {bin, <<>>}
  def split_at(bin, index) when is_binary(bin) and is_integer(index) and index < -1 * byte_size(bin), do: {<<>>, bin}

  def split_at(bin, index) when is_binary(bin) and is_integer(index) and index < 0 do
    split_at(bin, byte_size(bin) + index)
  end

  def split_at(bin, index) when is_binary(bin) and is_integer(index) do
    {Kernel.binary_part(bin, 0, index), Kernel.binary_part(bin, index, byte_size(bin) - index)}
  end

  @doc """
  Removes all specified leading bytes from the binary

  ## Examples

      iex> trim_leading(<<0, 1, 2, 0, 0>>)
      <<1, 2, 0, 0>>

      iex> trim_leading(<<1, 2>>, 1)
      <<2>>
  """
  @spec trim_leading(binary) :: binary
  @spec trim_leading(binary, byte) :: binary
  def trim_leading(bin, prefix \\ 0)

  def trim_leading(<<byte, bin::binary>>, byte) when is_binary(bin) and is_integer(byte), do: trim_leading(bin, byte)
  def trim_leading(bin, byte) when is_binary(bin) and is_integer(byte), do: bin

  @doc """
  Removes all specified trailing bytes from the binary

  ## Examples

      iex> trim_trailing(<<0, 1, 2, 0, 0>>)
      <<0, 1, 2>>

      iex> trim_trailing(<<1, 2>>, 2)
      <<1>>
  """
  @spec trim_trailing(binary) :: binary
  @spec trim_trailing(binary, byte) :: binary
  def trim_trailing(bin, suffix \\ 0) when is_binary(bin) and is_integer(suffix) do
    bin
    |> reverse()
    |> bin_trim_trailing(suffix)
  end

  @doc """
  Pad `bin` with `prefix` frmo the beginning, until it has `length`  bytes

  ## Examples

      iex> pad_leading(<<3, 7>>, 5)
      <<0, 0, 0, 3, 7>>

      iex> pad_leading(<<1, 2, 3>>, 2)
      <<1, 2, 3>>

      iex> pad_leading(<<1, 2>>, 3, 7)
      <<7, 1, 2>>
  """
  @spec pad_leading(binary, non_neg_integer) :: binary
  @spec pad_leading(binary, non_neg_integer, byte) :: binary
  def pad_leading(bin, length, prefix \\ 0)

  def pad_leading(bin, len, byte)
      when is_binary(bin) and is_integer(len) and is_integer(byte) and len > 0 and byte_size(bin) >= len,
      do: bin

  def pad_leading(bin, len, byte) when is_binary(bin) and is_integer(len) and is_integer(byte) and len > 0 do
    copy(<<byte>>, len - byte_size(bin)) <> bin
  end

  @doc """
  Pad `bin` with `prefix` at the end, until it is `length` bytes

  ## Examples

      iex> pad_trailing(<<3, 7>>, 5)
      <<3, 7, 0, 0, 0>>

      iex> pad_trailing(<<1, 2, 3>>, 1)
      <<1, 2, 3>>

      iex> pad_trailing(<<1, 2>>, 3, 9)
      <<1, 2, 9>>
  """
  @spec pad_trailing(binary, non_neg_integer) :: binary
  @spec pad_trailing(binary, non_neg_integer, byte) :: binary
  def pad_trailing(bin, length, suffix \\ 0)

  def pad_trailing(bin, len, byte)
      when is_binary(bin) and is_integer(len) and is_integer(byte) and len > 0 and byte_size(bin) >= len,
      do: bin

  def pad_trailing(bin, len, byte) when is_binary(bin) and is_integer(len) and is_integer(byte) and len > 0 do
    bin <> copy(<<byte>>, len - byte_size(bin))
  end

  @doc """
  Replace occurrences of `pattern` in `bin` with `replacement`

  By default it replaces all occurrences. If you only want to replace the first match, set
  `global: false`

  ## Examples

      iex> replace("a-b-c", "-", "..")
      "a..b..c"

      iex> replace("a-b-c", "-", "..", global: false)
      "a..b-c"
  """
  @spec replace(binary, binary, binary) :: binary
  @spec replace(binary, binary, binary, keyword) :: binary
  def replace(bin, pattern, replacement, opts \\ [])
      when is_binary(bin) and is_binary(pattern) and is_binary(replacement) do
    replace_opts = (opts[:global] == false && []) || [:global]
    :binary.replace(bin, pattern, replacement, replace_opts)
  end

  @doc """
  Returns the length of the longest common prefix in the binaries

  ## Examples

      iex> longest_common_prefix(["moo", "monad", "mojo"])
      2
  """
  @spec longest_common_prefix([binary]) :: non_neg_integer
  def longest_common_prefix(bins) when is_list(bins) do
    :binary.longest_common_prefix(bins)
  end

  @doc """
  Returns the length of the longest common suffix in the binaries

  ## Examples

      iex> longest_common_suffix(["moo", "boo", "mojo"])
      1
  """
  @spec longest_common_suffix([binary]) :: non_neg_integer
  def longest_common_suffix(bins) when is_list(bins) do
    :binary.longest_common_suffix(bins)
  end

  @doc """
  Extracts part of the `bin` starting at `index` with the given `length`

  * also accepts negative `index`, interpreting it as relative to the end of `bin`
  * `length` is allowed to be outside the size of `bin` i.e. it is the max number of bytes
    returned

  ## Examples

      iex> part(<<1, 2, 3, 4, 5>>, 1, 2)
      <<2, 3>>

      iex> part(<<1, 2, 3, 4, 5>>, -2, 1)
      <<4>>

      iex> part(<<1, 2, 3, 4, 5>>, -2, -1)
      <<3>>

      iex> part(<<1, 2, 3, 4, 5>>, -1, 10)
      <<5>>
  """
  @spec part(binary, integer, non_neg_integer) :: binary
  def part(bin, index, length)

  def part(bin, idx, len) when is_binary(bin) and is_integer(idx) and is_integer(len) and idx < 0 do
    part(bin, byte_size(bin) + idx, len)
  end

  def part(bin, idx, len) when is_binary(bin) and is_integer(idx) and is_integer(len) and idx + len > byte_size(bin) do
    part(bin, idx, byte_size(bin) - idx)
  end

  def part(bin, idx, len) when is_binary(bin) and is_integer(idx) and is_integer(len) and len < 0 and idx + len < 0 do
    part(bin, idx, idx * -1)
  end

  def part(bin, idx, len) when is_binary(bin) and is_integer(idx) and is_integer(len) do
    Kernel.binary_part(bin, idx, len)
  end

  @doc """
  Interpret `bin` as an unsigned integer. `endianness` is `:big` by default

  ## Examples

      iex> to_integer(<<1, 2>>)
      258

      iex> to_integer(<<1, 2>>, :little)
      513
  """
  @spec to_integer(binary) :: non_neg_integer
  @spec to_integer(binary, :big | :little) :: non_neg_integer
  def to_integer(bin, endianness \\ :big) when is_binary(bin) do
    :binary.decode_unsigned(bin, endianness)
  end

  @doc """
  Returns binary representation of `num`. `endianness` is `:big` by default

  ## Examples

      iex> from_integer(1234)
      <<4, 210>>

      iex> from_integer(1234, :little)
      <<210, 4>>
  """
  @spec from_integer(non_neg_integer) :: binary
  @spec from_integer(non_neg_integer, :big | :little) :: binary
  def from_integer(num, endianness \\ :big) when is_integer(num) and num >= 0 do
    :binary.encode_unsigned(num, endianness)
  end

  @doc """
  Returns the `bin` as a hex string

  ## Examples

      iex> to_hex(<<190, 239>>)
      "beef"
  """
  @spec to_hex(binary) :: binary
  def to_hex(bin) when is_binary(bin) do
    Base.encode16(bin, case: :lower)
  end

  @doc """
  Returns the raw binary of `hex`

  ## Examples

      iex> from_hex("ff01")
      <<255, 1>>
  """
  @spec from_hex(binary) :: binary
  def from_hex(hex) when is_binary(hex) do
    Base.decode16!(hex, case: :mixed)
  end

  @doc """
  Takes the first `num` bytes from `bin`

  When a negative `num` is given, the last `num` bytes from `bin` is returned. If `num` is greater
  than the size of `bin` the full `bin` is returned.

  ## Examples

      iex> take(<<1, 2, 3>>, 2)
      <<1, 2>>

      iex> take(<<1, 2>>, 10)
      <<1, 2>>

      iex> take(<<1, 2, 3>>, -2)
      <<2, 3>>
  """
  @spec take(binary, integer) :: binary
  def take(bin, num)

  def take(bin, num) when is_binary(bin) and is_integer(num) and num < 0 do
    bin
    |> split_at(num)
    |> elem(1)
  end

  def take(bin, num) when is_binary(bin) and is_integer(num) do
    bin
    |> split_at(num)
    |> elem(0)
  end

  @doc """
  Drops first `num` bytes from `bin`

  When a negative `num` is given, the last `num` bytes from `bin` is dropped. If `num` is greater
  than the size of `bin` it returns `<<>>`

  ## Examples

      iex> drop(<<1, 2, 3>>, 2)
      <<3>>

      iex> drop(<<1, 2>>, 10)
      <<>>

      iex> drop(<<1, 2, 3>>, -2)
      <<1>>
  """
  @spec drop(binary, integer) :: binary
  def drop(bin, num)

  def drop(bin, num) when is_binary(bin) and is_integer(num) and num < 0 do
    bin
    |> split_at(num)
    |> elem(0)
  end

  def drop(bin, num) when is_binary(bin) and is_integer(num) do
    bin
    |> split_at(num)
    |> elem(1)
  end

  @doc """
  Append `suffix` to `bin`

  Handy for piping. With binary args it's the same as `Kernel.<>/2`

  ## Examples

      iex> append("asd", "1")
      "asd1"

      iex> append("asd", 255)
      "asd\\xFF"
  """
  @spec append(binary, binary | byte) :: binary
  def append(bin, suffix)

  def append(bin, suffix) when is_binary(bin) and is_integer(suffix) and suffix >= 0 and suffix < 256 do
    append(bin, <<suffix>>)
  end

  def append(bin, suffix) when is_binary(bin) and is_binary(suffix) do
    bin <> suffix
  end

  @doc """
  Prepend `prefix` to `bin`

  ## Examples

      iex> prepend("asd", "1")
      "1asd"

      iex> prepend("asd", 255)
      <<255>> <> "asd"
  """
  @spec prepend(binary, binary | byte) :: binary
  def prepend(bin, prefix)

  def prepend(bin, prefix) when is_binary(bin) and is_integer(prefix) and prefix >= 0 and prefix < 256 do
    prepend(bin, <<prefix>>)
  end

  def prepend(bin, prefix) when is_binary(bin) and is_binary(prefix) do
    prefix <> bin
  end

  ## priv

  defp bin_reverse(<<>>, acc), do: acc
  defp bin_reverse(<<x::binary-size(1), bin::binary>>, acc), do: bin_reverse(bin, x <> acc)

  defp bin_trim_trailing(<<byte, bin::binary>>, byte), do: bin_trim_trailing(bin, byte)
  defp bin_trim_trailing(<<bin::binary>>, _byte), do: reverse(bin)
end
