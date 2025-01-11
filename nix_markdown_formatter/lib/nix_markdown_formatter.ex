defmodule Nix.MarkdownFormatter do
  @moduledoc """
  A formatter to be plugged in to `mix format` in order to format Markdown files and sigils.

  ## Usage

  Add `Nix.MarkdownFormatter` to the `.formatter.exs` plugin list.

  ```elixir
  [
    plugins: [Nix.MarkdownFormatter],
    inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}", "*.{md,markdown,livemd}"]
  ]
  ```

  ## Configuration

  Markdown formatting can be configured via a nested `:markdown` keyword list in the formatter configuration.

  * `:line_length` - (integer)

  ```elixir
  [
    plugins: [Nix.MarkdownFormatter],
    inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}", "*.{md,markdown,livemd}"],
    markdown: [
      line_length: 80
    ]
  ]
  ```
  """

  @behaviour Mix.Tasks.Format

  alias Mix.Tasks.Format

  @impl Format
  def features(_opts) do
    [sigils: [:M], extensions: [".md", ".markdown", ".livemd"]]
  end

  @impl Format
  def format(contents, opts) do
    markdown_opts =
      opts
      |> Keyword.get(:markdown, [])
      |> Keyword.validate!(line_length: nil)

    # markdown_ast = MDEx.parse_document!(contents)
    # MDEx.to_commonmark!(markdown_ast, render: [width: markdown_opts[:line_length]])

    {:ok, ast, []} = EarmarkParser.as_ast(contents)
    EarmarkReversal.markdown_from_ast(ast)
  end
end
