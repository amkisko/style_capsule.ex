defmodule PhoenixDemoWeb.Components.PricingTable do
  @moduledoc """
  Business case: SaaS pricing table component.
  Demonstrates complex component styling with multiple variants.
  """
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :saas, cache_strategy: :file

  @component_styles """
  .pricing-table {
    background: white;
    border-radius: 1rem;
    padding: 2rem;
    border: 2px solid #e2e8f0;
    transition: all 0.3s ease;
    position: relative;
    display: flex;
    flex-direction: column;
  }

  .pricing-table:hover {
    border-color: #667eea;
    box-shadow: 0 10px 25px rgba(102, 126, 234, 0.1);
  }

  .pricing-table.featured {
    border-color: #667eea;
    border-width: 3px;
    transform: scale(1.05);
    box-shadow: 0 15px 35px rgba(102, 126, 234, 0.2);
  }

  .pricing-badge {
    position: absolute;
    top: -0.75rem;
    left: 50%;
    transform: translateX(-50%);
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 0.25rem 1rem;
    border-radius: 1rem;
    font-size: 0.75rem;
    font-weight: 600;
    text-transform: uppercase;
  }

  .pricing-name {
    font-size: 1.5rem;
    font-weight: 700;
    color: #1a202c;
    margin-bottom: 0.5rem;
  }

  .pricing-description {
    color: #718096;
    font-size: 0.875rem;
    margin-bottom: 1.5rem;
  }

  .pricing-price {
    margin-bottom: 1.5rem;
  }

  .pricing-amount {
    font-size: 3rem;
    font-weight: 700;
    color: #1a202c;
    line-height: 1;
  }

  .pricing-period {
    font-size: 1rem;
    color: #718096;
    margin-left: 0.25rem;
  }

  .pricing-features {
    list-style: none;
    padding: 0;
    margin: 0 0 2rem 0;
    flex: 1;
  }

  .pricing-feature {
    padding: 0.75rem 0;
    border-bottom: 1px solid #e2e8f0;
    color: #4a5568;
    display: flex;
    align-items: center;
  }

  .pricing-feature:last-child {
    border-bottom: none;
  }

  .pricing-feature::before {
    content: '✓';
    color: #10b981;
    font-weight: 700;
    margin-right: 0.75rem;
    font-size: 1.25rem;
  }

  .pricing-button {
    width: 100%;
    padding: 0.75rem;
    border: 2px solid #667eea;
    background: white;
    color: #667eea;
    border-radius: 0.5rem;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
  }

  .pricing-button:hover {
    background: #667eea;
    color: white;
  }

  .pricing-table.featured .pricing-button {
    background: #667eea;
    color: white;
  }

  .pricing-table.featured .pricing-button:hover {
    background: #5568d3;
  }
  """

  attr :name, :string, required: true
  attr :description, :string, required: true
  attr :amount, :string, required: true
  attr :period, :string, default: "/month"
  attr :features, :list, default: []
  attr :featured, :boolean, default: false

  def pricing_table(assigns) do
    ~H"""
    <.capsule module={__MODULE__}>
      <div class={"pricing-table #{if @featured, do: "featured", else: ""}"}>
        <%= if @featured do %>
          <span class="pricing-badge">Most Popular</span>
        <% end %>
        <h3 class="pricing-name"><%= @name %></h3>
        <p class="pricing-description"><%= @description %></p>
        <div class="pricing-price">
          <span class="pricing-amount"><%= @amount %></span>
          <span class="pricing-period"><%= @period %></span>
        </div>
        <ul class="pricing-features">
          <%= for feature <- @features do %>
            <li class="pricing-feature"><%= feature %></li>
          <% end %>
        </ul>
        <button class="pricing-button">Get Started</button>
      </div>
    </.capsule>
    """
  end
end
