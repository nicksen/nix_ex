defmodule Nix.Glob.BraceExpansion.BalancedMatchTest do
  use ExUnit.Case, async: true

  import Nix.Glob.BraceExpansion.BalancedMatch

  @describetag :f

  describe "balanced" do
    test "basic" do
      assert %{start: 3, finish: 8, pre: "pre", body: "nest", post: "post"} = balanced("pre{nest}post", "{", "}")
    end

    test "invalid" do
      assert balanced("nuh-uh", "{", "}") == nil
    end
  end
end
