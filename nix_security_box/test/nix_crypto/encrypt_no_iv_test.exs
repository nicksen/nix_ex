defmodule Nix.Crypto.EncryptNoIVTest do
  use ExUnit.Case,
    async: true,
    parameterize: Enum.map(Nix.Crypto.ciphers_no_iv(), &%{type: &1})

  use ExUnitProperties

  import Nix.Crypto

  describe "encrypt" do
    test "is consistent", %{type: type} do
      msg = "example"
      key = generate_cipher_key(type)
      enc = encrypt(msg, key, type)

      assert enc != msg
      assert enc == encrypt(msg, key, type)
    end

    test "output changes with secret", %{type: type} do
      msg = "example"
      key1 = generate_cipher_key(type)
      key2 = generate_cipher_key(type)

      assert encrypt(msg, key1, type) != encrypt(msg, key2, type)
    end

    property "generates binary", %{type: type} do
      check all data <- iodata(),
                IO.iodata_length(data) > 0 do
        key = generate_cipher_key(type)
        enc = encrypt(data, key, type)

        assert is_binary(enc)
        assert bit_size(enc) > 0
      end
    end
  end
end
