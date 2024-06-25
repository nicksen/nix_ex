defmodule Nix.Dev.TaskRunner.Printer do
  @moduledoc false

  @doc """
  Inof log a message
  """
  @spec info(IO.ANSI.ansidata()) :: :ok
  def info(out \\ []), do: Mix.shell().info(out)

  @doc """
  Error log a message
  """
  @spec error(IO.ANSI.ansidata()) :: :ok
  def error(out \\ []), do: Mix.shell().info(out)
end
