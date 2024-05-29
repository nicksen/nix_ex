defmodule Nix.Glob do
  @moduledoc """
  Glob paths without walking the tree.

  Elixir and Erlang provide `wildcard` functions in the stdlib, but these will walk the directory
  tree. This module lets you test against strings.
  """

  alias Nix.Glob.Compiler
  alias Nix.Glob.Options
  alias Nix.Glob.ParseError

  ## types

  @type glob :: String.t()
  @type options :: [unquote(NimbleOptions.option_typespec(Nix.Glob.Options.schema()))]

  @opaque t :: Nix.Glob.Compiled.t()

  ## api

  @doc """
  Compile a glob expression.

  ## Options

  #{NimbleOptions.docs(Nix.Glob.Options.schema())}

  ## Examples

      iex> compile!("src/**/*oo.ex")
      ~g[src/**/*oo.ex]

      iex> compile!("src/**/*.oo.ex", nonegate: true)
      ~g[src/**/*oo.ex]n
  """
  @spec compile!(glob, options) :: t
  def compile!(glob, opts \\ []) do
    case compile(glob, opts) do
      {:ok, pattern} -> pattern
      {:error, reason} -> raise reason
    end
  end

  def compile(glob, opts \\ []) do
    with {:ok, opts} <- Options.new(opts) do
      Compiler.compile(glob, opts)
    end
  end
end
