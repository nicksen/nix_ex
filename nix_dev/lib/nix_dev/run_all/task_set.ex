defmodule Nix.Dev.Run.All.TaskSet do
  @moduledoc false

  ## types

  @typep command :: String.t()
  @typep task :: String.t()

  @opaque t :: %__MODULE__{
            commands: [command],
            source_map: %{command => [task]}
          }

  ## struct

  defstruct [:commands, :source_map]

  ## api

  @doc """
  Create a new `TaskSet`.
  """
  @spec new() :: t
  def new do
    %__MODULE__{commands: [], source_map: %{}}
  end

  @doc """
  Update `task_set` with `command` and `source`.
  """
  @spec add(t, command, task) :: t
  def add(%__MODULE__{} = task_set, command, source) do
    task_set
    |> put_distinct_command(command, source)
    |> put_source(command, source)
  end

  @doc """
  Convert `task_set` to a list.
  """
  @spec to_list(t) :: [command]
  def to_list(%__MODULE__{commands: commands}), do: Enum.reverse(commands)

  ## priv

  defp put_distinct_command(%__MODULE__{} = task_set, command, source) do
    source_list = Map.get(task_set.source_map, command)

    if source_list == nil || source in source_list do
      %{task_set | commands: [command | task_set.commands]}
    else
      task_set
    end
  end

  defp put_source(%__MODULE__{} = task_set, command, source) do
    source_map = Map.update(task_set.source_map, command, [source], &[source | &1])
    %{task_set | source_map: source_map}
  end

  ## `Enumerable` impl

  defimpl Enumerable do
    def count(%{commands: commands}), do: @protocol.List.count(commands)

    def member?(%{commands: commands}, val), do: @protocol.List.member?(commands, val)

    def slice(%{commands: commands}) do
      commands
      |> Enum.reverse()
      |> @protocol.List.slice()
    end

    def reduce(%{commands: commands}, acc, fun) do
      commands
      |> Enum.reverse()
      |> @protocol.List.reduce(acc, fun)
    end
  end
end
