defmodule Nix.CryptoTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import Nix.Crypto

  doctest Nix.Crypto, import: true

  describe "generate random" do
    property "characters of length" do
      check all num <- integer(0..100) do
        str = rand_chars(num)
        assert String.length(str) == num
      end
    end

    test "distributed integers" do
      size = 100_000
      set = for _n <- 1..size, do: rand_int(0, 100)
      avg = Enum.sum(set) / size

      assert avg > 49.5
      assert avg < 50.5
    end
  end
end
