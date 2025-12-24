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
  Renders all registered runtime styles from all namespaces as HTML.

  This is a convenience function that collects and renders all runtime styles
  (components with cache_strategy: :none or :time) from all namespaces in a single call.

  Namespaces are discovered dynamically from the registry, so no hardcoded values are needed.

  ## Examples

      <%= StyleCapsule.Phoenix.render_all_runtime_styles() %>

  """
  @spec render_all_runtime_styles() :: binary()
  def render_all_runtime_styles do
    # Get all namespaces dynamically from the registry
    namespaces = StyleCapsule.Registry.get_all_namespaces()

    # Collect all styles from all namespaces
    all_styles = Enum.reduce(namespaces, [], fn namespace, acc ->
      styles_html = render_styles(namespace: namespace)
      if styles_html && styles_html != "" do
        [styles_html | acc]
      else
        acc
      end
    end)

    # Return combined styles or empty string
    if length(all_styles) > 0 do
      Enum.join(Enum.reverse(all_styles), "\n")
    else
      ""
    end
  end

  @doc """
  Returns precompiled stylesheet links from the build registry.

  This function reads the build metadata from the compile-time registry
  and returns a list of stylesheet link maps that can be easily rendered.

  ## Options

    * `:namespace` - Specific namespace to return. If not provided, returns all namespaces.
    * `:base_path` - Base path for converting file paths to URLs. Defaults to removing `priv/static` prefix.

  ## Returns

    A list of stylesheet link maps with `:href` and `:attrs` keys.

  ## Examples

      # Get all stylesheet links
      links = StyleCapsule.Phoenix.precompiled_stylesheet_links()
      # => [%{href: "/assets/css/style_capsules_user.css", attrs: []}, ...]

      # Get links for specific namespace
      links = StyleCapsule.Phoenix.precompiled_stylesheet_links(namespace: :user)
      # => [%{href: "/assets/css/style_capsules_user.css", attrs: []}]

  """
  @spec precompiled_stylesheet_links(keyword()) :: [%{href: binary(), attrs: keyword()}]
  def precompiled_stylesheet_links(opts \\ []) do
    namespace_filter = Keyword.get(opts, :namespace)
    base_path = Keyword.get(opts, :base_path)

    case StyleCapsule.CompileRegistry.get_build_metadata() do
      %{namespaces: namespaces} when is_list(namespaces) ->
        namespaces
        |> Enum.filter(fn %{namespace: ns} ->
          if namespace_filter, do: ns == namespace_filter, else: true
        end)
        |> Enum.map(fn %{file: file} ->
          href = convert_file_path_to_url(file, base_path)
          %{href: href, attrs: [phx_track_static: true]}
        end)

      _ ->
        []
    end
  end

  @doc """
  Renders precompiled stylesheet links as HTML.

  This is a convenience function that calls `precompiled_stylesheet_links/1`
  and renders them as HTML `<link>` tags.

  ## Options

    * `:namespace` - Specific namespace to render. If not provided, renders all namespaces.
    * `:base_path` - Base path for converting file paths to URLs.

  ## Examples

      # In HEEx template
      <%= StyleCapsule.Phoenix.render_precompiled_stylesheets() %>

      # In Phlex component
      StyleCapsule.Phoenix.render_precompiled_stylesheets()
      |> Phlex.SGML.append_raw(state)

  """
  @spec render_precompiled_stylesheets(keyword()) :: binary()
  def render_precompiled_stylesheets(opts \\ []) do
    links = precompiled_stylesheet_links(opts)
    render_stylesheet_links(links)
  end

  defp convert_file_path_to_url(file, base_path) when is_binary(file) do
    case base_path do
      nil ->
        # Default: remove "priv/static" prefix and ensure it starts with "/"
        file
        |> String.replace(~r/^priv\/static\//, "")
        |> then(&if String.starts_with?(&1, "/"), do: &1, else: "/#{&1}")

      path when is_binary(path) ->
        # Custom base path
        file
        |> String.replace(~r/^priv\/static\//, "")
        |> then(&Path.join([path, &1]))
        |> String.replace("\\", "/")  # Normalize Windows paths

      _ ->
        file
    end
  end

  defp convert_file_path_to_url(_file, _base_path), do: ""

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
