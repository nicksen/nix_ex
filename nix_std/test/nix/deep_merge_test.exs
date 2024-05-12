defmodule Nix.DeepMergeTest do
  use ExUnit.Case, async: true

  import Nix.DeepMerge

  doctest Nix.DeepMerge, import: true

  describe "Nix.DeepMerge.merge/2" do
    test "keyword list & list combinations" do
      kw0 = [a: [b: []], f: 5]
      kw1 = [a: [b: [c: 2]]]
      assert merge(kw0, kw1) == [a: [b: [c: 2]], f: 5]

      kw2 = [a: [b: [c: 2]], f: 5]
      kw3 = [a: [b: []]]
      assert merge(kw2, kw3) == [a: [b: [c: 2]], f: 5]

      kw4 = [a: [b: [c: 2]], f: 5]
      kw5 = [a: [b: [1, 2, 3]]]
      assert merge(kw4, kw5) == [a: [b: [1, 2, 3]], f: 5]

      kw6 = [a: [b: [1, 2, 3]], f: 5]
      kw7 = [a: [b: [c: 2]]]
      assert merge(kw6, kw7) == [a: [b: [c: 2]], f: 5]

      kw8 = [a: [b: []], f: 5]
      kw9 = [a: [b: []]]
      assert merge(kw8, kw9) == [a: [b: []], f: 5]
    end

    test "doesn't merge structs" do
      left = %{a: %OtherStruct{attrs: %{b: 1}}}
      right = %{a: %OtherStruct{attrs: %{c: 2}}}
      assert merge(left, right) == right
    end

    test "merge structs with a resolver implemented" do
      left = %{a: %MyStruct{attrs: %{b: 1}}}
      right = %{a: %MyStruct{attrs: %{c: 2}}}
      assert merge(left, right) == %{a: %MyStruct{attrs: %{b: 1, c: 2}}}
    end

    test "merge top-level structs with resolver implemented" do
      left = %MyStruct{attrs: %{b: 1, c: 0}}
      right = %MyStruct{attrs: %{c: 2, e: 4}}
      assert merge(left, right) == %MyStruct{attrs: %{b: 1, c: 2, e: 4}}
    end

    test "merge structs with a derived resolver" do
      left = %{a: %DerivedStruct{attrs: %{b: 1, c: 0}}}
      right = %{a: %DerivedStruct{attrs: %{c: 2, e: 4}}}
      assert merge(left, right) == %{a: %DerivedStruct{attrs: %{b: 1, c: 2, e: 4}}}
    end

    test "merge top-level structs with a derived resolver" do
      left = %DerivedStruct{attrs: %{b: 1, a: 0}}
      right = %DerivedStruct{attrs: %{c: 2, a: 42}}
      assert merge(left, right) == %DerivedStruct{attrs: %{a: 42, b: 1, c: 2}}
    end

    test "merging different structs with derived resolvers doesn't work" do
      left = %{a: %DerivedStruct{attrs: %{b: 1, a: 0}}}
      right = %{a: %OtherDerivedStruct{attrs: %{c: 2, a: 42}}}
      assert merge(left, right) == right
    end

    test "doesn't merge structs not implementing the protocol" do
      left = %{a: %MyStruct{attrs: %{b: 1}}}
      right = %{a: %OtherStruct{attrs: %{c: 2}}}
      assert merge(left, right) == right
    end

    test "doesn't merge maps and structs" do
      with_map = %{a: %{attrs: %{b: 1}}}
      with_struct = %{a: %OtherStruct{attrs: %{c: 2}}}
      assert merge(with_map, with_struct) == with_struct
      assert merge(with_struct, with_map) == with_map
    end

    test "doesn't merge maps and keyword lists" do
      map = %{a: 1}
      kw = [b: 2]
      assert merge(map, kw) == kw
      assert merge(kw, map) == map
    end

    test "fails with incompatible types" do
      assert_raise FunctionClauseError, fn -> merge(%{a: 1}, 2) end
      assert_raise FunctionClauseError, fn -> merge(2, %{b: 2}) end
      assert_raise FunctionClauseError, fn -> merge(1, 2) end
      assert_raise FunctionClauseError, fn -> merge(:atom, :other) end
    end
  end

  describe "merging keyword lists" do
    test "keeps all keys" do
      kw0 = [a: 1, b: 2]
      kw1 = [b: 3, b: 4]
      assert merge(kw0, kw1) == [a: 1, b: 3, b: 4]

      kw2 = [a: 1, b: 2, b: 3]
      kw3 = [b: 4, c: 5]
      assert merge(kw2, kw3) == [a: 1, b: 4, b: 3, c: 5]
    end

    test "keeps nested key order" do
      left = [a: 1, b: [ba: true, bb: :v], c: [ca: 1]]
      right = [a: [aa: "x"], b: [ba: 1], c: :v]
      assert merge(left, right) == [a: [aa: "x"], b: [ba: 1, bb: :v], c: :v]
    end
  end
end
