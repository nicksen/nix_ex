defmodule Nix.Std.PredicateTest do
  use ExUnit.Case, async: true

  import Nix.Std.FP
  import Nix.Std.Predicate

  doctest Nix.Std.Predicate, import: true

  describe "and_then" do
    test "short circuits" do
      fails = fn _ignored -> raise "error!" end
      pred = and_then(&id/1, fails)

      assert pred.(false) == false
    end

    test "supports thruthy and falsy predicates" do
      pred = and_then(k(1), k(""))
      assert pred.(true) == ""
    end
  end

  describe "or_is" do
    test "short circuits" do
      fails = fn _ignored -> raise "error!" end
      pred = or_is(&id/1, fails)

      assert pred.(true) == true
    end

    test "supports thruthy and falsy predicates" do
      pred = or_is(k(0), k(1))
      assert pred.(true) == 0
    end
  end

  describe "invert" do
    test "supports truthy and falsy predicates" do
      pred = invert(k(nil))
      assert pred.(1) == true

      pred = invert(k(1))
      assert pred.(1) == false
    end
  end
end
