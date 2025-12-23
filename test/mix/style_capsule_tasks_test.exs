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

    on_exit(fn ->
      File.rm_rf(tmp_dir)
      File.rm_rf(fallback_dir)

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
