defmodule PhoenixDemoWeb.FeaturesLive do
  @moduledoc """
  Features showcase page demonstrating all StyleCapsule capabilities.
  """
  use PhoenixDemoWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="py-12 px-4">
      <div class="max-w-6xl mx-auto">
        <PhoenixDemoWeb.Components.FeaturesIntro.features_intro
          title="StyleCapsule Features"
          description="Comprehensive demonstration of all capabilities including conditional namespace loading"
        />

        <section class="mb-16">
          <h2 class="text-2xl font-bold text-gray-900 mb-6">Conditional Namespace Loading</h2>
          <div class="bg-blue-50 border border-blue-200 rounded-lg p-6 mb-8">
            <h3 class="text-xl font-bold text-gray-900 mb-4">Page-Specific Stylesheets</h3>
            <p class="mb-4 text-gray-700">
              This page demonstrates conditional loading of namespaced CSS files. Each page can load only the stylesheets it needs:
            </p>
            <ul class="list-disc list-inside space-y-2 text-gray-700 mb-4">
              <li><strong>Home page</strong> loads only <code class="bg-blue-100 px-1 rounded">:home</code> namespace styles</li>
              <li><strong>Showcase page</strong> loads only <code class="bg-blue-100 px-1 rounded">:showcase</code> namespace styles</li>
              <li><strong>Features page</strong> loads only <code class="bg-blue-100 px-1 rounded">:features</code> namespace styles</li>
            </ul>
            <div class="bg-white rounded p-4 border border-blue-200">
              <h4 class="font-semibold text-gray-900 mb-2">How it works:</h4>
              <div class="bg-gray-900 text-gray-100 p-3 rounded text-sm font-mono overflow-x-auto">
                <div class="text-purple-300">&lt;%=</div>
                <div class="text-yellow-300">  namespace</div>
                <div class="text-green-300"> =</div>
                <div class="text-blue-300"> page_namespace(assigns)</div>
                <div class="text-purple-300"> %&gt;</div>
                <div class="text-purple-300">&lt;%=</div>
                <div class="text-yellow-300">  if</div>
                <div class="text-green-300"> namespace</div>
                <div class="text-yellow-300"> do</div>
                <div class="text-purple-300"> %&gt;</div>
                <div class="text-gray-400 pl-4">
                  &lt;%= raw StyleCapsule.Phoenix.render_precompiled_stylesheets(namespace: namespace) %&gt;
                </div>
                <div class="text-purple-300">&lt;%</div>
                <div class="text-yellow-300">  else</div>
                <div class="text-purple-300"> %&gt;</div>
                <div class="text-gray-400 pl-4">
                  &lt;%= raw StyleCapsule.Phoenix.render_precompiled_stylesheets() %&gt;
                </div>
                <div class="text-purple-300">&lt;%</div>
                <div class="text-yellow-300">  end</div>
                <div class="text-purple-300"> %&gt;</div>
              </div>
              <p class="text-sm text-gray-600 mt-3">
                Check the HTML source to see only the relevant <code class="bg-blue-100 px-1 rounded">&lt;link&gt;</code> tags for this page's namespace.
              </p>
            </div>
          </div>
        </section>

        <section class="mb-16">
          <h2 class="text-2xl font-bold text-gray-900 mb-6">Scoping Strategies</h2>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <PhoenixDemoWeb.Components.Card.card heading="Patch Strategy (Default)">
              <p class="mb-4">
                The patch strategy prefixes each CSS selector with <code class="bg-gray-100 px-1 rounded">[data-capsule="..."]</code>.
                This is the most compatible approach, working in all browsers.
              </p>
              <div class="bg-gray-100 p-4 rounded text-sm font-mono">
                <div class="text-gray-600">Input:</div>
                <div>{".button { color: blue; }"}</div>
                <div class="text-gray-600 mt-2">Output:</div>
                <div>{"[data-capsule=\"abc123\"] .button { color: blue; }"}</div>
              </div>
            </PhoenixDemoWeb.Components.Card.card>

            <PhoenixDemoWeb.Components.AdminPanel.admin_panel title="Nesting Strategy">
              <p class="mb-4">
                The nesting strategy wraps all styles in a single <code class="bg-gray-100 px-1 rounded">{"[data-capsule=\"...\"] { ... }"}</code> block.
                This is ~3.4x faster but requires modern browser support for CSS Nesting.
              </p>
              <div class="bg-gray-100 p-4 rounded text-sm font-mono">
                <div class="text-gray-600">Input:</div>
                <div>{".button { color: blue; }"}</div>
                <div class="text-gray-600 mt-2">Output:</div>
                <div>{"[data-capsule=\"abc123\"] \\{"}</div>
                <div class="pl-4">{".button { color: blue; }"}</div>
                <div>{"\\}"}</div>
              </div>
            </PhoenixDemoWeb.Components.AdminPanel.admin_panel>
          </div>
        </section>

        <section class="mb-16">
          <h2 class="text-2xl font-bold text-gray-900 mb-6">Cache Strategies</h2>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
            <PhoenixDemoWeb.Components.Card.card heading="None (Default)">
              <p class="mb-2">Styles are registered inline on every render.</p>
              <code class="text-xs bg-gray-100 px-2 py-1 rounded">cache_strategy: :none</code>
            </PhoenixDemoWeb.Components.Card.card>

            <PhoenixDemoWeb.Components.Card.card heading="Time-based">
              <p class="mb-2">Styles are cached with a time-based expiration.</p>
              <code class="text-xs bg-gray-100 px-2 py-1 rounded">cache_strategy: :time</code>
              <p class="text-sm text-gray-600 mt-2">Used by: Gradient Buttons</p>
            </PhoenixDemoWeb.Components.Card.card>

            <PhoenixDemoWeb.Components.FileCachedCard.file_cached_card heading="File-based">
              <p class="mb-2">Styles are written to static files for HTTP caching.</p>
              <code class="text-xs bg-gray-100 px-2 py-1 rounded">cache_strategy: :file</code>
              <p class="text-sm text-gray-600 mt-2">Used by: Pricing Tables, Analytics Charts</p>
            </PhoenixDemoWeb.Components.FileCachedCard.file_cached_card>
          </div>

          <div class="bg-blue-50 border border-blue-200 rounded-lg p-6">
            <h3 class="text-xl font-bold text-gray-900 mb-4">File Caching Strategy</h3>
            <p class="mb-4 text-gray-700">
              File-based caching writes CSS to static files that can be served via HTTP with proper caching headers.
              This is ideal for production deployments where you want maximum performance and CDN compatibility.
            </p>

            <div class="space-y-4">
              <div>
                <h4 class="font-semibold text-gray-900 mb-2">How it works:</h4>
                <ol class="list-decimal list-inside space-y-2 text-gray-700">
                  <li>Components with <code class="bg-blue-100 px-1 rounded">cache_strategy: :file</code> register their styles during compilation</li>
                  <li>Run <code class="bg-blue-100 px-1 rounded">mix style_capsule.build</code> to generate CSS files</li>
                  <li>Files are written to <code class="bg-blue-100 px-1 rounded">priv/static/capsules/</code> organized by namespace</li>
                  <li>Files are served via <code class="bg-blue-100 px-1 rounded">StyleCapsule.Phoenix.render_precompiled_stylesheets()</code> in your layout</li>
                  <li>Browsers can cache these files with standard HTTP caching headers</li>
                </ol>
              </div>

              <div>
                <h4 class="font-semibold text-gray-900 mb-2">Benefits:</h4>
                <ul class="list-disc list-inside space-y-1 text-gray-700">
                  <li>HTTP caching support for better performance</li>
                  <li>CDN-friendly static asset delivery</li>
                  <li>Reduced server load (styles computed once at build time)</li>
                  <li>Namespace isolation (separate files per namespace)</li>
                </ul>
              </div>

              <div class="bg-white rounded p-4 border border-blue-200">
                <h4 class="font-semibold text-gray-900 mb-2">Try it:</h4>
                <div class="space-y-2 text-sm">
                  <p class="text-gray-700">
                    <strong>1. Build the files:</strong>
                  </p>
                  <div class="bg-gray-900 text-gray-100 p-3 rounded font-mono text-xs">
                    <div class="text-purple-300">cd</div> <div class="text-green-300">../../style_capsule</div>
                    <div class="text-purple-300">mix</div> <div class="text-yellow-300">style_capsule.build</div>
                  </div>
                  <p class="text-gray-700 mt-3">
                    <strong>2. View file-cached components:</strong>
                  </p>
                  <ul class="list-disc list-inside text-gray-700 ml-2">
                    <li><a href="/business" class="text-blue-600 hover:underline">Business Cases</a> - Pricing Tables (file-cached)</li>
                    <li><a href="/namespaces" class="text-blue-600 hover:underline">Namespaces</a> - Analytics Charts (file-cached)</li>
                  </ul>
                  <p class="text-gray-700 mt-3">
                    <strong>3. Check the generated files:</strong>
                  </p>
                  <div class="bg-gray-900 text-gray-100 p-3 rounded font-mono text-xs">
                    <div class="text-purple-300">ls</div> <div class="text-green-300">../../style_capsule/priv/static/capsules/</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        <section class="mb-16">
          <h2 class="text-2xl font-bold text-gray-900 mb-6">Namespaces</h2>
          <div class="bg-gray-100 rounded-lg p-6">
            <p class="mb-4">
              Namespaces allow you to isolate styles into separate registries. This is useful for:
            </p>
            <ul class="list-disc list-inside space-y-2 mb-4">
              <li>Separating admin styles from public styles</li>
              <li>Organizing styles by feature area (e-commerce, SaaS, dashboard)</li>
              <li>Preventing style conflicts between different parts of your application</li>
            </ul>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mt-6">
              <div class="bg-white p-4 rounded">
                <div class="font-semibold mb-2">:app (Default)</div>
                <div class="text-sm text-gray-600">General application components</div>
                <code class="text-xs bg-gray-100 px-2 py-1 rounded block mt-2">namespace: :app</code>
              </div>
              <div class="bg-white p-4 rounded">
                <div class="font-semibold mb-2">:admin</div>
                <div class="text-sm text-gray-600">Admin panel components</div>
                <code class="text-xs bg-gray-100 px-2 py-1 rounded block mt-2">namespace: :admin</code>
              </div>
              <div class="bg-white p-4 rounded">
                <div class="font-semibold mb-2">Custom Namespaces</div>
                <div class="text-sm text-gray-600">:ecommerce, :saas, :dashboard, :marketing, :blog, :support, :analytics, :settings</div>
                <code class="text-xs bg-gray-100 px-2 py-1 rounded block mt-2">namespace: :custom</code>
              </div>
            </div>
            <div class="mt-6">
              <a href="/namespaces" class="text-blue-600 hover:underline font-semibold">
                → View complete namespace showcase
              </a>
            </div>
          </div>
        </section>

        <section class="mb-16">
          <h2 class="text-2xl font-bold text-gray-900 mb-6">Component Patterns</h2>
          <div class="space-y-6">
            <PhoenixDemoWeb.Components.Card.card heading="Module Attribute Styles">
              <p class="mb-2">
                Define styles at compile-time using the <code class="bg-gray-100 px-1 rounded">@component_styles</code> module attribute.
                This is the recommended approach for most components.
              </p>
              <div class="bg-gray-900 text-gray-100 p-4 rounded text-sm font-mono overflow-x-auto">
                <div class="text-purple-300">@component_styles</div>
                <div class="text-yellow-300">"""</div>
                <div class="text-green-300">{".root { padding: 1rem; }"}</div>
                <div class="text-yellow-300">"""</div>
              </div>
            </PhoenixDemoWeb.Components.Card.card>

            <PhoenixDemoWeb.Components.Card.card heading="Dynamic Tag Support">
              <p class="mb-2">
                The <code class="bg-gray-100 px-1 rounded">capsule/1</code> component supports custom HTML tags:
              </p>
              <div class="bg-gray-900 text-gray-100 p-4 rounded text-sm font-mono overflow-x-auto">
                <div class="text-blue-300">&lt;.capsule module={__MODULE__} tag={:section}&gt;</div>
                <div class="text-gray-400 pl-4">...</div>
                <div class="text-blue-300">&lt;/.capsule&gt;</div>
              </div>
            </PhoenixDemoWeb.Components.Card.card>

            <PhoenixDemoWeb.Components.RootSelectorExample.root_selector_example
              label="Root Selector Pattern"
              value=":host"
              description="Use the :host selector to target only the root wrapper element, useful for container-level styles."
            />
          </div>
        </section>
      </div>
    </div>
    """
  end
end
