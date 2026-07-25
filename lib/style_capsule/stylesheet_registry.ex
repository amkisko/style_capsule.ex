defmodule StyleCapsule.StylesheetRegistry do
  @moduledoc """
  Registry for managing stylesheet registration per request or socket.

  The registry stores inline CSS blocks and stylesheet links, organized by namespace.
  This allows rendering only the styles needed for a specific page/context.

  Aligns with `StyleCapsule::StylesheetRegistry` in the Ruby library.
  """

  @storage_key :style_capsule_stylesheet_registry
  @legacy_storage_key :style_capsule_registry

  @type namespace :: atom() | binary()
  @type inline_style :: %{
          id: binary(),
          css: binary(),
          attrs: keyword(),
          capsule_id: binary()
        }
  @type stylesheet_link :: %{
          href: binary(),
          attrs: keyword()
        }

  @doc """
  Registers inline CSS in the registry.

  ## Options

    * `:namespace` - Namespace for the styles. Defaults to `:default`.
    * `:capsule_id` - Capsule ID for the styles. Required.
    * `:attrs` - Additional attributes for the style tag.

  ## Examples

      iex> StyleCapsule.StylesheetRegistry.register_inline(".test { color: red; }", "abc12345")
      :ok

  """
  @spec register_inline(binary(), binary(), keyword()) :: :ok
  def register_inline(css, capsule_id, opts \\ []) do
    namespace = Keyword.get(opts, :namespace, :default)
    attrs = Keyword.get(opts, :attrs, [])

    inline_style = %{
      id: capsule_id,
      css: css,
      attrs: attrs,
      capsule_id: capsule_id
    }

    store_inline(namespace, inline_style)
  end

  @doc """
  Registers a stylesheet link in the registry.

  ## Options

    * `:namespace` - Namespace for the stylesheet. Defaults to `:default`.
    * `:attrs` - Additional attributes for the link tag.

  ## Examples

      iex> StyleCapsule.StylesheetRegistry.register_stylesheet("/assets/capsules/card.css", namespace: :admin)
      :ok

  """
  @spec register_stylesheet(binary(), keyword()) :: :ok
  def register_stylesheet(href, opts \\ []) do
    namespace = Keyword.get(opts, :namespace, :default)
    attrs = Keyword.get(opts, :attrs, [])

    link = %{
      href: href,
      attrs: attrs
    }

    store_link(namespace, link)
  end

  @doc """
  Retrieves all inline styles for a namespace.

  ## Examples

      iex> StyleCapsule.StylesheetRegistry.register_inline(".test { color: red; }", "abc12345")
      iex> styles = StyleCapsule.StylesheetRegistry.get_inline_styles()
      iex> length(styles)
      1
      iex> hd(styles).id
      "abc12345"

  """
  @spec get_inline_styles(namespace()) :: [inline_style()]
  def get_inline_styles(namespace \\ :default) do
    get_storage()
    |> Map.get(:inline, %{})
    |> Map.get(namespace, [])
    |> Enum.reverse()
  end

  @doc """
  Retrieves all stylesheet links for a namespace.

  ## Examples

      iex> StyleCapsule.StylesheetRegistry.register_stylesheet("/assets/card.css")
      iex> StyleCapsule.StylesheetRegistry.get_stylesheet_links()
      [%{href: "/assets/card.css", attrs: []}]

  """
  @spec get_stylesheet_links(namespace()) :: [stylesheet_link()]
  def get_stylesheet_links(namespace \\ :default) do
    get_storage()
    |> Map.get(:links, %{})
    |> Map.get(namespace, [])
    |> Enum.reverse()
  end

  @doc """
  Gets all namespaces that have registered styles or stylesheet links.

  ## Examples

      iex> StyleCapsule.StylesheetRegistry.register_inline(".test { color: red; }", "abc123", namespace: :admin)
      iex> StyleCapsule.StylesheetRegistry.get_all_namespaces()
      [:admin]

  """
  @spec get_all_namespaces() :: [namespace()]
  def get_all_namespaces do
    storage = get_storage()
    inline_namespaces = Map.keys(storage[:inline] || %{})
    link_namespaces = Map.keys(storage[:links] || %{})

    (inline_namespaces ++ link_namespaces)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Clears the registry for a namespace or all namespaces.

  ## Examples

      iex> StyleCapsule.StylesheetRegistry.clear()
      :ok

      iex> StyleCapsule.StylesheetRegistry.clear(:admin)
      :ok

  """
  @spec clear(namespace() | :all) :: :ok
  def clear(namespace \\ :all) do
    case namespace do
      :all ->
        put_storage(%{inline: %{}, links: %{}})

      namespace_value ->
        storage = get_storage()

        new_storage = %{
          inline: Map.delete(storage.inline || %{}, namespace_value),
          links: Map.delete(storage.links || %{}, namespace_value)
        }

        put_storage(new_storage)
    end

    :ok
  end

  defp get_storage do
    default = %{inline: %{}, links: %{}}
    current = Process.get(@storage_key)
    legacy = Process.get(@legacy_storage_key)

    cond do
      storage_populated?(current) ->
        current

      storage_populated?(legacy) ->
        legacy

      current != nil ->
        current

      true ->
        legacy || default
    end
  end

  defp storage_populated?(%{inline: inline, links: links}) do
    map_size(inline) > 0 or map_size(links) > 0
  end

  defp storage_populated?(_storage), do: false

  defp put_storage(storage) do
    Process.put(@storage_key, storage)
    Process.delete(@legacy_storage_key)
    storage
  end

  defp store_inline(namespace, inline_style) do
    storage = get_storage()
    inline_map = Map.get(storage, :inline, %{})
    namespace_styles = Map.get(inline_map, namespace, [])

    new_styles =
      case Enum.find_index(namespace_styles, fn style -> style.id == inline_style.id end) do
        nil -> [inline_style | namespace_styles]
        _index -> namespace_styles
      end

    new_inline_map = Map.put(inline_map, namespace, new_styles)
    put_storage(Map.put(storage, :inline, new_inline_map))
    :ok
  end

  defp store_link(namespace, link) do
    storage = get_storage()
    links_map = Map.get(storage, :links, %{})
    namespace_links = Map.get(links_map, namespace, [])

    new_links =
      case Enum.find_index(namespace_links, fn entry -> entry.href == link.href end) do
        nil -> [link | namespace_links]
        _index -> namespace_links
      end

    new_links_map = Map.put(links_map, namespace, new_links)
    put_storage(Map.put(storage, :links, new_links_map))
    :ok
  end
end
