defmodule StyleCapsule.CompileRegistry do
  @moduledoc """
  Persistent compile-time registry for StyleCapsule components.

  Registry entries are stored as safely decoded Erlang terms under the current
  project so build tasks can consume component data without evaluating code.
  """

  @registry_file "style_capsule_registry.etf"
  @required_fields [:module, :capsule_id, :namespace, :strategy, :cache_strategy]

  @doc """
  Registers a component spec at compile time.
  """
  def register(spec) when is_map(spec) do
    validate_spec!(spec)

    existing_data = read_registry_data()
    existing_specs = extract_specs(existing_data)
    existing_build = extract_build_metadata(existing_data)
    specs = [spec | Enum.reject(existing_specs, &(&1.module == spec.module))]
    write_registry(if(existing_build, do: %{components: specs, build: existing_build}, else: specs))

    StyleCapsule.Instrumentation.component_discovered(
      module: spec.module,
      capsule_id: spec.capsule_id,
      namespace: spec.namespace,
      strategy: spec.strategy,
      cache_strategy: spec.cache_strategy,
      has_styles: is_binary(spec.styles) && String.trim(spec.styles) != "",
      discovery_type: :compile_time,
      source: :compile_registry
    )

    :ok
  rescue
    error ->
      reraise StyleCapsule.RegistryError,
              [
                message: "Failed to persist compile registry: #{Exception.message(error)}",
                operation: :register
              ],
              __STACKTRACE__
  end

  @doc """
  Reads all registered component specs.
  """
  def get_all, do: read_registry_data() |> extract_specs()

  @doc """
  Updates build metadata while preserving component specs.
  """
  def update_build_metadata(metadata) when is_map(metadata) do
    write_registry(%{components: get_all(), build: metadata})
  end

  @doc """
  Gets build metadata from the registry.
  """
  def get_build_metadata, do: read_registry_data() |> extract_build_metadata()

  @doc """
  Clears the compile-time registry.
  """
  def clear do
    case File.rm(registry_path()) do
      :ok -> :ok
      {:error, :enoent} -> :ok
      {:error, reason} -> raise File.Error, reason: reason, action: "remove file", path: registry_path()
    end
  end

  defp validate_spec!(spec) do
    missing_fields = Enum.reject(@required_fields, &Map.has_key?(spec, &1))

    if missing_fields != [] do
      raise StyleCapsule.RegistryError,
        message: "Invalid spec: missing required fields #{inspect(missing_fields)}",
        operation: :register
    end

    unless valid_spec?(spec) do
      raise StyleCapsule.RegistryError,
        message: "Invalid spec: field types do not match the registry schema",
        operation: :register
    end
  end

  defp write_registry(data) do
    path = registry_path()
    File.mkdir_p!(Path.dirname(path))
    temporary_path = "#{path}.#{System.unique_integer([:positive])}.tmp"

    try do
      File.write!(temporary_path, :erlang.term_to_binary(data, compressed: 6), [:binary])
      File.rename!(temporary_path, path)
      :ok
    after
      if File.exists?(temporary_path), do: File.rm(temporary_path)
    end
  end

  defp read_registry_data do
    case File.read(registry_path()) do
      {:ok, binary} ->
        binary
        |> :erlang.binary_to_term([:safe])
        |> validate_registry_data()

      {:error, :enoent} ->
        []

      {:error, _reason} ->
        []
    end
  rescue
    ArgumentError -> []
  end

  defp validate_registry_data(data) when is_list(data) do
    if Enum.all?(data, &valid_spec?/1), do: data, else: []
  end

  defp validate_registry_data(%{components: specs, build: metadata} = data)
       when is_list(specs) and is_map(metadata) do
    if Enum.all?(specs, &valid_spec?/1), do: data, else: []
  end

  defp validate_registry_data(_data), do: []

  defp valid_spec?(spec) when is_map(spec) do
    Enum.all?(@required_fields, &Map.has_key?(spec, &1)) &&
      is_atom(spec.module) &&
      is_binary(spec.capsule_id) &&
      (is_atom(spec.namespace) || is_binary(spec.namespace)) &&
      is_atom(spec.strategy) &&
      is_atom(spec.cache_strategy) &&
      (is_nil(Map.get(spec, :styles)) || is_binary(spec.styles))
  end

  defp valid_spec?(_spec), do: false

  defp extract_specs(specs) when is_list(specs), do: specs
  defp extract_specs(%{components: specs}) when is_list(specs), do: specs
  defp extract_specs(_data), do: []

  defp extract_build_metadata(%{build: metadata}) when is_map(metadata), do: metadata
  defp extract_build_metadata(_data), do: nil

  defp registry_path, do: Path.join([File.cwd!(), "priv", @registry_file])
end
