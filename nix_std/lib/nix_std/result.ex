defmodule Nix.Std.Result do
  @moduledoc """
  Monadic result.
  """

  ## types

  @type successful(value) :: {:ok, value}
  @type failed(reason) :: {:error, reason}
  @type result(value, reason) :: successful(value) | failed(reason)

  @type t :: result(term, term)

  ## api

  @doc """
  Wrap value as an `{:ok, value}` tuple.

  ## Example

      iex> ok("data")
      {:ok, "data"}
  """
  @spec ok(value) :: result(value, term) when value: term
  def ok(value), do: {:ok, value}

  @doc """
  Wrap reason as an `{:error, reason}` tuple.

  ## Example

      iex> error(:no_match)
      {:error, :no_match}
  """
  @spec error(reason) :: result(term, reason) when reason: term
  def error(reason), do: {:error, reason}

  @doc """
  Map an `{:ok, value}` tuple using `mapper`.

  ## Example

      iex> map({:ok, 2}, &(&1 * 3))
      {:ok, 6}

      iex> map({:error, :wrong}, &(&1 * 3))
      {:error, :wrong}
  """
  @spec map(result, mapper) :: mapped
        when result: result(value, reason),
             mapper: (value -> new_value),
             mapped: result(new_value, reason),
             value: term,
             reason: term,
             new_value: term
  def map(result, mapper)

  def map({:ok, value}, fun), do: {:ok, fun.(value)}
  def map({:error, _reason} = error, _fun), do: error

  @doc """
  Map an `{:ok, value}` tuple using `mapper`, flattening the result.

  ## Example

      iex> flat_map({:ok, "asd"}, &({:ok, String.duplicate(&1, 2)}))
      {:ok, "asdasd"}

      iex> flat_map({:error, :kaboom}, &({:error, Atom.to_string(&1)}))
      {:error, :kaboom}
  """
  @spec flat_map(result, mapper) :: mapped
        when result: result(value, reason),
             mapper: (value -> result(new_value, reason)),
             mapped: result(new_value, reason),
             value: term,
             reason: term,
             new_value: term
  def flat_map(result, mapper)

  def flat_map({:ok, value}, fun) when is_function(fun, 1), do: fun.(value)
  def flat_map({:error, _reason} = error, _fun), do: error

  @doc """
  Map an `{:error, reason}` tuple using `mapper`.

  ## Example

      iex> map_error({:error, :bang}, &to_string/1)
      {:error, "bang"}

      iex> map_error({:ok, 1}, &(&1 + 4))
      {:ok, 1}
  """
  @spec map_error(result, mapper) :: mapped
        when result: result(value, reason),
             mapper: (reason -> new_reason),
             mapped: result(value, new_reason),
             value: term,
             reason: term,
             new_reason: term
  def map_error(result, mapper)

  def map_error({:ok, _value} = result, _fun), do: result
  def map_error({:error, reason}, fun) when is_function(fun, 1), do: {:error, fun.(reason)}

  @doc """
  Unwrap result

  ## Example

      iex> unwrap({:ok, 4})
      4

      iex> unwrap({:error, "fail"})
      ** (RuntimeError) fail
  """
  @spec unwrap(result) :: value when result: result(value, reason), value: term, reason: term
  def unwrap(result)

  def unwrap({:ok, value}), do: value
  def unwrap({:error, reason}), do: raise(reason)

  @doc """
  Unwrap result or get `default`.

  ## Example

      iex> unwrap_or({:ok, 55}, 10)
      55

      iex> unwrap_or({:error, "fail"}, 10)
      10
  """
  @spec unwrap_or(result, default) :: value | default
        when result: result(value, reason), default: term, value: term, reason: term
  def unwrap_or(result, default)

  def unwrap_or({:ok, value}, _default), do: value
  def unwrap_or({:error, _reason}, default), do: default
end
