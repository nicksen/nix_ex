defmodule Nix.Glob.Options do
  @moduledoc false

  defmodule ValidationError do
    @moduledoc false

    defexception [:reason]

    @impl Exception
    def exception(%NimbleOptions.ValidationError{} = reason) do
      %__MODULE__{reason: Exception.message(reason)}
    end
  end

  @options_schema NimbleOptions.new!(
                    nobrace: [
                      type: :boolean,
                      default: false,
                      doc: "Do not expand `{a,b}` or `{1..3}` brace sets."
                    ],
                    noglobstar: [
                      type: :boolean,
                      default: false,
                      doc: "Disable `**` matching against multiple folder names."
                    ],
                    dot: [
                      type: :boolean,
                      default: false,
                      doc: """
                      Allow patterns to match filenames starting with a period, even if the
                      pattern does not explicitly have a period in that spot.

                      Note that by default, `a/**/b` will not match `a/.d/b`, unless `dot` is set.
                      """
                    ],
                    noext: [
                      type: :boolean,
                      default: false,
                      doc: ~s[Disable "extglob" style patterns like `+(a|b)`.]
                    ],
                    nocase: [
                      type: :boolean,
                      default: false,
                      doc: "Perform a case-insensitive match."
                    ],
                    match_base: [
                      type: :boolean,
                      default: false,
                      doc: """
                      If set, patterns without slashes will be matched against the basename of
                      the path if it contains slashes. For example, `a?b` would match the path
                      `/xyz/123/acb`, but not `/xyz/acb/123`.
                      """
                    ],
                    nocomment: [
                      type: :boolean,
                      default: false,
                      doc: "Do not treat leading `#` as a comment."
                    ],
                    nonegate: [
                      type: :boolean,
                      default: false,
                      doc: "Do not treat leading `!` as negation."
                    ]
                  )

  ## types

  @type t :: %__MODULE__{
          nobrace: boolean,
          noglobstar: boolean,
          dot: boolean,
          noext: boolean,
          nocase: boolean,
          match_base: boolean,
          nocomment: boolean,
          nonegate: boolean
        }

  ## struct

  @enforce_keys [:nobrace, :noglobstar, :dot, :noext, :nocase, :match_base, :nocomment, :nonegate]
  defstruct [:nobrace, :noglobstar, :dot, :noext, :nocase, :match_base, :nocomment, :nonegate]

  ## api

  def new!(opts \\ []) do
    case new(opts) do
      {:ok, opts} -> opts
      {:error, reason} -> raise ValidationError, reason
    end
  end

  def new(opts \\ []) do
    opts
    |> validate_opts()
    |> result_wrap(&create_new/1)
  end

  def schema, do: @options_schema

  defp create_new({:ok, valid_opts}) do
    struct!(__MODULE__, valid_opts)
  end

  defp create_new({:error, reason}) do
    reason
  end

  defp validate_opts(opts) do
    NimbleOptions.validate(opts, @options_schema)
  end

  defp result_wrap({kind, _value} = result, fun) when is_atom(kind), do: {kind, fun.(result)}
  defp result_wrap(result, fun), do: fun.(result)
end
