defmodule Nix.SecurityBoxTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import Nix.SecurityBox

  doctest Nix.SecurityBox, import: true

  describe "encrypt/1" do
    test "handles nil" do
      assert encrypt(nil) == "da39a3ee5e6b4b0d3255bfef95601890afd80709"
      assert encrypt("") == "da39a3ee5e6b4b0d3255bfef95601890afd80709"
    end

    property "is consistent" do
      check all data <- binary() do
        assert encrypt(data) != data
        assert encrypt(data) == encrypt(data)
      end
    end
  end
end
