defmodule Nix.Crypto.EncryptEncodingNoIVTest do
  use ExUnit.Case,
    async: true,
    parameterize:
      for(
        cipher <- Nix.Crypto.ciphers_no_iv(),
        enc <- Nix.Crypto.encoding_functions(),
        do: %{type: cipher, encoding: enc}
      )

  use ExUnitProperties

  import Nix.Crypto

  describe "encoded encrypt" do
    test "is consistent", %{type: type, encoding: encoding} do
      msg = "example"
      key = generate_cipher_key(type)
      enc = encrypt(msg, key, type, encoding)

      assert enc != msg
      assert enc == encrypt(msg, key, type, encoding)
    end

    test "output changes with secret", %{type: type, encoding: encoding} do
      msg = "example"
      key1 = generate_cipher_key(type)
      key2 = generate_cipher_key(type)

      assert encrypt(msg, key1, type, encoding) != encrypt(msg, key2, type, encoding)
    end

    property "generates binary", %{type: type, encoding: encoding} do
      check all data <- iodata(),
                IO.iodata_length(data) > 0 do
        key = generate_cipher_key(type)
        enc = encrypt(data, key, type, encoding)

        assert String.valid?(enc)
        assert String.length(enc) > 0
      end
    end
  end
end
