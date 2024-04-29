defmodule Nix.Std.FP do
  @moduledoc false

  ## api

  @doc """
  Normal (binary) function composition.

  ## Examples

    iex> f = b(&(&1 + 1), &Enum.sum/1)
    ...> f.([1,2,3])
    7
  """
  @spec b(f :: (y -> r), g :: (x -> y)) :: (x -> r) when x: term, y: term, r: term
  def b(f, g) when is_function(f, 1) and is_function(g, 1) do
    &f.(g.(&1))
  end

  @doc """
  Apply function with arguments reversed.

  ## Examples

    iex> c(&div/2).(1, 2)
    2

    iex> f = c(&Enum.concat/2)
    ...> f.([1,2,3], [4,5,6])
    [4,5,6,1,2,3]

    iex> flip(&div/2).(1, 2)
    2
  """
  @spec c(f :: (y, x -> r)) :: (x, y -> r) when x: term, y: term, r: term
  def c(f) when is_function(f, 2) do
    &f.(&2, &1)
  end

  defdelegate flip(f), to: __MODULE__, as: :c

  @doc """
  The `identity` combinator.

  ## Examples

    iex> i(1)
    1

    iex> i("i combinator")
    "i combinator"

    iex> id([1,2,3])
    [1,2,3]
  """
  @spec i(x) :: x when x: term
  def i(x), do: x

  defdelegate id(x), to: __MODULE__, as: :i

  @doc """
  The `constant` combinator.

  Creates a 1-arity function that returns the argument to _this_ function.

  ## Examples

    iex> f = k(1)
    ...> f.(2)
    1
    iex> f.(4)
    1

    iex> k("happy").("sad")
    "happy"
  """
  @spec k(x) :: (any -> x) when x: term
  def k(x) do
    fn _y -> x end
  end

  defdelegate const(x), to: __MODULE__, as: :k

  @doc """
  Apply a function to itself.

  ## Examples

    iex> even = fn me ->
    ...>   fn
    ...>     0 -> true
    ...>     n -> !me.(me).(n - 1)
    ...>   end
    ...> end
    ...> f = m(even)
    ...> f.(0)
    true
    iex> f.(1)
    false
  """
  @spec m(f :: (term -> (term -> term))) :: (term -> term)
  def m(f) when is_function(f, 1) do
    &f.(f).(&1)
  end

  @doc """
  The `substitution` combinator.

  Creates a function that applies the argument (`a`) to the 2nd function, and then applies `a`
  and the result to the first function.

  ## Examples

    iex> add = &(&1 + &2)
    ...> double = &(&1 * 2)
    ...> f = s(add, double)
    ...> f.(8)
    24
  """
  @spec s(f :: (x, y -> r), g :: (x -> y)) :: (x -> r) when x: term, y: term, r: term
  def s(f, g) when is_function(f, 2) and is_function(g, 1) do
    &f.(&1, g.(&1))
  end

  @doc """
  Apply an argument to a function twice.

  ## Examples

    iex> f = w(&Enum.concat/2)
    ...> f.([1,2])
    [1,2,1,2]

    iex> w(&Enum.zip/2).([1,2,3])
    [{1,1}, {2,2}, {3,3}]
  """
  @spec w(f :: (x, x -> r)) :: (x -> r) when x: term, r: term
  def w(f) when is_function(f, 2) do
    &f.(&1, &1)
  end

  @doc """
  The Y-combinator.

  ## Examples

    iex> fac = fn f ->
    ...>   fn
    ...>     0 -> 0
    ...>     1 -> 1
    ...>     n -> n * f.(n - 1)
    ...>   end
    ...> end
    ...> yfac = y(fac)
    iex> yfac.(3)
    6
    iex> yfac.(9)
    362880
  """
  @spec y(f :: ((term -> term) -> (term -> term))) :: (term -> term)
  def y(f) when is_function(f, 1) do
    (fn x -> x.(x) end).(fn y -> f.(fn a -> y.(y).(a) end) end)
  end

  def turing(f) when is_function(f, 1) do
    turing_inner().(turing_inner()).(f)
  end

  defp turing_inner do
    fn x ->
      fn y ->
        y.(&x.(x).(y).(&1))
      end
    end
  end

  def z(f) do
    fn a ->
      f.(z(f)).(a)
    end
  end

  @doc """
  Compose unary functions.

  ## Examples

    iex> incr = &(&1 + 1)
    ...> double = &(&1 * 2)
    ...> f = compose([incr, double, &Enum.sum/1])
    ...> f.([1,2,3])
    13
  """
  @spec compose(fns :: nonempty_list((term -> term))) :: (term -> term)
  def compose([_head | _tail] = fns) do
    Enum.reduce(fns, c(&b/2))
  end

  @doc """
  Left-to-right unary function composition.

  ## Examples

    iex> f = pipe([&Enum.join/1, &String.length/1])
    ...> f.(["a", "b", "c"])
    3
  """
  @spec pipe(fns :: nonempty_list((term -> term))) :: (term -> term)
  def pipe([_head | _tail] = fns) do
    Enum.reduce(fns, &b/2)
  end
end
