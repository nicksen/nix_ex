defmodule Nix.Crypto.EncryptEncodingIVTest do
  use ExUnit.Case,
    async: true,
    parameterize:
      for(
        cipher <- Nix.Crypto.ciphers_iv(),
        enc <- Nix.Crypto.encoding_functions(),
        do: %{type: cipher, encoding: enc}
      )

  use ExUnitProperties

  import Nix.Crypto

  describe "encoded encrypt" do
    test "is consistent", %{type: type, encoding: encoding} do
      msg = "example"
      key = generate_cipher_key(type)
      iv = generate_cipher_iv(type)
      enc = encrypt(msg, type, key, iv, encoding)

      assert enc != msg
      assert enc == encrypt(msg, type, key, iv, encoding)
    end

    test "output changes with secret", %{type: type, encoding: encoding} do
      msg = "example"
      key1 = generate_cipher_key(type)
      key2 = generate_cipher_key(type)
      iv = generate_cipher_iv(type)

      assert encrypt(msg, type, key1, iv, encoding) != encrypt(msg, type, key2, iv, encoding)
    end

    test "output changes with iv", %{type: type, encoding: encoding} do
      msg = "example"
      key = generate_cipher_key(type)
      iv1 = generate_cipher_iv(type)
      iv2 = generate_cipher_iv(type)

      assert encrypt(msg, type, key, iv1, encoding) != encrypt(msg, type, key, iv2, encoding)
    end

    property "generates binary", %{type: type, encoding: encoding} do
      check all data <- iodata(),
                IO.iodata_length(data) > 0 do
        key = generate_cipher_key(type)
        iv = generate_cipher_iv(type)
        enc = encrypt(data, type, key, iv, encoding)

        assert String.valid?(enc)
        assert String.length(enc) > 0
      end
    end
  end
end
