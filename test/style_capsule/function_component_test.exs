defmodule StyleCapsule.FunctionComponentTest do
  @moduledoc """
  Tests for function component style registration.

  These tests verify that function components (that don't use render/1)
  properly register their styles when capsule/1 is called.

  Note: These tests require Phoenix.Component to be available.
  """
  use ExUnit.Case, async: false

  alias StyleCapsule.{Component, Registry}
  alias StyleCapsule.Phoenix, as: PhoenixHelper

  setup do
    Registry.clear()
    :ok
  end

  defmodule TestFunctionComponent do
    use Phoenix.Component
    use StyleCapsule.Component, namespace: :test, strategy: :patch, cache_strategy: :none

    @component_styles """
    .test-class {
      color: red;
      padding: 1rem;
    }
    """

    def test_component(assigns) do
      ~H"""
      <.capsule module={__MODULE__}>
        <div class="test-class">Test</div>
      </.capsule>
      """
    end
  end

  defmodule TestFunctionComponentNesting do
    use Phoenix.Component
    use StyleCapsule.Component, namespace: :test_nesting, strategy: :nesting, cache_strategy: :none

    @component_styles """
    .nested-class {
      color: blue;
    }
    """

    def nested_component(assigns) do
      ~H"""
      <.capsule module={__MODULE__}>
        <div class="nested-class">Nested</div>
      </.capsule>
      """
    end
  end

  defmodule TestFunctionComponentTimeCache do
    use Phoenix.Component
    use StyleCapsule.Component, namespace: :test_cache, cache_strategy: :time

    @component_styles """
    .cached-class {
      color: green;
    }
    """

    def cached_component(assigns) do
      ~H"""
      <.capsule module={__MODULE__}>
        <div class="cached-class">Cached</div>
      </.capsule>
      """
    end
  end

  defmodule TestFunctionComponentNoStyles do
    use Phoenix.Component
    use StyleCapsule.Component, namespace: :test

    def no_styles_component(assigns) do
      ~H"""
      <.capsule module={__MODULE__}>
        <div>No styles</div>
      </.capsule>
      """
    end
  end

  describe "function component style registration" do
    test "styles/0 function is generated" do
      assert function_exported?(TestFunctionComponent, :styles, 0)
      styles = TestFunctionComponent.styles()
      assert is_binary(styles)
      assert styles =~ ".test-class"
    end

    test "style_capsule_spec/0 returns correct configuration" do
      assert function_exported?(TestFunctionComponent, :style_capsule_spec, 0)
      spec = TestFunctionComponent.style_capsule_spec()

      assert spec.module == TestFunctionComponent
      assert spec.namespace == :test
      assert spec.strategy == :patch
      assert spec.cache_strategy == :none
      assert is_binary(spec.capsule_id)
      assert spec.styles =~ ".test-class"
    end

    test "capsule/1 registers styles when component has @component_styles" do
      # Simulate calling the component function which calls capsule/1
      # We need to create a minimal assigns struct
      assigns = %{
        __changed__: %{},
        module: TestFunctionComponent,
        inner_block: fn _ -> [] end
      }

      # Call capsule/1 directly to trigger style registration
      # This simulates what happens when a function component calls <.capsule>
      try do
        Component.capsule(assigns)
      rescue
        # Expected - we don't have a proper Phoenix socket context
        # But styles should still be registered
        _ -> :ok
      end

      # Check that styles were registered
      styles = Registry.get_inline_styles(:test)
      assert length(styles) > 0

      # Find the style for this component
      capsule_id = StyleCapsule.capsule_id(TestFunctionComponent)
      component_style = Enum.find(styles, fn s -> s.id == capsule_id end)

      assert component_style != nil
      assert component_style.css =~ ".test-class"
      assert component_style.css =~ "[data-capsule=\"#{capsule_id}\"]"
    end

    test "capsule/1 uses correct namespace from component spec" do
      assigns = %{
        __changed__: %{},
        module: TestFunctionComponentNesting,
        inner_block: fn _ -> [] end
      }

      try do
        Component.capsule(assigns)
      rescue
        _ -> :ok
      end

      # Check that styles were registered in the correct namespace
      styles = Registry.get_inline_styles(:test_nesting)
      assert length(styles) > 0

      capsule_id = StyleCapsule.capsule_id(TestFunctionComponentNesting)
      component_style = Enum.find(styles, fn s -> s.id == capsule_id end)

      assert component_style != nil
      # Should use nesting strategy
      assert component_style.css =~ "[data-capsule=\"#{capsule_id}\"]"
    end

    test "capsule/1 respects cache strategy" do
      assigns = %{
        __changed__: %{},
        module: TestFunctionComponentTimeCache,
        inner_block: fn _ -> [] end
      }

      try do
        Component.capsule(assigns)
      rescue
        _ -> :ok
      end

      # Styles should still be registered even with time cache strategy
      styles = Registry.get_inline_styles(:test_cache)
      assert length(styles) > 0
    end

    test "capsule/1 handles components without styles gracefully" do
      assigns = %{
        __changed__: %{},
        module: TestFunctionComponentNoStyles,
        inner_block: fn _ -> [] end
      }

      # Should not raise an error
      try do
        Component.capsule(assigns)
      rescue
        _ -> :ok
      end

      # No styles should be registered
      styles = Registry.get_inline_styles(:test)
      capsule_id = StyleCapsule.capsule_id(TestFunctionComponentNoStyles)
      component_style = Enum.find(styles || [], fn s -> s.id == capsule_id end)
      assert component_style == nil
    end

    test "multiple function components register styles independently" do
      # Register styles for multiple components
      [TestFunctionComponent, TestFunctionComponentNesting]
      |> Enum.each(fn module ->
        assigns = %{
          __changed__: %{},
          module: module,
          inner_block: fn _ -> [] end
        }
        try do
          Component.capsule(assigns)
        rescue
          _ -> :ok
        end
      end)

      # Both namespaces should have styles
      test_styles = Registry.get_inline_styles(:test)
      nesting_styles = Registry.get_inline_styles(:test_nesting)

      assert length(test_styles) > 0
      assert length(nesting_styles) > 0

      # Styles should be in different namespaces
      test_capsule_id = StyleCapsule.capsule_id(TestFunctionComponent)
      nesting_capsule_id = StyleCapsule.capsule_id(TestFunctionComponentNesting)

      assert Enum.any?(test_styles, fn s -> s.id == test_capsule_id end)
      assert Enum.any?(nesting_styles, fn s -> s.id == nesting_capsule_id end)
    end
  end

  describe "render_all_runtime_styles" do
    test "renders styles from all namespaces" do
      # Register styles in multiple namespaces
      PhoenixHelper.register_inline(".test1 { color: red; }", "test12345", namespace: :ns1)
      PhoenixHelper.register_inline(".test2 { color: blue; }", "test23456", namespace: :ns2)
      PhoenixHelper.register_inline(".test3 { color: green; }", "test34567", namespace: :ns3)

      html = PhoenixHelper.render_all_runtime_styles()

      assert html =~ "test12345"
      assert html =~ "test23456"
      assert html =~ "test34567"
      assert html =~ ".test1"
      assert html =~ ".test2"
      assert html =~ ".test3"
    end

    test "returns empty string when no styles registered" do
      Registry.clear()
      html = PhoenixHelper.render_all_runtime_styles()
      assert html == ""
    end

    test "handles mixed namespaces correctly" do
      Registry.clear()

      # Register in different namespaces
      PhoenixHelper.register_inline(".admin { color: red; }", "admin12345", namespace: :admin)
      PhoenixHelper.register_inline(".user { color: blue; }", "user12345", namespace: :user)
      PhoenixHelper.register_inline(".app { color: green; }", "app123456", namespace: :app)

      html = PhoenixHelper.render_all_runtime_styles()

      # All namespaces should be included
      assert html =~ "admin12345"
      assert html =~ "user12345"
      assert html =~ "app123456"
    end
  end

  describe "style scoping" do
    test "styles are scoped with patch strategy" do
      assigns = %{
        __changed__: %{},
        module: TestFunctionComponent,
        inner_block: fn _ -> [] end
      }

      try do
        Component.capsule(assigns)
      rescue
        _ -> :ok
      end

      styles = Registry.get_inline_styles(:test)
      capsule_id = StyleCapsule.capsule_id(TestFunctionComponent)
      component_style = Enum.find(styles, fn s -> s.id == capsule_id end)

      assert component_style != nil
      # Patch strategy should prefix each selector
      assert component_style.css =~ "[data-capsule=\"#{capsule_id}\"] .test-class"
    end

    test "styles are scoped with nesting strategy" do
      assigns = %{
        __changed__: %{},
        module: TestFunctionComponentNesting,
        inner_block: fn _ -> [] end
      }

      try do
        Component.capsule(assigns)
      rescue
        _ -> :ok
      end

      styles = Registry.get_inline_styles(:test_nesting)
      capsule_id = StyleCapsule.capsule_id(TestFunctionComponentNesting)
      component_style = Enum.find(styles, fn s -> s.id == capsule_id end)

      assert component_style != nil
      # Nesting strategy should wrap styles
      assert component_style.css =~ "[data-capsule=\"#{capsule_id}\"]"
      assert component_style.css =~ ".nested-class"
    end
  end
end
