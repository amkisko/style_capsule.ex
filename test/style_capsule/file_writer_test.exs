defmodule StyleCapsule.FileWriterTest do
  use ExUnit.Case, async: false

  alias StyleCapsule.FileWriter

  setup do
    # Create temporary directories
    tmp_dir = System.tmp_dir!() |> Path.join("style_capsule_test_#{System.unique_integer([:positive])}")
    fallback_dir = System.tmp_dir!() |> Path.join("style_capsule_fallback_#{System.unique_integer([:positive])}")

    File.mkdir_p!(tmp_dir)
    File.mkdir_p!(fallback_dir)

    on_exit(fn ->
      File.rm_rf(tmp_dir)
      File.rm_rf(fallback_dir)
    end)

    {:ok, tmp_dir: tmp_dir, fallback_dir: fallback_dir}
  end

  describe "write/3" do
    test "writes CSS to file successfully", %{tmp_dir: tmp_dir} do
      capsule_id = "test12345"
      css = ".test { color: red; }"

      assert {:ok, path} = FileWriter.write(capsule_id, css, output_dir: tmp_dir)

      assert File.exists?(path)
      assert path =~ "capsule-#{capsule_id}.css"
      assert File.read!(path) == css
    end

    test "uses fallback directory when output dir is not writable", %{tmp_dir: tmp_dir, fallback_dir: fallback_dir} do
      # Make output dir read-only
      File.chmod!(tmp_dir, 0o555)

      capsule_id = "fallback123"
      css = ".test { color: blue; }"

      # Attach telemetry handler to capture fallback event
      test_pid = self()

      handler = fn _event, measurements, metadata, _config ->
        send(test_pid, {:fallback, Map.merge(measurements, metadata)})
      end

      :telemetry.attach_many(
        "test-fallback",
        [[:style_capsule, :file_writer, :fallback]],
        handler,
        nil
      )

      assert {:ok, path} =
               FileWriter.write(capsule_id, css,
                 output_dir: tmp_dir,
                 fallback_dir: fallback_dir
               )

      # Should use fallback
      assert path =~ fallback_dir
      assert File.exists?(path)
      assert File.read!(path) == css

      # Should have emitted fallback telemetry event
      assert_receive {:fallback, data}, 1000
      assert data[:component] =~ capsule_id || to_string(data[:component]) =~ capsule_id
      assert data[:original_path] =~ tmp_dir || to_string(data[:original_path]) =~ tmp_dir
      assert data[:fallback_path] =~ fallback_dir || to_string(data[:fallback_path]) =~ fallback_dir

      :telemetry.detach("test-fallback")
    end

    test "returns error when both directories fail", %{tmp_dir: tmp_dir, fallback_dir: fallback_dir} do
      # Make both directories read-only
      File.chmod!(tmp_dir, 0o555)
      File.chmod!(fallback_dir, 0o555)

      capsule_id = "failure123"
      css = ".test { color: red; }"

      # Attach telemetry handler for failure event
      test_pid = self()

      handler = fn _event, measurements, metadata, _config ->
        send(test_pid, {:failure, Map.merge(measurements, metadata)})
      end

      :telemetry.attach_many(
        "test-failure",
        [[:style_capsule, :file_writer, :failure]],
        handler,
        nil
      )

      assert {:error, {:both_failed, reason1, reason2}} =
               FileWriter.write(capsule_id, css,
                 output_dir: tmp_dir,
                 fallback_dir: fallback_dir
               )

      assert is_atom(reason1) or is_tuple(reason1)
      assert is_atom(reason2) or is_tuple(reason2)

      # Should have emitted failure telemetry event
      assert_receive {:failure, data}, 1000
      assert data[:component] =~ capsule_id || to_string(data[:component]) =~ capsule_id

      :telemetry.detach("test-failure")
    end

    test "emits write telemetry event on success", %{tmp_dir: tmp_dir} do
      capsule_id = "telemetry123"
      css = ".test { color: green; }"

      test_pid = self()

      handler = fn _event, measurements, metadata, _config ->
        send(test_pid, {:write, measurements, metadata})
      end

      :telemetry.attach_many(
        "test-write",
        [[:style_capsule, :file_writer, :write]],
        handler,
        nil
      )

      assert {:ok, path} = FileWriter.write(capsule_id, css, output_dir: tmp_dir)

      assert_receive {:write, measurements, _metadata}, 1000
      assert measurements[:bytes] == byte_size(css) || measurements.bytes == byte_size(css)
      assert (measurements[:duration_ms] || measurements.duration_ms) >= 0
      assert measurements[:path] == path || measurements.path == path

      :telemetry.detach("test-write")
    end

    test "respects custom filename pattern", %{tmp_dir: tmp_dir} do
      capsule_id = "custom123"
      css = ".test { color: red; }"

      filename_pattern = fn id, _css -> "custom-#{id}.css" end

      assert {:ok, path} =
               FileWriter.write(capsule_id, css,
                 output_dir: tmp_dir,
                 filename_pattern: filename_pattern
               )

      assert path =~ "custom-#{capsule_id}.css"
    end
  end
end
