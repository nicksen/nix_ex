defmodule Nix.Crypto.CipherKeyTest do
  use ExUnit.Case, async: true, parameterize: Enum.map(Nix.Crypto.ciphers(), &%{type: &1})

  import Nix.Crypto

  describe "generate cipher key" do
    test "is required length", %{type: type} do
      assert %{key_length: expected} = cipher_info(type)
      assert byte_size(generate_cipher_key(type)) == expected
    end

    test "is random", %{type: type} do
      assert generate_cipher_key(type) != generate_cipher_key(type)
    end
  end
end
