[
  import_deps: [:stream_data],
  inputs: ["*.{ex,exs}", "{config,lib,test}/**/*.{ex,exs}"],
  plugins: [Styler],
  markdown: [line_length: 100]
]
