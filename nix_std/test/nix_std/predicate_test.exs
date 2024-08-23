defmodule Nix.Std.PredicateTest do
  use ExUnit.Case, async: true

  import Nix.Std.FP
  import Nix.Std.Predicate

  doctest Nix.Std.Predicate, import: true

  describe "and_then" do
    test "only runs first predicate" do
      falsy = k(false)
      fails = fn _ignored -> raise "error!" end
      pred = and_then(falsy, fails)

      pred.(nil)
    end

    test "expects strict predicate functions" do
      pred = and_then(k(nil), &id/1)

      assert_raise BadBooleanError, fn ->
        pred.(true)
      end
    end
  end
end
