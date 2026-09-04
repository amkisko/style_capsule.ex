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

    test "translates :host() without double-prefixing" do
      css = ":host(.active) { color: red; }"
      result = CssProcessor.scope(css, "abc12345")

      assert result == ~s([data-capsule="abc12345"].active { color: red; })
    end

    test "translates :host-context() without double-prefixing" do
      css = ":host-context(.dark) { color: white; }"
      result = CssProcessor.scope(css, "abc12345")

      assert result == ~s([data-capsule="abc12345"] .dark { color: white; })
    end

    test "translates :host with a descendant on the same selector" do
      css = ":host .content { color: red; }"
      result = CssProcessor.scope(css, "abc12345")

      assert result == ~s([data-capsule="abc12345"] .content { color: red; })
    end
  end

  describe "scope/3 with at-rules" do
    test "scopes selectors inside @media without prefixing the query" do
      css = """
      @media (min-width: 768px) {
        .card { padding: 12px; }
      }
      """

      result = CssProcessor.scope(css, "abc12345")

      assert result =~ "@media (min-width: 768px)"
      refute result =~ ~r/\[data-capsule="abc12345"\]\s*@media/
      assert result =~ ~s([data-capsule="abc12345"] .card { padding: 12px; })
    end

    test "leaves keyframe stops unscoped" do
      css = """
      @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
      }
      """

      result = CssProcessor.scope(css, "abc12345")

      assert result =~ "@keyframes fadeIn"
      assert result =~ "from { opacity: 0; }"
      assert result =~ "to { opacity: 1; }"
      refute result =~ ~r/\[data-capsule="abc12345"\]\s*from/
      refute result =~ ~r/\[data-capsule="abc12345"\]\s*to/
    end
  end

  describe "scope/3 CSS body checks" do
    test "rejects a style-tag closer in CSS" do
      css = ".x { color: red; } </style><script>alert(1)</script>"

      assert_raise ArgumentError, ~r/must not contain/, fn ->
        CssProcessor.scope(css, "abc12345")
      end
    end

    test "rejects non-binary CSS" do
      assert_raise ArgumentError, ~r/must be a binary/, fn ->
        CssProcessor.scope(:not_css, "abc12345")
      end
    end
  end
end
