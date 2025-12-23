defmodule StyleCapsule.IdTest do
  use ExUnit.Case, async: true
  doctest StyleCapsule.Id

  alias StyleCapsule.Id

  describe "generate/2" do
    test "generates deterministic IDs for modules" do
      id1 = Id.generate(MyAppWeb.Components.Card)
      id2 = Id.generate(MyAppWeb.Components.Card)

      assert id1 == id2
      assert String.length(id1) == 12
    end

    test "generates different IDs for different modules" do
      id1 = Id.generate(MyAppWeb.Components.Card)
      id2 = Id.generate(MyAppWeb.Components.Button)

      assert id1 != id2
    end

    test "respects length option" do
      id = Id.generate(MyAppWeb.Components.Card, length: 8)
      assert String.length(id) == 8
    end

    test "respects prefix option" do
      id = Id.generate(MyAppWeb.Components.Card, prefix: "card-")
      assert String.starts_with?(id, "card-")
    end

    test "generates URL-safe IDs" do
      id = Id.generate(MyAppWeb.Components.Card)
      assert Regex.match?(~r/^[a-zA-Z0-9_-]+$/, id)
    end
  end

  describe "validate!/1" do
    test "accepts valid IDs" do
      assert Id.validate!("abc123def456") == :ok
      assert Id.validate!("ABC123-DEF_456") == :ok
    end

    test "rejects IDs that are too short" do
      assert_raise ArgumentError, ~r/must be at least/, fn ->
        Id.validate!("abc")
      end
    end

    test "rejects IDs that are too long" do
      long_id = String.duplicate("a", 33)

      assert_raise ArgumentError, ~r/must be at most/, fn ->
        Id.validate!(long_id)
      end
    end

    test "rejects IDs with invalid characters" do
      assert_raise ArgumentError, ~r/must match pattern/, fn ->
        Id.validate!("abc 123!")
      end
    end

    test "rejects non-binary IDs" do
      assert_raise ArgumentError, ~r/must be a binary/, fn ->
        Id.validate!(123)
      end
    end
  end

  describe "validate/1" do
    test "returns :ok for valid IDs" do
      assert Id.validate("abc123def456") == :ok
    end

    test "returns error tuple for invalid IDs" do
      assert {:error, _} = Id.validate("abc")
      assert {:error, _} = Id.validate("abc 123!")
      assert {:error, _} = Id.validate(123)
    end
  end
end
