defmodule Nix.Crypto do
  @moduledoc """
  Documentation for `Nix.Crypto`.
  """

  @doc """
  Returns a random integer between `low` and `high` (inclusive).

  ## Examples

      iex> n = rand_int(2, 20)
      iex> assert(n >= 2)
      true
      iex> assert(n <= 20)
      true

      iex> n = rand_int(23, 99)
      iex> assert(n >= 23)
      true
      iex> assert(n <= 99)
      true

      iex> n = rand_int(212, 736)
      iex> assert(n >= 212)
      true
      iex> assert(n <= 736)
      true

      iex> n = rand_int(-100, -1)
      iex> assert(n >= -100)
      true
      iex> assert(n <= -1)
      true

      iex> n = rand_int(-100, 100)
      iex> assert(n >= -100)
      true
      iex> assert(n <= 100)
      true
  """
  @spec rand_int(low :: integer, high :: integer) :: integer
  def rand_int(low, high) when is_integer(low) and is_integer(high) and low < high do
    low + :rand.uniform(high - low + 1) - 1
  end

  @doc """
  Returns a random integer bound by `range` (inclusive), or between `0` and `boundary` if called
  with an integer.

  ## Examples

      iex> n = rand_int(1..5)
      iex> assert(n >= 1)
      true
      iex> assert(n <= 5)
      true

      iex> n = rand_int(-5..-3)
      iex> assert(n >= -5)
      true
      iex> assert(n <= -3)
      true

      iex> n = rand_int(99)
      iex> assert(n >= 0)
      true
      iex> assert(n <= 99)
      true

      iex> n = rand_int(-40)
      iex> assert(n >= -40)
      true
      iex> assert(n <= 0)
      true
  """
  @spec rand_int(range :: Range.t()) :: integer
  @spec rand_int(high :: pos_integer) :: non_neg_integer
  @spec rand_int(low :: neg_integer) :: neg_integer | 0
  def rand_int(boundary)

  def rand_int(%Range{} = range), do: rand_int(range.first, range.last)
  def rand_int(high) when is_integer(high) and high > 0, do: rand_int(0, high)
  def rand_int(low) when is_integer(low) and low < 0, do: rand_int(low, 0)
end
