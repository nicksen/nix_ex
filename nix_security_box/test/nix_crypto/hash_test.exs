defmodule Nix.Crypto.HashTest do
  use ExUnit.Case, async: true, parameterize: Enum.map(Nix.Crypto.hash_algorithms(), &%{type: &1})
  use ExUnitProperties

  import Nix.Crypto

  describe "hashing" do
    test "is consistent", %{type: type} do
      msg = "example"
      enc = hash(msg, type)

      assert enc != msg
      assert enc == hash(msg, type)
    end

    property "generates binary", %{type: type} do
      check all data <- iodata() do
        enc = hash(data, type)

        assert is_binary(enc)
        assert bit_size(enc) > 0
      end
    end
  end
end
