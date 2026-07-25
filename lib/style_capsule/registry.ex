defmodule StyleCapsule.Registry do
  @moduledoc """
  Deprecated. Use `StyleCapsule.StylesheetRegistry` instead.
  """

  @deprecated "Use StyleCapsule.StylesheetRegistry instead"

  @spec register_inline(binary(), binary(), keyword()) :: :ok
  defdelegate register_inline(css, capsule_id, opts \\ []),
    to: StyleCapsule.StylesheetRegistry

  @spec register_stylesheet(binary(), keyword()) :: :ok
  defdelegate register_stylesheet(href, opts \\ []), to: StyleCapsule.StylesheetRegistry

  @spec get_inline_styles(StyleCapsule.StylesheetRegistry.namespace()) ::
          [StyleCapsule.StylesheetRegistry.inline_style()]
  defdelegate get_inline_styles(namespace \\ :default), to: StyleCapsule.StylesheetRegistry

  @spec get_stylesheet_links(StyleCapsule.StylesheetRegistry.namespace()) ::
          [StyleCapsule.StylesheetRegistry.stylesheet_link()]
  defdelegate get_stylesheet_links(namespace \\ :default), to: StyleCapsule.StylesheetRegistry

  @spec get_all_namespaces() :: [StyleCapsule.StylesheetRegistry.namespace()]
  defdelegate get_all_namespaces(), to: StyleCapsule.StylesheetRegistry

  @spec clear(StyleCapsule.StylesheetRegistry.namespace() | :all) :: :ok
  defdelegate clear(namespace \\ :all), to: StyleCapsule.StylesheetRegistry
end
