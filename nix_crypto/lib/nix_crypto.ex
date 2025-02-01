defmodule Nix.Crypto do
  @moduledoc """
  Documentation for `Nix.Crypto`.
  """

  @block_bytes 3
  @block_chars 4

  @aes_block_size 16
  @iv_bit_length 128

  @epoch NaiveDateTime.to_gregorian_seconds(~N[1970-01-01 00:00:00])

  ## types

  @type aes_key_type :: :aes_128 | :aes_192 | :aes_256
  @type key_format :: :base64 | :bytes

  defguardp is_integers(a, b) when is_integer(a) and is_integer(b)

  @doc """
  Returns `num` random characters.

  Each character represents 6 bits of entropy.

  ## Examples

      iex> rand_chars(24) |> String.length()
      24

      iex> rand_chars(32) |> String.length()
      32

      iex> rand_chars(44) |> String.length()
      44
  """
  @spec rand_chars(num :: pos_integer) :: String.t()
  def rand_chars(num) do
    block_count = div(num, @block_chars)
    block_partial = rem(num, @block_chars)

    block_count = if block_partial > 0, do: block_count + 1, else: block_count
    num_bytes = block_count * @block_bytes

    num_bytes
    |> :crypto.strong_rand_bytes()
    |> encode_key(:base64)
    |> String.slice(0, num)
  end

  @doc """
  Returns a random integer between `low` and `high` (inclusive).

  ## Examples

      iex> n = rand_int(2, 20)
      iex> assert(n >= 2)
      true
      iex> assert(n <= 20)
      true

      iex> n = rand_int(23, 99)
      iex> assert(n >= 23)
      true
      iex> assert(n <= 99)
      true

      iex> n = rand_int(212, 736)
      iex> assert(n >= 212)
      true
      iex> assert(n <= 736)
      true

      iex> n = rand_int(-100, -1)
      iex> assert(n >= -100)
      true
      iex> assert(n <= -1)
      true

      iex> n = rand_int(-100, 100)
      iex> assert(n >= -100)
      true
      iex> assert(n <= 100)
      true
  """
  @spec rand_int(low :: integer, high :: integer) :: integer
  def rand_int(low, high) when is_integers(low, high) and low < high do
    low + :rand.uniform(high - low + 1) - 1
  end

  def rand_int(high, low) when is_integers(low, high) and low < high do
    rand_int(low, high)
  end

  @doc """
  Returns a random integer bound by `range` (inclusive), or between `0` and `boundary` if called
  with an integer.

  ## Examples

      iex> n = rand_int(1..5)
      iex> assert(n >= 1)
      true
      iex> assert(n <= 5)
      true

      iex> n = rand_int(-5..-3)
      iex> assert(n >= -5)
      true
      iex> assert(n <= -3)
      true

      iex> n = rand_int(99)
      iex> assert(n >= 0)
      true
      iex> assert(n <= 99)
      true

      iex> n = rand_int(-40)
      iex> assert(n >= -40)
      true
      iex> assert(n <= 0)
      true

      iex> n = rand_int(5..1//-1)
      iex> assert(n >= 1)
      true
      iex> assert(n <= 5)
      true
  """
  @spec rand_int(range :: Range.t()) :: integer
  @spec rand_int(high :: pos_integer) :: non_neg_integer
  @spec rand_int(low :: neg_integer) :: neg_integer | 0
  def rand_int(boundary)

  def rand_int(%Range{first: low, last: high}) when is_integers(low, high) do
    rand_int(low, high)
  end

  def rand_int(high) when is_integer(high) and high > 0 do
    rand_int(0, high)
  end

  def rand_int(low) when is_integer(low) and low < 0 do
    rand_int(low, 0)
  end

  @doc """
  Returns a random string where the length is equal to `length`.

  ## Examples

      iex> str = rand_bytes(16)
      iex> byte_size(str)
      16
      iex> bit_size(str)
      128

      iex> str = rand_bytes(24)
      iex> byte_size(str)
      24
      iex> bit_size(str)
      192

      iex> str = rand_bytes(32)
      iex> byte_size(str)
      32
      iex> bit_size(str)
      256
  """
  @spec rand_bytes(length :: non_neg_integer) :: binary
  def rand_bytes(length) do
    :crypto.strong_rand_bytes(length)
  end

  @doc """
  Generates an AES key.

  ## Examples

      iex> key = generate_aes_key(:aes_256, :bytes)
      ...> bit_size(key)
      256

      iex> key = generate_aes_key(:aes_256, :base64)
      ...> String.length(key)
      44

      iex> key = generate_aes_key(:aes_192, :bytes)
      ...> bit_size(key)
      192

      iex> key = generate_aes_key(:aes_192, :base64)
      ...> String.length(key)
      32

      iex> key = generate_aes_key(:aes_128, :bytes)
      ...> bit_size(key)
      128

      iex> key = generate_aes_key(:aes_128, :base64)
      ...> String.length(key)
      24
  """
  @spec generate_aes_key(type, format) :: key
        when type: aes_key_type, format: key_format, key: binary
  def generate_aes_key(type, format) do
    type
    |> generate_key()
    |> encode_key(format)
  end

  @doc """
  Encrypt binary `data` with AES in GCM mode.

  Returns a tuple of the `initialization_vector`, the `cipher_text` and the `cipher_tag`.
  """
  @spec encrypt(key, authentication_data, initialization_vector, data) ::
          {:ok, result} | {:error, term}
        when key: binary,
             authentication_data: binary,
             initialization_vector: binary,
             data: binary,
             result: {authentication_data, payload},
             payload: {initialization_vector, cipher_text, cipher_tag},
             cipher_text: binary,
             cipher_tag: binary
  def encrypt(key, authentication_data, initialization_vector, data) do
    do_encrypt(key, initialization_vector, {authentication_data, data}, :aes_gcm)
  end

  @doc """
  Encrypt binary `data` with AES in CBC mode.

  Returns a tuple of `initialization_vector` and `cipher_text`.
  """
  @spec encrypt(key, data) :: {:ok, result} | {:error, term}
        when key: binary,
             data: binary,
             result: {initialization_vector, cipher_text},
             initialization_vector: binary,
             cipher_text: binary
  def encrypt(key, data) do
    iv = rand_bytes(16)
    do_encrypt(key, iv, pad(data, @aes_block_size), :aes_cbc256)
  end

  @doc """
  Encrypt binary `data` with AES in CBG mode with explicit iv via map.

  Returns a tuple of `initialization_vector` and `cipher_text`.
  """
  @spec encrypt(key, data, opts) :: {:ok, result} | {:error, term}
        when key: binary,
             data: binary,
             opts: %{initialization_vector: initialization_vector},
             result: {initialization_vector, cipher_text},
             initialization_vector: binary,
             cipher_text: binary
  def encrypt(key, data, %{initialization_vector: initialization_vector}) do
    do_encrypt(key, initialization_vector, pad(data, @aes_block_size), :aes_cbc256)
  end

  @doc """
  Same as `encrypt/4` but without providing an `initialization_vector`.

  A 128-bit `initialization_vector` is generated automatically, and is returned tupled with the
  `cipher_text` and the `cipher_tag`.
  """
  @spec encrypt(key, authentication_data, data) :: {:ok, result} | {:error, term}
        when key: binary,
             authentication_data: binary,
             data: binary,
             result: {authentication_data, payload},
             payload: {initialization_vector, cipher_text, cipher_tag},
             initialization_vector: binary,
             cipher_text: binary,
             cipher_tag: binary
  def encrypt(key, authentication_data, data) do
    iv = rand_bytes(16)
    do_encrypt(key, iv, {authentication_data, data}, :aes_gcm)
  end

  @doc """
  Decrypt binary `cipher_text` with AES in GCM mode.
  """
  @spec decrypt(key, authentication_data, initialization_vector, cipher_text, cipher_tag) ::
          {:ok, data} | {:error, term}
        when key: binary,
             authentication_data: binary,
             initialization_vector: binary,
             cipher_text: binary,
             cipher_tag: binary,
             data: binary
  def decrypt(key, authentication_data, initialization_vector, cipher_text, cipher_tag) do
    do_decrypt(
      key,
      initialization_vector,
      {authentication_data, cipher_text, cipher_tag},
      :aes_gcm
    )
  end

  @doc """
  Decrypt binary `cipher_text` with AES256 in CBC mode.
  """
  @spec decrypt(key, initialization_vector, cipher_text) :: {:ok, data} | {:error, term}
        when key: binary, initialization_vector: binary, cipher_text: binary, data: binary
  def decrypt(key, initialization_vector, cipher_text) do
    with {:ok, padded_data} <- do_decrypt(key, initialization_vector, cipher_text, :aes_cbc256) do
      {:ok, unpad(padded_data)}
    end
  end

  @doc """
  Encode the three parts of an encryped payload and encode to binary.

  This produces a Unicode `payload` string:

      init_vec   <> cipher_tag <> cipher_text
      [128 bits] <> [128 bits] <> [?? bits]

  This format is suitable for inclusion in for example HTTP request bodies. It can also be used
  with JSON transport formats.
  """
  @spec encode_payload(initialization_vector, cipher_text, cipher_tag) :: payload
        when initialization_vector: binary,
             cipher_text: binary,
             cipher_tag: binary,
             payload: String.t()
  def encode_payload(initialization_vector, cipher_text, cipher_tag) do
    encode_key(initialization_vector <> cipher_tag <> cipher_text, :base64)
  end

  @doc """
  Decode a binary `payload` into the three parts of an encrypted payload>
  """
  @spec decode_payload(payload) :: {:ok, result} | {:error, term}
        when payload: String.t(),
             result: {initialization_vector, cipher_text, cipher_tag},
             initialization_vector: binary,
             cipher_text: binary,
             cipher_tag: binary
  def decode_payload(payload) do
    with {:ok, decoded} <- Base.url_decode64(payload),
         <<iv::bytes-16, cipher_tag::bytes-16, cipher_text::bytes>> <- decoded do
      {:ok, {iv, cipher_text, cipher_tag}}
    end
  end

  @doc """
  Pad `data` with empty bytes to reach `block_size`.

  ## Examples

      iex> pad(<<?t, ?e, ?x>>, 4)
      <<?t, ?e, ?x, 1>>
  """
  @spec pad(data, block_size) :: padded_data
        when data: binary, block_size: integer, padded_data: binary
  def pad(data, block_size) do
    padding = block_size - rem(byte_size(data), block_size)
    data <> to_string(List.duplicate(padding, padding))
  end

  @doc """
  Removes padding from `data`.

  ## Examples

      iex> unpad(<<"text", 3, 3, 3>>)
      <<"text">>
  """
  @spec unpad(data) :: unpadded_data when data: binary, unpadded_data: binary
  def unpad(data) do
    padding = :binary.last(data)
    :binary.part(data, 0, byte_size(data) - padding)
  end

  ## priv

  defp do_encrypt(key, iv, payload, algorithm) do
    case crypto_block_encrypt(algorithm, key, iv, payload) do
      {cipher_text, cipher_tag} ->
        {auth_data, _data} = payload
        {:ok, {auth_data, {iv, cipher_text, cipher_tag}}}

      <<cipher_text::binary>> ->
        {:ok, {iv, cipher_text}}

      other ->
        {:error, other}
    end
  catch
    kind, error -> normalize_error(kind, error, __STACKTRACE__, {key, iv})
  end

  defp do_decrypt(key, iv, cipher_data, algorithm) do
    case crypto_block_decrypt(algorithm, key, iv, cipher_data) do
      :error -> {:error, :decrypt_failed}
      data -> {:ok, data}
    end
  end

  defp map_algorithm(:aes_cbc256, _key) do
    :aes_256_cbc
  end

  defp map_algorithm(:aes_gcm, key) do
    case bit_size(key) do
      128 -> :aes_128_gcm
      192 -> :aes_192_gcm
      256 -> :aes_256_gcm
    end
  end

  defp crypto_block_encrypt(algorithm, key, iv, {aad, data}) do
    :crypto.crypto_one_time_aead(map_algorithm(algorithm, key), key, iv, data, aad, true)
  end

  defp crypto_block_encrypt(algorithm, key, iv, data) do
    :crypto.crypto_one_time(map_algorithm(algorithm, key), key, iv, data, true)
  end

  defp crypto_block_decrypt(algorithm, key, iv, {aad, data, tag}) do
    :crypto.crypto_one_time_aead(map_algorithm(algorithm, key), key, iv, data, aad, tag, false)
  end

  defp crypto_block_decrypt(algorithm, key, iv, data) do
    :crypto.crypto_one_time(map_algorithm(algorithm, key), key, iv, data, false)
  end

  defp generate_key(:aes_128), do: rand_bytes(16)
  defp generate_key(:aes_192), do: rand_bytes(24)
  defp generate_key(:aes_256), do: rand_bytes(32)

  defp encode_key(key, :base64), do: Base.url_encode64(key)
  defp encode_key(key, :bytes), do: key

  defp normalize_error(kind, error, stacktrace, key_iv \\ nil) do
    # check for key and iv size errors
    with :ok <- check_key_iv_size(key_iv) do
      case Exception.normalize(kind, error) do
        %{term: %{message: message}} -> {:error, message}
        %{message: message} -> {:error, message}
        normalized_error -> {kind, normalized_error, stacktrace}
      end
    end
  end

  defp check_key_iv_size(nil), do: :ok

  defp check_key_iv_size({_key, iv}) when bit_size(iv) != @iv_bit_length, do: {:error, :bad_iv_size}

  defp check_key_iv_size({key, _iv}) when rem(bit_size(key), 128) == 0, do: :ok
  defp check_key_iv_size({key, _iv}) when rem(bit_size(key), 192) == 0, do: :ok
  defp check_key_iv_size({key, _iv}) when rem(bit_size(key), 256) == 0, do: :ok
  defp check_key_iv_size({_key, _iv}), do: {:error, :bad_key_size}
end
