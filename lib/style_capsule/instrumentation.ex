defmodule StyleCapsule.Instrumentation do
  @moduledoc """
  Telemetry instrumentation for StyleCapsule operations.

  Emits events for CSS processing, file writing, cache operations,
  and component discovery lifecycle.
  """

  @telemetry_prefix [:style_capsule]
  @inline_logged_table :style_capsule_inline_logged

  # Initialize ETS table for tracking logged inline components
  def init_inline_tracking do
    case :ets.whereis(@inline_logged_table) do
      :undefined ->
        :ets.new(@inline_logged_table, [:set, :public, :named_table])

      _table ->
        :ok
    end
  end

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

  @doc """
  Emits a component discovered event (compile-time or runtime).

  ## Examples

      iex> StyleCapsule.Instrumentation.component_discovered(
      ...>   module: MyApp.Components.Card,
      ...>   capsule_id: "abc123",
      ...>   namespace: :default,
      ...>   discovery_type: :compile_time
      ...> )
      :ok

  """
  @spec component_discovered(keyword()) :: :ok
  def component_discovered(opts) do
    measurements = %{
      module: Keyword.fetch!(opts, :module),
      capsule_id: Keyword.fetch!(opts, :capsule_id),
      namespace: Keyword.get(opts, :namespace, :default),
      strategy: Keyword.get(opts, :strategy, :patch),
      cache_strategy: Keyword.get(opts, :cache_strategy, :none),
      has_styles: Keyword.get(opts, :has_styles, false),
      discovery_type: Keyword.get(opts, :discovery_type, :runtime)
    }

    metadata = %{
      timestamp: System.system_time(:second),
      source: Keyword.get(opts, :source, :unknown)
    }

    safe_execute(
      @telemetry_prefix ++ [:component, :discovered],
      measurements,
      metadata
    )
  end

  @doc """
  Emits a component registered event.

  ## Examples

      iex> StyleCapsule.Instrumentation.component_registered(
      ...>   module: MyApp.Components.Card,
      ...>   capsule_id: "abc123",
      ...>   registry: :runtime,
      ...>   registration_time_ms: 5
      ...> )
      :ok

  """
  @spec component_registered(keyword()) :: :ok
  def component_registered(opts) do
    measurements = %{
      module: Keyword.fetch!(opts, :module),
      capsule_id: Keyword.fetch!(opts, :capsule_id),
      namespace: Keyword.get(opts, :namespace, :default),
      registry: Keyword.get(opts, :registry, :runtime),
      registration_time_ms: Keyword.get(opts, :registration_time_ms, 0)
    }

    metadata = %{
      timestamp: System.system_time(:second),
      source: Keyword.get(opts, :source, :unknown)
    }

    safe_execute(
      @telemetry_prefix ++ [:component, :registered],
      measurements,
      metadata
    )
  end

  @doc """
  Emits a component rendered event.

  ## Examples

      iex> StyleCapsule.Instrumentation.component_rendered(
      ...>   module: MyApp.Components.Card,
      ...>   capsule_id: "abc123",
      ...>   namespace: :default,
      ...>   render_time_ms: 2
      ...> )
      :ok

  """
  @spec component_rendered(keyword()) :: :ok
  def component_rendered(opts) do
    measurements = %{
      module: Keyword.fetch!(opts, :module),
      capsule_id: Keyword.fetch!(opts, :capsule_id),
      namespace: Keyword.get(opts, :namespace, :default),
      render_time_ms: Keyword.get(opts, :render_time_ms, 0)
    }

    metadata = %{
      timestamp: System.system_time(:second),
      request_id: Keyword.get(opts, :request_id)
    }

    safe_execute(
      @telemetry_prefix ++ [:component, :rendered],
      measurements,
      metadata
    )
  end

  @doc """
  Emits a discovery operation event.

  ## Examples

      iex> StyleCapsule.Instrumentation.discovery_operation(
      ...>   operation: :discover_components,
      ...>   modules_checked: 10,
      ...>   components_found: 5,
      ...>   duration_ms: 15,
      ...>   success: true
      ...> )
      :ok

  """
  @spec discovery_operation(keyword()) :: :ok
  def discovery_operation(opts) do
    measurements = %{
      operation: Keyword.fetch!(opts, :operation),
      modules_checked: Keyword.get(opts, :modules_checked, 0),
      components_found: Keyword.get(opts, :components_found, 0),
      duration_ms: Keyword.get(opts, :duration_ms, 0),
      success: Keyword.get(opts, :success, true)
    }

    metadata = %{
      timestamp: System.system_time(:second)
    }

    safe_execute(
      @telemetry_prefix ++ [:discovery, :operation],
      measurements,
      metadata
    )
  end

  # Safely execute telemetry events, handling cases where telemetry
  # might not be available (e.g., during compilation)
  defp safe_execute(event, measurements, metadata) do
    # Check if telemetry application is started before executing
    # This prevents warnings during compilation when telemetry isn't available
    if telemetry_available?() do
      try do
        :telemetry.execute(event, measurements, metadata)
      rescue
        # Handle any exceptions that might occur
        _ -> :ok
      end
    else
      :ok
    end
  end

  # Track inline component registration globally to avoid duplicate logs
  @doc false
  def track_inline_logged(module, capsule_id) do
    # Initialize table if needed
    init_inline_tracking()

    key = {module, capsule_id}

    case :ets.insert_new(@inline_logged_table, {key, true}) do
      # First time logging
      true -> true
      # Already logged
      false -> false
    end
  rescue
    # If ETS fails, allow logging
    _ -> true
  end

  # Check if telemetry application is available
  # During compilation, Application.started_applications/0 may not work correctly,
  # so we also check if the telemetry module is loaded and can be called
  defp telemetry_available? do
    # First check if telemetry module is loaded
    if Code.ensure_loaded?(:telemetry) do
      # Then check if application is started (if we're in runtime)
      try do
        apps = Application.started_applications()
        Keyword.has_key?(apps, :telemetry)
      rescue
        # During compilation, started_applications might fail
        # If telemetry module is loaded, it might still work
        _ -> true
      catch
        _ -> false
      end
    else
      false
    end
  end
end
