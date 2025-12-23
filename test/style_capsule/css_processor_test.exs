defmodule StyleCapsule.CssProcessorTest do
  use ExUnit.Case, async: true
  doctest StyleCapsule.CssProcessor

  alias StyleCapsule.CssProcessor

  describe "scope/3 with :patch strategy" do
    test "scopes simple class selector" do
      css = ".section { color: red; }"
      result = CssProcessor.scope(css, "abc12345")

      assert result =~ ~r/\[data-capsule="abc12345"\]/
      assert result =~ ".section"
    end

    test "scopes multiple selectors" do
      css = ".a, .b { color: red; }"
      result = CssProcessor.scope(css, "abc12345")

      assert result =~ ~r/\[data-capsule="abc12345"\]/
      assert result =~ ".a"
      assert result =~ ".b"
    end

    test "preserves CSS structure" do
      css = """
      .section { 
        color: red; 
        padding: 1rem;
      }
      """

      result = CssProcessor.scope(css, "abc12345")

      assert result =~ ~r/\[data-capsule="abc12345"\]/
      assert result =~ "color: red"
      assert result =~ "padding: 1rem"
    end
  end

  describe "scope/3 with :nesting strategy" do
    test "wraps CSS in nesting block" do
      css = ".section { color: red; }"
      result = CssProcessor.scope(css, "abc12345", strategy: :nesting)

      assert result =~ ~r/\[data-capsule="abc12345"\]/
      assert result =~ "{"
      assert result =~ ".section"
    end
  end

  describe "scope/3 error handling" do
    test "raises on invalid capsule ID" do
      css = ".section { color: red; }"

      assert_raise ArgumentError, fn ->
        CssProcessor.scope(css, "invalid id!")
      end
    end

    test "raises on unknown strategy" do
      css = ".section { color: red; }"

      assert_raise ArgumentError, ~r/Unknown strategy/, fn ->
        CssProcessor.scope(css, "abc12345", strategy: :unknown)
      end
    end
  end

  describe "scope/3 with :host selector" do
    test "translates :host to root selector" do
      css = ":host { display: block; }"
      result = CssProcessor.scope(css, "abc12345")

      assert result =~ ~r/\[data-capsule="abc12345"\]/
      assert result =~ "display: block"
      # :host should be replaced, not prefixed
      refute result =~ ":host"
    end

    test "translates :host with descendant selectors" do
      css = """
      :host {
        display: block;
      }
      .content {
        color: red;
      }
      """

      result = CssProcessor.scope(css, "abc12345")

      assert result =~ ~r/\[data-capsule="abc12345"\]/
      assert result =~ "display: block"
      assert result =~ ".content"
      refute result =~ ":host"
    end
  end
end
