defmodule Mix.Tasks.StyleCapsule.Build do
  @moduledoc """
  Builds CSS capsule files for file-based caching.

  This task discovers all components with styles and generates scoped CSS files.
  """

  use Mix.Task

  @shortdoc "Builds CSS capsule files"

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("compile")

    app = Mix.Project.config()[:app]
    _ = Application.load(app)

    output_dir = StyleCapsule.Config.output_dir()
    fallback_dir = StyleCapsule.Config.fallback_dir()

    File.mkdir_p!(output_dir)
    File.mkdir_p!(fallback_dir)

    Mix.shell().info("Building style capsule files...")
    Mix.shell().info("Output directory: #{output_dir}")

    modules =
      case Application.spec(app, :modules) do
        {:modules, mods} -> mods
        _ -> []
      end

    specs =
      modules
      |> Enum.flat_map(fn mod ->
        if function_exported?(mod, :style_capsule_spec, 0) do
          case safe_style_capsule_spec(mod) do
            %{} = spec -> [spec]
            _ -> []
          end
        else
          []
        end
      end)

    {entries, count} =
      Enum.reduce(specs, {[], 0}, fn spec, {acc, n} ->
        case build_component(spec, output_dir, fallback_dir) do
          {:ok, entry} ->
            {[entry | acc], n + 1}

          :skip ->
            {acc, n}

          {:error, reason} ->
            Mix.shell().error("Failed to build component #{inspect(spec.module)}: #{inspect(reason)}")
            {acc, n}
        end
      end)

    manifest = %{
      generated_at: DateTime.utc_now() |> DateTime.to_iso8601(),
      app: app,
      output_dir: output_dir,
      entries: Enum.reverse(entries)
    }

    manifest_path = Path.join(output_dir, "style_capsule_manifest.exs")
    File.write!(manifest_path, inspect(manifest, pretty: true, limit: :infinity))

    Mix.shell().info("Discovered #{count} StyleCapsule component(s).")
    Mix.shell().info("Manifest written to: #{manifest_path}")
    Mix.shell().info("Build complete!")
  end

  defp safe_style_capsule_spec(mod) do
    mod.style_capsule_spec()
  rescue
    _ -> nil
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
        # For non-file strategies, we still include an entry without a file path so
        # tooling can understand the component-level configuration.
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
