defmodule Nix.Crypto.HashXOFTest do
  use ExUnit.Case,
    async: true,
    parameterize: Enum.map(Nix.Crypto.hash_xof_algorithms(), &%{type: &1})

  use ExUnitProperties

  import Nix.Crypto

  describe "xof hashing" do
    test "allows setting output length", %{type: type} do
      assert bit_size(hash("example", type, length: 16)) == 16
      assert bit_size(hash("example", type, length: 56)) == 56
    end

    test "has default output length", %{type: type} do
      assert bit_size(hash("left", type)) > 0
    end

    property "output length is constant", %{type: type} do
      check all length <- non_negative_integer(),
                left <- iodata(),
                right <- iodata(),
                left != right do
        encl = hash(left, type, length: length)
        encr = hash(right, type, length: length)

        assert bit_size(encl) == bit_size(encr)
      end
    end
  end
end
