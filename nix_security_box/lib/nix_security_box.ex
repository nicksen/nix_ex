defmodule Nix.SecurityBox do
  @moduledoc """
  A collection of security oriented functions.
  """

  @doc """
  Encrypt a binary.
  """
  @spec encrypt(plaintext) :: encrypted when plaintext: iodata | nil, encrypted: binary
  def encrypt(plaintext)

  def encrypt(nil), do: encrypt("")

  def encrypt(plaintext) do
    Nix.Crypto.hash(plaintext, :shake256, encoding: :hex, length: 160)
  end

  @doc """
  Compare a binary to it's encrypted version to test if they match.
  """
  @spec decrypted?(plaintext, encrypted) :: boolean
        when plaintext: iodata | nil, encrypted: binary | nil
  def decrypted?(plaintext, encrypted) do
    plaintext
    |> encrypt()
    |> secure_compare(encrypted)
  end

  ## priv

  defp secure_compare(left, right) when byte_size(left) == byte_size(right) do
    :crypto.hash_equals(left, right)
  end

  defp secure_compare(_left, _right), do: false
end
