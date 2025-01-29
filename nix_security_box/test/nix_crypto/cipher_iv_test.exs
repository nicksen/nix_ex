defmodule Nix.Crypto.CipherIVTest do
  use ExUnit.Case, async: true, parameterize: Enum.map(Nix.Crypto.ciphers_iv(), &%{type: &1})

  import Nix.Crypto

  describe "generate cipher iv" do
    test "is required length", %{type: type} do
      assert %{iv_length: expected} = cipher_info(type)
      assert byte_size(generate_cipher_iv(type)) == expected
    end

    test "is random", %{type: type} do
      assert generate_cipher_iv(type) != generate_cipher_iv(type)
    end
  end
end
