defmodule Nix.Crypto do
  @moduledoc """
  This module provides a set of cryptographic functions.
  """

  @hashs [
    :sha,
    :sha224,
    :sha256,
    :sha384,
    :sha512,
    :sha3_224,
    :sha3_256,
    :sha3_384,
    :sha3_512,
    :shake128,
    :shake256,
    :blake2b,
    :blake2s
  ]
  @xof_hashs [:shake128, :shake256]

  @encs [:hex, :hex_upper, :base32, :base32_upper, :base64, :base64_url]

  ## types

  @type sha1 :: :sha
  @type sha2 :: :sha224 | :sha256 | :sha384 | :sha512
  @type sha3 :: :sha3_224 | :sha3_256 | :sha3_384 | :sha3_512
  @type sha3_xof :: :shake128 | :shake256
  @type blake2 :: :blake2b | :blake2s

  @type hash_xof_algorithm :: sha3_xof
  @type hash_algorithm :: sha1 | sha2 | sha3 | sha3_xof | blake2

  @type hex :: :hex | :hex_upper
  @type base32 :: :base32 | :base32_upper
  @type base64 :: :base64 | :base64_url

  @type encoding_function :: hex | base32 | base64

  @type hash_option :: {:encoding, encoding_function} | {:length, non_neg_integer}

  ## api

  @doc """
  Compute a message digest.

  `data` is the full message and `type` is a `t:hash_algorithm/0`.

  ## Options

    * `:encoding` (`t:encoding_function/0`) - Pass output through encoding function.

    * `:length` (`t:non_neg_integer/0`) - Digest length in bits. Only used by a
      `t:hash_xof_algorithm/0`. Note that this value applies to the raw digest, i.e. if an
      encoding is used the output length may differ.

  ## Examples

      hash("1", :sha)
      #=> <<53, 106, 25, 43, 121, ...>>

      iex> hash("1", :sha256, :hex)
      "6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b"

      iex> hash("1", :blake2s, :base64)
      "YlhR44dubm2kBclawkaHzkuyzdj72EWSePbwzoA+E+4"

      iex> hash("3", :shake128, encoding: :base64_url, length: 32)
      "Cn_dwg"
  """
  @spec hash(data, type, opts) :: digest
        when data: iodata, type: hash_algorithm, opts: [hash_option], digest: binary
  @spec hash(data, type, encoding) :: digest
        when data: iodata, type: hash_algorithm, encoding: encoding_function, digest: binary
  def hash(data, type, opts \\ [])

  def hash(data, type, encoding) when type in @hashs and encoding in @encs do
    hash(data, type, encoding: encoding)
  end

  def hash(data, type, opts) when type in @hashs and is_list(opts) do
    hashed =
      if type in hash_xof_algorithms() do
        length = Keyword.get(opts, :length, hash_xof_alg_length(type))
        :crypto.hash_xof(type, data, length)
      else
        :crypto.hash(type, data)
      end

    if enc = opts[:encoding] do
      encode(hashed, enc)
    else
      hashed
    end
  end

  @doc false
  @spec hash_algorithms() :: [hash_algorithm]
  def hash_algorithms, do: @hashs

  @doc false
  @spec hash_xof_algorithms() :: [hash_xof_algorithm]
  def hash_xof_algorithms, do: @xof_hashs

  @doc false
  @spec encoding_functions() :: [encoding_function]
  def encoding_functions, do: @encs

  ## priv

  defp encode(data, :hex), do: Base.encode16(data, case: :lower)
  defp encode(data, :hex_upper), do: Base.encode16(data, case: :upper)
  defp encode(data, :base32), do: Base.encode32(data, case: :lower, padding: false)
  defp encode(data, :base32_upper), do: Base.encode32(data, case: :upper, padding: false)
  defp encode(data, :base64), do: Base.encode64(data, padding: false)
  defp encode(data, :base64_url), do: Base.url_encode64(data, padding: false)

  defp hash_xof_alg_length(:shake128), do: 128
  defp hash_xof_alg_length(:shake256), do: 256
end
