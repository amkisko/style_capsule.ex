defmodule PhoenixDemoWeb.Telemetry do
  use Supervisor
  require Logger

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    # Attach StyleCapsule telemetry handlers
    attach_style_capsule_handlers()

    children = []

    Supervisor.init(children, strategy: :one_for_one)
  end

  # Attach telemetry handlers for StyleCapsule component discovery events
  defp attach_style_capsule_handlers do
    # Handler for component discovered events
    :telemetry.attach_many(
      "phoenix-demo-style-capsule-discovered",
      [[:style_capsule, :component, :discovered]],
      &__MODULE__.handle_component_discovered/4,
      nil
    )

    # Handler for component registered events
    :telemetry.attach_many(
      "phoenix-demo-style-capsule-registered",
      [[:style_capsule, :component, :registered]],
      &__MODULE__.handle_component_registered/4,
      nil
    )

    # Handler for discovery operation events
    :telemetry.attach_many(
      "phoenix-demo-style-capsule-discovery",
      [[:style_capsule, :discovery, :operation]],
      &__MODULE__.handle_discovery_operation/4,
      nil
    )

    # Handler for component rendered events (optional, can be noisy)
    # Only attach if render tracking is enabled
    if Application.get_env(:style_capsule, :track_component_renders, false) do
      :telemetry.attach_many(
        "phoenix-demo-style-capsule-rendered",
        [[:style_capsule, :component, :rendered]],
        &__MODULE__.handle_component_rendered/4,
        nil
      )
    end
  end

  # Handle component discovered events
  def handle_component_discovered(
         [:style_capsule, :component, :discovered],
         measurements,
         metadata,
         _config
       ) do
    module_name = measurements.module |> inspect()
    discovery_type = measurements.discovery_type

    # Use info level so it shows in console
    # Note: Compile-time discoveries happen during compilation, so they may not appear
    # in runtime logs. Runtime discoveries will appear here.
    Logger.info(
      "[StyleCapsule] Component discovered: #{module_name} " <>
        "(#{discovery_type}, namespace: #{measurements.namespace}, " <>
        "has_styles: #{measurements.has_styles})",
      metadata: Map.merge(metadata, %{module: measurements.module, capsule_id: measurements.capsule_id})
    )
  end

  # Handle component registered events
  def handle_component_registered(
         [:style_capsule, :component, :registered],
         measurements,
         metadata,
         _config
       ) do
    # Filter out unknown components
    module = measurements.module

    if module == :unknown do
      :ok
    else
      module_name = module |> inspect()
      registry = measurements.registry
      time_ms = measurements.registration_time_ms
      source = Map.get(metadata, :source, :unknown)

      # Log inline registrations at info level (they're now deduplicated globally)
      # ComponentRegistry registrations at debug level
      log_level = if source == :phoenix_register_inline, do: :info, else: :debug

      # Clarify what "registered" means: styles are registered for inclusion in <head>
      message = case source do
        :phoenix_register_inline ->
          "[StyleCapsule] Styles registered for #{module_name} " <>
            "(will be rendered in <head>, namespace: #{measurements.namespace})"
        _ ->
          "[StyleCapsule] Component registered: #{module_name} " <>
            "(registry: #{registry}, time: #{time_ms}ms)"
      end

      Logger.log(
        log_level,
        message,
        metadata: Map.merge(metadata, %{module: module, capsule_id: measurements.capsule_id})
      )
    end
  end

  # Handle discovery operation events
  def handle_discovery_operation(
         [:style_capsule, :discovery, :operation],
         measurements,
         _metadata,
         _config
       ) do
    operation = measurements.operation
    modules_checked = measurements.modules_checked
    components_found = measurements.components_found
    duration_ms = measurements.duration_ms
    success = if measurements.success, do: "success", else: "failed"

    Logger.debug(
      "[StyleCapsule] Discovery operation: #{operation} " <>
        "(checked: #{modules_checked}, found: #{components_found}, " <>
        "duration: #{duration_ms}ms, #{success})"
    )
  end

  # Handle component rendered events (optional, can be noisy)
  def handle_component_rendered(
         [:style_capsule, :component, :rendered],
         measurements,
         _metadata,
         _config
       ) do
    module_name = measurements.module |> inspect()
    render_time_ms = measurements.render_time_ms

    Logger.debug(
      "[StyleCapsule] Component rendered: #{module_name} " <>
        "(render_time: #{render_time_ms}ms)"
    )
  end
end
