defmodule StyleCapsule.ComponentRegistry do
  @moduledoc """
  Runtime registry for StyleCapsule components using an Agent.

  This provides a shared, persistent registry that works across processes,
  unlike the process-local Registry. Components can register themselves
  at runtime when first rendered, and the registry persists across requests.

  For precompilation, components should use compile-time registration.
  For inline styles, components register at runtime when first used.
  """

  use Agent

  @doc """
  Starts the component registry agent.
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{components: %{}, specs: []} end, name: __MODULE__)
  end

  @doc """
  Registers a component spec in the runtime registry.
  """
  def register(spec) when is_map(spec) do
    start_time = System.monotonic_time(:microsecond)

    result =
      Agent.update(__MODULE__, fn state ->
        module = spec.module

        # Store by module and deduplicate
        components = Map.put(state.components, module, spec)
        specs = [spec | Enum.reject(state.specs, &(&1.module == module))]

        %{state | components: components, specs: specs}
      end)

    end_time = System.monotonic_time(:microsecond)
    duration_ms = div(end_time - start_time, 1000)

    # Emit telemetry events
    StyleCapsule.Instrumentation.component_discovered(
      module: spec.module,
      capsule_id: spec.capsule_id,
      namespace: spec.namespace,
      strategy: spec.strategy,
      cache_strategy: spec.cache_strategy,
      has_styles: spec.styles != nil && spec.styles != "" && String.trim(spec.styles || "") != "",
      discovery_type: :runtime,
      source: :component_registry
    )

    StyleCapsule.Instrumentation.component_registered(
      module: spec.module,
      capsule_id: spec.capsule_id,
      namespace: spec.namespace,
      registry: :runtime,
      registration_time_ms: duration_ms,
      source: :component_registry
    )

    result
  end

  @doc """
  Gets a component spec by module.
  """
  def get(module) when is_atom(module) do
    Agent.get(__MODULE__, fn state ->
      Map.get(state.components, module)
    end)
  end

  @doc """
  Gets all registered component specs.
  """
  def get_all do
    Agent.get(__MODULE__, fn state -> state.specs end)
  end

  @doc """
  Clears the registry (useful for testing or reloading).
  """
  def clear do
    Agent.update(__MODULE__, fn _ -> %{components: %{}, specs: []} end)
  end
end
