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
  @hmac_hashs [
    :sha,
    :sha224,
    :sha256,
    :sha384,
    :sha512,
    :sha3_224,
    :sha3_256,
    :sha3_384,
    :sha3_512
  ]

  @cipher_ivs [
    :aes_128_cbc,
    :aes_128_cfb128,
    :aes_128_cfb8,
    :aes_128_ctr,
    :aes_128_ofb,
    :aes_192_cbc,
    :aes_192_cfb128,
    :aes_192_cfb8,
    :aes_192_ctr,
    :aes_192_ofb,
    :aes_256_cbc,
    :aes_256_cfb128,
    :aes_256_cfb8,
    :aes_256_ctr,
    :aes_256_ofb,
    :aes_cbc,
    :aes_cfb128,
    :aes_cfb8,
    :aes_ctr,
    :blowfish_cbc,
    :blowfish_cfb64,
    :blowfish_ofb64,
    :chacha20,
    :des_cbc,
    :des_cfb,
    :des_ede3_cbc,
    :des_ede3_cfb,
    :rc2_cbc,
    :sm4_cbc,
    :sm4_cfb,
    :sm4_ctr,
    :sm4_ofb
  ]
  @cipher_no_ivs [
    :aes_128_ecb,
    :aes_192_ecb,
    :aes_256_ecb,
    :aes_ecb,
    :blowfish_ecb,
    :des_ecb,
    :rc4,
    :sm4_ecb
  ]

  @encs [:hex, :hex_upper, :base32, :base32_upper, :base64, :base64_url]

  ## types

  @type sha1 :: :sha
  @type sha2 :: :sha224 | :sha256 | :sha384 | :sha512
  @type sha3 :: :sha3_224 | :sha3_256 | :sha3_384 | :sha3_512
  @type sha3_xof :: :shake128 | :shake256
  @type blake2 :: :blake2b | :blake2s

  @type hash_xof_algorithm :: sha3_xof
  @type hash_algorithm :: sha1 | sha2 | sha3 | sha3_xof | blake2
  @type hmac_hash_algorithm :: sha1 | sha2 | sha3

  @type cipher_mode ::
          :undefined
          | :cbc_mode
          | :ccm_mode
          | :cfb_mode
          | :ctr_mode
          | :ecb_mode
          | :gcm_mode
          | :ige_mode
          | :ocb_mode
          | :ofb_mode
          | :wrap_mode
          | :xts_mode

  @type cipher_iv ::
          :aes_128_cbc
          | :aes_128_cfb128
          | :aes_128_cfb8
          | :aes_128_ctr
          | :aes_128_ofb
          | :aes_192_cbc
          | :aes_192_cfb128
          | :aes_192_cfb8
          | :aes_192_ctr
          | :aes_192_ofb
          | :aes_256_cbc
          | :aes_256_cfb128
          | :aes_256_cfb8
          | :aes_256_ctr
          | :aes_256_ofb
          | :aes_cbc
          | :aes_cfb128
          | :aes_cfb8
          | :aes_ctr
          | :blowfish_cbc
          | :blowfish_cfb64
          | :blowfish_ofb64
          | :chacha20
          | :des_cbc
          | :des_cfb
          | :des_ede3_cbc
          | :des_ede3_cfb
          | :rc2_cbc
          | :sm4_cbc
          | :sm4_cfb
          | :sm4_ctr
          | :sm4_ofb
  @type cipher_no_iv ::
          :aes_128_ecb
          | :aes_192_ecb
          | :aes_256_ecb
          | :aes_ecb
          | :blowfish_ecb
          | :des_ecb
          | :rc4
          | :sm4_ecb
  @type cipher :: cipher_no_iv | cipher_iv

  @type hex :: :hex | :hex_upper
  @type base32 :: :base32 | :base32_upper
  @type base64 :: :base64 | :base64_url

  @type encoding_function :: hex | base32 | base64

  @type hash_option :: {:encoding, encoding_function} | {:length, non_neg_integer}
  @type hmac_option :: {:encoding, encoding_function}
  @type encrypt_option :: {:encoding, encoding_function}

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
    fun =
      if type in hash_xof_algorithms() do
        length = Keyword.get(opts, :length, hash_xof_alg_length(type))
        &:crypto.hash_xof(&2, &1, length)
      else
        &:crypto.hash(&2, &1)
      end

    do_crypto(fun, data, type, opts)
  end

  @doc """
  Compute a HMAC (Hash-based Message Authentication Code).

  `data` is the full message and `type` is a `t:hmac_hash_algorithm/0`.

  `key` is the authentication key with a length according to the `type`. The key length can be
  found with the `:crypto.hash_info/1` function.

  ## Options

    * `:encoding` (`t:encoding_function/0`) - Pass output through encoding function.

  ## Examples

      hmac("1", :sha, "secret")
      #=> <<81, 161, 228, 211, 205, ...>>

      iex> hmac("1", :sha256, "secret", :hex)
      "bd28ee142ca5b46259f6e27fc3a4216f447bd5843c406e63219cff30e73b135b"

      iex> hmac("1", :sha3_384, "secret", :base64_url)
      "nDgul0AU1yYS-LXD7_sOPf7A1MnEZyZwsPjiKb3YjQhALa5IgP20tVMlZTeDfyvE"
  """
  @spec hmac(data, type, key, opts) :: mac
        when data: iodata,
             type: hmac_hash_algorithm,
             key: iodata,
             opts: [hmac_option],
             mac: binary
  @spec hmac(data, type, key, encoding) :: mac
        when data: iodata,
             type: hmac_hash_algorithm,
             key: iodata,
             encoding: encoding_function,
             mac: binary
  def hmac(data, type, key, opts \\ [])

  def hmac(data, type, key, encoding) when type in @hmac_hashs and encoding in @encs do
    hmac(data, type, key, encoding: encoding)
  end

  def hmac(data, type, key, opts) when type in @hmac_hashs and is_list(opts) do
    fun = &:crypto.mac(:hmac, &2, key, &1)
    do_crypto(fun, data, type, opts)
  end

  @doc """
  Encrypt the `data`.

  `data` is the full data to be encrypted and `cipher` is a `t:cipher_no_iv/0`.

  ## Options

  ## Examples
  """
  @spec encrypt(data, cipher, key, opts) :: result
        when data: iodata,
             cipher: cipher_no_iv,
             key: iodata,
             opts: [encrypt_option],
             result: binary
  @spec encrypt(data, cipher, key, encoding) :: result
        when data: iodata,
             cipher: cipher_no_iv,
             key: iodata,
             encoding: encoding_function,
             result: binary
  def encrypt(data, cipher, key, opts \\ [])

  def encrypt(data, cipher, key, encoding) when cipher in @cipher_no_ivs and encoding in @encs do
    encrypt(data, cipher, key, encoding: encoding)
  end

  def encrypt(data, cipher, key, opts) when cipher in @cipher_no_ivs and is_list(opts) do
    fun = &:crypto.crypto_one_time(&2, key, &1, encrypt: true, padding: :zero)
    do_crypto(fun, data, cipher, opts)
  end

  def encrypt(data, cipher, key, iv) when cipher in @cipher_ivs do
    encrypt(data, cipher, key, iv, [])
  end

  @doc """
  Encrypt the `data`.

  `data` is the full data to be encrypted and `cipher` is a `t:cipher_iv/0`.

  ## Options

  ## Examples
  """
  @spec encrypt(data, cipher, key, iv, opts) :: result
        when data: iodata,
             cipher: cipher_iv,
             key: iodata,
             iv: iodata,
             opts: [encrypt_option],
             result: binary
  @spec encrypt(data, cipher, key, iv, encoding) :: result
        when data: iodata,
             cipher: cipher_iv,
             key: iodata,
             iv: iodata,
             encoding: encoding_function,
             result: binary
  def encrypt(data, cipher, key, iv, opts)

  def encrypt(data, cipher, key, iv, encoding) when cipher in @cipher_ivs and encoding in @encs do
    encrypt(data, cipher, key, iv, encoding: encoding)
  end

  def encrypt(data, cipher, key, iv, opts) when cipher in @cipher_ivs and is_list(opts) do
    fun = &:crypto.crypto_one_time(&2, key, iv, &1, encrypt: true, padding: :zero)
    do_crypto(fun, data, cipher, opts)
  end

  @doc """
  Generate a random key with the length required by `cipher`.

  ## Examples

      iex> generate_cipher_key(:aes_256_ecb) |> byte_size()
      32

      iex> generate_cipher_key(:aes_128_cbc) |> byte_size()
      16
  """
  @spec generate_cipher_key(cipher) :: key when cipher: cipher, key: binary
  def generate_cipher_key(cipher) when cipher in @cipher_no_ivs or cipher in @cipher_ivs do
    cipher
    |> :crypto.cipher_info()
    |> Map.fetch!(:key_length)
    |> generate_key()
  end

  @doc """
  Generate a random IV with the length required by `cipher`.

  ## Examples

      iex> generate_cipher_iv(:aes_128_cbc) |> byte_size()
      16

      iex> generate_cipher_iv(:aes_256_ecb)
      <<>>
  """
  @spec generate_cipher_iv(cipher) :: iv when cipher: cipher, iv: binary
  def generate_cipher_iv(cipher)

  def generate_cipher_iv(cipher) when cipher in @cipher_no_ivs, do: <<>>

  def generate_cipher_iv(cipher) when cipher in @cipher_ivs do
    cipher
    |> :crypto.cipher_info()
    |> Map.fetch!(:iv_length)
    |> generate_key()
  end

  @doc """
  Generate a random key with `length`.

  ## Examples

      iex> generate_key(16) |> byte_size()
      16

      iex> generate_key(32) |> byte_size()
      32

      iex> generate_key(128) |> byte_size()
      128
  """
  @spec generate_key(length) :: key when length: non_neg_integer, key: binary
  def generate_key(length) when is_integer(length) and length > 0 do
    :crypto.strong_rand_bytes(length)
  end

  @doc false
  @spec hash_algorithms() :: [hash_algorithm]
  def hash_algorithms, do: @hashs

  @doc false
  @spec hash_xof_algorithms() :: [hash_xof_algorithm]
  def hash_xof_algorithms, do: @xof_hashs

  @doc false
  @spec hmac_hash_algorithms() :: [hmac_hash_algorithm]
  def hmac_hash_algorithms, do: @hmac_hashs

  @doc false
  @spec ciphers() :: [cipher]
  def ciphers, do: ciphers_no_iv() ++ ciphers_iv()

  @doc false
  @spec ciphers_no_iv() :: [cipher_no_iv]
  def ciphers_no_iv, do: @cipher_no_ivs

  @doc false
  @spec ciphers_iv() :: [cipher_iv]
  def ciphers_iv, do: @cipher_ivs

  @doc false
  @spec encoding_functions() :: [encoding_function]
  def encoding_functions, do: @encs

  @doc false
  @spec cipher_info(type) :: result
        when type: cipher,
             result: %{
               key_length: integer,
               iv_length: integer,
               block_size: integer,
               mode: cipher_mode,
               type: :undefined | integer,
               prop_aead: boolean
             }
  def cipher_info(type) when type in @cipher_no_ivs or type in @cipher_ivs do
    :crypto.cipher_info(type)
  end

  @doc false
  @spec hash_info(type) :: result
        when type: hash_algorithm, result: %{size: integer, block_size: integer, type: integer}
  def hash_info(type) when type in @hashs do
    :crypto.hash_info(type)
  end

  ## priv

  defp do_crypto(fun, data, type, opts) do
    hashed = fun.(data, type)

    case Keyword.fetch(opts, :encoding) do
      {:ok, enc} -> encode(hashed, enc)
      :error -> hashed
    end
  end

  defp encode(data, :hex), do: Base.encode16(data, case: :lower)
  defp encode(data, :hex_upper), do: Base.encode16(data, case: :upper)
  defp encode(data, :base32), do: Base.encode32(data, case: :lower, padding: false)
  defp encode(data, :base32_upper), do: Base.encode32(data, case: :upper, padding: false)
  defp encode(data, :base64), do: Base.encode64(data, padding: false)
  defp encode(data, :base64_url), do: Base.url_encode64(data, padding: false)

  defp hash_xof_alg_length(:shake128), do: 128
  defp hash_xof_alg_length(:shake256), do: 256
end
