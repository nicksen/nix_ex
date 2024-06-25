defmodule Nix.Dev.TaskRunner.Config do
  @moduledoc false

  alias Nix.Dev.TaskRunner.Project

  @options_schema NimbleOptions.new!(
                    jobs: [
                      type: :pos_integer
                    ]
                  )

  @config_filename ".tasks.exs"
  # @option_list ~w(jobs)a

  @default_config [
    tasks: [],
    jobs: 4
  ]

  ## types

  @type task_name :: atom
  @type task_group :: [String.t()]
  @type task :: {task_name, [task_group]}
  @type t :: [{:tasks, [task]}, {:jobs, pos_integer}]

  ## api

  @spec load!(keyword) :: t
  def load!(opts) do
    opts = NimbleOptions.validate!(opts, @options_schema)

    project_root_config = config_filename(Project.mix_root_dir())
    files = project_root_config
    default_config = @default_config

    config =
      default_config
      |> merge_from_files(files)
      |> merge_config(opts)

    config
  end

  @spec pipeline(t, atom | String.t()) :: [task_group] | nil

  def pipeline(config, task) when is_atom(task) do
    Keyword.get(config[:tasks], task, [{Atom.to_string(task), deps: []}])
  end

  def pipeline(config, task) when is_binary(task) do
    pipeline(config, String.to_atom(task))
  end

  ## priv

  defp config_filename(dir) do
    dir
    |> Path.join(@config_filename)
    |> Path.expand()
    |> List.wrap()
  end

  defp merge_from_files(config, files) do
    for file <- files, File.exists?(file), reduce: config do
      acc ->
        {file_config, []} = Code.eval_file(file)
        merge_config(acc, file_config)
    end
  end

  defp merge_config(config, update) do
    Keyword.merge(config, update)
  end
end
