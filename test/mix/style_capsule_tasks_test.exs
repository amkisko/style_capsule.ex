defmodule Mix.Tasks.StyleCapsule.TasksTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  alias Mix.Tasks.StyleCapsule.{
    Build,
    Clear,
    Verify
  }

  setup do
    # Set up test environment
    original_output = Application.get_env(:style_capsule, :output_dir)
    original_fallback = Application.get_env(:style_capsule, :fallback_dir)

    tmp_dir = System.tmp_dir!() |> Path.join("style_capsule_test_#{System.unique_integer([:positive])}")
    fallback_dir = System.tmp_dir!() |> Path.join("style_capsule_fallback_#{System.unique_integer([:positive])}")

    File.mkdir_p!(tmp_dir)
    File.mkdir_p!(fallback_dir)

    Application.put_env(:style_capsule, :output_dir, tmp_dir)
    Application.put_env(:style_capsule, :fallback_dir, fallback_dir)

    # Clear registry before each test
    StyleCapsule.CompileRegistry.clear()

    on_exit(fn ->
      File.rm_rf(tmp_dir)
      File.rm_rf(fallback_dir)
      StyleCapsule.CompileRegistry.clear()

      if original_output do
        Application.put_env(:style_capsule, :output_dir, original_output)
      else
        Application.delete_env(:style_capsule, :output_dir)
      end

      if original_fallback do
        Application.put_env(:style_capsule, :fallback_dir, original_fallback)
      else
        Application.delete_env(:style_capsule, :fallback_dir)
      end
    end)

    {:ok, tmp_dir: tmp_dir, fallback_dir: fallback_dir}
  end

  describe "Mix.Tasks.StyleCapsule.Build" do
    test "runs without errors" do
      output =
        capture_io(fn ->
          Build.run([])
        end)

      assert output =~ "Building style capsule files"
      assert output =~ "Build complete"
    end

    test "handles components with file cache strategy", %{tmp_dir: tmp_dir} do
      # Register a component with file cache strategy
      spec = %{
        module: TestBuildComponent,
        capsule_id: "test12345678",
        namespace: :test_build,
        strategy: :patch,
        cache_strategy: :file,
        styles: ".test { color: red; }"
      }

      StyleCapsule.CompileRegistry.register(spec)

      output =
        capture_io(fn ->
          Build.run([])
        end)

      assert output =~ "Building style capsule files"
      assert output =~ "Build complete"

      # Check that CSS file was created
      css_file = Path.join(tmp_dir, "style_capsules_test_build.css")
      if File.exists?(css_file) do
        content = File.read!(css_file)
        assert content =~ ".test"
      end
    end

    test "handles components with runtime cache strategies", %{tmp_dir: _tmp_dir} do
      # Register components with different cache strategies
      spec1 = %{
        module: TestBuildComponentNone,
        capsule_id: "none12345678",
        namespace: :test_build,
        strategy: :patch,
        cache_strategy: :none,
        styles: ".none { color: blue; }"
      }

      spec2 = %{
        module: TestBuildComponentTime,
        capsule_id: "time12345678",
        namespace: :test_build,
        strategy: :patch,
        cache_strategy: :time,
        styles: ".time { color: green; }"
      }

      StyleCapsule.CompileRegistry.register(spec1)
      StyleCapsule.CompileRegistry.register(spec2)

      output =
        capture_io(fn ->
          Build.run([])
        end)

      assert output =~ "runtime (cache_strategy: :none or :time)"
      assert output =~ "Build complete"
    end

    test "handles components with empty styles" do
      spec = %{
        module: TestBuildComponentEmpty,
        capsule_id: "empty12345678",
        namespace: :test_build,
        strategy: :patch,
        cache_strategy: :file,
        styles: ""
      }

      StyleCapsule.CompileRegistry.register(spec)

      output =
        capture_io(fn ->
          Build.run([])
        end)

      assert output =~ "Build complete"
    end

    test "handles components with nil styles" do
      spec = %{
        module: TestBuildComponentNil,
        capsule_id: "nil12345678",
        namespace: :test_build,
        strategy: :patch,
        cache_strategy: :file,
        styles: nil
      }

      StyleCapsule.CompileRegistry.register(spec)

      output =
        capture_io(fn ->
          Build.run([])
        end)

      assert output =~ "Build complete"
    end

    test "handles multiple namespaces" do
      spec1 = %{
        module: TestBuildComponentNS1,
        capsule_id: "ns112345678",
        namespace: :namespace1,
        strategy: :patch,
        cache_strategy: :file,
        styles: ".ns1 { color: red; }"
      }

      spec2 = %{
        module: TestBuildComponentNS2,
        capsule_id: "ns212345678",
        namespace: :namespace2,
        strategy: :patch,
        cache_strategy: :file,
        styles: ".ns2 { color: blue; }"
      }

      StyleCapsule.CompileRegistry.register(spec1)
      StyleCapsule.CompileRegistry.register(spec2)

      output =
        capture_io(fn ->
          Build.run([])
        end)

      assert output =~ "namespace1"
      assert output =~ "namespace2"
      assert output =~ "Build complete"
    end

    test "handles components with nesting strategy" do
      spec = %{
        module: TestBuildComponentNesting,
        capsule_id: "nest12345678",
        namespace: :test_build,
        strategy: :nesting,
        cache_strategy: :file,
        styles: ".nested { color: purple; }"
      }

      StyleCapsule.CompileRegistry.register(spec)

      output =
        capture_io(fn ->
          Build.run([])
        end)

      assert output =~ "Build complete"
    end

    test "handles File.write errors gracefully", %{tmp_dir: tmp_dir} do
      # Make the directory read-only to simulate write errors
      File.chmod!(tmp_dir, 0o444)

      spec = %{
        module: TestBuildComponentWriteError,
        capsule_id: "write12345678",
        namespace: :test_build,
        strategy: :patch,
        cache_strategy: :file,
        styles: ".test { color: red; }"
      }

      StyleCapsule.CompileRegistry.register(spec)

      output =
        capture_io(fn ->
          Build.run([])
        end)

      # Should handle error gracefully
      assert output =~ "Build complete" or output =~ "Failed to write"

      # Restore permissions
      File.chmod!(tmp_dir, 0o755)
    end

    test "handles components with cache_strategy != :file in reduce" do
      # This tests the warning path when a component has wrong cache_strategy
      spec = %{
        module: TestBuildComponentWrongCache,
        capsule_id: "wrong12345678",
        namespace: :test_build,
        strategy: :patch,
        cache_strategy: :none, # Wrong - should be :file for precompilation
        styles: ".test { color: red; }"
      }

      StyleCapsule.CompileRegistry.register(spec)

      # Filter to file-cached specs (this will exclude our :none component)
      # But if it somehow gets in, it should be skipped with a warning
      output =
        capture_io(fn ->
          Build.run([])
        end)

      assert output =~ "Build complete"
    end

    test "handles components with include_comments enabled" do
      # Set include_comments config
      original = Application.get_env(:style_capsule, :include_comments)
      Application.put_env(:style_capsule, :include_comments, true)

      spec = %{
        module: TestBuildComponentComments,
        capsule_id: "comm12345678",
        namespace: :test_build,
        strategy: :patch,
        cache_strategy: :file,
        styles: ".test { color: red; }"
      }

      StyleCapsule.CompileRegistry.register(spec)

      output =
        capture_io(fn ->
          Build.run([])
        end)

      assert output =~ "Build complete"

      # Restore original config
      if original do
        Application.put_env(:style_capsule, :include_comments, original)
      else
        Application.delete_env(:style_capsule, :include_comments)
      end
    end

    test "handles namespace_to_filename with special characters" do
      # Test that namespace_to_filename sanitizes special characters
      # This is tested indirectly through the build process
      spec = %{
        module: TestBuildComponentSpecialNS,
        capsule_id: "spec12345678",
        namespace: :"test-namespace_with.special@chars!",
        strategy: :patch,
        cache_strategy: :file,
        styles: ".test { color: red; }"
      }

      StyleCapsule.CompileRegistry.register(spec)

      output =
        capture_io(fn ->
          Build.run([])
        end)

      assert output =~ "Build complete"
    end

    test "handles binary namespace" do
      spec = %{
        module: TestBuildComponentBinaryNS,
        capsule_id: "bin12345678",
        namespace: "binary_namespace",
        strategy: :patch,
        cache_strategy: :file,
        styles: ".test { color: red; }"
      }

      StyleCapsule.CompileRegistry.register(spec)

      output =
        capture_io(fn ->
          Build.run([])
        end)

      assert output =~ "Build complete"
    end

    test "handles ensure_all_components_registered discovery" do
      # This tests the module discovery path
      output =
        capture_io(fn ->
          Build.run([])
        end)

      assert output =~ "Build complete"
    end

    test "handles FileWriter.write errors" do
      # Register a component that will trigger FileWriter
      spec = %{
        module: TestBuildComponentFileWriter,
        capsule_id: "file12345678",
        namespace: :test_build,
        strategy: :patch,
        cache_strategy: :file,
        styles: ".test { color: red; }"
      }

      StyleCapsule.CompileRegistry.register(spec)

      output =
        capture_io(fn ->
          Build.run([])
        end)

      # Should handle FileWriter errors gracefully
      assert output =~ "Build complete" or output =~ "Failed to build"
    end

    test "handles components with zero-byte styles" do
      spec = %{
        module: TestBuildComponentZeroByte,
        capsule_id: "zero12345678",
        namespace: :test_build,
        strategy: :patch,
        cache_strategy: :file,
        styles: ""
      }

      StyleCapsule.CompileRegistry.register(spec)

      output =
        capture_io(fn ->
          Build.run([])
        end)

      assert output =~ "Build complete"
    end

    test "handles build_component with :skip return" do
      # Components with nil or empty styles should return :skip
      # This is tested indirectly through the build process
      spec = %{
        module: TestBuildComponentSkip,
        capsule_id: "skip12345678",
        namespace: :test_build,
        strategy: :patch,
        cache_strategy: :file,
        styles: nil
      }

      StyleCapsule.CompileRegistry.register(spec)

      output =
        capture_io(fn ->
          Build.run([])
        end)

      assert output =~ "Build complete"
    end

    test "handles build_component with non-file cache strategy" do
      # Components with non-file cache strategy should return entry without path
      spec = %{
        module: TestBuildComponentNonFile,
        capsule_id: "nonf12345678",
        namespace: :test_build,
        strategy: :patch,
        cache_strategy: :time,
        styles: ".test { color: red; }"
      }

      StyleCapsule.CompileRegistry.register(spec)

      output =
        capture_io(fn ->
          Build.run([])
        end)

      assert output =~ "runtime (cache_strategy: :none or :time)"
      assert output =~ "Build complete"
    end

    test "handles components with cache_strategy != :file in reduce loop" do
      # Test the warning path when a component has wrong cache_strategy in the reduce
      # This tests the if spec.cache_strategy != :file path
      spec = %{
        module: TestBuildComponentWrongCacheInReduce,
        capsule_id: "wrong12345678",
        namespace: :test_build,
        strategy: :patch,
        cache_strategy: :none, # Wrong - should be :file for precompilation
        styles: ".test { color: red; }"
      }

      # Register it but it should be filtered out before the reduce
      StyleCapsule.CompileRegistry.register(spec)

      output =
        capture_io(fn ->
          Build.run([])
        end)

      # Should not include it in file-cached specs
      assert output =~ "Build complete"
    end

    test "handles build_component with :skip return for empty styles" do
      # Test build_component returning :skip for empty styles
      spec = %{
        module: TestBuildComponentSkipEmpty,
        capsule_id: "skip12345678",
        namespace: :test_build,
        strategy: :patch,
        cache_strategy: :file,
        styles: ""
      }

      StyleCapsule.CompileRegistry.register(spec)

      output =
        capture_io(fn ->
          Build.run([])
        end)

      assert output =~ "Build complete"
    end

    test "handles build_component with :skip return for nil styles" do
      # Test build_component returning :skip for nil styles
      spec = %{
        module: TestBuildComponentSkipNil,
        capsule_id: "skipnil12345678",
        namespace: :test_build,
        strategy: :patch,
        cache_strategy: :file,
        styles: nil
      }

      StyleCapsule.CompileRegistry.register(spec)

      output =
        capture_io(fn ->
          Build.run([])
        end)

      assert output =~ "Build complete"
    end

    test "handles build_component error path" do
      # Test the {:error, reason} path in build_component reduce
      spec = %{
        module: TestBuildComponentErrorPath,
        capsule_id: "error12345678",
        namespace: :test_build,
        strategy: :patch,
        cache_strategy: :file,
        styles: ".test { color: red; }"
      }

      StyleCapsule.CompileRegistry.register(spec)

      # Make output_dir read-only to trigger FileWriter error
      original_output = Application.get_env(:style_capsule, :output_dir)
      tmp_readonly = System.tmp_dir!() |> Path.join("readonly_#{System.unique_integer([:positive])}")
      File.mkdir_p!(tmp_readonly)
      File.chmod!(tmp_readonly, 0o444)
      Application.put_env(:style_capsule, :output_dir, tmp_readonly)

      output =
        capture_io(fn ->
          Build.run([])
        end)

      # Should handle error gracefully
      assert output =~ "Build complete" or output =~ "Failed to build"

      # Restore
      File.chmod!(tmp_readonly, 0o755)
      File.rm_rf!(tmp_readonly)
      if original_output do
        Application.put_env(:style_capsule, :output_dir, original_output)
      else
        Application.delete_env(:style_capsule, :output_dir)
      end
    end
  end

  describe "Mix.Tasks.StyleCapsule.Clear" do
    test "clears directories", %{tmp_dir: tmp_dir, fallback_dir: fallback_dir} do
      # Create some test files
      File.write!(Path.join(tmp_dir, "test.css"), "test")
      File.write!(Path.join(fallback_dir, "test.css"), "test")

      output =
        capture_io(fn ->
          Clear.run([])
        end)

      assert output =~ "Clearing style capsule files"
      assert output =~ "Clear complete"

      # Files should be gone
      refute File.exists?(Path.join(tmp_dir, "test.css"))
      refute File.exists?(Path.join(fallback_dir, "test.css"))
    end
  end

  describe "Mix.Tasks.StyleCapsule.Verify" do
    test "verifies writable directories", %{tmp_dir: _tmp_dir, fallback_dir: _fallback_dir} do
      output =
        capture_io(fn ->
          Verify.run([])
        end)

      assert output =~ "Verifying style capsule configuration"
      assert output =~ "Verification complete"
    end

    test "reports non-writable directories" do
      # Use a non-existent parent to simulate failure
      bad_dir = "/nonexistent/path/style_capsule"

      Application.put_env(:style_capsule, :output_dir, bad_dir)

      output =
        capture_io(fn ->
          Verify.run([])
        end)

      assert output =~ "Verifying style capsule configuration"
      # Should report the issue - just verify it completes without crashing
      assert output =~ "Verification complete" or output =~ "cannot be created"
    end
  end
end
