defmodule Nix.Crypto.CipherNoIVTest do
  use ExUnit.Case, async: true, parameterize: Enum.map(Nix.Crypto.ciphers_no_iv(), &%{type: &1})

  import Nix.Crypto

  describe "generate empty cipher iv" do
    test "is empty", %{type: type} do
      assert generate_cipher_iv(type) == <<>>
    end
  end
end
