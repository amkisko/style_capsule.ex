defmodule StyleCapsuleTest do
  use ExUnit.Case, async: true
  doctest StyleCapsule

  alias StyleCapsule

  test "scope_css/3 delegates to CssProcessor" do
    css = ".section { color: red; }"
    result = StyleCapsule.scope_css(css, "abc12345")

    assert result =~ ~r/\[data-capsule="abc12345"\]/
  end

  test "wrap/3 delegates to Wrapper" do
    html = "<div>Hello</div>"
    result = StyleCapsule.wrap(html, "abc12345")

    assert result =~ ~r/data-capsule="abc12345"/
  end

  test "capsule_id/2 delegates to Id" do
    id = StyleCapsule.capsule_id(MyAppWeb.Components.Card)

    assert is_binary(id)
    assert String.length(id) >= 8
  end

  test "validate_capsule_id!/1 delegates to Id" do
    assert StyleCapsule.validate_capsule_id!("abc12345") == :ok

    assert_raise ArgumentError, fn ->
      StyleCapsule.validate_capsule_id!("invalid id!")
    end
  end

  describe "discover_components/1 telemetry" do
    test "emits discovery_operation telemetry event on success" do
      test_pid = self()

      handler = fn event, measurements, metadata, _config ->
        send(test_pid, {:telemetry, event, measurements, metadata})
      end

      :telemetry.attach_many(
        "test-discover-components-telemetry",
        [[:style_capsule, :discovery, :operation]],
        handler,
        nil
      )

      # Create a test module with style_capsule_spec/0
      defmodule TestComponentForDiscovery do
        def style_capsule_spec do
          %{
            module: __MODULE__,
            capsule_id: "test123",
            namespace: :default,
            strategy: :patch,
            cache_strategy: :none,
            styles: ".test { color: red; }"
          }
        end
      end

      result = StyleCapsule.discover_components(modules: [TestComponentForDiscovery])

      assert length(result) == 1
      assert hd(result).module == TestComponentForDiscovery

      assert_receive {:telemetry, [:style_capsule, :discovery, :operation], measurements, metadata}, 1000

      assert measurements.operation == :discover_components
      assert measurements.modules_checked == 1
      assert measurements.components_found == 1
      assert measurements.success == true
      assert measurements.duration_ms >= 0
      assert is_integer(metadata.timestamp)

      :telemetry.detach("test-discover-components-telemetry")
    end

    test "emits discovery_operation telemetry event with correct counts" do
      test_pid = self()

      handler = fn event, measurements, metadata, _config ->
        send(test_pid, {:telemetry, event, measurements, metadata})
      end

      :telemetry.attach_many(
        "test-discover-components-counts",
        [[:style_capsule, :discovery, :operation]],
        handler,
        nil
      )

      # Create test modules
      defmodule TestComponent1 do
        def style_capsule_spec do
          %{module: __MODULE__, capsule_id: "test1", namespace: :default, strategy: :patch, cache_strategy: :none}
        end
      end

      defmodule TestComponent2 do
        def style_capsule_spec do
          %{module: __MODULE__, capsule_id: "test2", namespace: :default, strategy: :patch, cache_strategy: :none}
        end
      end

      # Module without style_capsule_spec
      defmodule TestComponentNoSpec do
      end

      result =
        StyleCapsule.discover_components(
          modules: [TestComponent1, TestComponent2, TestComponentNoSpec, NonExistentModule]
        )

      assert length(result) == 2

      assert_receive {:telemetry, [:style_capsule, :discovery, :operation], measurements, _metadata}, 1000

      assert measurements.modules_checked == 4
      assert measurements.components_found == 2
      assert measurements.success == true

      :telemetry.detach("test-discover-components-counts")
    end
  end
end
