defmodule PhoenixDemoWeb.BusinessLive do
  @moduledoc """
  Business cases showcase - real-world component examples.
  """
  use PhoenixDemoWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="py-12 px-4 bg-gray-50">
      <div class="max-w-7xl mx-auto">
        <h1 class="text-4xl font-bold text-gray-900 mb-2">Business Cases</h1>
        <p class="text-gray-600 mb-12">Real-world component examples for e-commerce, SaaS, and dashboards</p>

        <section class="mb-16">
          <h2 class="text-2xl font-bold text-gray-900 mb-6">E-commerce Product Cards</h2>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <PhoenixDemoWeb.Components.ProductCard.product_card
              title="Premium Widget"
              description="High-quality widget with advanced features and premium materials."
              price="$99"
              original_price="$149"
              badge="Sale"
              icon="🎁"
            />
            <PhoenixDemoWeb.Components.ProductCard.product_card
              title="Standard Widget"
              description="Reliable widget perfect for everyday use. Great value for money."
              price="$49"
              icon="📦"
            />
            <PhoenixDemoWeb.Components.ProductCard.product_card
              title="Deluxe Widget"
              description="Top-of-the-line widget with all premium features included."
              price="$199"
              badge="New"
              icon="⭐"
            />
          </div>
          <p class="text-sm text-gray-500 mt-4">
            Uses <code class="bg-gray-200 px-1 rounded">namespace: :ecommerce</code> and <code class="bg-gray-200 px-1 rounded">strategy: :nesting</code>
          </p>
        </section>

        <section class="mb-16">
          <h2 class="text-2xl font-bold text-gray-900 mb-6">SaaS Pricing Tables</h2>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <PhoenixDemoWeb.Components.PricingTable.pricing_table
              name="Starter"
              description="Perfect for individuals"
              amount="$9"
              period="/month"
              features={[
                "Up to 5 projects",
                "10GB storage",
                "Email support",
                "Basic analytics"
              ]}
            />
            <PhoenixDemoWeb.Components.PricingTable.pricing_table
              name="Professional"
              description="For growing teams"
              amount="$29"
              period="/month"
              featured={true}
              features={[
                "Unlimited projects",
                "100GB storage",
                "Priority support",
                "Advanced analytics",
                "Team collaboration",
                "API access"
              ]}
            />
            <PhoenixDemoWeb.Components.PricingTable.pricing_table
              name="Enterprise"
              description="For large organizations"
              amount="$99"
              period="/month"
              features={[
                "Everything in Professional",
                "1TB storage",
                "24/7 phone support",
                "Custom integrations",
                "Dedicated account manager",
                "SLA guarantee"
              ]}
            />
          </div>
          <p class="text-sm text-gray-500 mt-4">
            Uses <code class="bg-gray-200 px-1 rounded">namespace: :saas</code> and <code class="bg-gray-200 px-1 rounded">cache_strategy: :file</code> for HTTP caching
          </p>
        </section>

        <section class="mb-16">
          <h2 class="text-2xl font-bold text-gray-900 mb-6">Dashboard Widgets</h2>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <PhoenixDemoWeb.Components.DashboardWidget.dashboard_widget
              title="Total Revenue"
              value="$45,231"
              trend="+12.5%"
              trend_direction="up"
              icon="💰"
            />
            <PhoenixDemoWeb.Components.DashboardWidget.dashboard_widget
              title="Active Users"
              value="2,341"
              trend="+8.2%"
              trend_direction="up"
              icon="👥"
            />
            <PhoenixDemoWeb.Components.DashboardWidget.dashboard_widget
              title="Conversion Rate"
              value="3.24%"
              trend="-2.1%"
              trend_direction="down"
              icon="📈"
            />
            <PhoenixDemoWeb.Components.DashboardWidget.dashboard_widget
              title="Avg. Order Value"
              value="$127.50"
              trend="+5.3%"
              trend_direction="up"
              icon="🛒"
            />
          </div>
          <p class="text-sm text-gray-500 mt-4">
            Uses <code class="bg-gray-200 px-1 rounded">namespace: :dashboard</code> and <code class="bg-gray-200 px-1 rounded">strategy: :nesting</code>
          </p>
        </section>

        <section>
          <h2 class="text-2xl font-bold text-gray-900 mb-6">Notification System</h2>
          <div class="max-w-2xl">
            <PhoenixDemoWeb.Components.NotificationBadge.notification_badge
              variant="success"
              title="Payment Successful"
              message="Your payment of $99.00 has been processed successfully."
            />
            <PhoenixDemoWeb.Components.NotificationBadge.notification_badge
              variant="error"
              title="Upload Failed"
              message="The file upload failed. Please try again or contact support."
            />
            <PhoenixDemoWeb.Components.NotificationBadge.notification_badge
              variant="warning"
              title="Storage Almost Full"
              message="You're using 85% of your storage. Consider upgrading your plan."
            />
            <PhoenixDemoWeb.Components.NotificationBadge.notification_badge
              variant="info"
              title="New Feature Available"
              message="Check out our new dashboard analytics. Click here to learn more."
            />
          </div>
          <p class="text-sm text-gray-500 mt-4">
            Uses <code class="bg-gray-200 px-1 rounded">cache_strategy: :none</code> for always-fresh styles
          </p>
        </section>
      </div>
    </div>
    """
  end
end
