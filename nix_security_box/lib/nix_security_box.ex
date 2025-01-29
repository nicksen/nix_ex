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
    plaintext
    |> Nix.Crypto.hash(:sha)
    |> :erlang.bitstring_to_list()
    |> Enum.map(&:io_lib.format("~2.16.0b", [&1]))
    |> :erlang.list_to_bitstring()
  end
end
