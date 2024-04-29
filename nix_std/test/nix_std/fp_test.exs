defmodule Nix.Std.FPTest do
  use ExUnit.Case, async: true

  import Nix.Std.FP

  doctest Nix.Std.FP, import: true

  describe "m" do
    test "exponent" do
      exponent = fn me ->
        fn {x, n} ->
          cond do
            n == 0 -> 1
            rem(n, 2) == 1 -> x * me.(me).({x * x, div(n, 2)})
            :else -> me.(me).({x * x, div(n, 2)})
          end
        end
      end

      m_exponent = m(exponent)

      assert m_exponent.({2, 8}) == 256
    end

    test "even?" do
      even? = fn me ->
        fn
          0 -> true
          n -> !me.(me).(n - 1)
        end
      end

      m_even? = m(even?)

      assert m_even?.(0) === true
      assert m_even?.(1) === false
    end
  end

  describe "y" do
    @describetag :f

    test "turing" do
      fac = fn fac ->
        fn
          0 -> 0
          1 -> 1
          n -> n * fac.(n - 1)
        end
      end

      factorial = turing(fac)

      assert factorial.(9) == 362_880
    end

    test "z" do
      fac = fn fac ->
        fn
          0 -> 0
          1 -> 1
          n -> n * fac.(n - 1)
        end
      end

      factorial = z(fac)

      assert factorial.(9) == 362_880
    end
  end
end
