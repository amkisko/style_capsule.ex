defmodule Mix.Tasks.StyleCapsule.Build do
  @moduledoc """
  Builds CSS capsule files for file-based caching.

  This task reads component specs from the compile-time registry and generates
  namespace-separated CSS files to prevent style leakage between namespaces.

  Components register themselves during compilation via `__before_compile__` hooks,
  making discovery reliable and automatic.

  ## Namespace Isolation

  Styles are organized by namespace to prevent leakage:
  - Each namespace gets its own CSS file: `style_capsules_<namespace>.css`
  - Styles from different namespaces are never mixed in the same file
  - No consolidated CSS file is generated - only namespace-specific files
  """

  use Mix.Task

  @shortdoc "Builds CSS capsule files"

  @impl Mix.Task
  def run(_args) do
    # Ensure project is compiled so components have registered themselves
    Mix.Task.run("compile")

    app = Mix.Project.config()[:app]
    output_dir = StyleCapsule.Config.output_dir()
    fallback_dir = StyleCapsule.Config.fallback_dir()

    File.mkdir_p!(output_dir)
    File.mkdir_p!(fallback_dir)

    Mix.shell().info("Building style capsule files...")
    Mix.shell().info("Output directory: #{output_dir}")

    # Read component specs from compile-time registry
    specs = StyleCapsule.CompileRegistry.get_all()

    # Ensure all components with style_capsule_spec/0 are registered
    # This handles cases where __before_compile__ didn't run or registry was cleared
    specs = ensure_all_components_registered(specs)

    Mix.shell().info("Found #{length(specs)} component(s) with styles in registry")

    # Filter to only components with non-empty styles
    specs_with_styles =
      Enum.filter(specs, fn spec ->
        spec.styles && spec.styles != "" && byte_size(spec.styles) > 0
      end)

    Mix.shell().info("Found #{length(specs_with_styles)} component(s) with non-empty styles")

    # Separate components by cache_strategy
    # Only :file strategy should be precompiled into namespace CSS files
    # :none and :time strategies are handled at runtime
    file_cached_specs =
      Enum.filter(specs_with_styles, fn spec ->
        spec.cache_strategy == :file
      end)

    runtime_specs =
      Enum.filter(specs_with_styles, fn spec ->
        spec.cache_strategy != :file
      end)

    Mix.shell().info("Found #{length(file_cached_specs)} component(s) with :file cache_strategy (will be precompiled)")
    Mix.shell().info("Found #{length(runtime_specs)} component(s) with runtime cache_strategy (:none or :time)")

    # Group file-cached specs by namespace to ensure isolation
    specs_by_namespace = Enum.group_by(file_cached_specs, & &1.namespace)

    Mix.shell().info(
      "Found #{map_size(specs_by_namespace)} namespace(s) with file-cached components: #{Enum.map_join(specs_by_namespace, ", ", fn {ns, _} -> inspect(ns) end)}"
    )

    # Build CSS files per namespace to prevent style leakage
    # Only include components with :file cache_strategy
    namespace_files =
      Enum.map(specs_by_namespace, fn {namespace, namespace_specs} ->
        {entries, count, namespace_css} =
          Enum.reduce(namespace_specs, {[], 0, []}, fn spec, {acc, n, css_acc} ->
            # Verify this is a :file strategy component
            if spec.cache_strategy != :file do
              Mix.shell().warn(
                "Skipping component #{inspect(spec.module)} with cache_strategy #{inspect(spec.cache_strategy)} - only :file components are precompiled"
              )

              {acc, n, css_acc}
            else
              case build_component(spec, output_dir, fallback_dir) do
                {:ok, entry} ->
                  scoped_css = StyleCapsule.CssProcessor.scope(spec.styles, spec.capsule_id, strategy: spec.strategy)

                  # Add module name comment if configured to include comments
                  final_css =
                    if StyleCapsule.Config.include_comments() do
                      module_name = inspect(spec.module)
                      "/* Component: #{module_name} (cache_strategy: :file) */\n#{scoped_css}"
                    else
                      scoped_css
                    end

                  {[entry | acc], n + 1, [final_css | css_acc]}

                :skip ->
                  {acc, n, css_acc}

                {:error, reason} ->
                  Mix.shell().error("Failed to build component #{inspect(spec.module)}: #{inspect(reason)}")
                  {acc, n, css_acc}
              end
            end
          end)

        # Generate namespace-specific CSS file
        namespace_css_content = Enum.join(Enum.reverse(namespace_css), "\n\n")
        namespace_filename = namespace_to_filename(namespace)
        namespace_path = Path.join(output_dir, namespace_filename)

        case File.write(namespace_path, namespace_css_content) do
          :ok ->
            Mix.shell().info(
              "Generated CSS for namespace #{inspect(namespace)}: #{namespace_path} (#{count} component(s))"
            )

            {namespace, namespace_path, entries, count}

          {:error, reason} ->
            Mix.shell().error("Failed to write CSS for namespace #{inspect(namespace)}: #{inspect(reason)}")
            {namespace, nil, entries, count}
        end
      end)

    # Update registry with build metadata (instead of creating separate manifest)
    # Include both file-cached entries (precompiled) and runtime entries (for reference)
    file_cached_entries = Enum.flat_map(namespace_files, fn {_, _, entries, _} -> entries end)

    runtime_entries =
      Enum.map(runtime_specs, fn spec ->
        %{
          module: Atom.to_string(spec.module),
          capsule_id: spec.capsule_id,
          namespace: spec.namespace,
          strategy: spec.strategy,
          cache_strategy: spec.cache_strategy,
          # Runtime components don't have file paths
          path: nil
        }
      end)

    all_entries = file_cached_entries ++ runtime_entries
    total_file_cached = Enum.sum(Enum.map(namespace_files, fn {_, _, _, count} -> count end))
    total_runtime = length(runtime_entries)

    build_metadata = %{
      generated_at: DateTime.utc_now() |> DateTime.to_iso8601(),
      app: app,
      output_dir: output_dir,
      namespaces:
        Enum.map(namespace_files, fn {ns, path, _, count} -> %{namespace: ns, file: path, component_count: count} end),
      entries: all_entries,
      total_components: total_file_cached + total_runtime,
      file_cached_components: total_file_cached,
      runtime_components: total_runtime
    }

    StyleCapsule.CompileRegistry.update_build_metadata(build_metadata)

    Mix.shell().info("Discovered #{total_file_cached + total_runtime} StyleCapsule component(s):")

    Mix.shell().info(
      "  - #{total_file_cached} precompiled (cache_strategy: :file) across #{map_size(specs_by_namespace)} namespace(s)"
    )

    Mix.shell().info("  - #{total_runtime} runtime (cache_strategy: :none or :time)")
    Mix.shell().info("Build metadata updated in registry")
    Mix.shell().info("Build complete!")
  end

  defp namespace_to_filename(namespace) when is_atom(namespace) do
    namespace
    |> Atom.to_string()
    |> String.replace(~r/[^a-zA-Z0-9_-]/, "_")
    |> then(&"style_capsules_#{&1}.css")
  end

  defp namespace_to_filename(namespace) when is_binary(namespace) do
    namespace
    |> String.replace(~r/[^a-zA-Z0-9_-]/, "_")
    |> then(&"style_capsules_#{&1}.css")
  end

  # Ensures all components with style_capsule_spec/0 are registered
  # This handles cases where __before_compile__ didn't run during compilation
  defp ensure_all_components_registered(existing_specs) do
    registered_modules = MapSet.new(existing_specs, & &1.module)

    # Try to discover and register any missing components
    # This is a fallback for components that didn't register during compilation
    try do
      # Get all loaded modules that might be components
      all_loaded = :code.all_loaded()

      # Also try to load modules from the application's beam files
      app = Mix.Project.config()[:app]
      app_modules = discover_app_modules(app)

      # Combine both sources
      candidate_modules =
        ((all_loaded |> Enum.map(fn {m, _} -> m end)) ++ app_modules)
        |> Enum.uniq()
        |> Enum.filter(fn module ->
          is_atom(module) and
            Module.split(module) |> length() > 2 and
            not MapSet.member?(registered_modules, module)
        end)

      new_specs =
        candidate_modules
        |> Enum.map(fn module ->
          try do
            # Try to ensure the module is loaded
            case Code.ensure_loaded(module) do
              {:module, _} ->
                # Check for both PhlexComponent and Component style_capsule_spec
                if function_exported?(module, :style_capsule_spec, 0) do
                  spec = module.style_capsule_spec()

                  if spec && spec.styles && spec.styles != "" && byte_size(spec.styles) > 0 do
                    # Register the missing component
                    StyleCapsule.CompileRegistry.register(spec)
                    spec
                  else
                    nil
                  end
                else
                  nil
                end

              _ ->
                nil
            end
          rescue
            _ -> nil
          end
        end)
        |> Enum.filter(&(!is_nil(&1)))

      if not Enum.empty?(new_specs) do
        Mix.shell().info("Discovered and registered #{length(new_specs)} additional component(s) with styles")
      end

      existing_specs ++ new_specs
    rescue
      _ -> existing_specs
    end
  end

  # Discovers modules from the application's compiled beam files
  defp discover_app_modules(app) do
    app_name = app |> Atom.to_string() |> Macro.camelize()
    ebin_path = Path.join([Mix.Project.build_path(), "lib", Atom.to_string(app), "ebin"])

    if File.exists?(ebin_path) do
      ebin_path
      |> Path.join("*.beam")
      |> Path.wildcard()
      |> Enum.map(fn beam_path ->
        beam_path
        |> Path.basename(".beam")
        |> String.split(".")
        |> Enum.map(&Macro.camelize/1)
        |> Module.concat()
      end)
      |> Enum.filter(fn module ->
        # Filter to likely component modules
        module_string = inspect(module)

        String.contains?(module_string, app_name) and
          (String.contains?(module_string, "Component") or
             String.contains?(module_string, "Layout"))
      end)
    else
      []
    end
  rescue
    _ -> []
  end

  defp build_component(%{styles: styles}, _output_dir, _fallback_dir) when styles in [nil, ""] do
    :skip
  end

  defp build_component(
         %{
           module: module,
           capsule_id: capsule_id,
           namespace: namespace,
           strategy: strategy,
           cache_strategy: cache_strategy,
           styles: styles
         },
         output_dir,
         fallback_dir
       ) do
    scoped_css = StyleCapsule.CssProcessor.scope(styles, capsule_id, strategy: strategy)

    filename_pattern =
      fn id, _css ->
        ns =
          namespace
          |> to_string()
          |> String.replace(~r/[^a-zA-Z0-9_-]/, "_")

        "#{ns}-#{id}.css"
      end

    file_opts = [
      output_dir: output_dir,
      fallback_dir: fallback_dir,
      filename_pattern: filename_pattern,
      namespace: namespace
    ]

    case cache_strategy do
      :file ->
        case StyleCapsule.FileWriter.write(capsule_id, scoped_css, file_opts) do
          {:ok, path} ->
            {:ok,
             %{
               module: Atom.to_string(module),
               capsule_id: capsule_id,
               namespace: namespace,
               strategy: strategy,
               cache_strategy: cache_strategy,
               path: path
             }}

          {:error, reason} ->
            {:error, reason}
        end

      _other ->
        # For non-file strategies, we still include an entry without a file path
        {:ok,
         %{
           module: Atom.to_string(module),
           capsule_id: capsule_id,
           namespace: namespace,
           strategy: strategy,
           cache_strategy: cache_strategy,
           path: nil
         }}
    end
  end
end
