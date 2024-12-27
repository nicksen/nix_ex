[
  import_deps: [:stream_data],
  inputs: ["*.{ex,exs,md}", "{config,lib,test}/**/*.{ex,exs}"],
  plugins: [Styler, MarkdownFormatter],
  markdown: [line_length: 100]
]
