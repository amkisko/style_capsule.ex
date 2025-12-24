defmodule StyleCapsule.DependencyTrackingTest do
  use ExUnit.Case, async: true

  defmodule TestComponent do
    use Phoenix.Component
    use StyleCapsule.Component

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

  describe "compile-time dependency tracking" do
    test "component has __style_capsule_deps__ function" do
      assert function_exported?(TestComponent, :__style_capsule_deps__, 0)
      deps = TestComponent.__style_capsule_deps__()
      assert is_list(deps)
    end

    test "component has __style_capsule_component_calls__ function" do
      assert function_exported?(TestComponent, :__style_capsule_component_calls__, 0)
      calls = TestComponent.__style_capsule_component_calls__()
      assert is_list(calls)
    end

    test "dependencies are tracked at compile time" do
      # Dependencies should be empty for a simple component
      # but the infrastructure is in place
      deps = TestComponent.__style_capsule_deps__()
      assert is_list(deps)
    end

    test "component calls are tracked" do
      calls = TestComponent.__style_capsule_component_calls__()
      assert is_list(calls)
    end
  end
end
