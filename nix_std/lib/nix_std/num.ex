defmodule Nix.Std.Num do
  @moduledoc """
  Functions to operate on numbers.
  """

  ## guards

  defguardp is_integers(v1, v2, v3) when is_integer(v1) and is_integer(v2) and is_integer(v3)

  defguardp is_floats(v1, v2, v3) when is_float(v1) and is_float(v2) and is_float(v3)

  ## api

  @doc """
  Returns a number `n` clamped within the `[low, high]` range.

  ## Examples

      iex> clamp(1, 0, 2)
      1

      iex> clamp(10, 1, 3)
      3

      iex> clamp(1, 4, 8)
      4

      iex> clamp(0.5, 0.0, 1.0)
      0.5

      iex> clamp(1.5, 0.0, 1.0)
      1.0

      iex> clamp(0.3, 0.7, 1.0)
      0.7
  """
  @spec clamp(n :: cmp, low :: cmp, high :: cmp) :: result :: cmp when cmp: integer | float
  def clamp(n, low, high)

  def clamp(n, min, max) when is_integers(n, min, max) and n > max, do: max
  def clamp(n, min, max) when is_integers(n, min, max) and n < min, do: min
  def clamp(n, min, max) when is_integers(n, min, max), do: n

  def clamp(n, min, max) when is_floats(n, min, max) and n > max, do: max
  def clamp(n, min, max) when is_floats(n, min, max) and n < min, do: min
  def clamp(n, min, max) when is_floats(n, min, max), do: n
end
