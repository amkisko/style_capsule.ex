defmodule StyleCapsule.Registry do
  @moduledoc """
  Registry for managing stylesheet registration per request or socket.

  The registry stores inline CSS blocks and stylesheet links, organized by namespace.
  This allows rendering only the styles needed for a specific page/context.
  """

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

      iex> StyleCapsule.Registry.register_inline(".test { color: red; }", "abc12345")
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

      iex> StyleCapsule.Registry.register_stylesheet("/assets/capsules/card.css", namespace: :admin)
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

      iex> StyleCapsule.Registry.register_inline(".test { color: red; }", "abc12345")
      iex> styles = StyleCapsule.Registry.get_inline_styles()
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

      iex> StyleCapsule.Registry.register_stylesheet("/assets/card.css")
      iex> StyleCapsule.Registry.get_stylesheet_links()
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
  Clears the registry for a namespace or all namespaces.

  ## Examples

      iex> StyleCapsule.Registry.clear()
      :ok

      iex> StyleCapsule.Registry.clear(:admin)
      :ok

  """
  @spec clear(namespace() | :all) :: :ok
  def clear(namespace \\ :all) do
    case namespace do
      :all ->
        put_storage(%{inline: %{}, links: %{}})

      ns ->
        storage = get_storage()

        new_storage = %{
          inline: Map.delete(storage.inline || %{}, ns),
          links: Map.delete(storage.links || %{}, ns)
        }

        put_storage(new_storage)
    end

    :ok
  end

  # Private functions for storage management

  @doc false
  defp get_storage do
    Process.get(:style_capsule_registry, %{inline: %{}, links: %{}})
  end

  @doc false
  defp put_storage(storage) do
    Process.put(:style_capsule_registry, storage)
  end

  @doc false
  defp store_inline(namespace, inline_style) do
    storage = get_storage()
    inline_map = Map.get(storage, :inline, %{})
    namespace_styles = Map.get(inline_map, namespace, [])

    # Deduplicate by id
    new_styles =
      case Enum.find_index(namespace_styles, fn s -> s.id == inline_style.id end) do
        nil -> [inline_style | namespace_styles]
        _index -> namespace_styles
      end

    new_inline_map = Map.put(inline_map, namespace, new_styles)
    put_storage(Map.put(storage, :inline, new_inline_map))
    :ok
  end

  @doc false
  defp store_link(namespace, link) do
    storage = get_storage()
    links_map = Map.get(storage, :links, %{})
    namespace_links = Map.get(links_map, namespace, [])

    # Deduplicate by href
    new_links =
      case Enum.find_index(namespace_links, fn l -> l.href == link.href end) do
        nil -> [link | namespace_links]
        _index -> namespace_links
      end

    new_links_map = Map.put(links_map, namespace, new_links)
    put_storage(Map.put(storage, :links, new_links_map))
    :ok
  end
end
