defmodule Nix.Glob.Sigils do
  @moduledoc """
  Provide the `~g` and `~G` sigils.
  """

  alias Nix.Glob

  @doc """
  Handles the sigil `~g` for globs.
  """
  defmacro sigil_g(term, modifiers)

  defmacro sigil_g({:<<>>, _meta, [string]}, _opts) when is_binary(string) do
    binary = :elixir_interpolation.unescape_string(string)
    glob = Glob.compile!(binary)

    Macro.escape(glob)
  end

  defmacro sigil_g({:<<>>, meta, pieces}, _opts) do
    binary = {:<<>>, meta, unescape_tokens(pieces)}

    quote do
      Nix.Glob.compile!(unquote(binary))
    end
  end

  @doc """
  Handle the sigil `~G` for globs.

  Compiles a glob expression without interpolation or escape characters.
  """
  defmacro sigil_G({:<<>>, _meta, [string]}, _opts) when is_binary(string) do
    string
    |> Glob.compile!()
    |> Macro.escape()
  end

  ## priv

  defp unescape_tokens(tokens) do
    for token <- tokens do
      :elixir_interpolation.unescape_string(token)
    end
  end
end
