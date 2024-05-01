defmodule Nix.Lint.Setup do
  @moduledoc false

  @tools [:compiler, :xref, :unused_deps, :formatter, :recode, :hex_audit, :mix_audit, :credo, :dialyzer]

  def run(opts) do
    @tools
    |> Enum.reject(&disabled?(&1, opts))
    |> inject_dependencies()
    |> copy_new_files()
    |> dbg()
  end

  defp inject_dependencies(tools) do
    file_path = Mix.Project.project_file()
    file = File.read!(file_path)

    for tool <- tools do
      case inject_dependency(file, @tool_deps[tool]) do
        {:ok, new_file} ->
          print_injecting(file_path)
          File.write!(file_path, new_file)

        :already_injected ->
          :ok

        {:error, :unable_to_inject} ->
          Mix.shell().info("""

          Add your #{mix_dependency} dependency to #{file_path}:

              defp deps do
                [
                  #{mix_dependency},
                  ...
                ]
              end
          """)
      end
    end

    tools
  end

  defp copy_new_files(tools) do
    tools
  end

  defp disabled?(tool, opts) do
    if Keyword.has_key?(opts, :only) do
      !Enum.any?(opts, &(&1 == {:only, tool}))
    else
      Enum.any?(opts, &(&1 == {:except, tool}))
    end
  end
end
