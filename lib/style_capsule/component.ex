defmodule StyleCapsule.Component do
  @moduledoc """
  Provides component integration for StyleCapsule with Phoenix LiveView components.

  Use this module to automatically wrap components with capsule scoping and register styles.
  This is designed for Phoenix LiveView components using `Phoenix.Component`.

  ## Usage

      defmodule MyAppWeb.Components.Card do
        use Phoenix.Component
        use StyleCapsule.Component

        @component_styles \"""
        .root { padding: 1rem; }
        \"""

        def card(assigns) do
          ~H\"""
          <.capsule module={__MODULE__}>
            <div class="root">
              <%= render_slot(@inner_block) %>
            </div>
          </.capsule>
          \"""
        end
      end

  ## Configuration

      use StyleCapsule.Component, namespace: :admin, strategy: :nesting
  """

  use Phoenix.Component

  defmacro __using__(opts \\ []) do
    quote do
      @style_capsule_opts unquote(opts)

      # Register attributes for compile-time dependency tracking
      Module.register_attribute(__MODULE__, :__style_capsule_deps__, accumulate: true)
      Module.register_attribute(__MODULE__, :__style_capsule_component_calls__, accumulate: true)

      import StyleCapsule.Component, only: [capsule: 1]

      @before_compile StyleCapsule.Component
    end
  end

  @doc """
  Tracks a dependency on another component at compile time.

  This is automatically called when using `capsule/1` with a module reference.
  """
  defmacro track_dependency(module) do
    quote do
      Module.put_attribute(__MODULE__, :__style_capsule_deps__, unquote(module))
    end
  end

  defmacro __before_compile__(env) do
    # Get styles at compile time from module attribute
    styles = case Module.get_attribute(env.module, :component_styles) do
      nil -> nil
      s when is_binary(s) -> s
      _ -> nil
    end

    # Get configuration from module attribute (set in __using__)
    opts = Module.get_attribute(env.module, :style_capsule_opts) || []
    namespace = Keyword.get(opts, :namespace, :default)
    strategy = Keyword.get(opts, :strategy, :patch)
    cache_strategy = Keyword.get(opts, :cache_strategy, :none)

    # Build spec at compile time
    spec = %{
      module: env.module,
      capsule_id: StyleCapsule.capsule_id(env.module),
      namespace: namespace,
      strategy: strategy,
      cache_strategy: cache_strategy,
      styles: styles
    }

    # Validate styles if present
    if styles && styles != "" do
      # Basic validation - check for common issues
      if String.contains?(styles, "<script") or String.contains?(styles, "javascript:") do
        raise StyleCapsule.InvalidStyleError,
          message: "Invalid styles detected in #{inspect(env.module)}: styles may not contain script tags or javascript: URLs",
          module: env.module,
          styles: styles
      end

      # Register at compile time
      try do
        StyleCapsule.CompileRegistry.register(spec)
      rescue
        e ->
          raise StyleCapsule.RegistryError,
            message: "Failed to register component #{inspect(env.module)}: #{Exception.message(e)}",
            operation: :register
      end
    end

    # Track compile-time dependencies and component calls
    deps = Module.get_attribute(env.module, :__style_capsule_deps__) || []
    component_calls = Module.get_attribute(env.module, :__style_capsule_component_calls__) || []

    quote do
      # Only override render/1 if it exists
      # Components may define their own functions like card/1, button/1, etc.
      if function_exported?(__MODULE__, :render, 1) do
        defoverridable render: 1

        def render(assigns) do
          # Get component styles if defined
          styles = get_component_styles()

          if styles && styles != "" do
            # Generate capsule ID
            capsule_id = try do
              StyleCapsule.capsule_id(__MODULE__)
            rescue
              e ->
                raise StyleCapsule.CapsuleNotFoundError,
                  message: "Failed to generate capsule ID for #{inspect(__MODULE__)}: #{Exception.message(e)}",
                  module: __MODULE__
            end

            # Register styles
            namespace = Keyword.get(@style_capsule_opts, :namespace, :default)
            strategy = Keyword.get(@style_capsule_opts, :strategy, :patch)
            cache_strategy = Keyword.get(@style_capsule_opts, :cache_strategy, :none)

            try do
              StyleCapsule.Phoenix.register_inline(styles, capsule_id,
                namespace: namespace,
                strategy: strategy,
                cache_strategy: cache_strategy
              )
            rescue
              e ->
                raise StyleCapsule.Error,
                  message: "Failed to register inline styles for #{inspect(__MODULE__)}: #{Exception.message(e)}"
            end

            # Wrap content
            assigns = assign(assigns, :__style_capsule_id__, capsule_id)
          end

          super(assigns)
        end
      end

      defp get_component_styles do
        # Check module attribute first (compile-time check)
        # Use Module.get_attribute/2 to avoid warnings when attribute doesn't exist
        case Module.get_attribute(__MODULE__, :component_styles) do
          nil ->
            # Fallback to styles/0 function if it exists (runtime check)
            if function_exported?(__MODULE__, :styles, 0) do
              try do
                styles()
              rescue
                _ -> nil
              end
            else
              nil
            end
          styles when is_binary(styles) ->
            styles
          _ ->
            nil
        end
      end

      def styles do
        unquote(if styles, do: Macro.escape(styles), else: Macro.escape(""))
      end

      @doc false
      def style_capsule_spec do
        unquote(Macro.escape(spec))
      end

      defoverridable style_capsule_spec: 0

      @doc false
      def __style_capsule_deps__ do
        unquote(Macro.escape(deps))
      end

      @doc false
      def __style_capsule_component_calls__ do
        unquote(Macro.escape(component_calls))
      end
    end
  end

  @doc """
  Wraps content in a capsule element with data-capsule attribute.

  This is a function component that uses Phoenix's built-in `render_slot/2`
  to properly handle slot rendering.

  ## Examples

      <.capsule module={__MODULE__}>
        <div class="content">Hello</div>
      </.capsule>

      <.capsule module={__MODULE__} tag={:section} class="wrapper">
        <div class="content">Hello</div>
      </.capsule>
  """
  attr :module, :atom, required: true, doc: "The component module that defines the styles"
  attr :tag, :atom, default: :div, doc: "HTML tag to use for the wrapper element"
  slot :inner_block, required: true, doc: "The content to wrap in the capsule"
  attr :rest, :global, doc: "Additional HTML attributes for the wrapper element"

  def capsule(assigns) do
    module = assigns.module

    # Validate module is provided
    unless module do
      raise StyleCapsule.CapsuleNotFoundError,
        message: "Module is required for capsule/1",
        module: nil
    end

    capsule_id = try do
      StyleCapsule.capsule_id(module)
    rescue
      e ->
        raise StyleCapsule.CapsuleNotFoundError,
          message: "Failed to generate capsule ID for #{inspect(module)}: #{Exception.message(e)}",
          module: module
    end

    # Register styles if the module has component_styles
    # This ensures function components (that don't use render/1) still register their styles
    case Code.ensure_loaded(module) do
      {:module, _} ->
        # Try to get styles from the module
        # First check if module has styles/0 function (generated by __before_compile__)
        styles = cond do
          function_exported?(module, :styles, 0) ->
            try do
              module.styles()
            rescue
              _e ->
                # Silently handle errors - module may not have styles/0 or it may fail
                nil
            end
          # Fallback: check if module has @component_styles attribute via Module.get_attribute
          # This won't work at runtime, but we can try get_component_styles if it exists
          function_exported?(module, :get_component_styles, 0) ->
            try do
              module.get_component_styles()
            rescue
              _ -> nil
            end
          true ->
            nil
        end

        if styles && styles != "" && String.trim(styles) != "" do
          # Get configuration from module if available
          opts = if function_exported?(module, :style_capsule_spec, 0) do
            try do
              spec = module.style_capsule_spec()
              [
                namespace: Map.get(spec, :namespace, :default),
                strategy: Map.get(spec, :strategy, :patch),
                cache_strategy: Map.get(spec, :cache_strategy, :none)
              ]
            rescue
              _ -> [namespace: :default, strategy: :patch, cache_strategy: :none]
            end
          else
            [namespace: :default, strategy: :patch, cache_strategy: :none]
          end

          # Register styles
          try do
            StyleCapsule.Phoenix.register_inline(styles, capsule_id, opts)
          rescue
            # Silently handle errors - styles might already be registered
            _e -> :ok
          end
        end
      {:error, _reason} ->
        # Module not loaded, skip style registration
        :ok
    end

    # Use HEEx template with conditional tag rendering for common tags
    assigns = assign(assigns, :capsule_id, capsule_id)
    assigns = assign(assigns, :tag, assigns.tag || :div)

    # Use HEEx with conditional rendering based on tag
    ~H"""
    <%= cond do %>
      <% @tag == :div -> %>
        <div data-capsule={@capsule_id} {@rest}>
          <%= render_slot(@inner_block) %>
        </div>
      <% @tag == :section -> %>
        <section data-capsule={@capsule_id} {@rest}>
          <%= render_slot(@inner_block) %>
        </section>
      <% @tag == :article -> %>
        <article data-capsule={@capsule_id} {@rest}>
          <%= render_slot(@inner_block) %>
        </article>
      <% @tag == :aside -> %>
        <aside data-capsule={@capsule_id} {@rest}>
          <%= render_slot(@inner_block) %>
        </aside>
      <% @tag == :header -> %>
        <header data-capsule={@capsule_id} {@rest}>
          <%= render_slot(@inner_block) %>
        </header>
      <% @tag == :footer -> %>
        <footer data-capsule={@capsule_id} {@rest}>
          <%= render_slot(@inner_block) %>
        </footer>
      <% @tag == :nav -> %>
        <nav data-capsule={@capsule_id} {@rest}>
          <%= render_slot(@inner_block) %>
        </nav>
      <% true -> %>
        <%
        # For dynamic tags, we need to build the HTML manually
        # Convert tag atom to string for HTML generation
        tag_name = @tag |> to_string()

        # Build attributes string from @rest
        # Use Plug.HTML.html_escape for proper HTML attribute escaping
        attrs_list = Enum.map(@rest, fn
          {key, value} when is_atom(key) ->
            key_str = key |> to_string() |> String.replace("_", "-")
            value_str = value |> to_string() |> Plug.HTML.html_escape()
            ~s(#{key_str}="#{value_str}")
          {key, value} when is_binary(key) ->
            value_str = value |> to_string() |> Plug.HTML.html_escape()
            ~s(#{key}="#{value_str}")
          key when is_atom(key) ->
            key |> to_string() |> String.replace("_", "-")
          key when is_binary(key) ->
            key
        end)

        # Add data-capsule attribute (already safe, no escaping needed for capsule_id)
        capsule_attr = ~s(data-capsule="#{@capsule_id}")
        attrs_string = [capsule_attr | attrs_list] |> Enum.join(" ")

        slot_rendered = render_slot(@inner_block)
        slot_html = case slot_rendered do
          %Phoenix.LiveView.Rendered{} = rendered ->
            static = rendered.static || []
            dynamic_result = rendered.dynamic.(false)
            [static | dynamic_result] |> IO.iodata_to_binary()
          other ->
            to_string(other)
        end
        %>
        <%= Phoenix.HTML.raw("<#{tag_name} #{attrs_string}>#{slot_html}</#{tag_name}>") %>
    <% end %>
    """
  end
end
