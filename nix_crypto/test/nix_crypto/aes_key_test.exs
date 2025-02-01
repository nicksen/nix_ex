defmodule Nix.Crypto.AesKeyTest do
  use ExUnit.Case, async: true

  import Nix.Crypto

  describe "aes keys" do
    test "generate 128 bit key as bytes" do
      key = generate_aes_key(:aes_128, :bytes)

      assert is_bitstring(key)
      assert byte_size(key) == 16
      assert bit_size(key) == 128
    end

    test "generate 128 bit key as base64" do
      key = generate_aes_key(:aes_128, :base64)

      assert String.valid?(key)
      assert String.length(key) == 24
    end

    test "generate 192 bit key as bytes" do
      key = generate_aes_key(:aes_192, :bytes)

      assert is_bitstring(key)
      assert byte_size(key) == 24
      assert bit_size(key) == 192
    end

    test "generate 192 bit key as base64" do
      key = generate_aes_key(:aes_192, :base64)

      assert String.valid?(key)
      assert String.length(key) == 32
    end

    test "generate 256 bit key as bytes" do
      key = generate_aes_key(:aes_256, :bytes)

      assert is_bitstring(key)
      assert byte_size(key) == 32
      assert bit_size(key) == 256
    end

    test "generate 256 bit key as base64" do
      key = generate_aes_key(:aes_256, :base64)

      assert String.valid?(key)
      assert String.length(key) == 44
    end
  end
end
