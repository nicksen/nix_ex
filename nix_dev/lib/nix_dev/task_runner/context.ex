defmodule Nix.Dev.TaskRunner.Context do
  @moduledoc false

  alias Nix.Dev.TaskRunner.Option.TimeUnit

  @time_unit {:custom, TimeUnit, :validate, [[:s, :ms, :us, :ns]]}
  @options_schema NimbleOptions.new!(
                    jobs: [
                      type: :pos_integer,
                      default: 4
                    ],
                    timing_unit: [
                      type: @time_unit,
                      default: :us
                    ]
                  )

  @switches [
    jobs: :integer,
    timing_unit: :string
  ]
  @aliases [
    j: :jobs
  ]

  ## struct

  @enforce_keys [:argv, :opts, :args]
  defstruct [:argv, :opts, :args]

  ## types

  @type duration :: {non_neg_integer, TimeUnit.unit()}

  @opaque t :: %__MODULE__{
            argv: [String.t()],
            opts: [unquote(NimbleOptions.option_typespec(@options_schema))],
            args: [String.t()]
          }

  ## api

  @doc """
  Create new context
  """
  @spec new!([String.t()]) :: t
  def new!(argv) do
    {opts, args} = OptionParser.parse_head!(argv, strict: @switches, aliases: @aliases)
    config = NimbleOptions.validate!(opts, @options_schema)

    %__MODULE__{argv: argv, opts: config, args: args}
  end

  @doc """
  Extract commands from context
  """
  @spec commands(t) :: [[String.t(), ...]]
  def commands(%__MODULE__{} = ctx) do
    gather_commands(ctx.args, [], [])
  end

  @doc """
  Measure the execution time of `fun`
  """
  @spec timed(t, (-> value)) :: {duration, value} when value: term
  def timed(%__MODULE__{} = ctx, fun) when is_function(fun, 0) do
    unit = ctx.opts[:timing_unit]
    {duration, results} = :timer.tc(fun, unit)

    {{duration, unit}, results}
  end

  ## priv

  defp gather_commands([], current, acc) do
    Enum.reverse([Enum.reverse(current) | acc])
  end

  defp gather_commands(["+" | rest], current, acc) do
    gather_commands(rest, [], [Enum.reverse(current) | acc])
  end

  defp gather_commands([head | tail], current, acc) do
    gather_commands(tail, [head | current], acc)
  end
end
