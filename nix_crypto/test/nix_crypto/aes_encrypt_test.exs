defmodule Nix.Crypto.AesEncryptTest do
  use ExUnit.Case, async: true

  import Nix.Crypto

  describe "aes encrypt" do
    test "gcm with 128 bit key" do
      key = generate_aes_key(:aes_128, :bytes)
      iv = rand_bytes(16)
      cleartext = "a very secret message"
      auth_data = "authenticated secret"

      assert {:ok, {ad, payload}} = encrypt(key, auth_data, iv, cleartext)
      {_c_iv, cipher_text, cipher_tag} = payload
      assert cleartext != cipher_text

      assert {:ok, decrypted} = decrypt(key, ad, iv, cipher_text, cipher_tag)
      assert decrypted == cleartext
    end

    test "gcm with undefined iv and 128 bit key" do
      key = generate_aes_key(:aes_128, :bytes)
      cleartext = "a very secret message"
      auth_data = "auth and associated data"

      assert {:ok, {ad, payload}} = encrypt(key, auth_data, cleartext)
      {iv, cipher_text, cipher_tag} = payload
      assert byte_size(iv) == 16
      assert byte_size(cipher_tag) == 16
      assert cleartext != cipher_text

      assert {:ok, decrypted} = decrypt(key, ad, iv, cipher_text, cipher_tag)
      assert decrypted == cleartext
    end

    test "gcm with undefined iv and 256 bit key" do
      key = generate_aes_key(:aes_256, :bytes)
      cleartext = "a very secret message"
      auth_data = "auth and associated data"

      assert {:ok, {ad, payload}} = encrypt(key, auth_data, cleartext)
      {iv, cipher_text, cipher_tag} = payload
      assert byte_size(iv) == 16
      assert byte_size(cipher_tag) == 16
      assert cleartext != cipher_text

      assert {:ok, decrypted} = decrypt(key, ad, iv, cipher_text, cipher_tag)
      assert decrypted == cleartext
    end

    test "cbc with undefined iv and 256 bit key" do
      key = generate_aes_key(:aes_256, :bytes)
      cleartext = "a very secret message"

      assert {:ok, {iv, cipher_text}} = encrypt(key, cleartext)
      assert byte_size(iv) == 16
      assert cleartext != cipher_text

      assert {:ok, decrypted} = decrypt(key, iv, cipher_text)
      assert decrypted == cleartext
    end

    test "pack aes gcm payload" do
      key = generate_aes_key(:aes_256, :bytes)
      cleartext = "soo secret..."
      auth_data = "auth and other data"

      assert {:ok, {_ad, payload}} = encrypt(key, auth_data, cleartext)
      {iv, cipher_text, cipher_tag} = payload
      assert byte_size(iv) == 16
      assert byte_size(cipher_tag) == 16
      assert cipher_text != cleartext

      payload = encode_payload(iv, cipher_text, cipher_tag)

      assert {:ok, {piv, pc_text, pc_tag}} = decode_payload(payload)
      assert iv == piv
      assert cipher_text == pc_text
      assert cipher_tag == pc_tag
    end

    test "fails with bad key length" do
      raw_bad_key = rand_bytes(27)
      bad_key = Base.url_encode64(raw_bad_key)
      cleartext = "message"

      assert {:error, :bad_key_size} = encrypt(bad_key, cleartext)
    end

    test "fils with bad iv length" do
      key = generate_aes_key(:aes_256, :bytes)
      bad_iv = rand_bytes(27)
      cleartext = "message"

      assert {:error, :bad_iv_size} = encrypt(key, cleartext, %{initialization_vector: bad_iv})
    end

    test "fails decrypting with bad auth data" do
      key = generate_aes_key(:aes_256, :bytes)
      iv = rand_bytes(16)
      cleartext = "secret message"
      auth_data = "auth data"

      assert {:ok, {_ad, payload}} = encrypt(key, auth_data, iv, cleartext)
      {_c_iv, cipher_text, cipher_tag} = payload

      assert {:error, :decrypt_failed} =
               decrypt(key, "wrong auth data", iv, cipher_text, cipher_tag)
    end
  end
end
