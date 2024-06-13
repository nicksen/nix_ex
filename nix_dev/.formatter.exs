{default, []} = Code.eval_file("../format.config.exs", __DIR__)

extras = [
  subdirectories: ["test"],
  inputs: ["*.{ex,exs,md}", "{config,lib}/**/*.{ex,exs}"]
]

Keyword.merge(default, extras)
