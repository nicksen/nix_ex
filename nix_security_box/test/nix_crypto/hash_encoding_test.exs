defmodule Nix.Crypto.HashEncodingTest do
  use ExUnit.Case,
    async: true,
    parameterize:
      for(
        hash <- Nix.Crypto.hash_algorithms(),
        enc <- Nix.Crypto.encoding_functions(),
        do: %{type: hash, encoding: enc}
      )

  use ExUnitProperties

  import Nix.Crypto

  describe "encoded hashing" do
    test "is consistent", %{type: type, encoding: encoding} do
      msg = "example"
      enc = hash(msg, type, encoding)

      assert enc != msg
      assert enc == hash(msg, type, encoding)
    end

    property "generates valid strings", %{type: type, encoding: encoding} do
      check all data <- iodata() do
        enc = hash(data, type, encoding)

        assert String.valid?(enc)
        assert String.length(enc) > 0
      end
    end
  end
end
