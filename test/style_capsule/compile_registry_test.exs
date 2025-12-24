defmodule StyleCapsule.CompileRegistryTest do
  use ExUnit.Case, async: false

  alias StyleCapsule.CompileRegistry

  setup do
    # Clear registry before each test
    # Note: clear() deletes the file, so we need to ensure it exists for tests
    CompileRegistry.clear()

    on_exit(fn ->
      # Clean up after tests
      CompileRegistry.clear()
    end)

    :ok
  end

  describe "CompileRegistry" do
    test "register stores a component spec" do
      # Get initial count (may have existing components from compilation)
      initial_count = length(CompileRegistry.get_all())

      spec = %{
        module: TestComponent,
        capsule_id: "test12345678",
        namespace: :test,
        strategy: :patch,
        cache_strategy: :none,
        styles: ".test { color: red; }"
      }

      CompileRegistry.register(spec)

      specs = CompileRegistry.get_all()
      assert length(specs) == initial_count + 1

      # Find our component
      our_spec = Enum.find(specs, fn s -> s.module == TestComponent end)
      assert our_spec != nil
      assert our_spec.capsule_id == "test12345678"
    end

    test "register deduplicates by module" do
      # Get initial count
      initial_count = length(CompileRegistry.get_all())

      spec1 = %{
        module: TestComponentDedup,
        capsule_id: "test12345678",
        namespace: :test,
        strategy: :patch,
        cache_strategy: :none,
        styles: ".test { color: red; }"
      }

      spec2 = %{
        module: TestComponentDedup,
        capsule_id: "test87654321",
        namespace: :test2,
        strategy: :nesting,
        cache_strategy: :time,
        styles: ".test2 { color: blue; }"
      }

      CompileRegistry.register(spec1)
      CompileRegistry.register(spec2)

      specs = CompileRegistry.get_all()
      # Should have added only 1 (deduplicated)
      assert length(specs) == initial_count + 1

      # Find our component
      our_spec = Enum.find(specs, fn s -> s.module == TestComponentDedup end)
      assert our_spec != nil
      assert our_spec.namespace == :test2
    end

    test "register validates required fields" do
      invalid_spec = %{
        module: TestComponent
        # Missing required fields
      }

      assert_raise StyleCapsule.RegistryError, fn ->
        CompileRegistry.register(invalid_spec)
      end
    end

    test "get_all returns all registered specs" do
      initial_count = length(CompileRegistry.get_all())

      spec1 = %{
        module: TestComponentGetAll1,
        capsule_id: "test11111111",
        namespace: :test,
        strategy: :patch,
        cache_strategy: :none,
        styles: ".test1 { color: red; }"
      }

      spec2 = %{
        module: TestComponentGetAll2,
        capsule_id: "test22222222",
        namespace: :test,
        strategy: :patch,
        cache_strategy: :none,
        styles: ".test2 { color: blue; }"
      }

      CompileRegistry.register(spec1)
      CompileRegistry.register(spec2)

      specs = CompileRegistry.get_all()
      assert length(specs) == initial_count + 2

      modules = Enum.map(specs, & &1.module)
      assert TestComponentGetAll1 in modules
      assert TestComponentGetAll2 in modules
    end

    test "clear removes all specs" do
      initial_count = length(CompileRegistry.get_all())

      spec = %{
        module: TestComponentClear,
        capsule_id: "test12345678",
        namespace: :test,
        strategy: :patch,
        cache_strategy: :none,
        styles: ".test { color: red; }"
      }

      CompileRegistry.register(spec)
      assert length(CompileRegistry.get_all()) == initial_count + 1

      CompileRegistry.clear()
      # After clear, file is deleted, so get_all should return empty or minimal
      specs_after_clear = CompileRegistry.get_all()
      # May have some components from compilation, but our test component should be gone
      refute Enum.any?(specs_after_clear, fn s -> s.module == TestComponentClear end)
    end

    test "register handles file creation errors gracefully" do
      # This tests the rescue block in register
      # We can't easily simulate file system errors, but we can test
      # that the function handles edge cases

      initial_count = length(CompileRegistry.get_all())

      spec = %{
        module: TestComponentError,
        capsule_id: "test12345678",
        namespace: :test,
        strategy: :patch,
        cache_strategy: :none,
        styles: ".test { color: red; }"
      }

      # Should not raise
      CompileRegistry.register(spec)
      assert length(CompileRegistry.get_all()) == initial_count + 1
    end

    test "get_build_metadata returns nil or map when no explicit metadata" do
      # Clear to remove any existing build metadata
      CompileRegistry.clear()

      metadata = CompileRegistry.get_build_metadata()
      # May be nil or may have metadata from build task
      assert metadata == nil or is_map(metadata)
    end

    test "get_build_metadata returns metadata when set" do
      metadata = %{
        build_time: ~U[2024-01-01 00:00:00Z],
        version: "1.0.0"
      }

      CompileRegistry.update_build_metadata(metadata)

      retrieved = CompileRegistry.get_build_metadata()
      assert retrieved == metadata
    end

    test "update_build_metadata overwrites previous metadata" do
      metadata1 = %{build_time: ~U[2024-01-01 00:00:00Z]}
      metadata2 = %{build_time: ~U[2024-01-02 00:00:00Z]}

      CompileRegistry.update_build_metadata(metadata1)
      CompileRegistry.update_build_metadata(metadata2)

      retrieved = CompileRegistry.get_build_metadata()
      assert retrieved.build_time == ~U[2024-01-02 00:00:00Z]
    end

    test "update_build_metadata preserves existing specs" do
      initial_count = length(CompileRegistry.get_all())

      spec = %{
        module: TestComponentMetadata,
        capsule_id: "test12345678",
        namespace: :test,
        strategy: :patch,
        cache_strategy: :none,
        styles: ".test { color: red; }"
      }

      CompileRegistry.register(spec)
      assert length(CompileRegistry.get_all()) == initial_count + 1

      metadata = %{build_time: ~U[2024-01-01 00:00:00Z]}
      CompileRegistry.update_build_metadata(metadata)

      # Specs should still be there
      assert length(CompileRegistry.get_all()) == initial_count + 1
      retrieved_metadata = CompileRegistry.get_build_metadata()
      assert is_map(retrieved_metadata)
      assert retrieved_metadata.build_time == ~U[2024-01-01 00:00:00Z]
    end

    test "get_all handles missing registry file" do
      # Clear to ensure no file exists
      CompileRegistry.clear()

      # Should return empty list or handle gracefully
      specs = CompileRegistry.get_all()
      assert is_list(specs)
    end

    test "register with empty styles still registers" do
      initial_count = length(CompileRegistry.get_all())

      spec = %{
        module: TestComponentEmpty,
        capsule_id: "test12345678",
        namespace: :test,
        strategy: :patch,
        cache_strategy: :none,
        styles: ""
      }

      CompileRegistry.register(spec)

      # Empty styles should still register (for discovery)
      specs = CompileRegistry.get_all()
      assert length(specs) == initial_count + 1
      our_spec = Enum.find(specs, fn s -> s.module == TestComponentEmpty end)
      assert our_spec != nil
      assert our_spec.styles == ""
    end

    test "register with nil styles still registers" do
      initial_count = length(CompileRegistry.get_all())

      spec = %{
        module: TestComponentNil,
        capsule_id: "test12345678",
        namespace: :test,
        strategy: :patch,
        cache_strategy: :none,
        styles: nil
      }

      CompileRegistry.register(spec)

      # Nil styles should still register (for discovery)
      specs = CompileRegistry.get_all()
      assert length(specs) == initial_count + 1
      our_spec = Enum.find(specs, fn s -> s.module == TestComponentNil end)
      assert our_spec != nil
    end
  end
end
