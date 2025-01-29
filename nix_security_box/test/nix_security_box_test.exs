defmodule Nix.SecurityBoxTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import Nix.SecurityBox

  doctest Nix.SecurityBox, import: true

  describe "one-way encrypt" do
    test "handles nil" do
      expected = "46b9dd2b0ba88d13233b3feb743eeb243fcd52ea"

      assert encrypt(nil) == expected
      assert encrypt("") == expected
    end

    property "is consistent" do
      check all data <- binary() do
        assert encrypt(data) != data
        assert encrypt(data) == encrypt(data)
      end
    end

    test "check is decrypted" do
      assert decrypted?("secret", "XXX") == false
      assert decrypted?("secret", encrypt("wrong")) == false
      assert decrypted?("secret", encrypt("secret")) == true
    end

    test "decrypted check handles nil" do
      assert decrypted?(nil, "XXX") == false
      assert decrypted?("secret", nil) == false
      assert decrypted?(nil, nil) == false
      assert decrypted?(nil, encrypt(nil)) == true
      assert decrypted?("", encrypt("")) == true
    end
  end
end
