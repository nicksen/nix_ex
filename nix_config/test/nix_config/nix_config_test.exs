defmodule Nix.ConfigTest do
  use Nix.ConfigCase, async: true

  import Nix.Config

  describe "env_specific" do
    test "set in correct env" do
      assert env_specific(test: "test") == "test"
    end

    test "unset in wrong env" do
      assert env_specific(not_test: "test") == nil
    end

    test "fallback to default" do
      assert env_specific(else: "default") == "default"
    end

    test "only evaluates matching env" do
      assert env_specific(test: "test", else: raise("evaluated :else")) == "test"
    end
  end

  describe "env_specific!" do
    test "fetch env" do
      assert env_specific!(test: "main") == "main"
    end

    test "use fallback when env is unset" do
      assert env_specific!(else: "fallback") == "fallback"
    end

    test "fails without env or fallback set" do
      assert_raise KeyError, fn -> env_specific!(asd: "asd") end
    end
  end

  describe "merge" do
    test "simple lists" do
      l1 = [a: 1]
      l2 = [b: 2]

      assert merge(l1, l2) == [a: 1, b: 2]
    end

    test "left-to-right" do
      l1 = [a: 1]
      l2 = [a: true]

      assert merge(l1, l2) == [a: true]
    end

    test "nested lists" do
      l1 = [a: 1, b: [ba: true, bb: :v], c: [ca: 1]]
      l2 = [a: [aa: "x"], b: [ba: 1], c: :v]

      assert merge(l1, l2) == [a: [aa: "x"], b: [ba: 1, bb: :v], c: :v]
    end

    test "merge repeated flags" do
      l1 = [a: 1, a: 2]
      l2 = [a: 3]

      assert merge(l1, l2) == [a: 3, a: 2]
    end

    test "list of keywords" do
      assert merge([[a: 1], [a: 2], [a: 3], [a: 4], [a: 5]]) == [a: 5]
    end
  end
end
