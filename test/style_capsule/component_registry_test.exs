defmodule StyleCapsule.ComponentRegistryTest do
  use ExUnit.Case, async: false

  alias StyleCapsule.ComponentRegistry

  setup do
    # Start the registry if not already started
    case Process.whereis(ComponentRegistry) do
      nil ->
        start_supervised!(ComponentRegistry)

      _pid ->
        :ok
    end

    # Clear registry before each test
    ComponentRegistry.clear()

    on_exit(fn ->
      # Only clear if process is still alive
      if Process.whereis(ComponentRegistry) do
        ComponentRegistry.clear()
      end
    end)

    :ok
  end

  describe "ComponentRegistry" do
    test "start_link starts the agent" do
      assert Process.whereis(ComponentRegistry) != nil
    end

    test "register stores a component spec" do
      spec = %{
        module: TestComponent,
        capsule_id: "test12345678",
        namespace: :test,
        strategy: :patch,
        cache_strategy: :none,
        styles: ".test { color: red; }"
      }

      ComponentRegistry.register(spec)

      retrieved = ComponentRegistry.get(TestComponent)
      assert retrieved != nil
      assert retrieved.module == TestComponent
      assert retrieved.capsule_id == "test12345678"
      assert retrieved.namespace == :test
    end

    test "register deduplicates by module" do
      spec1 = %{
        module: TestComponent,
        capsule_id: "test12345678",
        namespace: :test,
        strategy: :patch,
        cache_strategy: :none,
        styles: ".test { color: red; }"
      }

      spec2 = %{
        module: TestComponent,
        capsule_id: "test87654321",
        namespace: :test2,
        strategy: :nesting,
        cache_strategy: :time,
        styles: ".test2 { color: blue; }"
      }

      ComponentRegistry.register(spec1)
      ComponentRegistry.register(spec2)

      # Should only have one spec for TestComponent (the latest)
      all_specs = ComponentRegistry.get_all()
      test_specs = Enum.filter(all_specs, fn s -> s.module == TestComponent end)
      assert length(test_specs) == 1

      retrieved = ComponentRegistry.get(TestComponent)
      assert retrieved.capsule_id == "test87654321"
      assert retrieved.namespace == :test2
    end

    test "get_all returns all registered specs" do
      spec1 = %{
        module: TestComponent1,
        capsule_id: "test11111111",
        namespace: :test,
        strategy: :patch,
        cache_strategy: :none,
        styles: ".test1 { color: red; }"
      }

      spec2 = %{
        module: TestComponent2,
        capsule_id: "test22222222",
        namespace: :test,
        strategy: :patch,
        cache_strategy: :none,
        styles: ".test2 { color: blue; }"
      }

      ComponentRegistry.register(spec1)
      ComponentRegistry.register(spec2)

      all_specs = ComponentRegistry.get_all()
      assert length(all_specs) == 2

      modules = Enum.map(all_specs, & &1.module)
      assert TestComponent1 in modules
      assert TestComponent2 in modules
    end

    test "get returns nil for unregistered module" do
      assert ComponentRegistry.get(NonExistentModule) == nil
    end

    test "clear removes all specs" do
      spec = %{
        module: TestComponent,
        capsule_id: "test12345678",
        namespace: :test,
        strategy: :patch,
        cache_strategy: :none,
        styles: ".test { color: red; }"
      }

      ComponentRegistry.register(spec)
      assert ComponentRegistry.get(TestComponent) != nil

      ComponentRegistry.clear()
      assert ComponentRegistry.get(TestComponent) == nil
      assert ComponentRegistry.get_all() == []
    end

    test "register handles multiple registrations correctly" do
      spec1 = %{
        module: TestComponent1,
        capsule_id: "test11111111",
        namespace: :test,
        strategy: :patch,
        cache_strategy: :none,
        styles: ".test1 { color: red; }"
      }

      spec2 = %{
        module: TestComponent2,
        capsule_id: "test22222222",
        namespace: :test,
        strategy: :patch,
        cache_strategy: :none,
        styles: ".test2 { color: blue; }"
      }

      spec3 = %{
        module: TestComponent1,
        capsule_id: "test33333333",
        namespace: :test,
        strategy: :patch,
        cache_strategy: :none,
        styles: ".test1-updated { color: green; }"
      }

      ComponentRegistry.register(spec1)
      ComponentRegistry.register(spec2)
      ComponentRegistry.register(spec3)

      all_specs = ComponentRegistry.get_all()
      assert length(all_specs) == 2

      # TestComponent1 should be updated
      retrieved = ComponentRegistry.get(TestComponent1)
      assert retrieved.capsule_id == "test33333333"
      assert retrieved.styles =~ "test1-updated"

      # TestComponent2 should still be there
      retrieved2 = ComponentRegistry.get(TestComponent2)
      assert retrieved2.capsule_id == "test22222222"
    end
  end
end
