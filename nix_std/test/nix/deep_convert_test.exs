defmodule Nix.DeepConvertTest do
  use ExUnit.Case, async: true

  import Nix.DeepConvert

  doctest Nix.DeepConvert, import: true

  describe "Nix.DeepConvert.to_map/2" do
    test "keep non-keyword list values" do
      assert %{a: %{b: 2}, c: [1, 2, 3], d: []} = to_map(a: [b: 2], c: [1, 2, 3], d: [])
    end

    test "convert empty list" do
      assert %{} = to_map([])
    end

    test "keep excluded items as-is" do
      assert %{a: [b: [f: 5]]} = to_map([a: [b: [f: 5]]], [:a])
    end

    test "excluded item is nested" do
      assert %{a: %{b: [f: 5]}, c: %{d: 3}} = to_map([a: [b: [f: 5]], c: [d: 3]], [:b])
    end
  end
end
