defmodule PriorityQueueTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import PriorityQueue

  @moduletag :f

  doctest PriorityQueue, import: true

  describe "PriorityQueue" do
    test "new" do
      assert to_list(new()) == []
    end

    test "insert" do
      q = insert(new(), 4, "item1")
      assert to_list(q) == [{"item1", 4}]

      q = insert(q, -2, "item2")
      assert to_list(q) == [{"item1", 4}, {"item2", -2}]
    end

    test "empty?" do
      assert empty?(new())

      q = insert(new(), -2, "item1")
      refute empty?(q)
    end

    test "size" do
      assert size(new()) == 0

      q = insert(new(), -2, "item")
      assert size(q) == 1

      q =
        new()
        |> insert(-2, "item1")
        |> insert("item2", 4)
        |> top()

      assert size(q) == 1

      q =
        new()
        |> insert("item1", 2)
        |> insert("item2", 1)
        |> insert("item3", 3)

      assert size(q) == 3
    end

    test "to_list" do
      q =
        new()
        |> insert("item1", 2)
        |> insert("item2", 1)
        |> insert("item3", 3)

      assert to_list(q) == [{1, "item2"}, {2, "item1"}, {3, "item3"}]
    end

    test "peek" do
      q =
        new()
        |> insert("item1", 2)
        |> insert("item2", 1)
        |> insert("item3", 1)

      assert peek(q) == "item3"
    end
  end
end
