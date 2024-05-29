defmodule Nix.Glob.BraceExpansionTest do
  use ExUnit.Case, async: true

  import Nix.Glob.BraceExpansion

  doctest Nix.Glob.BraceExpansion, import: true

  describe "brace expansion" do
    test "basic" do
      assert expand("abcd") == ["abcd"]
    end
  end
end
