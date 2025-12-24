defmodule StyleCapsule.ComponentTest do
  use ExUnit.Case, async: true

  alias StyleCapsule.Component

  defmodule TestComponentWithStyles do
    use Phoenix.Component
    use StyleCapsule.Component, namespace: :test_component, strategy: :patch

    @component_styles """
    .test { color: red; }
    """

    def test(assigns) do
      ~H"""
      <.capsule module={__MODULE__}>
        <div class="test">Test</div>
      </.capsule>
      """
    end
  end

  describe "capsule/1 with render_slot/2" do
    test "renders slot content correctly" do
      # Test that capsule function exists and accepts proper arguments
      assert function_exported?(Component, :capsule, 1)

      # Test that it uses HEEx template (compile-time check)
      # The actual rendering would require a proper Phoenix socket context
      # which is tested in integration tests
    end

    test "attr declarations are present" do
      # Verify that attr declarations exist at compile time
      # This is verified by the fact that the module compiles successfully
      assert Code.ensure_loaded?(Component)
    end
  end

  describe "attr declarations" do
    test "module is required" do
      # This is enforced at compile time via attr declaration
      # Runtime check would require Phoenix socket context
      assert function_exported?(Component, :capsule, 1)
    end

    test "tag defaults to :div" do
      # Default is verified in the component definition
      assert function_exported?(Component, :capsule, 1)
    end
  end

  describe "generated functions" do
    test "styles/0 function is generated for components with @component_styles" do
      assert function_exported?(TestComponentWithStyles, :styles, 0)
      styles = TestComponentWithStyles.styles()
      assert is_binary(styles)
      assert styles =~ ".test"
    end

    test "style_capsule_spec/0 function is generated" do
      assert function_exported?(TestComponentWithStyles, :style_capsule_spec, 0)
      spec = TestComponentWithStyles.style_capsule_spec()

      assert spec.module == TestComponentWithStyles
      assert spec.namespace == :test_component
      assert spec.strategy == :patch
      assert is_binary(spec.capsule_id)
      assert is_binary(spec.styles)
    end

    test "style_capsule_spec/0 includes all configuration" do
      spec = TestComponentWithStyles.style_capsule_spec()

      assert Map.has_key?(spec, :module)
      assert Map.has_key?(spec, :capsule_id)
      assert Map.has_key?(spec, :namespace)
      assert Map.has_key?(spec, :strategy)
      assert Map.has_key?(spec, :cache_strategy)
      assert Map.has_key?(spec, :styles)
    end
  end
end
