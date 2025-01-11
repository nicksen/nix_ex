# Nix.MarkdownFormatter

An Elixir formatter for markdown files and sigils.

## Installation

The package can be installed by adding `nix_markdown_formatter` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:nix_markdown_formatter, github: "nicksen/nix_ex", subdir: "nix_markdown_formatter", depth: 1, only: [:dev, :test], runtime: false}
  ]
end
```

Run `mix deps.get` and `mix deps.compile`, or the module will not be available to the formatter.

## Usage

Add `Nix.MarkdownFormatter` to the `.formatter.exs` plugin list, and add `.md` files to the list of inputs.

```elixir
[
  plugins: [Nix.MarkdownFormatter],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}", "*.{md,markdown,livemd}"]
]
```

Configure with a `:markdown` section:

```elixir
[
  plugins: [Nix.MarkdownFormatter],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}", "*.{md,markdown,livemd}"],
  markdown: [
    line_length: 120
  ]
]
```