defmodule MyStruct do
  @moduledoc false

  defstruct [:attrs]

  defimpl Nix.DeepMerge.Resolver do
    def resolve(original, %@for{} = override, resolver) do
      Map.merge(original, override, resolver)
    end

    def resolve(_original, override, _resolver) do
      override
    end
  end
end

defmodule OtherStruct do
  @moduledoc false

  defstruct [:attrs]
end

defmodule DerivedStruct do
  @moduledoc false

  @derive [Nix.DeepMerge.Resolver]
  defstruct [:attrs]
end

defmodule OtherDerivedStruct do
  @moduledoc false

  @derive [Nix.DeepMerge.Resolver]
  defstruct [:attrs]
end
