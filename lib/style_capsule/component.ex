defmodule StyleCapsule.Component do
  @moduledoc """
  Provides component integration for StyleCapsule.

  Use this module to automatically wrap components with capsule scoping and register styles.
  """

  defmacro __using__(opts \\ []) do
    quote do
      @style_capsule_opts unquote(opts)

      import StyleCapsule.Component, only: [capsule: 1]

      @before_compile StyleCapsule.Component
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      defoverridable render: 1

      def render(assigns) do
        # Get component styles if defined
        styles = get_component_styles()

        if styles && styles != "" do
          # Generate capsule ID
          capsule_id = StyleCapsule.capsule_id(__MODULE__)

          # Register styles
          namespace = Keyword.get(@style_capsule_opts, :namespace, :default)
          strategy = Keyword.get(@style_capsule_opts, :strategy, :patch)
          cache_strategy = Keyword.get(@style_capsule_opts, :cache_strategy, :none)

          StyleCapsule.Phoenix.register_inline(styles, capsule_id,
            namespace: namespace,
            strategy: strategy,
            cache_strategy: cache_strategy
          )

          # Wrap content
          assigns = assign(assigns, :__style_capsule_id__, capsule_id)
        end

        super(assigns)
      end

      defp get_component_styles do
        cond do
          function_exported?(__MODULE__, :component_styles, 0) ->
            component_styles()

          Module.has_attribute?(__MODULE__, :component_styles) ->
            @component_styles

          true ->
            nil
        end
      end

      @doc false
      def style_capsule_spec do
        styles = get_component_styles()

        %{
          module: __MODULE__,
          capsule_id: StyleCapsule.capsule_id(__MODULE__),
          namespace: Keyword.get(@style_capsule_opts, :namespace, :default),
          strategy: Keyword.get(@style_capsule_opts, :strategy, :patch),
          cache_strategy: Keyword.get(@style_capsule_opts, :cache_strategy, :none),
          styles: styles
        }
      end

      defoverridable style_capsule_spec: 0
    end
  end

  @doc """
  Wraps content in a capsule element with data-capsule attribute.
  """
  @spec capsule(map()) :: binary()
  def capsule(assigns) do
    module = assigns.module
    capsule_id = StyleCapsule.capsule_id(module)
    tag = Map.get(assigns, :tag, :div) || :div
    attrs = Map.get(assigns, :attrs, []) || []

    attrs_string =
      Enum.map_join(attrs, "", fn
        {key, value} when is_atom(key) ->
          key_str = to_string(key) |> String.replace("_", "-")
          ~s( #{key_str}="#{value}")

        {key, value} when is_binary(key) ->
          ~s( #{key}="#{value}")

        key when is_atom(key) ->
          key_str = to_string(key) |> String.replace("_", "-")
          ~s( #{key_str})
      end)

    tag_str = to_string(tag)
    content = render_slot(assigns.inner_block)

    ~s(<#{tag_str} data-capsule="#{capsule_id}"#{attrs_string}>#{content}</#{tag_str}>)
  end

  @doc false
  defp render_slot(slot) when is_function(slot, 1) do
    slot.(%{})
  end

  @doc false
  defp render_slot(slot) when is_function(slot, 0) do
    slot.()
  end

  @doc false
  defp render_slot(other), do: other
end
