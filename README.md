# style_capsule

[![Hex.pm](https://img.shields.io/hexpm/v/style_capsule)](https://hex.pm/packages/style_capsule) [![Hex.pm](https://img.shields.io/hexpm/dt/style_capsule)](https://hex.pm/packages/style_capsule) [![Test Status](https://github.com/amkisko/style_capsule.ex/actions/workflows/test.yml/badge.svg)](https://github.com/amkisko/style_capsule.ex/actions/workflows/test.yml)

CSS scoping extension for Elixir/Phoenix components. Provides attribute-based style encapsulation for Phoenix LiveView components and standalone Elixir applications to prevent style leakage between components. Works with Phoenix and can be used standalone in other Elixir frameworks or plain Elixir scripts. Includes configurable caching strategies for optimal performance.

**Migrating from the Ruby version?** See [MIGRATION_FROM_RUBY.md](MIGRATION_FROM_RUBY.md) for a detailed guide.

## Features

- **Attribute-based CSS scoping** (no class name renaming)
- **Phoenix LiveView support** with client-side hook injection
- **HEEx function component support** with automatic integration
- **Per-component-type scope IDs** (shared across instances)
- **CSS Nesting support** (optional, ~3.4x faster than patch strategy, requires modern browsers)
- **Stylesheet registry** with namespace support
- **Multiple cache strategies**: none, time-based, custom, and file-based (HTTP caching)
- **Comprehensive instrumentation** via Telemetry for monitoring and metrics
- **Fallback directory support** for read-only filesystems (e.g., Docker containers)
- **Security protections**: path traversal protection, input validation, size limits

## Installation

Add `style_capsule` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:style_capsule, "~> 0.7.0"}
  ]
end
```

For Phoenix LiveView support, also ensure you have:

```elixir
{:phoenix_live_view, "~> 0.20"}
```

## Quick Start

### 1. Add Style Tags to Your Layout

In your Phoenix app's root layout (`lib/your_app_web/components/layouts/root.html.heex`):

```heex
<head>
  <!-- Precompiled stylesheets (for file-based caching) -->
  <%= raw StyleCapsule.Phoenix.render_precompiled_stylesheets() %>
</head>
<body>
  <!-- Your content -->
  <%= @inner_content %>
  
  <!-- Runtime styles (for :none and :time cache strategies) -->
  <%= raw StyleCapsule.Phoenix.render_all_runtime_styles() %>
</body>
```

For page-specific stylesheets, you can conditionally load namespaces:

```heex
<head>
  <% namespace = page_namespace(assigns) %>
  <%= if namespace do %>
    <%= raw StyleCapsule.Phoenix.render_precompiled_stylesheets(namespace: namespace) %>
  <% end %>
</head>
```

### 2. Create a Component with Styles

```elixir
defmodule MyAppWeb.Components.Card do
  use Phoenix.Component
  use StyleCapsule.Component

  @component_styles """
  .card { 
    padding: 1rem;
    border: 1px solid #ccc;
    border-radius: 0.5rem;
  }
  .title { 
    font-size: 1.5rem;
    font-weight: bold;
  }
  """

  def card(assigns) do
    ~H"""
    <.capsule module={__MODULE__}>
      <div class="card">
        <h2 class="title"><%= render_slot(@inner_block) %></h2>
      </div>
    </.capsule>
    """
  end
end
```

### 3. Use in LiveView

```elixir
defmodule MyAppWeb.PageLive do
  use MyAppWeb, :live_view

  def render(assigns) do
    ~H"""
    <div>
      <.card>Hello from StyleCapsule</.card>
    </div>
    """
  end
end
```

That's it! Styles are automatically scoped and registered. No JavaScript required.

## Usage

StyleCapsule automatically scopes your CSS with `[data-capsule="..."]` attributes and wraps your component content in a scoped element. Each component type gets a unique scope ID that's shared across all instances, ensuring styles don't leak between components.

You can customize the wrapper tag by passing `tag` to the capsule component:

```elixir
<.capsule module={__MODULE__} tag={:section}>
  <!-- your content -->
</.capsule>
```

### Phlex Components

For Phlex components, use `StyleCapsule.PhlexComponent`:

```elixir
defmodule MyAppWeb.Components.Card do
  use StyleCapsule.PhlexComponent

  @component_styles """
  .card { padding: 1rem; border: 1px solid #ccc; }
  .heading { font-size: 1.5rem; color: #333; }
  """

  defp render_template(assigns, attrs, state) do
    div(state, attrs, fn state ->
      h2(state, [class: "heading"], "Card Title")
    end)
  end
