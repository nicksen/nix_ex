defmodule Nix.Dev.Printer do
  @moduledoc false

  def info(output \\ []), do: Mix.shell().info(output)

  def error(output \\ []), do: Mix.shell().error(output)
end
