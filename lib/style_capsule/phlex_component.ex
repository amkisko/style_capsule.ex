defmodule StyleCapsule.PhlexComponent do
  @moduledoc """
  Provides automatic StyleCapsule integration for Phlex components.

  Components using this module automatically:
  - Register styles at compile time for precompilation
  - Add capsule attributes to rendered HTML
  - Generate style_capsule_spec for discovery

  ## Usage

      defmodule MyAppWeb.Components.Card do
        use StyleCapsule.PhlexComponent

        @component_styles \"\"\"
        .card { padding: 1rem; }
        \"\"\"

        defp render_template(assigns, attrs, state) do
          div(state, attrs, fn state ->
            # Component content
          end)
        end
      end

  ## Configuration

  Configuration is automatically read from StyleCapsule.Config. Override per-component:

      use StyleCapsule.PhlexComponent, namespace: :admin, strategy: :nesting
  """

  defmacro __using__(opts \\ []) do
    quote do
      use Phlex.HTML

      # Get configuration from opts or fall back to StyleCapsule.Config defaults
      @style_capsule_namespace Keyword.get(unquote(opts), :namespace) ||
                                 StyleCapsule.Config.default_namespace()
      @style_capsule_strategy Keyword.get(unquote(opts), :strategy) ||
                                StyleCapsule.Config.default_strategy()
      @style_capsule_cache Keyword.get(unquote(opts), :cache_strategy) ||
                             StyleCapsule.Config.default_cache_strategy()

      @before_compile StyleCapsule.PhlexComponent

      def view_template(component, state) do
        # Extract assigns from component struct
        assigns =
          case Map.get(component, :_assigns) do
            nil ->
              component
              |> Map.from_struct()
              |> Map.delete(:__struct__)

            assigns_map ->
              assigns_map
          end

        # Register styles at runtime for :none and :time cache strategies
        # :file strategy components are precompiled and don't need runtime registration
        cache_strategy = @style_capsule_cache

        # Only register at runtime if not using file-based caching
        # Use a helper function to avoid type checker warnings about compile-time constants
        # The type checker may see @style_capsule_cache as always :none, but at runtime
        # it can be :none, :time, :file, or a function depending on component configuration
        if should_register_runtime?(cache_strategy) do
          register_runtime_styles(__MODULE__, cache_strategy)
        end

        # Add capsule attributes
        base_attrs = Map.get(assigns, :attrs, [])
        attrs = StyleCapsule.PhlexComponent.add_capsule_attrs(base_attrs, __MODULE__)

        # Call render_template (must be implemented by component)
        render_template(assigns, attrs, state)
      end

      defp register_runtime_styles(module, cache_strategy) do
        # Get styles from the module
        styles =
          if function_exported?(module, :styles, 0) do
            try do
              module.styles()
            rescue
              _ -> ""
            end
          else
            ""
          end

        if styles && styles != "" do
          namespace = @style_capsule_namespace
          strategy = @style_capsule_strategy
          capsule_id = StyleCapsule.capsule_id(module)

          # Register inline styles for runtime cache strategies
          StyleCapsule.Phoenix.register_inline(styles, capsule_id,
            namespace: namespace,
            strategy: strategy,
            cache_strategy: cache_strategy
          )
        end
      end

      # Must be overridden in components
      def render_template(_assigns, _attrs, _state) do
        raise "#{__MODULE__} must implement render_template/3"
      end

      # Helper function to check if styles should be registered at runtime
      # This avoids type checker warnings by using a function call instead of direct comparison
      defp should_register_runtime?(cache_strategy) do
        cache_strategy != :file
      end

      defoverridable view_template: 2, render_template: 3
    end
  end

  defmacro __before_compile__(env) do
    # Get component styles at compile time
    styles =
      case Module.get_attribute(env.module, :component_styles) do
        nil -> ""
        s when is_binary(s) -> s
        _ -> ""
      end

    # Get configuration from module attributes
    namespace = Module.get_attribute(env.module, :style_capsule_namespace) || :default
    strategy = Module.get_attribute(env.module, :style_capsule_strategy) || :patch
    cache_strategy = Module.get_attribute(env.module, :style_capsule_cache) || :none

    # Build the spec
    spec = %{
      module: env.module,
      capsule_id: StyleCapsule.capsule_id(env.module),
      namespace: namespace,
      strategy: strategy,
      cache_strategy: cache_strategy,
      styles: styles
    }

    # Register at compile time if styles are present
    if styles != "" do
      StyleCapsule.CompileRegistry.register(spec)
    end

    # Generate the module code
    quote do
      def styles do
        unquote(Macro.escape(styles))
      end

      def style_capsule_spec do
        unquote(Macro.escape(spec))
      end
    end
  end

  @doc false
  @dialyzer {:nowarn_function, add_capsule_attrs: 2}
  def add_capsule_attrs(attrs, module) do
    case Code.ensure_loaded(Phlex.StyleCapsule) do
      {:module, Phlex.StyleCapsule} ->
        if function_exported?(Phlex.StyleCapsule, :add_capsule_attr, 2) do
          # Phlex.StyleCapsule is an optional dependency, use apply to avoid Dialyzer warnings
          # credo:disable-for-next-line
          apply(Phlex.StyleCapsule, :add_capsule_attr, [attrs, module])
        else
          add_capsule_attr_direct(attrs, StyleCapsule.capsule_id(module))
        end

      {:error, _} ->
        # Phlex.StyleCapsule not available, generate capsule ID directly
        add_capsule_attr_direct(attrs, StyleCapsule.capsule_id(module))
    end
  rescue
    _ ->
      add_capsule_attr_direct(attrs, StyleCapsule.capsule_id(module))
  end

  defp add_capsule_attr_direct(attrs, capsule_id) when is_list(attrs) do
    Keyword.put(attrs, :"data-capsule", capsule_id)
  end

  defp add_capsule_attr_direct(attrs, capsule_id) when is_map(attrs) do
    Map.put(attrs, "data-capsule", capsule_id)
  end

  defp add_capsule_attr_direct(attrs, _capsule_id), do: attrs
end
