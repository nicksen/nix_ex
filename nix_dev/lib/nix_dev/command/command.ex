defmodule Nix.Dev.Command do
  @moduledoc false

  @doc """
  Run the command configured by `profile`
  """
  @callback run(profile :: atom, extra_args :: keyword) :: non_neg_integer

  defmacro __using__(opts) do
    Module.put_attribute(__CALLER__.module, :behaviour, __MODULE__)

    quote do
      @impl unquote(__MODULE__)
      @spec run(atom, keyword) :: non_neg_integer
      def run(profile, extra_args) do
        unquote(__MODULE__).run(unquote(opts[:command]), profile, extra_args)
      end
    end
  end

  @doc """
  Runs the given `command` with `args`.

  The given args will be appended to the configured args. The task output will be streamed
  directly to stdio. Returns the exit code from the underlying call.
  """
  @spec run(String.t(), atom, keyword) :: non_neg_integer
  def run(command, profile, extra_args) when is_binary(command) and is_atom(profile) and is_list(extra_args) do
    config = config_for!(profile)
    config_args = config[:args] || []
    cmd_args = config_args ++ extra_args

    args =
      if cmd = config[:cmd] do
        [cmd | cmd_args]
      else
        cmd_args
      end

    {_output, exit_code} =
      System.cmd(command, args,
        env: config[:env] || %{},
        cd: config[:cd] || File.cwd!(),
        into: IO.stream(:stdio, :line),
        stderr_to_stdout: true
      )

    exit_code
  end

  @doc """
  Returns the configuration for the given profile
  """
  @spec config_for!(atom) :: keyword
  def config_for!(profile) when is_atom(profile) do
    Application.get_env(:nix_dev, profile) ||
      raise ArgumentError, """
        unknown profile. Make sure the profile is defined in your config files, such as:

            config :nix_dev,
              #{profile}: [
                cmd: "foo",
                args: ~w(--verbose),
                cd: Path.expand("../", __DIR__)
              ]
      """
  end
end
