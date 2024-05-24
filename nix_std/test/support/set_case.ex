defmodule SetCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  using do
    quote do
      import unquote(__MODULE__)
    end
  end

  def new(mod, eq) do
    new(mod, eq, &mod.new/0, &mod.from_list/1)
  end

  def new(mod, eq0, new, from_list) do
    eq = fn s1, s2 ->
      res = eq0.(s1, s2)
      ^res = mod.equals?(s1, s2)
    end

    &call(&1, &2, mod, eq, new, from_list)
  end

  ## priv

  defp call(:put, {s0, el}, mod, _eq, _new, _from_list) do
    s = mod.put(s0, el)
    assert mod.contains?(s, el)
    refute mod.empty?(s)
    assert mod.set?(s)
    s
  end

  defp call(:del, {s0, el}, mod, _eq, _new, _from_list) do
    s = mod.delete(s0, el)
    refute mod.contains?(s, el)
    assert mod.set?(s)
    s
  end

  defp call(:empty, [], _mod, _eq, new, _from_list) do
    new.()
  end

  defp call(:filter, {s, f}, mod, _eq, _new, _from_list) do
    assert mod.set?(s)
    mod.filter(s, f)
  end

  defp call(:filter_map, {s, f}, mod, _eq, _new, _from_list) do
    assert mod.set?(s)
    mod.filter_map(s, f)
  end

  defp call(:fold, {s, a, f}, mod, _eq, _new, _from_list) do
    assert mod.set?(s)
    mod.fold(s, a, f)
  end

  defp call(:from_list, l, _mod, _eq, _new, from_list) do
    from_list.(l)
  end

  defp call(:intersection, {s1, s2}, mod, eq, _new, _from_list) do
    s = mod.intersection(s1, s2)
    assert eq.(s, mod.intersection(s2, s1))
    empty? = mod.empty?(s)
    assert mod.disjoint?(s1, s2) == empty?
    assert mod.disjoint?(s2, s1) == empty?
    s
  end

  defp call(:intersection, ss, mod, eq, _new, _from_list) do
    s = mod.intersection(ss)
    assert eq.(s, mod.intersection(Enum.reverse(ss)))
    s
  end

  defp call(:equals?, {s, set}, _mod, eq, _new, _from_list) do
    eq.(s, set)
  end

  defp call(:disjoint?, {s, set}, mod, _eq, _new, _from_list) do
    mod.disjoint?(s, set)
  end

  defp call(:empty?, s, mod, _eq, _new, _from_list) do
    mod.empty?(s)
  end

  defp call(:set?, s, mod, _eq, _new, _from_list) do
    mod.set?(s)
  end

  defp call(:subset?, {s, set}, mod, eq, _new, _from_list) do
    if mod.subset?(s, set) and mod.subset?(set, s) do
      assert eq.(s, set)
    end
  end

  defp call(:iterator, s, mod, _eq, _new, _from_list) do
    mod.iterator(s)
  end

  defp call(:iterator_from, {s, start}, mod, _eq, _new, _from_list) do
    mod.iterator_from(s, start)
  end

  defp call(:map, {s, f}, mod, _eq, _new, _from_list) do
    assert mod.set?(s)
    mod.map(s, f)
  end

  defp call(:module, [], mod, _eq, _new, _from_list) do
    mod
  end

  defp call(:next, i, mod, _eq, _new, _from_list) do
    mod.next(i)
  end

  defp call(:singleton, e, mod, _eq, _new, from_list) do
    if function_exported?(mod, :singleton, 1) do
      mod.singleton(e)
    else
      from_list.([e])
    end
  end

  defp call(:size, s, mod, _eq, _new, _from_list) do
    mod.size(s)
  end

  defp call(:subtract, {s1, s2}, mod, _eq, _new, _from_list) do
    s = mod.subtract(s1, s2)
    assert mod.set?(s)
    assert mod.size(s) <= mod.size(s1)
    s
  end

  defp call(:to_list, s, mod, _eq, _new, _from_list) do
    mod.to_list(s)
  end

  defp call(:union, {s1, s2}, mod, eq, _new, _from_list) do
    s = mod.union(s1, s2)
    assert eq.(s, mod.union(s2, s1))
    assert mod.set?(s)
    s
  end

  defp call(:union, ss, mod, eq, _new, _from_list) do
    s = mod.union(ss)
    assert eq.(s, mod.union(Enum.reverse(ss)))
    s
  end
end
