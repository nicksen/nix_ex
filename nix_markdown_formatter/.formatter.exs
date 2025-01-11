[
  import_deps: [:stream_data],
  inputs: ["*.{ex,exs}", "{config,lib,test}/**/*.{ex,exs}", "*.{md,livemd}"],
  plugins: [Styler, Nix.MarkdownFormatter],
  markdown: [line_length: 100]
]
