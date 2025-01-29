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
      enc = hmac(msg, key, type)

      assert enc != msg
      assert enc == hmac(msg, key, type)
    end

    test "output changes with secret", %{type: type} do
      msg = "example"
      assert hmac(msg, "secret1", type) != hmac(msg, "secret2", type)
    end

    property "generates binary", %{type: type} do
      check all data <- iodata(),
                key <- iodata() do
        enc = hmac(data, key, type)

        assert is_binary(enc)
        assert bit_size(enc) > 0
      end
    end
  end
end
