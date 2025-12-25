defmodule StyleCapsule.CompileRegistry do
  @moduledoc """
  Compile-time registry for StyleCapsule components.

  Components register themselves at compile time via `__before_compile__` hooks,
  storing their specs in a persistent location that the build task can read.

  This approach is more reliable than runtime discovery because:
  - Components explicitly register themselves
  - No need to discover modules from file system or application spec
  - Works regardless of compilation state or code paths

  ## Namespace Support

  Each component spec includes a namespace, which is used by the build task
  to generate separate CSS files per namespace, preventing style leakage.
  """

  @registry_file "style_capsule_registry.exs"

  @doc """
  Registers a component spec at compile time.

  Called automatically by components via `__before_compile__` hooks.
  """
  def register(spec) when is_map(spec) do
    # Validate spec has required fields
    required_fields = [:module, :capsule_id, :namespace, :strategy, :cache_strategy]
    missing_fields = Enum.filter(required_fields, &(!Map.has_key?(spec, &1)))

    if missing_fields != [] do
      raise StyleCapsule.RegistryError,
        message: "Invalid spec: missing required fields #{inspect(missing_fields)}",
        operation: :register
    end

    # Write to a file that the build task can read
    # This file is created during compilation and read during build
    registry_path = registry_path()

    File.mkdir_p!(Path.dirname(registry_path))

    # Read existing registry or start fresh
    existing_data = read_registry_data()
    existing_specs = extract_specs(existing_data)
    existing_build = extract_build_metadata(existing_data)

    # Add new spec (deduplicate by module)
    new_specs = [spec | Enum.reject(existing_specs, &(&1.module == spec.module))]

    # Write back to file, preserving build metadata if it exists
    registry_data =
      if existing_build do
        %{components: new_specs, build: existing_build}
      else
        new_specs
      end

    content = """
    # Auto-generated StyleCapsule component registry
    # Do not edit manually - this file is generated during compilation and build
    #{inspect(registry_data, pretty: true, limit: :infinity, printable_limit: :infinity)}
    """

    File.write!(registry_path, content)

    # Emit telemetry event
    StyleCapsule.Instrumentation.component_discovered(
      module: spec.module,
      capsule_id: spec.capsule_id,
      namespace: spec.namespace,
      strategy: spec.strategy,
      cache_strategy: spec.cache_strategy,
      has_styles: spec.styles != nil && spec.styles != "" && String.trim(spec.styles || "") != "",
      discovery_type: :compile_time,
      source: :compile_registry
    )

    :ok
  rescue
    e ->
      reraise StyleCapsule.RegistryError,
              [message: "Failed to create registry directory: #{Exception.message(e)}", operation: :register],
              __STACKTRACE__
  end

  @doc """
  Reads all registered component specs from the compile-time registry.

  Used by the build task to discover all components.
  """
  def get_all do
    read_registry()
  end

  @doc """
  Updates the registry with build metadata.

  Called by the build task after generating CSS files to add build information.
  """
  def update_build_metadata(metadata) when is_map(metadata) do
    registry_path = registry_path()

    # Read existing specs (preserve them)
    existing_data = read_registry_data()
    specs = extract_specs(existing_data)

    # Create enhanced registry with build metadata
    enhanced_registry = %{
      components: specs,
      build: metadata
    }

    # Write back with build metadata
    content = """
    # Auto-generated StyleCapsule component registry
    # Do not edit manually - this file is generated during compilation and build
    #{inspect(enhanced_registry, pretty: true, limit: :infinity, printable_limit: :infinity)}
    """

    File.mkdir_p!(Path.dirname(registry_path))
    File.write!(registry_path, content)
    :ok
  end

  @doc """
  Gets build metadata from the registry.

  Returns nil if no build metadata exists.
  """
  def get_build_metadata do
    data = read_registry_data()
    extract_build_metadata(data)
  end

  @doc """
  Clears the compile-time registry.

  Useful for testing or clean builds.
  """
  def clear do
    registry_path = registry_path()

    if File.exists?(registry_path) do
      File.rm!(registry_path)
    end

    :ok
  end

  defp read_registry do
    data = read_registry_data()
    extract_specs(data)
  end

  defp read_registry_data do
    registry_path = registry_path()

    if File.exists?(registry_path) do
      try do
        # Use absolute path for Code.eval_file
        abs_path = Path.expand(registry_path)
        {data, _} = Code.eval_file(abs_path)
        data
      rescue
        _e ->
          # Fallback: try reading as string and evaluating
          try do
            content = File.read!(registry_path)
            {data, _} = Code.eval_string(content)
            data
          rescue
            _ ->
              # If both methods fail, return empty list
              []
          end
      end
    else
      # Try alternative paths if the primary path doesn't exist
      # This helps when the app is running from a different directory
      alternative_paths = [
        # Try from current working directory
        Path.join([File.cwd!(), "priv", @registry_file]),
        # Try from common Phoenix app locations
        Path.join([System.user_home!(), ".mix", "projects", "phoenix_demo", "priv", @registry_file])
      ]

      Enum.reduce_while(alternative_paths, [], fn alt_path, _acc ->
        if File.exists?(alt_path) do
          try do
            abs_path = Path.expand(alt_path)
            {data, _} = Code.eval_file(abs_path)
            {:halt, data}
          rescue
            _ -> {:cont, []}
          end
        else
          {:cont, []}
        end
      end)
    end
  end

  defp extract_specs(data) do
    case data do
      list when is_list(list) -> list
      %{components: specs} when is_list(specs) -> specs
      _ -> []
    end
  end

  defp extract_build_metadata(data) do
    case data do
      %{build: metadata} when is_map(metadata) -> metadata
      _ -> nil
    end
  end

  defp registry_path do
    # Store in project root's priv directory (not in _build)
    # Try multiple strategies to find the registry file at runtime

    # Strategy 1: Try to find from any loaded application
    # Check all loaded applications for a registry file
    apps_with_registry =
      try do
        Application.loaded_applications()
        |> Enum.map(fn {app, _description, _version} ->
          try do
            app_dir = Application.app_dir(app)
            # Navigate from _build/dev/lib/app_name/ebin to project root
            # Path structure: _build/dev/lib/app_name/ebin
            project_root =
              app_dir
              # Remove ebin -> _build/dev/lib/app_name
              |> Path.dirname()
              # Remove lib/app_name -> _build/dev/lib
              |> Path.dirname()
              # Remove lib -> _build/dev
              |> Path.dirname()
              # Remove _build/dev -> _build
              |> Path.dirname()
              # Remove _build -> project root
              |> Path.dirname()

            registry_path = Path.join([project_root, "priv", @registry_file])

            if File.exists?(registry_path) do
              registry_path
            else
              nil
            end
          rescue
            _ -> nil
          end
        end)
        |> Enum.filter(&(&1 != nil))
      rescue
        _ -> []
      end

    if apps_with_registry != [] do
      # Use the first found registry file
      hd(apps_with_registry)
    else
      # Strategy 2: Try Mix.Project (compilation time only)
      app =
        try do
          if Code.ensure_loaded?(Mix.Project) do
            Mix.Project.config()[:app]
          else
            nil
          end
        rescue
          _ -> nil
        end

      if app do
        try do
          app_dir = Application.app_dir(app)

          project_root =
            app_dir
            # Remove ebin
            |> Path.dirname()
            # Remove lib/app_name
            |> Path.dirname()
            # Remove lib
            |> Path.dirname()
            # Remove _build/dev (or _build/prod)
            |> Path.dirname()
            # Remove _build
            |> Path.dirname()

          project_priv = Path.join([project_root, "priv"])
          Path.join([project_priv, @registry_file])
        rescue
          _ -> fallback_registry_path()
        end
      else
        fallback_registry_path()
      end
    end
  end

  defp fallback_registry_path do
    # Strategy 3: Fall back to File.cwd!() (works during compilation)
    Path.join([File.cwd!(), "priv", @registry_file])
  rescue
    _ -> Path.join([System.tmp_dir!(), @registry_file])
  end
end
