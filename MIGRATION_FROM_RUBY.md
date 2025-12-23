# Migration Guide: style_capsule.rb to style_capsule.ex

This guide helps you migrate from the Ruby `style_capsule` gem to the Elixir `style_capsule` library.

## Overview

Both libraries provide attribute-based CSS scoping for component-scoped styles, but there are some differences in API and integration patterns due to the different ecosystems (Rails vs Phoenix).

## Core Concepts

Both libraries share the same core concepts:
- **Capsule IDs**: Deterministic IDs generated from component modules
- **CSS Scoping**: Attribute-based scoping using `[data-capsule="..."]`
- **Namespaces**: Isolated style registries per namespace
- **Caching Strategies**: `:none`, `:time`, `:file`, and custom strategies

## API Mapping

### Component Integration

**Ruby (Rails/ViewComponent):**
```ruby
class CardComponent < ViewComponent::Base
  include StyleCapsule::Component

  def initialize(title:)
    @title = title
  end

  private

  def component_styles
    <<~CSS
      .root { padding: 1rem; }
      .heading { font-weight: bold; }
    CSS
  end
end
```

**Elixir (Phoenix):**
```elixir
defmodule MyAppWeb.Components.Card do
  use Phoenix.Component

  @component_styles """
  .root { padding: 1rem; }
  .heading { font-weight: bold; }
  """

  def card(assigns) do
    assigns = assign(assigns, :title, Map.get(assigns, :title))

    capsule_id = StyleCapsule.capsule_id(__MODULE__)
    StyleCapsule.Phoenix.register_inline(@component_styles, capsule_id, namespace: :app)

    assigns = assign(assigns, :capsule_id, capsule_id)

    ~H"""
    <div data-capsule={@capsule_id} class="root">
      <h2 class="heading"><%= @title %></h2>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
```

### Using the Component Helper

**Ruby:**
```ruby
# Automatically wrapped via include StyleCapsule::Component
```

**Elixir:**
```elixir
defmodule MyAppWeb.Components.Card do
  use Phoenix.Component
  import StyleCapsule.Component, only: [capsule: 1]

  def card(assigns) do
    capsule_id = StyleCapsule.capsule_id(__MODULE__)
    StyleCapsule.Phoenix.register_inline(@component_styles, capsule_id)

    ~H"""
    <.capsule module={__MODULE__}>
      <div class="root">
        <%= render_slot(@inner_block) %>
      </div>
    </.capsule>
    """
  end
end
```

### Rendering Styles in Layout

**Ruby (ERB):**
```erb
<%= StyleCapsule.render_styles(namespace: :app) %>
```

**Elixir (HEEx):**
```elixir
<%= raw StyleCapsule.Phoenix.render_styles(namespace: :app) %>
```

Note: In Elixir, you need `raw` because HEEx escapes HTML by default.

### CSS Scoping Strategies

Both libraries support `:patch` and `:nesting` strategies:

**Ruby:**
```ruby
StyleCapsule.scope_css(css, capsule_id, strategy: :patch)
StyleCapsule.scope_css(css, capsule_id, strategy: :nesting)
```

**Elixir:**
```elixir
StyleCapsule.scope_css(css, capsule_id, strategy: :patch)
StyleCapsule.scope_css(css, capsule_id, strategy: :nesting)
```

### Caching Strategies

**Ruby:**
```ruby
# Time-based caching
StyleCapsule.register_inline(css, capsule_id, 
  namespace: :app,
  cache_strategy: :time,
  cache_ttl: 3600
)

# File-based caching
StyleCapsule.register_inline(css, capsule_id,
  namespace: :app,
  cache_strategy: :file
)
```

**Elixir:**
```elixir
# Time-based caching
StyleCapsule.Phoenix.register_inline(css, capsule_id,
  namespace: :app,
  cache_strategy: :time,
  cache_ttl: 3600
)

# File-based caching
StyleCapsule.Phoenix.register_inline(css, capsule_id,
  namespace: :app,
  cache_strategy: :file
)
```

### Root Selector Pattern (`:host`)

Both libraries support the `:host` selector pattern:

**Ruby:**
```ruby
component_styles = <<~CSS
  :host {
    display: block;
    padding: 1rem;
  }
CSS
```

**Elixir:**
```elixir
@component_styles """
:host {
  display: block;
  padding: 1rem;
}
"""
```

