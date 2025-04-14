defmodule Nix.TOTP do
  @moduledoc """
  Functions for implementing time-based one-time passwords (TOTP) for use in multi-factor
  authentication flows.

  Provided functions:

    * Generate secrets composed of random bytes
    * Generate URIs for use in authenticator apps
    * Generate time-based one-time passwords for a secret
  """

  @totp_size 6
  @default_totp_period 30
  @otpauth_base_uri "otpauth://totp"

  ## types

  @typedoc "A `DateTime`, `NaiveDateTime` or the unix epoch in seconds."
  @type time :: DateTime.t() | NaiveDateTime.t() | integer

  @typedoc "Options for `verification_code/2`."
  @type code_options :: {:time, time} | {:period, pos_integer}

  @typedoc "Options for `valid?/3`."
  @type valid_options :: {:time, time} | {:period, pos_integer} | {:since, time | nil}

  @type param_name :: String.t() | atom | number
  @type param_value :: String.t() | atom | number | boolean | nil

  @type query_parameters :: [{param_name, param_value}]

  ## api

  @doc """
  Generate a URI to use with authenticator apps.

  Can also be encoded in a QR code, for example using [eqrcode](https://hexdocs.pm/eqrcode) to
  get an svg.

  ## Examples

      iex> otpauth_uri("Acme:alice", "abcd", issuer: "Acme")
      "otpauth://totp/Acme:alice?secret=MFRGGZA&issuer=Acme"
  """
  @spec otpauth_uri(label, secret, uri_params) :: String.t()
        when label: String.t(), secret: binary, uri_params: query_parameters
  def otpauth_uri(label, secret, uri_params \\ []) when is_binary(label) and is_binary(secret) do
    key = Base.encode32(secret, padding: false)

    query =
      uri_params
      |> Keyword.put(:secret, key)
      |> URI.encode_query(:rfc3986)

    uri = URI.parse(@otpauth_base_uri <> "/" <> URI.encode(label))

    uri
    |> URI.append_query(query)
    |> URI.to_string()
  end

  @doc """
  Generate a secret binary made up of random bytes.

  ## Examples

      iex> key = secret()
      ...> byte_size(key)
      20

      iex> key = secret(32)
      ...> byte_size(key)
      32
  """
  @spec secret(size) :: binary when size: non_neg_integer
  def secret(size \\ 20) when is_integer(size) and size >= 0 do
    :crypto.strong_rand_bytes(size)
  end

  @doc """
  Generate time-based one-time password (TOTP).

  ## Options

    * `:time` - the time (can be either a `NaiveDateTime`, `DateTime` or an epoch *in seconds*)
      to be used. Defaults to current timestamp.
    * `:period` - the period (in seconds) for how long the code is valid. Defaults to 30. If this
      option is given to `verification_code/2`, it must also be provided to `valid?/3`.

  ## Examples

      iex> secret = Base.decode32!("PTEPUGZ7DUWTBGMW4WLKB6U63MGKKMCA")
      ...> verification_code(secret, time: 1)
      "579282"
  """
  @spec verification_code(secret, opts) :: String.t() when secret: binary, opts: [code_options]
  def verification_code(secret, opts \\ []) when is_binary(secret) and is_list(opts) do
    time =
      opts
      |> Keyword.get_lazy(:time, &now/0)
      |> to_unix()

    period = Keyword.get(opts, :period, @default_totp_period)

    generate_code(secret, time, period)
  end

  @doc """
  Check the validity of the given `secret` + `otp` combination.

  ## Options

    * `:time` - the time (can be either a `NaiveDateTime`, `DateTime` or an epoch *in seconds*)
      to be used. Defaults to current timestamp.
    * `:since` - the last time the secret was used. Same type as `:time`.
    * `:period` - the period (in seconds) for how long the code is valid. Defaults to 30. If this
      option is given to `verification_code/2`, it must also be provided to `valid?/3`.

  ## Examples

      iex> key = secret()
      iex> code = verification_code(key)
      ...> valid?(key, code)
      true
  """
  @spec valid?(secret, otp, opts) :: boolean
        when secret: binary, otp: String.t(), opts: [valid_options]
  def valid?(secret, otp, opts \\ [])

  def valid?(secret, code, opts) do
    time =
      opts
      |> Keyword.get_lazy(:time, &now/0)
      |> to_unix()

    period = Keyword.get(opts, :period, @default_totp_period)
    since = Keyword.get(opts, :since)
    verification = generate_code(secret, time, period)

    matches? =
      byte_size(code) == byte_size(verification) and :crypto.hash_equals(code, verification)

    matches? and not reused?(time, period, since)
  end

  @doc """
  Convert `timestamp` to unix epoch seconds.

  ## Examples

      iex> to_unix(~U[1970-01-01 00:00:00Z])
      0

      iex> to_unix(~N[1970-01-02 00:00:00])
      86_400

      iex> to_unix(50)
      50
  """
  @spec to_unix(timestamp) :: epoch when timestamp: time, epoch: integer
  def to_unix(timestamp)

  def to_unix(%NaiveDateTime{} = ts), do: NaiveDateTime.diff(ts, ~N[1970-01-01 00:00:00])
  def to_unix(%DateTime{} = ts), do: DateTime.to_unix(ts)
  def to_unix(epoch) when is_integer(epoch), do: epoch

  ## priv

  defp generate_code(secret, time, period) do
    secret
    |> hmac(time, period)
    |> hmac_trunc()
    |> rem(1_000_000)
    |> to_string()
    |> String.pad_leading(@totp_size, "0")
  end

  defp reused?(_time, _period, nil), do: false

  defp reused?(time, period, since) do
    Integer.floor_div(to_unix(time), period) <= Integer.floor_div(to_unix(since), period)
  end

  defp hmac(secret, time, period) do
    moving_factor = <<Integer.floor_div(time, period)::64>>
    hmac_sha(secret, moving_factor)
  end

  defp hmac_sha(key, data), do: :crypto.mac(:hmac, :sha, key, data)

  defp hmac_trunc(data) do
    <<_::19-binary, _::4, offset::4>> = data
    <<_::size(offset)-binary, p::4-binary, _::binary>> = data
    <<_::1, bits::31>> = p

    bits
  end

  defp now(unit \\ :second), do: System.os_time(unit)
end
