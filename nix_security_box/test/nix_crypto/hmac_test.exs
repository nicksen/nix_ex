defmodule Nix.Crypto.HmacTest do
  use ExUnit.Case,
    async: true,
    parameterize: Enum.map(Nix.Crypto.hmac_hash_algorithms(), &%{type: &1})

  use ExUnitProperties

  import Nix.Crypto

  describe "hmac" do
    test "is consistent", %{type: type} do
      msg = "example"
      key = "secret"
      enc = hmac(msg, type, key)

      assert enc != msg
      assert enc == hmac(msg, type, key)
    end

    test "output changes with secret", %{type: type} do
      msg = "example"
      assert hmac(msg, type, "secret1") != hmac(msg, type, "secret2")
    end

    property "generates binary", %{type: type} do
      check all data <- iodata(),
                key <- iodata() do
        enc = hmac(data, type, key)

        assert is_binary(enc)
        assert bit_size(enc) > 0
      end
    end
  end
end
