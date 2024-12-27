defmodule Nix.Binary.QueueTest do
  use ExUnit.Case, async: true

  alias Nix.Binary

  doctest Binary.Queue, import: true

  describe "Binary.Queue" do
    test "create" do
      queue = Binary.Queue.new()
      assert Binary.Queue.size(queue) == 0
      assert Binary.Queue.is_empty(queue)
    end

    test "push a binary chunk" do
      q = Binary.Queue.push(Binary.Queue.new(), <<0, 1, 2, 3, 4, 5, 6, 7, 8, 9>>)

      assert Binary.Queue.size(q) == 10
      assert Binary.Queue.is_empty(q) == false
    end

    test "push two binary chunks" do
      q =
        Binary.Queue.new()
        |> Binary.Queue.push(<<0, 1, 2, 3, 4, 5, 6, 7, 8, 9>>)
        |> Binary.Queue.push(<<10, 11, 12, 13, 14>>)

      assert Binary.Queue.size(q) == 15
      assert Binary.Queue.is_empty(q) == false
    end

    test "pull shorter than first element length" do
      q = Binary.Queue.push(Binary.Queue.new(), <<0, 1, 2, 3, 4, 5, 6, 7, 8, 9>>)

      {data, q2} = Binary.Queue.pull(q, 5)
      assert Binary.Queue.size(q2) == 5
      assert data == <<0, 1, 2, 3, 4>>
    end

    test "pull equal as first element length" do
      q = Binary.Queue.push(Binary.Queue.new(), <<0, 1, 2, 3, 4, 5, 6, 7, 8, 9>>)

      {data, q2} = Binary.Queue.pull(q, 10)
      assert Binary.Queue.size(q2) == 0
      assert data == <<0, 1, 2, 3, 4, 5, 6, 7, 8, 9>>
    end

    test "pull larger as first element length without more data" do
      q = Binary.Queue.push(Binary.Queue.new(), <<0, 1, 2, 3, 4, 5, 6, 7, 8, 9>>)

      {data, q2} = Binary.Queue.pull(q, 15)
      assert Binary.Queue.size(q2) == 0
      assert Binary.Queue.is_empty(q2) == true
      assert data == <<0, 1, 2, 3, 4, 5, 6, 7, 8, 9>>
    end

    test "pull larger as first element length with extra data" do
      q =
        Binary.Queue.new()
        |> Binary.Queue.push(<<0, 1, 2, 3, 4, 5, 6, 7, 8, 9>>)
        |> Binary.Queue.push(<<10, 11, 12, 13, 14>>)

      {data, q2} = Binary.Queue.pull(q, 12)
      assert Binary.Queue.size(q2) == 3
      assert Binary.Queue.is_empty(q2) == false
      assert data == <<0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11>>
    end

    test "extensive test" do
      q =
        Binary.Queue.new()
        |> Binary.Queue.push(<<1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14>>)
        |> Binary.Queue.push(<<1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12>>)
        |> Binary.Queue.push(<<1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17>>)
        |> Binary.Queue.push(<<1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23>>)

      assert Binary.Queue.size(q) == 66

      {first_10, q_10} = Binary.Queue.pull(q, 10)
      assert byte_size(first_10) == 10
      assert Binary.Queue.size(q_10) == 56

      {second_10, q_20} = Binary.Queue.pull(q_10, 10)
      assert byte_size(second_10) == 10
      assert Binary.Queue.size(q_20) == 46

      {third_10, q_30} = Binary.Queue.pull(q_20, 10)
      assert byte_size(third_10) == 10
      assert Binary.Queue.size(q_30) == 36

      {fourth_10, q_40} = Binary.Queue.pull(q_30, 10)
      assert byte_size(fourth_10) == 10
      assert Binary.Queue.size(q_40) == 26

      {fifth_10, q_50} = Binary.Queue.pull(q_40, 10)
      assert byte_size(fifth_10) == 10
      assert Binary.Queue.size(q_50) == 16

      {sixth_10, q_60} = Binary.Queue.pull(q_50, 10)
      assert byte_size(sixth_10) == 10
      assert Binary.Queue.size(q_60) == 6

      {rest_6, q_66} = Binary.Queue.pull(q_60, 10)
      assert byte_size(rest_6) == 6
      assert Binary.Queue.size(q_66) == 0
      assert Binary.Queue.is_empty(q_66)
    end
  end
end