end
```

PhlexComponent automatically registers styles at compile time, adds `data-capsule` attributes, and generates `style_capsule_spec/0` for discovery.

### Standalone Usage

StyleCapsule can be used outside of Phoenix:

```elixir
css = ".section { color: red; }"
capsule_id = StyleCapsule.capsule_id(MyComponent)
scoped_css = StyleCapsule.scope_css(css, capsule_id)
# => "[data-capsule="abc123"] .section { color: red; }"

html = """
<div class="section">Hello from standalone</div>
"""

wrapped_html = StyleCapsule.wrap(html, capsule_id, tag: :section, attrs: [class: "wrapper"])
# => <section data-capsule="abc123" class="wrapper"><div class="section">Hello from standalone</div></section>
```

For a complete, runnable script, see `examples/standalone/example.exs`.

## CSS Scoping Strategies

StyleCapsule supports two CSS scoping strategies:

1. **Selector Patching (default)**: Adds `[data-capsule="..."]` prefix to each selector. Works in all modern browsers. Output: `[data-capsule="abc123"] .section { color: red; }`

2. **CSS Nesting (optional)**: Wraps entire CSS in `[data-capsule="..."] { ... }`. More performant (~3.4x faster) but requires CSS nesting support (Chrome 112+, Firefox 117+, Safari 16.5+). Output: `[data-capsule="abc123"] { .section { color: red; } }`

Configure the strategy when using the component:

```elixir
use StyleCapsule.Component, 
  strategy: :nesting,  # Use CSS nesting
  namespace: :admin,
  cache_strategy: :time,
  cache_ttl: 3600
```

## Caching Strategies

StyleCapsule offers multiple caching strategies to optimize performance:

- **No Caching (default)**: Styles are registered inline on every render. Use for development or when styles change frequently.

- **Time-Based Caching**: Cache styles with a time-based expiration. Useful for production when styles are relatively stable.

```elixir
use StyleCapsule.Component, 
  cache_strategy: :time, 
  cache_ttl: 3600  # Cache for 1 hour (in seconds)
```

- **File-Based Caching**: Styles are written to static files for HTTP caching. Best for production performance. Run `mix style_capsule.build` to generate CSS files, which are automatically built during `mix assets.deploy`.

```elixir
use StyleCapsule.Component, cache_strategy: :file
```

## Example Application

A complete Phoenix example application is available in `examples/phoenix_demo/`. It demonstrates component-scoped CSS, multiple caching strategies, namespace isolation, and Phoenix LiveView integration.

To run the example:

```bash
cd examples/phoenix_demo
mix deps.get
mix phx.server
```

Then visit http://localhost:4000 to see StyleCapsule in action.

## Development

```bash
# Install dependencies
mix deps.get

# Run tests
mix test

# Run all quality checks
mix quality

# Format code
mix format

# Run code analysis
mix credo --strict

# Run type checking
mix dialyzer
```

### Benchmarks

Performance benchmarks are available to measure and track StyleCapsule operations:

```bash
# Run all benchmarks
mix style_capsule.bench

# Run specific benchmark suite
mix style_capsule.bench css_processor
mix style_capsule.bench id_generation
mix style_capsule.bench cache
mix style_capsule.bench file_writer
```

Benchmarks generate HTML reports in `benchmarks/output/` with detailed performance metrics. See [benchmarks/README.md](benchmarks/README.md) for more information.

#### Performance Characteristics

Based on benchmark results (Apple M3 Max, Elixir 1.18.4):

- **ID Generation**: ~0.64 μs per operation (1.5M+ ops/sec)
- **CSS Nesting Strategy**: ~1.40 μs per operation (713K+ ops/sec) - **3.4x faster than patch**
- **CSS Patch Strategy**: ~4.80 μs per operation (208K+ ops/sec)
- **Cache Hit**: ~1.71 μs per operation (583K+ ops/sec)
- **File Write**: ~85 μs per operation (I/O bound, filesystem dependent)
- **Memory Usage**: 2-5 KB per operation

All operations are highly optimized and suitable for production use. The nesting strategy provides significant performance benefits when browser support is available.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/amkisko/style_capsule.ex

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Requirements

- Elixir >= 1.18
- Phoenix >= 1.7 (optional, for Phoenix integration)
- Phoenix LiveView >= 0.20 (optional, for LiveView integration)

## License

The library is available as open source under the terms of the [MIT License](LICENSE.md).
