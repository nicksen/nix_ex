defmodule Nix.Dev.TaskRunner.Option.TimeUnit do
  @moduledoc false

  @known_units [:second, :millisecond, :microsecond, :nanosecond]
  @aliases [second: :s, millisecond: :ms, microsecond: :us, nanosecond: :ns]

  ## types

  @type unit :: :second | :millisecond | :microsecond | :nanosecond

  ## api

  @doc """
  Validate time unit.
  """
  @spec validate(atom | String.t(), [atom]) :: {:ok, unit} | {:error, term}

  def validate(value, choices) when is_atom(value) do
    long_value = long_name(value)
    long_choices = Enum.map(choices, &long_name/1)

    if long_value in long_choices do
      {:ok, long_value}
    else
      {:error, "unknown unit: #{long_value}, not one of (#{Enum.join(long_choices, ",")})"}
    end
  end

  def validate(value, choices) when is_binary(value) do
    value
    |> String.to_existing_atom()
    |> validate(choices)
  end

  ## priv

  defp long_name(unit) when unit in @known_units, do: unit

  for {name, alias} <- @aliases do
    defp long_name(unquote(alias)), do: unquote(name)
  end
end
