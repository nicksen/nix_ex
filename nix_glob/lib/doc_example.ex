defmodule DocExample do
  @moduledoc false

  @indent "    "
  @start "iex>"
  @cont "...>"
  @cont_ident @indent <> @cont

  @doc false
  defmacro ex(result, do: body) do
    result = Macro.to_string(result)

    example =
      body
      |> Macro.to_string()
      |> Code.format_string!()
      |> IO.iodata_to_binary()
      |> String.replace(~r/^/, @cont_ident <> " ")
      |> String.replace_leading(@cont_ident, @start)

    """
    #{@indent}#{example}
    #{@indent}#{result}
    """
  end
end