The `:host` selector is automatically translated to `[data-capsule="..."]` in both libraries.

### Namespaces

**Ruby:**
```ruby
StyleCapsule.register_inline(css, capsule_id, namespace: :admin)
StyleCapsule.render_styles(namespace: :admin)
```

**Elixir:**
```elixir
StyleCapsule.Phoenix.register_inline(css, capsule_id, namespace: :admin)
StyleCapsule.Phoenix.render_styles(namespace: :admin)
```

### Mix Tasks / Rake Tasks

**Ruby:**
```bash
rake style_capsule:build
rake style_capsule:clear
rake style_capsule:verify
```

**Elixir:**
```bash
mix style_capsule.build
mix style_capsule.clear
mix style_capsule.verify
```

### Assets Precompilation

**Ruby (Rails):**
```ruby
# config/application.rb or Rakefile
Rake::Task["assets:precompile"].enhance do
  Rake::Task["style_capsule:build"].invoke
end
```

**Elixir (Phoenix):**
```elixir
# mix.exs
defp aliases do
  [
    "assets.deploy": [
      "style_capsule.build",
      "phx.digest"
    ]
  ]
end
```

## Key Differences

### 1. Template Syntax

- **Ruby**: ERB templates with `<% %>` and `<%= %>`
- **Elixir**: HEEx templates with `<%= %>` and `~H"""` sigils

### 2. Component Pattern

- **Ruby**: Uses `include StyleCapsule::Component` and automatic wrapping
- **Elixir**: Explicit registration and manual wrapping (or use `capsule/1` helper)

### 3. HTML Escaping

- **Ruby**: ERB automatically handles escaping
- **Elixir**: HEEx escapes by default, use `raw` for HTML output

### 4. LiveView Integration

- **Ruby**: Standard Rails request/response cycle
- **Elixir**: Phoenix LiveView with server-side rendering and optional client hooks

### 5. Registry Scope

- **Ruby**: Request-scoped via `ActionDispatch::Request`
- **Elixir**: Process-local via `Process.put/get` (works for both HTTP and LiveView)

## Migration Steps

1. **Install the library:**
   ```elixir
   # mix.exs
   {:style_capsule, "~> 0.5"}
   ```

2. **Convert components:**
   - Replace `include StyleCapsule::Component` with explicit registration
   - Convert ERB templates to HEEx
   - Update CSS to use `@component_styles` module attribute

3. **Update layouts:**
   - Replace ERB `<%= %>` with HEEx `<%= raw %>`
   - Update namespace rendering calls

4. **Update build tasks:**
   - Replace Rake tasks with Mix tasks
   - Update asset precompilation aliases

5. **Test thoroughly:**
   - Verify all components render correctly
   - Check that styles are scoped properly
   - Test caching strategies
   - Verify namespace isolation

## Example: Full Component Migration

**Before (Ruby):**
```ruby
class CardComponent < ViewComponent::Base
  include StyleCapsule::Component

  def initialize(title:, variant: :default)
    @title = title
    @variant = variant
  end

  private

  def component_styles
    <<~CSS
      .root { padding: 1rem; border: 1px solid #ccc; }
      .root.primary { border-color: blue; }
      .heading { font-weight: bold; }
    CSS
  end
end
```

**After (Elixir):**
```elixir
defmodule MyAppWeb.Components.Card do
  use Phoenix.Component

  @component_styles """
  .root { padding: 1rem; border: 1px solid #ccc; }
  .root.primary { border-color: blue; }
  .heading { font-weight: bold; }
  """

  def card(assigns) do
    assigns = assign(assigns, :title, Map.get(assigns, :title))
    assigns = assign(assigns, :variant, Map.get(assigns, :variant, :default))

    capsule_id = StyleCapsule.capsule_id(__MODULE__)
    StyleCapsule.Phoenix.register_inline(@component_styles, capsule_id, namespace: :app)

    assigns = assign(assigns, :capsule_id, capsule_id)

    ~H"""
    <div data-capsule={@capsule_id} class={"root #{@variant}"}>
      <h2 class="heading"><%= @title %></h2>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
```

## Need Help?

- Check the [main README](README.md) for detailed usage examples
- See the [example Phoenix app](examples/phoenix_demo/README.md) for a complete working example
- Open an issue on GitHub if you encounter migration issues

