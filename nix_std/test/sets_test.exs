defmodule SetsTest do
  use SetCase, async: true

  describe "Sets" do
    @describetag :f

    test "create" do
      test_all(fn m ->
        s0 = m.(:empty, [])
        assert m.(:to_list, s0) == []
        assert m.(:size, s0) == 0
        assert m.(:empty?, s0)

        e = make_ref()
        one = m.(:singleton, e)
        assert m.(:size, one) == 1
        refute m.(:empty?, one)
        assert m.(:to_list, one) == [e]

        s0
      end)
    end

    test "put" do
      test_all([{0, 132}, {253, 258}, {510, 514}], fn m, list ->
        s = m.(:from_list, list)
        assert usort(list) == sort(m.(:to_list, s))

        s2 = Enum.reduce(list, m.(:empty, []), fn el, set -> m.(:put, {set, el}) end)
        assert m.(:equals?, {s, s2})

        s3 = add_element_del(list, m, m.(:empty, []), [], [])
        assert m.(:equals?, {s2, s3})
        assert m.(:equals?, {s, s3})

        s
      end)
    end

    defp add_element_del([h | t], m, s, del, []) do
      add_element_del(t, m, m.(:put, {s, h}), del, [h])
    end

    defp add_element_del([h | t], m, s0, del, ins) do
      s1 = m.(:put, {s0, h})

      if :rand.uniform(3) == 1 do
        old_el = Enum.random(ins)
        s = m.(:del, {s1, old_el})
        add_element_del(t, m, s, [old_el | del], [h | ins])
      else
        add_element_del(t, m, s1, del, [h | ins])
      end
    end

    defp add_element_del([], m, s, del, _ins) do
      m.(:union, {s, m.(:from_list, del)})
    end

    test "delete" do
      test_all([{0, 132}, {253, 258}, {510, 514}, {1022, 1026}], fn m, list ->
        s0 = m.(:from_list, list)
        empty = Enum.reduce(list, s0, fn el, set -> m.(:del, {set, el}) end)
        assert m.(:equals?, {empty, m.(:empty, [])})
        assert m.(:empty?, empty)

        s1 = Enum.reduce(Enum.reverse(list), s0, fn el, set -> m.(:put, {set, el}) end)
        assert m.(:equals?, {s0, s1})

        s1
      end)
    end

    test "subtract" do
      test_all(fn m ->
        empty = m.(:empty, [])
        s = m.(:subtract, {empty, empty})
        assert m.(:empty?, s)

        s
      end)

      test_all([{2, 69}, {126, 130}, {253, 258}, 511, 512, {1023, 1030}], fn m, list ->
        s0 = m.(:from_list, list)
        empty = m.(:empty, [])

        assert m.(:empty?, m.(:subtract, {empty, s0}))
        assert m.(:equals?, {s0, m.(:subtract, {s0, empty})})

        subtract_check(list, mutate_some(remove_some(list, 0.4)), m)
        subtract_check(list, rnd_list(div(length(list), 2) + 5), m)
        subtract_check(list, rnd_list(div(length(list), 7) + 9), m)
        subtract_check(list, mutate_some(list), m)
      end)
    end

    defp subtract_check(a, b, m) do
      one_subtract_check(a, b, m)
      one_subtract_check(b, a, m)
    end

    defp one_subtract_check(a, b, m) do
      a_sorted = usort(a)
      b_sorted = usort(b)
      a_set = m.(:from_list, a)
      b_set = m.(:from_list, b)
      diff_set = m.(:subtract, {a_set, b_set})
      diff = a_sorted -- b_sorted
      assert m.(:equals?, {diff_set, m.(:from_list, diff)})
      assert sort(m.(:to_list, diff_set)) == diff

      diff_set
    end

    test "intersection" do
      test_all([{1, 65}, {126, 130}, {253, 259}, {499, 513}, {1023, 1025}], fn m, list ->
        s0 = m.(:from_list, list)

        assert m.(:equals?, {s0, m.(:intersection, {s0, s0})})
        assert m.(:equals?, {s0, m.(:intersection, [s0, s0])})
        assert m.(:equals?, {s0, m.(:intersection, [s0, s0, s0])})
        assert m.(:equals?, {s0, m.(:intersection, [s0])})

        empty = m.(:empty, [])
        assert m.(:equals?, {empty, m.(:intersection, {s0, empty})})
        assert m.(:equals?, {empty, m.(:intersection, [s0, empty, s0, empty])})

        disjoint = for el <- list, do: {el}
        disjoint_set = m.(:from_list, disjoint)
        assert m.(:empty?, m.(:intersection, {s0, disjoint_set}))

        for n <- [0.3, 0.5, 0.7, 0.9] do
          some_removed = m.(:from_list, remove_some(disjoint, n))
          assert m.(:empty?, m.(:intersection, {s0, some_removed}))
          more_removed = m.(:from_list, remove_some(list, n))
          assert m.(:empty?, m.(:intersection, {more_removed, disjoint_set}))
        end

        partial_overlap = mutate_some(list, [])
        intersection_set = check_intersection(list, partial_overlap, m)
        refute m.(:empty?, intersection_set)

        check_intersection(list, remove_some(partial_overlap, 0.1), m)
        check_intersection(list, remove_some(partial_overlap, 0.3), m)
        check_intersection(list, remove_some(partial_overlap, 0.5), m)
        check_intersection(list, remove_some(partial_overlap, 0.7), m)
        check_intersection(list, remove_some(partial_overlap, 0.9), m)

        intersection_set
      end)
    end

    defp check_intersection(orig, mutated, m) do
      orig_set = m.(:from_list, orig)
      mutated_set = m.(:from_list, mutated)
      intersection = for el <- mutated, not is_tuple(el), do: el
      sorted_intersection = usort(intersection)
      intersection_set = m.(:intersection, {orig_set, mutated_set})

      assert m.(:equals?, {intersection_set, m.(:from_list, sorted_intersection)})
      assert sort(m.(:to_list, intersection_set)) == sorted_intersection

      intersection_set
    end

    test "union" do
      test_all([{1, 71}, {125, 129}, {254, 259}, {510, 513}, {1023, 1025}], fn m, list ->
        s = m.(:from_list, list)

        empty = m.(:empty, [])
        assert m.(:equals?, {s, m.(:union, {s, s})})
        assert m.(:equals?, {s, m.(:union, [s, s])})
        assert m.(:equals?, {s, m.(:union, [s, s, empty])})
        assert m.(:equals?, {s, m.(:union, [s, empty, s])})
        assert m.(:equals?, {s, m.(:union, {s, empty})})
        assert m.(:equals?, {s, m.(:union, [s])})
        assert m.(:empty?, m.(:union, []))

        check_union(list, remove_some(mutate_some(list), 0.9), m)
        check_union(list, remove_some(mutate_some(list), 0.7), m)
        check_union(list, remove_some(mutate_some(list), 0.5), m)
        check_union(list, remove_some(mutate_some(list), 0.3), m)
        check_union(list, remove_some(mutate_some(list), 0.1), m)

        check_union(list, mutate_some(remove_some(list, 0.9)), m)
        check_union(list, mutate_some(remove_some(list, 0.7)), m)
        check_union(list, mutate_some(remove_some(list, 0.5)), m)
        check_union(list, mutate_some(remove_some(list, 0.3)), m)
        check_union(list, mutate_some(remove_some(list, 0.1)), m)
      end)
    end

    defp check_union(orig, other, m) do
      orig_set = m.(:from_list, orig)
      other_set = m.(:from_list, other)
      union = orig ++ other
      sorted_union = usort(union)
      union_set = m.(:union, {orig_set, other_set})

      assert sort(m.(:to_list, union_set)) == sorted_union
      assert m.(:equals?, {union_set, m.(:from_list, union)})

      union_set
    end

    defp usort(enum) do
      enum
      |> sort()
      |> Enum.uniq()
    end

    defp sort(enum) do
      Enum.sort(enum)
    end
  end

  defp sets_mods do
    # ordsets = new(Ordsets, fn x, y -> x == y end)
    new_sets =
      new(Sets, fn x, y -> x == y end, fn -> Sets.new(version: 2) end, fn x ->
        Sets.from_list(x, version: 2)
      end)

    mix_sets =
      new(
        Sets,
        fn x, y -> Enum.sort(Sets.to_list(x)) == Enum.sort(Sets.to_list(y)) end,
        &mixed_new/0,
        &mixed_from_list/1
      )

    old_sets =
      new(
        Sets,
        fn x, y -> Enum.sort(Sets.to_list(x)) == Enum.sort(Sets.to_list(y)) end,
        &Sets.new/0,
        &Sets.from_list/1
      )

    # gb = new(GbSets, fn x, y -> GbSets.to_list(x) == GbSets.to_list(y) end)

    # [ordsets, old_sets, mix_sets, new_sets, gb]
    [old_sets, mix_sets, new_sets]
  end

  defp mixed_new do
    case Process.delete(:sets_type) do
      :deprecated ->
        Sets.new()

      nil ->
        Process.put(:sets_type, :deprecated)
        Sets.new(version: 2)
    end
  end

  defp mixed_from_list(list) do
    case Process.delete(:sets_type) do
      :deprecated ->
        Sets.from_list(list)

      nil ->
        Process.put(:sets_type, :deprecated)
        Sets.from_list(list, version: 2)
    end
  end

  defp test_all(tester) do
    res =
      for mod <- sets_mods() do
        :rand.seed(:exsplus, {1, 2, 42})
        s = tester.(mod)
        {mod.(:size, s), Enum.sort(mod.(:to_list, s))}
      end

    all_same(res)
  end

  defp test_all([{low, high} | tail], tester) do
    test_all(Enum.concat(low..high, tail), tester)
  end

  defp test_all([size | tail], tester) when is_integer(size) do
    list = rnd_list(size)

    res =
      for mod <- sets_mods() do
        :rand.seed(:exsplus, {19, 2, size})
        s = tester.(mod, list)
        {mod.(:size, s), Enum.sort(mod.(:to_list, s))}
      end

    all_same(res)
    test_all(tail, tester)
  end

  defp test_all([], _tester) do
    :ok
  end

  defp all_same([head | tail]), do: check_all_same(tail, head)

  defp check_all_same([head | tail], head), do: check_all_same(tail, head)
  defp check_all_same([], _match), do: :ok

  defp rnd_list(size), do: get_rnd_list(size, [])

  defp get_rnd_list(0, acc), do: acc
  defp get_rnd_list(n, acc), do: get_rnd_list(n - 1, [atomic_rnd_term() | acc])

  defp mutate_some(list), do: mutate_some(list, [])

  defp mutate_some([x, y, z | t], acc), do: mutate_some(t, [{x}, z, y | acc])
  defp mutate_some([h | t], acc), do: mutate_some(t, [h | acc])
  defp mutate_some([], acc), do: acc

  defp remove_some(list0, p) do
    case remove_some(list0, p, []) do
      list when length(list) == length(list0) -> tl(list)
      list -> list
    end
  end

  defp remove_some([h | t], p, acc) do
    if :rand.uniform() < p do
      remove_some(t, p, acc)
    else
      remove_some(t, p, [h | acc])
    end
  end

  defp remove_some([], _p, acc) do
    acc
  end

  defp atomic_rnd_term do
    case :rand.uniform(3) do
      1 -> :erlang.list_to_atom(:erlang.integer_to_list(?\s + :rand.uniform(94)) ++ ~c"rnd")
      2 -> :rand.uniform()
      3 -> :rand.uniform(50) - 37
    end
  end
end
