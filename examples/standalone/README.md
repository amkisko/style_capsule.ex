# Standalone StyleCapsule Example

This example demonstrates how to use `style_capsule` **without Phoenix** in a plain Elixir context.

## What it shows

- Generating a capsule ID
- Scoping CSS with `StyleCapsule.scope_css/3`
- Wrapping HTML with `StyleCapsule.wrap/3`
- Using the in-memory cache (`StyleCapsule.Cache`) and centralized config (`StyleCapsule.Config`)

## Running the example

**Important:** This example must be run from the **project root** (not from the `examples/standalone` directory) because it needs access to the compiled `style_capsule` library.

From the project root:

```bash
cd /Users/amkisko/workflow/github/amkisko/style_capsule.ex
mix deps.get  # This will fetch plug and plug_cowboy (optional dependencies)
mix compile
mix run examples/standalone/example.exs
```

The example will:
1. Start a simple web server on **http://localhost:4000**
2. Display all the CSS and HTML examples in a beautiful web interface
3. Show a live demo of the rendered component with scoped CSS applied

**Open your browser** and visit **http://localhost:4000** to see:
- Original CSS
- Scoped CSS (with `[data-capsule]` attributes)
- Original HTML
- Wrapped HTML (with `data-capsule` attribute)
- **Live demo** (rendered component with styles applied)
- Cached CSS output
- Configuration values

Press `Ctrl+C` to stop the server.

**Note:** The example uses `Mix.install/1` to install `plug` and `plug_cowboy` at runtime, so it works standalone without requiring these dependencies in the main project.

You should see output similar to:

- Original CSS
- Scoped CSS with `[data-capsule="..."]` selectors
- Wrapped HTML with a `data-capsule` attribute
- Cached scoped CSS (time-based cache)

This example is framework-agnostic and can be adapted to:

- Simple Plug applications
- EEx templates
- Email rendering pipelines
- Any other Elixir code that needs component-scoped CSS without Phoenix.
