defmodule StyleCapsule.Phoenix do
  @moduledoc """
  Phoenix integration helpers for StyleCapsule.

  Provides HEEx helpers and template integration for registering and rendering styles.
  """

  @doc """
  Renders registered styles for a namespace as HTML.

  ## Options

    * `:namespace` - Namespace to render. Defaults to `:default`.

  ## Examples

      <%= StyleCapsule.Phoenix.render_styles(namespace: :admin) %>

  """
  @spec render_styles(keyword()) :: binary()
  def render_styles(opts \\ []) do
    namespace = Keyword.get(opts, :namespace, :default)

    inline_styles = StyleCapsule.Registry.get_inline_styles(namespace)
    stylesheet_links = StyleCapsule.Registry.get_stylesheet_links(namespace)

    [
      render_inline_styles(inline_styles),
      render_stylesheet_links(stylesheet_links)
    ]
    |> Enum.filter(&(&1 != ""))
    |> Enum.join("\n")
  end

  @doc """
  Registers inline CSS for head rendering.

  ## Options

    * `:namespace` - Namespace for the styles. Defaults to `:default`.
    * `:capsule_id` - Capsule ID. If not provided, will be generated from module.
    * `:strategy` - Scoping strategy. Defaults to `:patch`.
    * `:cache_strategy` - Cache strategy. Defaults to `:none`.

  ## Examples

      <% StyleCapsule.Phoenix.register_inline(".test { color: red; }", "abc12345") %>

  """
  @spec register_inline(binary(), binary(), keyword()) :: :ok
  def register_inline(css, capsule_id, opts \\ []) do
    namespace = Keyword.get(opts, :namespace, :default)
    strategy = Keyword.get(opts, :strategy, :patch)
    cache_strategy = Keyword.get(opts, :cache_strategy, :none)

    scoped_css =
      StyleCapsule.Cache.get_or_compute(
        capsule_id,
        css,
        fn ->
          StyleCapsule.scope_css(css, capsule_id, strategy: strategy)
        end,
        strategy: cache_strategy,
        namespace: namespace
      )

    StyleCapsule.Registry.register_inline(scoped_css, capsule_id,
      namespace: namespace,
      attrs: Keyword.get(opts, :attrs, [])
    )
  end

  @doc """
  Registers a stylesheet link for head rendering.

  ## Options

    * `:namespace` - Namespace for the stylesheet. Defaults to `:default`.
    * `:attrs` - Additional attributes for the link tag.

  ## Examples

      <% StyleCapsule.Phoenix.register_stylesheet("/assets/capsules/card.css") %>

  """
  @spec register_stylesheet(binary(), keyword()) :: :ok
  def register_stylesheet(href, opts \\ []) do
    StyleCapsule.Registry.register_stylesheet(href, opts)
  end

  # Private functions

  @doc false
  defp render_inline_styles(styles) do
    Enum.map_join(styles, "\n", fn style ->
      attrs_string = build_attrs_string(style.attrs)
      ~s(<style data-style-capsule="#{style.id}"#{attrs_string}>#{style.css}</style>)
    end)
  end

  @doc false
  defp render_stylesheet_links(links) do
    Enum.map_join(links, "\n", fn link ->
      attrs_string = build_attrs_string(link.attrs)
      ~s(<link rel="stylesheet" href="#{link.href}"#{attrs_string}>)
    end)
  end

  @doc false
  defp build_attrs_string(attrs) when is_list(attrs) do
    Enum.map_join(attrs, "", fn
      {key, value} when is_atom(key) ->
        key_str = to_string(key) |> String.replace("_", "-")
        value_str = escape_html_attr(to_string(value))
        ~s( #{key_str}="#{value_str}")

      {key, value} when is_binary(key) ->
        value_str = escape_html_attr(to_string(value))
        ~s( #{key}="#{value_str}")

      key when is_atom(key) ->
        key_str = to_string(key) |> String.replace("_", "-")
        ~s( #{key_str})
    end)
  end

  @doc false
  defp build_attrs_string(_), do: ""

  @doc false
  defp escape_html_attr(str) do
    str
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&#39;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
  end
end
