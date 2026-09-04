defmodule StyleCapsule.FileWriter do
  @moduledoc """
  Writes scoped CSS to files for HTTP caching.

  Supports fallback directory for read-only filesystems (e.g., Docker containers).
  """

  @doc """
  Writes CSS to a file.

  ## Options

    * `:output_dir` - Output directory. Defaults to `StyleCapsule.Config.output_dir/0`.
    * `:fallback_dir` - Fallback directory for read-only filesystems. Defaults to `StyleCapsule.Config.fallback_dir/0`.
    * `:filename_pattern` - Function to generate filename. Defaults to `capsule-{id}.css`.

  ## Examples

      StyleCapsule.FileWriter.write("abc12345", ".test { color: red; }", output_dir: "priv/static/capsules")
      #=> {:ok, "priv/static/capsules/capsule-abc12345.css"}

  """
  @spec write(binary(), binary(), keyword()) :: {:ok, binary()} | {:error, term()}
  def write(capsule_id, css, opts \\ []) do
    StyleCapsule.Id.validate!(capsule_id)

    output_dir = Keyword.get(opts, :output_dir, StyleCapsule.Config.output_dir())
    fallback_dir = Keyword.get(opts, :fallback_dir, StyleCapsule.Config.fallback_dir())
    filename_pattern = Keyword.get(opts, :filename_pattern, &default_filename_pattern/2)

    filename = filename_pattern.(capsule_id, css)
    path = contained_path!(output_dir, filename)

    start_time = System.monotonic_time(:microsecond)

    case write_file(path, css) do
      :ok ->
        end_time = System.monotonic_time(:microsecond)
        duration_ms = div(end_time - start_time, 1000)
        bytes = byte_size(css)

        StyleCapsule.Instrumentation.file_writer_write(duration_ms, bytes, path)
        {:ok, path}

      {:error, reason} ->
        fallback_path = contained_path!(fallback_dir, filename)

        case write_file(fallback_path, css) do
          :ok ->
            end_time = System.monotonic_time(:microsecond)
            duration_ms = div(end_time - start_time, 1000)
            bytes = byte_size(css)

            StyleCapsule.Instrumentation.file_writer_fallback(
              inspect(capsule_id),
              path,
              fallback_path,
              reason
            )

            StyleCapsule.Instrumentation.file_writer_write(duration_ms, bytes, fallback_path)
            {:ok, fallback_path}

          {:error, fallback_reason} ->
            StyleCapsule.Instrumentation.file_writer_failure(
              inspect(capsule_id),
              path,
              fallback_reason
            )

            {:error, {:both_failed, reason, fallback_reason}}
        end
    end
  end

  @doc false
  defp write_file(path, content) do
    dir = Path.dirname(path)

    case File.mkdir_p(dir) do
      :ok ->
        File.write(path, content)

      error ->
        error
    end
  end

  @doc false
  defp contained_path!(dir, filename) do
    expanded_dir = Path.expand(dir)
    expanded_path = Path.expand(filename, expanded_dir)
    dir_prefix = String.trim_trailing(expanded_dir, "/") <> "/"

    if expanded_path == expanded_dir or String.starts_with?(expanded_path, dir_prefix) do
      expanded_path
    else
      raise ArgumentError, "Filename escapes output directory: #{inspect(filename)}"
    end
  end

  @doc false
  defp default_filename_pattern(capsule_id, _css) do
    "capsule-#{capsule_id}.css"
  end
end
