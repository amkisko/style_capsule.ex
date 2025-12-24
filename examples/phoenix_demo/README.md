# StyleCapsule Phoenix Demo

This is a comprehensive Phoenix application demonstrating StyleCapsule integration with all major features.

## Setup

1. Install dependencies:
   ```bash
   mix deps.get
   ```

2. (Optional) Build file-cached styles:
   ```bash
   cd ../../style_capsule
   mix style_capsule.build
   cd ../examples/phoenix_demo
   ```

3. Start the server:
   ```bash
   mix phx.server
   ```

4. Visit http://localhost:4000

## Features Demonstrated

### Scoping Strategies

- **`:patch` strategy** (default): Prefixes each selector with `[data-capsule="..."]`
  - Used by: `Card`, `Button`, `FileCachedCard`, `RootSelectorExample`
- **`:nesting` strategy**: Wraps entire CSS block in `[data-capsule="..."] { ... }`
  - Used by: `AdminPanel`

### Namespaces

- **`:app` namespace**: Main application styles
  - Used by: `Card`, `Button`, `FileCachedCard`, `RootSelectorExample`
- **`:admin` namespace**: Admin-specific styles (isolated from app styles)
  - Used by: `AdminPanel`

### Caching Strategies

- **`:none`** (default): No caching, styles computed on every render
  - Used by: `Card`
- **`:time`**: Time-based caching with TTL
  - Used by: `Button` (TTL: 3600 seconds)
- **`:file`**: File-based caching for HTTP caching
  - Used by: `FileCachedCard`
  - Requires running `mix style_capsule.build` in the main library

### Root Selector Pattern

- **`:host` selector**: Targets only the root wrapper element
  - Demonstrated in: `RootSelectorExample` and `AdminPanel`
  - Automatically translated to `[data-capsule="..."]` by the CSS processor

### Component Helper

- **`StyleCapsule.Component.capsule/1`**: HEEx helper for wrapping content
  - Used by: All components
  - Usage: `<.capsule module={__MODULE__}>...</.capsule>`
  - Automatically adds `data-capsule` attribute and registers styles

## Components

All components use the modern `StyleCapsule.Component` pattern:

- **`Card`** - Basic card with `:patch` strategy and `:none` caching (default)
- **`Button`** - Button variants with `:time` caching
- **`AdminPanel`** - Admin namespace with `:nesting` strategy and `:host` selector
- **`FileCachedCard`** - File-based caching example with `cache_strategy: :file`
- **`RootSelectorExample`** - Demonstrates `:host` selector pattern

All components:
- Use `use StyleCapsule.Component` with configuration options
- Define `@component_styles` attribute
- Use `<.capsule module={__MODULE__}>` helper to wrap content
- Automatically register styles and add capsule attributes

## Integration

The app integrates StyleCapsule using the modern approach:

1. Adding `{:style_capsule, path: "../../style_capsule"}` to `mix.exs`
2. Using `StyleCapsule.Component` in components with `use StyleCapsule.Component`
3. Defining `@component_styles` attribute with CSS
4. Using the `<.capsule module={__MODULE__}>` helper to wrap content
5. Rendering styles in `lib/phoenix_demo_web/components/layouts/root.html.heex`:
   ```heex
   <%= raw StyleCapsule.Phoenix.render_precompiled_stylesheets() %>
   ```
   And at the end of `<body>`:
   ```heex
   <%= raw StyleCapsule.Phoenix.render_all_runtime_styles() %>
   ```

### Modern Component Pattern

All components follow this pattern:

```elixir
defmodule MyAppWeb.Components.Card do
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :app

  @component_styles """
  .root { padding: 1rem; }
  """

  attr :heading, :string, default: nil

  def card(assigns) do
    ~H"""
    <.capsule module={__MODULE__}>
      <div class="root">
        <%= if @heading do %>
          <h2><%= @heading %></h2>
        <% end %>
        <%= render_slot(@inner_block) %>
      </div>
    </.capsule>
    """
  end
end
```

## Assets Precompilation

The demo includes a `mix assets.deploy` alias that:
1. Builds StyleCapsule files (`mix style_capsule.build`)
2. Runs Phoenix asset digest (`mix phx.digest`)

To use:
```bash
cd examples/phoenix_demo
mix assets.deploy
```

This will:

- Generate capsule CSS files under `priv/static/capsules`
- Allow the `FileCachedCard` component to load its styles via
  `<link rel="stylesheet" href="/capsules/capsule-<id>.css">` in addition to inline styles

This is useful for production deployments where you want file-cached styles to be precompiled, digested, and served via the static asset pipeline.

