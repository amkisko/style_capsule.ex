defmodule PhoenixDemoWeb.PageLive do
  use PhoenixDemoWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="py-12 px-4">
      <div class="max-w-6xl mx-auto">
        <PhoenixDemoWeb.Components.HomeHero.home_hero
          title="StyleCapsule Demo"
          subtitle="Attribute-based CSS scoping for Phoenix components"
        >
          Namespace: :home
        </PhoenixDemoWeb.Components.HomeHero.home_hero>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-12">
          <PhoenixDemoWeb.Components.Card.card heading="Welcome">
            <p>This is a card component with scoped CSS using StyleCapsule.</p>
            <p>The styles are automatically scoped to this component instance using <code>data-capsule</code> attributes.</p>
          </PhoenixDemoWeb.Components.Card.card>

          <PhoenixDemoWeb.Components.Card.card heading="Quick Start">
            <p>Explore the demo pages to see StyleCapsule in action:</p>
            <ul class="list-disc list-inside space-y-1 mt-2">
              <li><a href="/showcase" class="text-blue-600 hover:underline">Showcase</a> - Modern CSS effects and animations</li>
              <li><a href="/business" class="text-blue-600 hover:underline">Business Cases</a> - Real-world components</li>
              <li><a href="/features" class="text-blue-600 hover:underline">Features</a> - All capabilities</li>
              <li><a href="/namespaces" class="text-blue-600 hover:underline">Namespaces</a> - Style isolation showcase</li>
            </ul>
          </PhoenixDemoWeb.Components.Card.card>
        </div>

        <div class="space-y-6">
          <PhoenixDemoWeb.Components.Card.card heading="Basic Components">
            <div class="space-y-4">
              <div>
                <h3 class="font-semibold mb-2">Buttons</h3>
                <div class="space-x-4">
                  <PhoenixDemoWeb.Components.Button.button variant="primary">
                    Primary Button
                  </PhoenixDemoWeb.Components.Button.button>
                  <PhoenixDemoWeb.Components.Button.button variant="secondary">
                    Secondary Button
                  </PhoenixDemoWeb.Components.Button.button>
                </div>
              </div>
            </div>
          </PhoenixDemoWeb.Components.Card.card>

          <PhoenixDemoWeb.Components.AdminPanel.admin_panel title="Admin Namespace Example">
            <p>This component uses the <code>:admin</code> namespace and <code>:nesting</code> strategy.</p>
            <p>Notice how the styles are wrapped in <code>{"[data-capsule=\"...\"] { ... }"}</code> instead of prefixing each selector.</p>
            <p class="text-sm text-gray-600 mt-2">This is ~3.4x faster than the patch strategy but requires modern browser support.</p>
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
    </div>
    """
  end
end
