defmodule Nix.Dev.Run.All.Matcher do
  @moduledoc false

  ## struct

  @enforce_keys [:pattern, :task, :args]
  defstruct [:pattern, :task, :args]

  ## types

  @opaque pattern :: Regex.t()
  @type task :: String.t()
  @type args :: String.t()

  @type t :: %__MODULE__{
          pattern: pattern,
          task: task,
          args: args
        }

  ## api

  @doc """
  Creates a new matcher.
  """
  @spec new!(binary, task, args) :: t
  def new!(glob, task, args) do
    pattern = compile!(glob, [])
    struct!(__MODULE__, pattern: pattern, task: task, args: args)
  end

  @doc """
  Test a matcher against a path.
  """
  @spec match?(t, String.t()) :: boolean
  def match?(%__MODULE__{pattern: pattern}, path) do
    matches?(pattern, path)
  end

  ## priv

  defp compile!(glob, opts) do
    case compile(glob, opts) do
      {:ok, re} ->
        re

      {:error, reason} ->
        raise ArgumentError, "failed to compile glob expression, reason: #{inspect(reason)}"
    end
  end

  defp compile(glob, opts) do
    glob
    |> to_charlist()
    |> convert([], opts)
  end

  defp matches?(glob, path) do
    Regex.match?(glob, path)
  end

  defp convert([], acc, _opts) do
    re = [?^, Enum.reverse(acc), ?$]

    re
    |> IO.iodata_to_binary()
    |> Regex.compile()
  end

  defp convert([?* | rest], acc, opts) do
    convert(rest, [?*, ?. | acc], opts)
  end

  defp convert([?? | rest], acc, opts) do
    convert(rest, [?. | acc], opts)
  end

  defp convert([?\\], _acc, _opts) do
    {:error, :escape_sequence_at_end_of_pattern}
  end

  defp convert([?\\, char | rest], acc, opts) do
    convert(rest, [char, ?\\ | acc], opts)
  end

  defp convert([?[, ?! | rest], acc, opts) do
    convert_char_class(rest, [?^, ?[ | acc], opts)
  end

  defp convert([?[ | rest], acc, opts) do
    convert_char_class(rest, [?[ | acc], opts)
  end

  defp convert([char | rest], acc, opts) do
    convert(rest, escape(char, acc), opts)
  end

  defp convert_char_class([], _acc, _opts) do
    {:error, :non_terminated_character_class}
  end

  defp convert_char_class([?\\], _acc, _opts) do
    {:error, :escape_sequence_at_end_of_pattern}
  end

  defp convert_char_class([?\\, char | rest], acc, opts) do
    convert_char_class(rest, [char, ?\\ | acc], opts)
  end

  defp convert_char_class([?] | rest], acc, opts) do
    convert(rest, [?] | acc], opts)
  end

  defp convert_char_class([char | rest], acc, opts) do
    convert_char_class(rest, [char | acc], opts)
  end

  defp escape(?^, acc), do: [?^, ?\\ | acc]
  defp escape(?$, acc), do: [?$, ?\\ | acc]
  defp escape(?., acc), do: [?., ?\\ | acc]
  defp escape(?|, acc), do: [?|, ?\\ | acc]
  defp escape(?(, acc), do: [?(, ?\\ | acc]
  defp escape(?), acc), do: [?), ?\\ | acc]
  defp escape(?+, acc), do: [?+, ?\\ | acc]
  defp escape(?{, acc), do: [?{, ?\\ | acc]
  defp escape(?}, acc), do: [?}, ?\\ | acc]
  defp escape(char, acc), do: [char | acc]
end
