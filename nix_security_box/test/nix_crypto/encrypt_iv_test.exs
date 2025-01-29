defmodule Nix.Crypto.EncryptIVTest do
  use ExUnit.Case,
    async: true,
    parameterize: Enum.map(Nix.Crypto.ciphers_iv(), &%{type: &1})

  use ExUnitProperties

  import Nix.Crypto

  describe "encrypt" do
    test "is consistent", %{type: type} do
      msg = "example"
      key = generate_cipher_key(type)
      iv = generate_cipher_iv(type)
      enc = encrypt(msg, type, key, iv)

      assert enc != msg
      assert enc == encrypt(msg, type, key, iv)
    end

    test "output changes with secret", %{type: type} do
      msg = "example"
      key1 = generate_cipher_key(type)
      key2 = generate_cipher_key(type)
      iv = generate_cipher_iv(type)

      assert encrypt(msg, type, key1, iv) != encrypt(msg, type, key2, iv)
    end

    test "output changes with iv", %{type: type} do
      msg = "example"
      key = generate_cipher_key(type)
      iv1 = generate_cipher_iv(type)
      iv2 = generate_cipher_iv(type)

      assert encrypt(msg, type, key, iv1) != encrypt(msg, type, key, iv2)
    end

    property "generates binary", %{type: type} do
      check all data <- iodata(),
                IO.iodata_length(data) > 0 do
        key = generate_cipher_key(type)
        iv = generate_cipher_iv(type)
        enc = encrypt(data, type, key, iv)

        assert is_binary(enc)
        assert bit_size(enc) > 0
      end
    end
  end
end
