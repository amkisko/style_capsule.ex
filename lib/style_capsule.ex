defmodule StyleCapsule do
  @moduledoc """
  StyleCapsule provides attribute-based CSS scoping for Phoenix LiveView components
  and standalone Elixir applications.

  This module provides the main public API for scoping CSS and wrapping HTML content
  with capsule identifiers.
  """

  @doc """
  Scopes CSS by adding `[data-capsule="..."]` attribute selectors.

  ## Options

    * `:strategy` - Scoping strategy (`:patch` or `:nesting`). Defaults to `:patch`.
    * `:namespace` - Namespace for the styles. Defaults to `:default`.

  ## Examples

      iex> css = ".section { color: red; }"
      iex> capsule_id = "abc12345"
      iex> StyleCapsule.scope_css(css, capsule_id)
      "[data-capsule=\\"abc12345\\"] .section { color: red; }"

  """
  @spec scope_css(binary(), binary(), keyword()) :: binary()
  def scope_css(css, capsule_id, opts \\ []) do
    StyleCapsule.CssProcessor.scope(css, capsule_id, opts)
  end

  @doc """
  Wraps HTML content in a root element with `data-capsule` attribute.

  ## Options

    * `:tag` - HTML tag name. Defaults to `:div`.
    * `:attrs` - Additional attributes to add to the wrapper element.

  ## Examples

      iex> html = "<div class=\\"content\\">Hello</div>"
      iex> capsule_id = "abc12345"
      iex> StyleCapsule.wrap(html, capsule_id)
      ~s(<div data-capsule="abc12345"><div class="content">Hello</div></div>)

  """
  @spec wrap(iodata(), binary(), keyword()) :: binary()
  def wrap(html_or_iodata, capsule_id, opts \\ []) do
    StyleCapsule.Wrapper.wrap(html_or_iodata, capsule_id, opts)
  end

  @doc """
  Generates a deterministic capsule ID for a module or term.

  ## Examples

      iex> id = StyleCapsule.capsule_id(MyAppWeb.Components.Card)
      iex> String.length(id) >= 8
      true

  """
  @spec capsule_id(module() | term(), keyword()) :: binary()
  def capsule_id(module_or_term, opts \\ []) do
    StyleCapsule.Id.generate(module_or_term, opts)
  end

  @doc """
  Validates a capsule ID and raises if invalid.

  ## Examples

      iex> StyleCapsule.validate_capsule_id!("abc12345")
      :ok

      iex> StyleCapsule.validate_capsule_id!("invalid id!")
      ** (ArgumentError) Invalid capsule ID: must match pattern ^[a-zA-Z0-9_-]+$

  """
  @spec validate_capsule_id!(binary()) :: :ok
  def validate_capsule_id!(id) when is_binary(id) do
    StyleCapsule.Id.validate!(id)
  end

  def validate_capsule_id!(id) do
    raise ArgumentError, "Capsule ID must be a binary, got: #{inspect(id)}"
  end
end
