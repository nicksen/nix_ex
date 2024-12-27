defmodule Nix.Binary do
  @moduledoc """
  Functions to operate on binaries.

  Wrapper for [Erlangs `:binary` module](`:binary`) that try to mimic `String` behavior but on
  bytes, and some very simple functions that are here just to make piping operations on binaries
  easier.
  """

  ## guards

  @doc """
  Returns `true` if `term` is a `t:byte/0`, otherwise returns `false`.

  A `t:byte/0` is an integer within the `0..255` range.
  """
  @doc guard: true
  defguard is_byte(value) when is_integer(value) and value >= 0 and value < 256

  ## types

  @typedoc """
  Represents a part (or range) of a binary. `start` is a zero-based offset into a `t:binary/0`
  and `length` is the length of that part.

  As input to functions in this module, a reverse part specification is allowed, constructed with
  a negative `length`, so that the part of the binary begins at `start + length` and is `-length`
  long. This is useful for referencing the last `n` bytes of a binary as `{size(binary), -n}`.
  The functions in this module always return `t:part/0`s with positive `length`.
  """
  @type part :: {start :: non_neg_integer, length :: integer}

  ## api

  @doc """
  Concatenates two binaries.

  Handy for piping. With binary args it's the same as `<>/2`.

  ## Examples

      iex> append(<<2, 3>>, <<4>>)
      <<2, 3, 4>>

      iex> append(<<2, 3>>, 4)
      <<2, 3, 4>>

      iex> append(<<>>, 0)
      <<0>>
  """
  @spec append(left, right) :: binary when left: binary, right: binary | byte
  def append(left, right)

  def append(bin, suffix) when is_binary(bin) and is_binary(suffix) do
    bin <> suffix
  end

  def append(bin, suffix) when is_binary(bin) and is_byte(suffix) do
    append(bin, <<suffix>>)
  end

  @doc """
  Returns the byte at position `pos` (zero-based) in binary `subject` as an integer.

  If `pos` is negative, it is relative to the end of `subject`.

  If `pos` >= [`byte_size(subject)`](`byte_size/1`), `nil` will be returned (following `Enum` and
  `String` behaviour).

  ## Examples

      iex> at(<<1, 2, 3>>, 0)
      1

      iex> at(<<1, 2, 3>>, 2)
      3

      iex> at(<<1, 2, 3>>, -1)
      3

      iex> at(<<1, 2, 3>>, -3)
      1

      iex> at(<<1, 2, 3>>, 3)
      nil

      iex> at(<<1, 2, 3>>, -4)
      nil
  """
  @spec at(subject, pos) :: byte | nil when subject: binary, pos: integer
  def at(subject, pos)

  def at(bin, index) when is_binary(bin) and is_integer(index) and index >= 0 and index < byte_size(bin) do
    :binary.at(bin, index)
  end

  def at(bin, index) when is_binary(bin) and is_integer(index) and index < 0 and abs(index) <= byte_size(bin) do
    at(bin, byte_size(bin) + index)
  end

  def at(bin, index) when is_binary(bin) and is_integer(index) do
    nil
  end

  @doc """
  Same as [`copy(subject, 1)`](`copy/2`).
  """
  @spec copy(subject) :: binary when subject: binary
  def copy(subject)

  def copy(bin) do
    copy(bin, 1)
  end

  @doc """
  Creates a binary with the content of `subject` duplicated `n` times.

  This function always creates a new binary, even if `n = 1`. By using `copy/1` on a binary
  referencing a larger binary, one can free up the larger binary for garbage collection.

    > #### Note {: .info }
    >
    > By deliberately copying a single binary to avoid referencing a larger binary, one can,
    > instead of freeing up the larger binary for later garbage collection, create much more
    > binary data than needed. Sharing binary data is usually good. Only in special cases, when
    > small parts reference large binaries and the large binaries are no longer used in any
    > process, deliberate copying can be a good idea.

  ## Examples

      iex> copy(<<3, 7>>, 3)
      <<3, 7, 3, 7, 3, 7>>

      iex> copy(<<1, 2, 3>>, 1)
      <<1, 2, 3>>

      iex> copy(<<>>, 10)
      <<>>

      iex> copy(<<1>>, 0)
      <<>>
  """
  @spec copy(subject, n) :: binary when subject: binary, n: non_neg_integer
  def copy(subject, n)

  def copy(bin, num) when is_binary(bin) and is_integer(num) do
    :binary.copy(bin, num)
  end

  @doc """
  Creates a binary without the first `n` bytes from `subject`.

  A negative `n` can be used to drop from the end of `subject`. If `n` references outside the
  binary, an empty binary will be returned.

  ## Examples

      iex> drop(<<1, 2, 3>>, 2)
      <<3>>

      iex> drop(<<1, 2, 3>>, -1)
      <<1, 2>>

      iex> drop(<<1, 2>>, 10)
      <<>>
  """
  @spec drop(subject, n) :: binary when subject: binary, n: integer
  def drop(subject, n)

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
  Returns the first byte of `bin`, or `nil` if `bin` is empty

  ## Examples

      iex> first(<<97, 98>>)
      97

      iex> first(<<1>>)
      1

      iex> first(<<>>)
      nil
  """
  @spec first(subject) :: byte | nil when subject: binary

  def first(bin) when is_binary(bin) and byte_size(bin) == 0 do
    nil
  end

  def first(bin) when is_binary(bin) do
    :binary.first(bin)
  end

  @doc """
  Returns the first byte of `bin`. Raises `ArgumentError` if `bin` is empty.

  ## Examples

      iex> first!(<<97, 98>>)
      97

      iex> first!("")
      ** (ArgumentError) a zero-sized binary is not allowed
  """
  @spec first!(subject) :: byte when subject: binary
  def first!(bin) when is_binary(bin) do
    with nil <- first(bin) do
      raise ArgumentError, "a zero-sized binary is not allowed"
    end
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
  Convert list of bytes into binary

  ## Examples

      iex> from_list([1, 2])
      <<1, 2>>

      iex> from_list([])
      <<>>
  """
  @spec from_list(byte_list) :: binary when byte_list: [byte]
  def from_list(list) when is_list(list) do
    :binary.list_to_bin(list)
  end

  @doc """
  Returns the last byte of `bin`, or `nil` if `bin` is empty

  ## Examples

      iex> last("bender is great")
      ?t

      iex> last(<<1>>)
      1

      iex> last(<<>>)
      nil
  """
  @spec last(subject) :: byte | nil when subject: binary

  def last(bin) when is_binary(bin) and byte_size(bin) == 0 do
    nil
  end

  def last(bin) when is_binary(bin) do
    :binary.last(bin)
  end

  @doc """
  Returns the last byte of `bin`. Raises `ArgumentError` if `bin` is empty.

  ## Examples

      iex> last!("what")
      ?t

      iex> last!("")
      ** (ArgumentError) a zero-sized binary is not allowed
  """
  @spec last!(subject) :: byte when subject: binary
  def last!(bin) when is_binary(bin) do
    with nil <- last(bin) do
      raise ArgumentError, "a zero-sized binary is not allowed"
    end
  end

  @doc """
  Returns the length of the longest common prefix in the binaries

  ## Examples

      iex> longest_common_prefix(["moo", "monad", "mojo"])
      2
  """
  @spec longest_common_prefix([binary, ...]) :: non_neg_integer
  def longest_common_prefix(bins) when is_list(bins) do
    :binary.longest_common_prefix(bins)
  end

  @doc """
  Returns the length of the longest common suffix in the binaries

  ## Examples

      iex> longest_common_suffix(["moo", "boo", "mojo"])
      1
  """
  @spec longest_common_suffix([binary, ...]) :: non_neg_integer
  def longest_common_suffix(bins) when is_list(bins) do
    :binary.longest_common_suffix(bins)
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
  @spec pad_leading(binary, pos_integer) :: binary
  @spec pad_leading(binary, pos_integer, byte) :: binary
  def pad_leading(bin, length, prefix \\ 0)

  def pad_leading(bin, len, byte)
      when is_binary(bin) and is_integer(len) and is_byte(byte) and len > 0 and byte_size(bin) >= len do
    bin
  end

  def pad_leading(bin, len, byte) when is_binary(bin) and is_integer(len) and is_byte(byte) and len > 0 do
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
  @spec pad_trailing(binary, pos_integer) :: binary
  @spec pad_trailing(binary, pos_integer, byte) :: binary
  def pad_trailing(bin, length, suffix \\ 0)

  def pad_trailing(bin, len, byte)
      when is_binary(bin) and is_integer(len) and is_byte(byte) and len > 0 and byte_size(bin) >= len do
    bin
  end

  def pad_trailing(bin, len, byte) when is_binary(bin) and is_integer(len) and is_byte(byte) and len > 0 do
    bin <> copy(<<byte>>, len - byte_size(bin))
  end

  @doc """
  Extracts the part of binary `subject` starting at the offset `pos` and of the given `length`.

  A negative `pos` can be used to start extracting bytes relative the end of a binary. A negative
  `length` can be used to extract bytes at the end of a binary.

  If `length` references outside the binary, it will clip to the binary size.

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
  @spec part(subject, pos, length) :: binary when subject: binary, pos: integer, length: integer
  def part(subject, pos, length)

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
    binary_part(bin, idx, len)
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

  def prepend(bin, prefix) when is_binary(bin) and is_byte(prefix) do
    prepend(bin, <<prefix>>)
  end

  def prepend(bin, prefix) when is_binary(bin) and is_binary(prefix) do
    prefix <> bin
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
  @spec replace(binary, nonempty_binary, binary) :: binary
  @spec replace(binary, binary, binary, keyword) :: binary
  def replace(bin, pattern, replacement, opts \\ [])
      when is_binary(bin) and is_binary(pattern) and is_binary(replacement) do
    replace_opts = (opts[:global] == false && []) || [:global]
    :binary.replace(bin, pattern, replacement, replace_opts)
  end

  @doc """
  Reverse bytes order in the binary

  ## Examples

      iex> reverse(<<1, 2, 3>>)
      <<3, 2, 1>>

      iex> reverse(<<1>>)
      <<1>>

      iex> reverse(<<>>)
      <<>>
  """
  @spec reverse(subject) :: binary when subject: binary
  def reverse(bin) when is_binary(bin), do: bin_reverse(bin, <<>>)

  @doc """
  Splits `subject` into a list of binaries based on `pattern`.

  `pattern` can be a binary or a byte. It mimics erlangs `:binary.split/3` split behavior rather
  than `String.split/3`, and only splits once by default. `global: true` option can be provided
  to split on all occurences.

  ## Options

    * `:scope` - limit the scope of the search for matches.
    * `:trim` - remove trailing empty parts (default `false`).
    * `:trim_all` - remove all empty parts (default `false`).
    * `:global` - split on all occurrences, or only the first (default `false`).

  ## Examples

      iex> split(<<1, 2, 3, 2, 3>>, <<3, 2>>)
      [<<1, 2>>, <<3>>]

      iex> split(<<1, 2, 3, 2, 3>>, 2)
      [<<1>>, <<3, 2, 3>>]

      iex> split(<<1, 2, 3, 2, 3>>, 2, global: true)
      [<<1>>, <<3>>, <<3>>]
  """
  @spec split(subject, pattern, options) :: parts
        when subject: binary,
             pattern: nonempty_binary | byte,
             options: [option],
             option: {:global, boolean} | {:scope, part} | {:trim, boolean} | {:trim_all, boolean},
             parts: [binary]
  def split(bin, pattern, opts \\ [])

  def split(bin, pattern, opts) when is_binary(bin) and is_byte(pattern) do
    split(bin, <<pattern>>, opts)
  end

  def split(bin, pattern, opts) when is_binary(bin) and is_binary(pattern) and byte_size(pattern) > 0 do
    split_opts = get_opts(opts, [:global, :scope, :trim, :trim_all])
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

  def split_at(bin, index) when is_binary(bin) and is_integer(index) and index >= byte_size(bin) do
    {bin, <<>>}
  end

  def split_at(bin, index) when is_binary(bin) and is_integer(index) and index < byte_size(bin) * -1 do
    {<<>>, bin}
  end

  def split_at(bin, index) when is_binary(bin) and is_integer(index) and index < 0 do
    split_at(bin, byte_size(bin) + index)
  end

  def split_at(bin, index) when is_binary(bin) and is_integer(index) do
    {binary_part(bin, 0, index), binary_part(bin, index, byte_size(bin) - index)}
  end

  @doc """
  Creates a binary from the first `n` bytes out of `subject`.

  A negative `n` can be used to extract bytes at the end of `subject`. If `n` >
  [`byte_size(subject)`](`byte_size/1`), it will return the full binary.

  ## Examples

      iex> take(<<1, 2, 3>>, 2)
      <<1, 2>>

      iex> take(<<1, 2>>, 10)
      <<1, 2>>

      iex> take(<<1, 2, 3>>, -2)
      <<2, 3>>
  """
  @spec take(subject, n) :: binary when subject: binary, n: integer
  def take(subject, n)

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
  Converts `subject` to to a list of `byte`s.

  ## Examples

      iex> to_list(<<1, 2>>)
      [1, 2]

      iex> to_list("moo")
      [?m, ?o, ?o]

      iex> to_list(<<>>)
      []
  """
  @spec to_list(subject) :: [byte] when subject: binary
  def to_list(bin) when is_binary(bin) do
    :binary.bin_to_list(bin)
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

  def trim_leading(<<byte, bin::binary>>, byte) when is_binary(bin) and is_byte(byte) do
    trim_leading(bin, byte)
  end

  def trim_leading(bin, byte) when is_binary(bin) and is_byte(byte) do
    bin
  end

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
  def trim_trailing(bin, suffix \\ 0) when is_binary(bin) and is_byte(suffix) do
    bin
    |> reverse()
    |> bin_trim_trailing(suffix)
  end

  ## priv

  defp bin_reverse(<<>>, acc), do: acc
  defp bin_reverse(<<x::binary-size(1), bin::binary>>, acc), do: bin_reverse(bin, x <> acc)

  defp bin_trim_trailing(<<byte, bin::binary>>, byte), do: bin_trim_trailing(bin, byte)
  defp bin_trim_trailing(<<bin::binary>>, _byte), do: reverse(bin)

  defp get_opts(opts, keys) do
    opts
    |> Keyword.new(fn
      opt when is_atom(opt) -> {opt, true}
      {_opt, _value} = item -> item
    end)
    |> Keyword.take(keys)
    |> Keyword.filter(fn {_opt, value} -> value != false end)
    |> Enum.map(fn
      {opt, true} -> opt
      {_opt, _value} = item -> item
    end)
  end
end
