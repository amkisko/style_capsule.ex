defmodule PhoenixDemoWeb.NamespacesLive do
  @moduledoc """
  Namespaces showcase page demonstrating namespace isolation.
  """
  use PhoenixDemoWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="py-12 px-4 bg-gray-50">
      <div class="max-w-7xl mx-auto">
        <h1 class="text-4xl font-bold text-gray-900 mb-2">Namespace Isolation</h1>
        <p class="text-gray-600 mb-12">
          StyleCapsule namespaces allow you to isolate styles into separate registries.
          Each namespace maintains its own style registry, preventing conflicts between different parts of your application.
        </p>

        <section class="mb-16">
          <h2 class="text-2xl font-bold text-gray-900 mb-6">:marketing Namespace</h2>
          <p class="text-gray-600 mb-4">
            Marketing components use the <code class="bg-gray-200 px-1 rounded">:marketing</code> namespace with <code class="bg-gray-200 px-1 rounded">strategy: :nesting</code>.
          </p>
          <PhoenixDemoWeb.Components.MarketingBanner.marketing_banner
            title="Special Offer: 50% Off"
            subtitle="Limited time only! Upgrade your plan today and save big."
            cta_text="Claim Offer"
          />
        </section>

        <section class="mb-16">
          <h2 class="text-2xl font-bold text-gray-900 mb-6">:blog Namespace</h2>
          <p class="text-gray-600 mb-4">
            Blog components use the <code class="bg-gray-200 px-1 rounded">:blog</code> namespace with <code class="bg-gray-200 px-1 rounded">cache_strategy: :time</code>.
          </p>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <PhoenixDemoWeb.Components.BlogPostCard.blog_post_card
              title="Getting Started with StyleCapsule"
              excerpt="Learn how to use attribute-based CSS scoping in your Phoenix applications."
              author="Author One"
              date="2024-01-15"
              tag="Tutorial"
            />
            <PhoenixDemoWeb.Components.BlogPostCard.blog_post_card
              title="Advanced CSS Scoping Patterns"
              excerpt="Explore advanced techniques for component-scoped styles and namespace isolation."
              author="Author Two"
              date="2024-01-20"
              tag="Advanced"
            />
            <PhoenixDemoWeb.Components.BlogPostCard.blog_post_card
              title="Performance Optimization Tips"
              excerpt="Discover how to optimize your CSS delivery with StyleCapsule's caching strategies."
              author="Author Three"
              date="2024-01-25"
              tag="Performance"
            />
          </div>
        </section>

        <section class="mb-16">
          <h2 class="text-2xl font-bold text-gray-900 mb-6">:support Namespace</h2>
          <p class="text-gray-600 mb-4">
            Support components use the <code class="bg-gray-200 px-1 rounded">:support</code> namespace with <code class="bg-gray-200 px-1 rounded">strategy: :patch</code>.
          </p>
          <div class="max-w-3xl">
            <PhoenixDemoWeb.Components.SupportTicket.support_ticket
              id="SUP-1234"
              title="Payment processing issue"
              description="Customer reports that payment is not being processed correctly. Need to investigate the payment gateway integration."
              status="in-progress"
              priority="high"
              assignee="Support Team"
            />
            <PhoenixDemoWeb.Components.SupportTicket.support_ticket
              id="SUP-1235"
              title="Feature request: Dark mode"
              description="User requests dark mode support for the application. This is a popular feature request."
              status="open"
              priority="medium"
            />
            <PhoenixDemoWeb.Components.SupportTicket.support_ticket
              id="SUP-1236"
              title="Account verification question"
              description="User has a question about the account verification process. Standard support ticket."
              status="resolved"
              priority="low"
              assignee="Support Team"
            />
          </div>
        </section>

        <section class="mb-16">
          <h2 class="text-2xl font-bold text-gray-900 mb-6">:analytics Namespace</h2>
          <p class="text-gray-600 mb-4">
            Analytics components use the <code class="bg-gray-200 px-1 rounded">:analytics</code> namespace with <code class="bg-gray-200 px-1 rounded">cache_strategy: :file</code>.
          </p>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <PhoenixDemoWeb.Components.AnalyticsChart.analytics_chart
              title="User Growth"
              period="Last 7 days"
            />
            <PhoenixDemoWeb.Components.AnalyticsChart.analytics_chart
              title="Revenue Trends"
              period="Last 30 days"
            />
          </div>
        </section>

        <section class="mb-16">
          <h2 class="text-2xl font-bold text-gray-900 mb-6">:settings Namespace</h2>
          <p class="text-gray-600 mb-4">
            Settings components use the <code class="bg-gray-200 px-1 rounded">:settings</code> namespace with <code class="bg-gray-200 px-1 rounded">strategy: :nesting</code>.
          </p>
          <PhoenixDemoWeb.Components.SettingsPanel.settings_panel title="Account Settings">
            <div class="settings-section">
              <div class="settings-group">
                <label class="settings-label">Email Notifications</label>
                <p class="settings-description">Receive email updates about your account activity</p>
                <div class="settings-toggle">
                  <div class="settings-toggle-switch active"></div>
                  <span>Enabled</span>
                </div>
              </div>
              <div class="settings-group">
                <label class="settings-label">Two-Factor Authentication</label>
                <p class="settings-description">Add an extra layer of security to your account</p>
                <div class="settings-toggle">
                  <div class="settings-toggle-switch"></div>
                  <span>Disabled</span>
                </div>
              </div>
            </div>
            <button class="settings-button">Save Changes</button>
          </PhoenixDemoWeb.Components.SettingsPanel.settings_panel>
        </section>

        <section class="bg-white rounded-lg p-8">
          <h2 class="text-2xl font-bold text-gray-900 mb-6">Namespace Summary</h2>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <div class="bg-gray-50 p-4 rounded-lg">
              <div class="font-semibold mb-2">:app (Default)</div>
              <div class="text-sm text-gray-600 mb-2">General application components</div>
              <div class="text-xs text-gray-500">Used by: Cards, Buttons, Navigation</div>
            </div>
            <div class="bg-gray-50 p-4 rounded-lg">
              <div class="font-semibold mb-2">:admin</div>
              <div class="text-sm text-gray-600 mb-2">Admin panel components</div>
              <div class="text-xs text-gray-500">Used by: AdminPanel</div>
            </div>
            <div class="bg-gray-50 p-4 rounded-lg">
              <div class="font-semibold mb-2">:ecommerce</div>
              <div class="text-sm text-gray-600 mb-2">E-commerce components</div>
              <div class="text-xs text-gray-500">Used by: ProductCard</div>
            </div>
            <div class="bg-gray-50 p-4 rounded-lg">
              <div class="font-semibold mb-2">:saas</div>
              <div class="text-sm text-gray-600 mb-2">SaaS application components</div>
              <div class="text-xs text-gray-500">Used by: PricingTable</div>
            </div>
            <div class="bg-gray-50 p-4 rounded-lg">
              <div class="font-semibold mb-2">:dashboard</div>
              <div class="text-sm text-gray-600 mb-2">Dashboard widgets</div>
              <div class="text-xs text-gray-500">Used by: DashboardWidget</div>
            </div>
            <div class="bg-gray-50 p-4 rounded-lg">
              <div class="font-semibold mb-2">:marketing</div>
              <div class="text-sm text-gray-600 mb-2">Marketing components</div>
              <div class="text-xs text-gray-500">Used by: MarketingBanner</div>
            </div>
            <div class="bg-gray-50 p-4 rounded-lg">
              <div class="font-semibold mb-2">:blog</div>
              <div class="text-sm text-gray-600 mb-2">Blog components</div>
              <div class="text-xs text-gray-500">Used by: BlogPostCard</div>
            </div>
            <div class="bg-gray-50 p-4 rounded-lg">
              <div class="font-semibold mb-2">:support</div>
              <div class="text-sm text-gray-600 mb-2">Support system components</div>
              <div class="text-xs text-gray-500">Used by: SupportTicket</div>
            </div>
            <div class="bg-gray-50 p-4 rounded-lg">
              <div class="font-semibold mb-2">:analytics</div>
              <div class="text-sm text-gray-600 mb-2">Analytics components</div>
              <div class="text-xs text-gray-500">Used by: AnalyticsChart</div>
            </div>
            <div class="bg-gray-50 p-4 rounded-lg">
              <div class="font-semibold mb-2">:settings</div>
              <div class="text-sm text-gray-600 mb-2">Settings panels</div>
              <div class="text-xs text-gray-500">Used by: SettingsPanel</div>
            </div>
          </div>
        </section>
      </div>
    </div>
    """
  end
end
