defmodule PhoenixDemoWeb.PageLive do
  use PhoenixDemoWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="py-8">
      <h1 class="text-3xl font-bold mb-6">StyleCapsule Demo</h1>

      <div class="space-y-6">
        <PhoenixDemoWeb.Components.Card.card heading="Welcome">
          <p>This is a card component with scoped CSS using StyleCapsule.</p>
          <p>The styles are automatically scoped to this component instance.</p>
        </PhoenixDemoWeb.Components.Card.card>

        <PhoenixDemoWeb.Components.Card.card heading="Buttons">
          <div class="space-x-4">
            <PhoenixDemoWeb.Components.Button.button variant="primary">
              Primary Button
            </PhoenixDemoWeb.Components.Button.button>
            <PhoenixDemoWeb.Components.Button.button variant="secondary">
              Secondary Button
            </PhoenixDemoWeb.Components.Button.button>
          </div>
        </PhoenixDemoWeb.Components.Card.card>

        <PhoenixDemoWeb.Components.Card.card>
          <p>Check the page source to see the scoped CSS in the <code>&lt;head&gt;</code> section.</p>
          <p>Each component has a unique <code>data-capsule</code> attribute for CSS scoping.</p>
        </PhoenixDemoWeb.Components.Card.card>

        <PhoenixDemoWeb.Components.AdminPanel.admin_panel title="Admin Namespace Example">
          <p>This component uses the <code>:admin</code> namespace and <code>:nesting</code> strategy.</p>
          <p>Notice how the styles are wrapped in <code>[data-capsule="..."] { ... }</code> instead of prefixing each selector.</p>
        </PhoenixDemoWeb.Components.AdminPanel.admin_panel>

        <PhoenixDemoWeb.Components.FileCachedCard.file_cached_card heading="File Caching Example">
          <p>This component uses <code>cache_strategy: :file</code>.</p>
          <p>To see file-based caching in action, run <code>mix style_capsule.build</code> in the main library directory.</p>
          <p>Files will be written to <code>priv/static/capsules/</code> for HTTP caching.</p>
        </PhoenixDemoWeb.Components.FileCachedCard.file_cached_card>

        <PhoenixDemoWeb.Components.RootSelectorExample.root_selector_example
          label="Root Selector"
          value=":host"
          description="This component demonstrates the :host selector pattern, which targets only the root wrapper element."
        />
      </div>
    </div>
    """
  end
end

