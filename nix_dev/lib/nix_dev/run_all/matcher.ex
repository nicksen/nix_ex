defmodule Nix.Dev.Run.All.Matcher do
  @moduledoc false

  ## struct

  @enforce_keys [:pattern, :task, :args]
  defstruct [:pattern, :task, :args]

  ## types

  @opaque pattern :: GlobEx.t()
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
    pattern = compile!(glob)
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

  defp compile!(glob, opts \\ []), do: GlobEx.compile!(glob, opts)

  defp matches?(glob, path), do: GlobEx.match?(glob, path)
end
