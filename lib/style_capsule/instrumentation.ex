defmodule StyleCapsule.Instrumentation do
  @moduledoc """
  Telemetry instrumentation for StyleCapsule operations.

  Emits events for CSS processing, file writing, and cache operations.
  """

  @telemetry_prefix [:style_capsule]

  @doc """
  Emits a CSS processor scope event.

  ## Examples

      iex> StyleCapsule.Instrumentation.css_processor_scope(100, 150, :patch)
      :ok

  """
  @spec css_processor_scope(non_neg_integer(), non_neg_integer(), non_neg_integer(), atom()) :: :ok
  def css_processor_scope(duration_ms, input_bytes, output_bytes, strategy) do
    :telemetry.execute(
      @telemetry_prefix ++ [:css_processor, :scope],
      %{
        duration_ms: duration_ms,
        input_bytes: input_bytes,
        output_bytes: output_bytes,
        strategy: strategy
      },
      %{}
    )
  end

  @doc """
  Emits a file writer write event.

  ## Examples

      iex> StyleCapsule.Instrumentation.file_writer_write(50, 1024, "/path/to/file.css")
      :ok

  """
  @spec file_writer_write(non_neg_integer(), non_neg_integer(), binary()) :: :ok
  def file_writer_write(duration_ms, bytes, path) do
    :telemetry.execute(
      @telemetry_prefix ++ [:file_writer, :write],
      %{
        duration_ms: duration_ms,
        bytes: bytes,
        path: path
      },
      %{}
    )
  end

  @doc """
  Emits a file writer fallback event.

  ## Examples

      iex> StyleCapsule.Instrumentation.file_writer_fallback("MyComponent", "/original", "/fallback", %RuntimeError{message: "Permission denied"})
      :ok

  """
  @spec file_writer_fallback(binary(), binary(), binary(), term()) :: :ok
  def file_writer_fallback(component, original_path, fallback_path, exception) do
    :telemetry.execute(
      @telemetry_prefix ++ [:file_writer, :fallback],
      %{
        component: component,
        original_path: original_path,
        fallback_path: fallback_path
      },
      %{
        exception: exception,
        exception_type: Kernel.is_exception(exception) && exception.__struct__
      }
    )
  end

  @doc """
  Emits a file writer failure event.

  ## Examples

      iex> StyleCapsule.Instrumentation.file_writer_failure("MyComponent", "/path", %RuntimeError{message: "Failed"})
      :ok

  """
  @spec file_writer_failure(binary(), binary(), term()) :: :ok
  def file_writer_failure(component, path, exception) do
    :telemetry.execute(
      @telemetry_prefix ++ [:file_writer, :failure],
      %{
        component: component,
        path: path
      },
      %{
        exception: exception,
        exception_type: Kernel.is_exception(exception) && exception.__struct__
      }
    )
  end
end
