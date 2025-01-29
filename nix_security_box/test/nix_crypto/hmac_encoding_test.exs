defmodule Nix.Crypto.HmacEncodingTest do
  use ExUnit.Case,
    async: true,
    parameterize:
      for(
        hash <- Nix.Crypto.hmac_hash_algorithms(),
        enc <- Nix.Crypto.encoding_functions(),
        do: %{type: hash, encoding: enc}
      )

  use ExUnitProperties

  import Nix.Crypto

  describe "encoded hmac" do
    test "is consistent", %{type: type, encoding: encoding} do
      msg = "example"
      key = "secret"
      enc = hmac(msg, type, key, encoding)

      assert enc != msg
      assert enc == hmac(msg, type, key, encoding)
    end

    property "generates binary", %{type: type, encoding: encoding} do
      check all data <- iodata(),
                key <- iodata() do
        enc = hmac(data, type, key, encoding)

        assert String.valid?(enc)
        assert String.length(enc) > 0
      end
    end
  end
end
