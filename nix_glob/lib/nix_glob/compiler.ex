defmodule Nix.Glob.Compiler do
  @moduledoc false

  alias Nix.Glob.Compiled
  alias Nix.Glob.Options

  def compile(glob, opts) do
    with {:ok, parsed} <- make_re(glob, opts) do
      {pattern, negate} = parsed
      compiled = Compiled.new(glob, pattern, negate, opts)
      {:ok, compiled}
    end
  end

  ## priv

  defp make_re(pattern, opts) do
    {negate, pattern} = parse_negate(pattern, opts)
    expanded_pattern_set = expand_braces(pattern, opts)
    glob_parts_set = split_pattern(expanded_pattern_set)

    with {:ok, regex_parts_set} <- convert_to_regex(glob_parts_set) do
      {:ok, {regex_parts_set, negate}}
    end
  end

  defp parse_negate(pattern, %Options{nonegate: true}), do: {pattern, false}

  defp parse_negate(pattern, _opts) do
    range = 0..(String.length(pattern) - 1)

    {_prev, negate, offset} =
      Enum.reduce(range, {true, false, 0}, fn i, {prev_negate, negate, offset} ->
        cond do
          not prev_negate ->
            {prev_negate, negate, offset}

          String.at(pattern, i) == "!" ->
            {prev_negate, not negate, offset + 1}

          :else ->
            {false, negate, offset}
        end
      end)

    if offset > 0 do
      {negate, String.slice(pattern, offset, String.length(pattern))}
    else
      {negate, pattern}
    end
  end

  defp expand_braces(pattern, %Options{} = opts) do
    if opts.nobrace or not (pattern =~ ~r/\{.*\}/) do
      [pattern]
    end
  end

  defp split_pattern(patterns) do
    patterns
  end

  defp convert_to_regex(patterns) do
    {:ok, patterns}
  end
end
