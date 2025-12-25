defmodule PhoenixDemo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      PhoenixDemoWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: PhoenixDemo.PubSub},
      # Start the Endpoint (http/https)
      PhoenixDemoWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhoenixDemo.Supervisor]
    result = Supervisor.start_link(children, opts)

    # Log discovered components from compile-time registry (for demonstration)
    log_compile_time_components()

    result
  end

  # Log components discovered at compile-time (for demonstration)
  defp log_compile_time_components do
    # Read from compile-time registry to show what was discovered
    specs = StyleCapsule.CompileRegistry.get_all()

    if length(specs) > 0 do
      require Logger

      Logger.info(
        "[StyleCapsule] Found #{length(specs)} component(s) in compile-time registry"
      )

      # Log all components
      specs
      |> Enum.each(fn spec ->
        Logger.info(
          "[StyleCapsule] Compile-time component: #{inspect(spec.module)} " <>
            "(namespace: #{spec.namespace}, has_styles: #{spec.styles != nil && spec.styles != ""})"
        )
      end)
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhoenixDemoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
