defmodule Nix.CryptoTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import Nix.Crypto

  doctest Nix.Crypto, import: true

  describe "generate key" do
    property "has required length and is random" do
      check all len <- positive_integer() do
        key1 = generate_key(len)
        key2 = generate_key(len)

        assert byte_size(key1) == len
        assert byte_size(key2) == len

        assert key1 != key2
      end
    end
  end
end
