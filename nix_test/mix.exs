defmodule Nix.Test.MixProject do
  use Mix.Project

  @vsn "1.0.0"

  def project do
    [
      app: :nix_test,
      version: @vsn,
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      docs: [
        main: "readme",
        api_reference: false,
        extras: ["README.md"],
        formatters: ["html"]
      ],
      dialyzer: dialyzer()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:ex_unit, :logger]
    ]
  end

  # specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      ## testing
      {:stream_data, "~> 1.1", only: [:dev, :test]},

      ## dev
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:credo_contrib, "~> 0.2", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:doctor, "~> 0.21", only: :dev, runtime: false},
      {:ex_doc, "~> 0.32", only: :dev, runtime: false},
      {:markdown_formatter, "~> 1.0", only: [:dev, :test], runtime: false},
      {:mix_audit, "~> 2.1", only: [:dev, :test], runtime: false},
      {:recode, "~> 0.7", only: [:dev, :test], runtime: false},
      {:styler, "~> 1.2", only: [:dev, :test], runtime: false}
    ]
  end

  # aliases are shortcuts or tasks specific to the current project
  # see the documentation for `mix` for more info on aliases
  defp aliases do
    [
      "lint.check": [
        "compile --all-warnings --warnings-as-errors",
        "deps.unlock --check-unused",
        "cmd mix hex.audit",
        "deps.audit",
        "xref graph --label compile-connected --fail-above 0",
        "format --check-formatted",
        "cmd mix recode --no-autocorrect",
        "credo suggest",
        "doctor --raise --failed --summary",
        "dialyzer"
      ],
      "lint.fmt": [
        "deps.unlock --unused",
        "deps.clean --unused",
        "format",
        "cmd mix recode --autocorrect"
      ]
    ]
  end

  defp dialyzer do
    [
      flags: [
        :error_handling,
        :missing_return,
        :no_undefined_callbacks,
        :underspecs,
        :unknown,
        :unmatched_returns
      ],
      ignore_warnings: ".dialyzer_ignore.exs",
      list_unused_filters: true
    ]
  end
end
