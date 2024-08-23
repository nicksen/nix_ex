defmodule Nix.Std.Lazy do
  @moduledoc """
  Lazy evaluations.
  """

  ## api

  @doc """
  Creates a new function that applies `arg` to `fun`

  ## Examples

      iex> bind(3, &(&1 * 2)).()
      6

      iex> bind([[4, 3], [2, 1]], &Enum.concat/1).()
      [4, 3, 2, 1]
  """
  @spec bind(x, (x -> r)) :: (-> r) when x: term, r: term
  def bind(arg, fun) when is_function(fun, 1) do
    fn -> fun.(arg) end
  end
end
