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
    {:style_capsule, "~> 0.5.0"}
  ]
end
```

For Phoenix LiveView support, also ensure you have:

```elixir
{:phoenix_live_view, "~> 0.20"}
```

## Usage

### Phoenix LiveView Components

```elixir
defmodule MyAppWeb.Components.Card do
  use Phoenix.Component
  use StyleCapsule.Component

  @component_styles """
  .root { 
    padding: 1rem;
    border: 1px solid #ccc;
  }
  .heading { 
    font-size: 1.5rem;
    color: #333;
  }
  .heading:hover { 
    opacity: 0.8;
  }
  """

  def card(assigns) do
    ~H"""
    <.capsule module={__MODULE__}>
      <div class="root">
        <h2 class="heading"><%= render_slot(@inner_block) %></h2>
      </div>
    </.capsule>
    """
  end
end
```

CSS is automatically scoped with `[data-capsule="..."]` attributes and content is wrapped in a scoped element.

### Standalone Usage

```elixir
css = ".section { color: red; }"
capsule_id = StyleCapsule.capsule_id(MyComponent)
scoped_css = StyleCapsule.scope_css(css, capsule_id)
# => "[data-capsule=\"abc123\"] .section { color: red; }"

html = """
<div class="section">Hello from standalone</div>
"""

wrapped_html = StyleCapsule.wrap(html, capsule_id, tag: :section, attrs: [class: "wrapper"])

# => <section data-capsule="abc123" class="wrapper"><div class="section">Hello from standalone</div></section>
```

For a complete, runnable script, see `examples/standalone/example.exs`.

## CSS Scoping Strategies

StyleCapsule supports two CSS scoping strategies:

1. **Selector Patching (default)**: Adds `[data-capsule="..."]` prefix to each selector
   - Better browser support (all modern browsers)
   - Output: `[data-capsule="abc123"] .section { color: red; }`

2. **CSS Nesting (optional)**: Wraps entire CSS in `[data-capsule="..."] { ... }`
   - More performant (no CSS parsing needed)
   - Requires CSS nesting support (Chrome 112+, Firefox 117+, Safari 16.5+)
   - Output: `[data-capsule="abc123"] { .section { color: red; } }`

### Configuration

```elixir
defmodule MyAppWeb.Components.Card do
  use Phoenix.Component
  use StyleCapsule.Component, 
    scoping_strategy: :nesting,  # Use CSS nesting
    namespace: :admin,
    cache_strategy: :time,
    cache_ttl: 3600
end
```

## Caching Strategies

### No Caching (Default)

```elixir
use StyleCapsule.Component  # No cache strategy set (default: :none)
```

### Time-Based Caching

```elixir
use StyleCapsule.Component, 
  cache_strategy: :time, 
  cache_ttl: 3600  # Cache for 1 hour (in seconds)
```

### File-Based Caching (HTTP Caching)

```elixir
use StyleCapsule.Component, cache_strategy: :file
```

Then run the build task:

```bash
mix style_capsule.build
```

Files are automatically built during `mix assets.deploy`.

## Phoenix example

There is no bundled Phoenix app in this repo, but you can try StyleCapsule in any Phoenix 1.7+ app.

### 1. Add dependency

In your Phoenix app `mix.exs`:

```elixir
def deps do
  [
    {:phoenix, \"~> 1.7\"},
    {:phoenix_live_view, \"~> 0.20\"},
    {:style_capsule, path: \"../style_capsule.ex/style_capsule\"}
  ]
end
```

Then run:

```bash
mix deps.get
```

### 2. Define a component

```elixir
defmodule MyAppWeb.Components.Card do
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :app

  @component_styles \"\"\"
  .root { padding: 1rem; border: 1px solid #ccc; }
  .heading { font-weight: bold; }
  \"\"\"

  def card(assigns) do
    ~H\"\"\"
    <.capsule module={__MODULE__}>
      <div class=\"root\">
        <h2 class=\"heading\"><%= render_slot(@inner_block) %></h2>
      </div>
    </.capsule>
    \"\"\"
  end
end
```

### 3. Render styles in your layout

In `root.html.heex` (or another layout):

```elixir
<head>
  <%= raw StyleCapsule.Phoenix.render_styles(namespace: :app) %>
</head>
```

### 4. Use the component

In a LiveView or template:

```elixir
<.card>
  Hello from StyleCapsule
</.card>
```

Run your Phoenix app with:

```bash
mix phx.server
```

You should see scoped styles applied using `[data-capsule=\"...\"]` attributes with no JavaScript required.

## Example Application

A complete Phoenix example application is available in `examples/phoenix_demo/`. It demonstrates:

- Component-scoped CSS with `StyleCapsule.Component`
- Multiple caching strategies (`:none`, `:time`, `:file`)
- Namespace isolation
- Integration with Phoenix LiveView

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
