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
  - Demonstrated in: `RootSelectorExample`
  - Usage: `<.capsule module={__MODULE__}>...</.capsule>`

## Components

- **`Card`** - Basic card with `:patch` strategy and `:none` caching
- **`Button`** - Button variants with `:time` caching
- **`AdminPanel`** - Admin namespace with `:nesting` strategy and `:host` selector
- **`FileCachedCard`** - File-based caching example (writes CSS files to `priv/static/capsules` and registers `<link rel="stylesheet" href="/capsules/...">`)
- **`RootSelectorExample`** - Demonstrates `:host` selector and `capsule/1` helper

## Integration

The app integrates StyleCapsule by:

1. Adding `{:style_capsule, path: "../../style_capsule"}` to `mix.exs`
2. Registering styles in components using `StyleCapsule.Phoenix.register_inline/3`
3. Rendering styles in `lib/phoenix_demo_web/components/layouts/root.html.heex`:
   ```elixir
   <%= raw StyleCapsule.Phoenix.render_styles(namespace: :app) %>
   <%= raw StyleCapsule.Phoenix.render_styles(namespace: :admin) %>
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

