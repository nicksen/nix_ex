[
  subdirectories: ["test"],
  inputs: ["*.{ex,exs,md}", "{config,lib}/**/*.{ex,exs}"],
  plugins: [Styler, MarkdownFormatter],
  markdown: [line_length: 100]
]
