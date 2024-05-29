defmodule Nix.Glob.Compiled do
  @moduledoc false

  alias Nix.Glob.Options

  ## types

  @type source :: binary
  @type pattern :: [term]
  @type negate :: boolean
  @type opts :: Options.t()

  @type t :: %__MODULE__{
          source: source,
          pattern: pattern,
          negate: negate,
          opts: opts
        }

  ## struct

  @enforce_keys [:source, :pattern, :negate, :opts]
  defstruct [:source, :pattern, :negate, :opts]

  ## api

  def new(source, pattern, negate, opts) do
    %__MODULE__{
      source: source,
      pattern: pattern,
      negate: negate,
      opts: opts
    }
  end
end
