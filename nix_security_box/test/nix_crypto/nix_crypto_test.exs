defmodule Nix.CryptoTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import Nix.Crypto

  doctest Nix.Crypto, import: true

  describe "generate cipher key" do
    test "is random" do
      cipher = Enum.random(ciphers_no_iv() ++ ciphers_iv())
      assert generate_cipher_key(cipher) != generate_cipher_key(cipher)
    end

    property "is required length" do
      check all cipher <- one_of(ciphers_no_iv() ++ ciphers_iv()) do
        key = generate_cipher_key(cipher)
        assert byte_size(key) in [8, 16, 24, 32]
      end
    end
  end

  describe "generate cipher iv" do
    test "is random" do
      cipher = Enum.random(ciphers_iv())
      assert generate_cipher_iv(cipher) != generate_cipher_iv(cipher)
    end

    test "is empty for ciphers without iv" do
      for cipher <- ciphers_no_iv() do
        assert generate_cipher_iv(cipher) == <<>>
      end
    end

    property "is required length" do
      check all cipher <- one_of(ciphers_iv()) do
        iv = generate_cipher_iv(cipher)
        assert byte_size(iv) in [8, 16, 24, 32]
      end
    end
  end

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
