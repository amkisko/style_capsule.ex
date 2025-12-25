defmodule StyleCapsule.InstrumentationTest do
  use ExUnit.Case, async: true

  alias StyleCapsule.Instrumentation

  describe "component_discovered/1" do
    test "emits component discovered event" do
      test_pid = self()

      handler = fn event, measurements, metadata, _config ->
        send(test_pid, {:telemetry, event, measurements, metadata})
      end

      :telemetry.attach_many(
        "test-component-discovered",
        [[:style_capsule, :component, :discovered]],
        handler,
        nil
      )

      Instrumentation.component_discovered(
        module: TestComponent,
        capsule_id: "test123",
        namespace: :default,
        strategy: :patch,
        cache_strategy: :none,
        has_styles: true,
        discovery_type: :compile_time,
        source: :compile_registry
      )

      assert_receive {:telemetry, [:style_capsule, :component, :discovered], measurements, metadata}

      assert measurements.module == TestComponent
      assert measurements.capsule_id == "test123"
      assert measurements.namespace == :default
      assert measurements.strategy == :patch
      assert measurements.cache_strategy == :none
      assert measurements.has_styles == true
      assert measurements.discovery_type == :compile_time
      assert metadata.source == :compile_registry
      assert is_integer(metadata.timestamp)

      :telemetry.detach("test-component-discovered")
    end

    test "uses default values when options are missing" do
      test_pid = self()

      handler = fn event, measurements, metadata, _config ->
        send(test_pid, {:telemetry, event, measurements, metadata})
      end

      :telemetry.attach_many(
        "test-component-discovered-defaults",
        [[:style_capsule, :component, :discovered]],
        handler,
        nil
      )

      Instrumentation.component_discovered(
        module: TestComponent,
        capsule_id: "test123"
      )

      assert_receive {:telemetry, [:style_capsule, :component, :discovered], measurements, metadata}

      assert measurements.namespace == :default
      assert measurements.strategy == :patch
      assert measurements.cache_strategy == :none
      assert measurements.has_styles == false
      assert measurements.discovery_type == :runtime
      assert metadata.source == :unknown

      :telemetry.detach("test-component-discovered-defaults")
    end
  end

  describe "component_registered/1" do
    test "emits component registered event" do
      test_pid = self()

      handler = fn event, measurements, metadata, _config ->
        send(test_pid, {:telemetry, event, measurements, metadata})
      end

      :telemetry.attach_many(
        "test-component-registered",
        [[:style_capsule, :component, :registered]],
        handler,
        nil
      )

      Instrumentation.component_registered(
        module: TestComponent,
        capsule_id: "test123",
        namespace: :default,
        registry: :runtime,
        registration_time_ms: 5,
        source: :component_registry
      )

      assert_receive {:telemetry, [:style_capsule, :component, :registered], measurements, metadata}

      assert measurements.module == TestComponent
      assert measurements.capsule_id == "test123"
      assert measurements.namespace == :default
      assert measurements.registry == :runtime
      assert measurements.registration_time_ms == 5
      assert metadata.source == :component_registry
      assert is_integer(metadata.timestamp)

      :telemetry.detach("test-component-registered")
    end

    test "uses default values when options are missing" do
      test_pid = self()

      handler = fn event, measurements, metadata, _config ->
        send(test_pid, {:telemetry, event, measurements, metadata})
      end

      :telemetry.attach_many(
        "test-component-registered-defaults",
        [[:style_capsule, :component, :registered]],
        handler,
        nil
      )

      Instrumentation.component_registered(
        module: TestComponent,
        capsule_id: "test123"
      )

      assert_receive {:telemetry, [:style_capsule, :component, :registered], measurements, metadata}

      assert measurements.namespace == :default
      assert measurements.registry == :runtime
      assert measurements.registration_time_ms == 0
      assert metadata.source == :unknown

      :telemetry.detach("test-component-registered-defaults")
    end
  end

  describe "component_rendered/1" do
    test "emits component rendered event" do
      test_pid = self()

      handler = fn event, measurements, metadata, _config ->
        send(test_pid, {:telemetry, event, measurements, metadata})
      end

      :telemetry.attach_many(
        "test-component-rendered",
        [[:style_capsule, :component, :rendered]],
        handler,
        nil
      )

      Instrumentation.component_rendered(
        module: TestComponent,
        capsule_id: "test123",
        namespace: :default,
        render_time_ms: 2,
        request_id: "req-123"
      )

      assert_receive {:telemetry, [:style_capsule, :component, :rendered], measurements, metadata}

      assert measurements.module == TestComponent
      assert measurements.capsule_id == "test123"
      assert measurements.namespace == :default
      assert measurements.render_time_ms == 2
      assert metadata.request_id == "req-123"
      assert is_integer(metadata.timestamp)

      :telemetry.detach("test-component-rendered")
    end

    test "uses default values when options are missing" do
      test_pid = self()

      handler = fn event, measurements, metadata, _config ->
        send(test_pid, {:telemetry, event, measurements, metadata})
      end

      :telemetry.attach_many(
        "test-component-rendered-defaults",
        [[:style_capsule, :component, :rendered]],
        handler,
        nil
      )

      Instrumentation.component_rendered(
        module: TestComponent,
        capsule_id: "test123"
      )

      assert_receive {:telemetry, [:style_capsule, :component, :rendered], measurements, metadata}

      assert measurements.namespace == :default
      assert measurements.render_time_ms == 0
      assert metadata.request_id == nil

      :telemetry.detach("test-component-rendered-defaults")
    end
  end

  describe "discovery_operation/1" do
    test "emits discovery operation event" do
      test_pid = self()

      handler = fn event, measurements, metadata, _config ->
        send(test_pid, {:telemetry, event, measurements, metadata})
      end

      :telemetry.attach_many(
        "test-discovery-operation",
        [[:style_capsule, :discovery, :operation]],
        handler,
        nil
      )

      Instrumentation.discovery_operation(
        operation: :discover_components,
        modules_checked: 10,
        components_found: 5,
        duration_ms: 15,
        success: true
      )

      assert_receive {:telemetry, [:style_capsule, :discovery, :operation], measurements, metadata}

      assert measurements.operation == :discover_components
      assert measurements.modules_checked == 10
      assert measurements.components_found == 5
      assert measurements.duration_ms == 15
      assert measurements.success == true
      assert is_integer(metadata.timestamp)

      :telemetry.detach("test-discovery-operation")
    end

    test "uses default values when options are missing" do
      test_pid = self()

      handler = fn event, measurements, metadata, _config ->
        send(test_pid, {:telemetry, event, measurements, metadata})
      end

      :telemetry.attach_many(
        "test-discovery-operation-defaults",
        [[:style_capsule, :discovery, :operation]],
        handler,
        nil
      )

      Instrumentation.discovery_operation(operation: :discover_components)

      assert_receive {:telemetry, [:style_capsule, :discovery, :operation], measurements, _metadata}

      assert measurements.modules_checked == 0
      assert measurements.components_found == 0
      assert measurements.duration_ms == 0
      assert measurements.success == true

      :telemetry.detach("test-discovery-operation-defaults")
    end

    test "handles failure case" do
      test_pid = self()

      handler = fn event, measurements, metadata, _config ->
        send(test_pid, {:telemetry, event, measurements, metadata})
      end

      :telemetry.attach_many(
        "test-discovery-operation-failure",
        [[:style_capsule, :discovery, :operation]],
        handler,
        nil
      )

      Instrumentation.discovery_operation(
        operation: :discover_components,
        modules_checked: 5,
        components_found: 0,
        duration_ms: 0,
        success: false
      )

      assert_receive {:telemetry, [:style_capsule, :discovery, :operation], measurements, _metadata}

      assert measurements.success == false
      assert measurements.components_found == 0

      :telemetry.detach("test-discovery-operation-failure")
    end
  end
end
