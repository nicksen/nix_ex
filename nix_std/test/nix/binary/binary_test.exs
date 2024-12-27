defmodule Nix.BinaryTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Nix.Binary

  doctest Binary, import: true

  describe "Binary" do
    property "append" do
      check all left <- binary(),
                right <- binary() do
        bin = Binary.append(left, right)
        assert <<^left::binary, ^right::binary>> = bin
      end

      check all left <- binary(),
                right <- byte() do
        bin = Binary.append(left, right)
        assert <<^left::binary, ^right::integer>> = bin
      end
    end

    property "at" do
      check all needle <- byte(),
                pre <- binary(),
                post <- binary() do
        haystack = IO.iodata_to_binary([pre, needle, post])
        idx = byte_size(pre)

        assert Binary.at(haystack, idx) == needle
      end
    end

    test "copy" do
      assert_raise ArgumentError, fn ->
        Binary.copy("boo", -1)
      end
    end

    property "copy" do
      check all sub <- binary(min_length: 1),
                n <- positive_integer() do
        bin = Binary.copy(sub, n)
        assert <<^sub::binary, _rest::binary>> = bin
      end
    end

    test "drop" do
      assert Binary.drop(<<>>, 1) == <<>>
      assert Binary.drop(<<1>>, 0) == <<1>>
      assert Binary.drop(<<1, 2, 3, 4>>, 1) == <<2, 3, 4>>
      assert Binary.drop(<<1, 2, 3, 4>>, 2) == <<3, 4>>
      assert Binary.drop(<<1, 2, 3, 4>>, 5) == <<>>
      assert Binary.drop(<<1, 2, 3, 4>>, -1) == <<1, 2, 3>>
      assert Binary.drop(<<1, 2, 3, 4>>, -3) == <<1>>
      assert Binary.drop(<<1, 2, 3, 4>>, -13) == <<>>
    end

    test "from_hex" do
      assert Binary.from_hex("BEEF") == <<190, 239>>
      assert Binary.from_hex("beef") == <<190, 239>>
      assert Binary.from_hex("bEEf") == <<190, 239>>
      assert Binary.from_hex("") == <<>>
    end

    test "from_integer" do
      assert Binary.from_integer(0) == <<0>>
      assert Binary.from_integer(258) == <<1, 2>>
      assert Binary.from_integer(258, :little) == <<2, 1>>
    end

    test "from_list" do
      assert_raise ArgumentError, fn ->
        Binary.from_list([1234, 4])
      end
    end

    test "longest_common_prefix" do
      assert Binary.longest_common_prefix(["foo fighters", "foofoo"]) == 3
    end

    test "longest_common_suffix" do
      assert Binary.longest_common_suffix(["foo", "mooooo", "boo"]) == 2
    end

    test "pad_leading" do
      assert Binary.pad_leading(<<1, 2>>, 4) == <<0, 0, 1, 2>>
      assert Binary.pad_leading(<<1, 2>>, 1) == <<1, 2>>
      assert Binary.pad_leading(<<>>, 1) == <<0>>
    end

    test "pad_trailing" do
      assert Binary.pad_trailing(<<1>>, 3) == <<1, 0, 0>>
      assert Binary.pad_trailing(<<1, 2>>, 3, 7) == <<1, 2, 7>>
      assert Binary.pad_trailing(<<1, 2, 3>>, 3, 7) == <<1, 2, 3>>
      assert Binary.pad_trailing(<<1, 2, 3>>, 2, 7) == <<1, 2, 3>>
      assert Binary.pad_trailing(<<>>, 2) == <<0, 0>>
    end

    test "part" do
      assert Binary.part(<<1, 2, 3, 4, 5>>, 1, 2) == <<2, 3>>
      assert Binary.part(<<1, 2, 3, 4, 5>>, 2, -1) == <<2>>

      assert Binary.part(<<1, 2, 3, 4, 5>>, -3, 2) == <<3, 4>>
      assert Binary.part(<<1, 2, 3, 4, 5>>, -3, -2) == <<1, 2>>

      assert Binary.part(<<1, 2, 3, 4, 5>>, 2, 15) == <<3, 4, 5>>
      assert Binary.part(<<1, 2, 3, 4, 5>>, -4, 15) == <<2, 3, 4, 5>>

      assert Binary.part(<<1, 2, 3, 4, 5>>, 2, -15) == <<1, 2>>
      assert Binary.part(<<1, 2, 3, 4, 5>>, -2, -15) == <<1, 2, 3>>
    end

    test "prepend" do
      assert Binary.prepend(<<2, 3>>, <<1>>) == <<1, 2, 3>>
      assert Binary.prepend(<<2, 3>>, 1) == <<1, 2, 3>>
      assert Binary.prepend(<<>>, 0) == <<0>>
    end

    test "replace" do
      assert Binary.replace("hoothoot", "oo", "a") == "hathat"
      assert Binary.replace("hoothoot", "oo", "a", global: false) == "hathoot"
    end

    # test "reverse" do
    #   assert Binary.reverse(<<>>) == <<>>
    #   assert Binary.reverse(<<1, 2, 3>>) == <<3, 2, 1>>
    #   assert Binary.reverse(<<1>>) == <<1>>
    # end

    test "split" do
      x = <<1, 2, 3, 2, 4, 5, 3>>
      assert Binary.split(x, <<2>>) == [<<1>>, <<3, 2, 4, 5, 3>>]
      assert Binary.split(x, 2) == [<<1>>, <<3, 2, 4, 5, 3>>]
      assert Binary.split(x, <<2>>, global: true) == [<<1>>, <<3>>, <<4, 5, 3>>]
      assert Binary.split(x, 2, global: true) == [<<1>>, <<3>>, <<4, 5, 3>>]
      assert Binary.split(x, "foo") == [x]
      assert Binary.split(x, 123) == [x]
      assert Binary.split(x, 3, global: true) == [<<1, 2>>, <<2, 4, 5>>, <<>>]
      assert Binary.split(x, <<2, 3, 2>>) == [<<1>>, <<4, 5, 3>>]
      assert Binary.split(<<>>, <<3>>) == [<<>>]
      assert Binary.split(<<1, 0>>, 0) == [<<1>>, <<>>]
    end

    test "split_at" do
      assert Binary.split_at(<<1, 2, 3>>, 1) == {<<1>>, <<2, 3>>}
      assert Binary.split_at(<<1, 2, 3>>, 0) == {<<>>, <<1, 2, 3>>}
      assert Binary.split_at(<<1, 2, 3>>, 3) == {<<1, 2, 3>>, <<>>}
      assert Binary.split_at(<<1, 2, 3>>, -1) == {<<1, 2>>, <<3>>}
    end

    test "take" do
      assert Binary.take(<<1, 2, 3, 4>>, 1) == <<1>>
      assert Binary.take(<<1, 2, 3, 4>>, 2) == <<1, 2>>
      assert Binary.take(<<1, 2, 3, 4>>, 5) == <<1, 2, 3, 4>>
      assert Binary.take(<<1, 2, 3, 4>>, -1) == <<4>>
      assert Binary.take(<<1, 2, 3, 4>>, -3) == <<2, 3, 4>>
      assert Binary.take(<<1, 2, 3, 4>>, -13) == <<1, 2, 3, 4>>
      assert Binary.take("Dave Brubeck", 5) == "Dave "

      assert Binary.take(<<>>, 1) == <<>>
      assert Binary.take(<<1>>, 0) == <<>>
    end

    test "to_hex" do
      assert Binary.to_hex(<<>>) == ""
      assert Binary.to_hex(<<1>>) == "01"
      assert Binary.to_hex(<<255, 1>>) == "ff01"
    end

    test "to_integer" do
      assert Binary.to_integer(<<17>>) == 17
      assert Binary.to_integer(<<4, 210>>) == 1234
      assert Binary.to_integer(<<210, 4>>, :little) == 1234
    end

    test "trim_leading" do
      assert Binary.trim_leading(<<0, 1, 0, 0>>) == <<1, 0, 0>>
      assert Binary.trim_leading(<<>>) == <<>>
      assert Binary.trim_leading(<<1, 1, 2>>, 1) == <<2>>
    end

    test "trim_trailing" do
      assert Binary.trim_trailing(<<1, 2, 0, 0, 0>>) == <<1, 2>>
      assert Binary.trim_trailing(<<1, 2, 0, 0, 0>>, 0) == <<1, 2>>
      assert Binary.trim_trailing(<<1, 2, 0, 0, 0>>, 1) == <<1, 2, 0, 0, 0>>
      assert Binary.trim_trailing(<<7, 7, 1, 2, 7>>, 7) == <<7, 7, 1, 2>>
      assert Binary.trim_trailing(<<>>, 7) == <<>>
    end
  end
end
