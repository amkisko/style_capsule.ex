defmodule PhoenixDemoWeb.Components.ProductCard do
  @moduledoc """
  Business case: E-commerce product card component.
  Shows real-world component styling with pricing, badges, and actions.
  """
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :ecommerce, strategy: :nesting

  @component_styles """
  .product-card {
    background: white;
    border-radius: 0.75rem;
    overflow: hidden;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    transition: all 0.3s ease;
    display: flex;
    flex-direction: column;
  }

  .product-card:hover {
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
    transform: translateY(-4px);
  }

  .product-image {
    width: 100%;
    height: 200px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 3rem;
    position: relative;
  }

  .product-badge {
    position: absolute;
    top: 0.75rem;
    right: 0.75rem;
    background: #ef4444;
    color: white;
    padding: 0.25rem 0.75rem;
    border-radius: 0.25rem;
    font-size: 0.75rem;
    font-weight: 600;
    text-transform: uppercase;
  }

  .product-content {
    padding: 1.5rem;
    flex: 1;
    display: flex;
    flex-direction: column;
  }

  .product-title {
    font-size: 1.25rem;
    font-weight: 600;
    color: #1a202c;
    margin-bottom: 0.5rem;
  }

  .product-description {
    color: #718096;
    font-size: 0.875rem;
    line-height: 1.5;
    margin-bottom: 1rem;
    flex: 1;
  }

  .product-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: auto;
    padding-top: 1rem;
    border-top: 1px solid #e2e8f0;
  }

  .product-price {
    font-size: 1.5rem;
    font-weight: 700;
    color: #1a202c;
  }

  .product-price-original {
    font-size: 1rem;
    color: #a0aec0;
    text-decoration: line-through;
    margin-left: 0.5rem;
  }

  .product-button {
    background: #667eea;
    color: white;
    border: none;
    padding: 0.5rem 1.5rem;
    border-radius: 0.5rem;
    font-weight: 600;
    cursor: pointer;
    transition: background 0.2s;
  }

  .product-button:hover {
    background: #5568d3;
  }
  """

  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :price, :string, required: true
  attr :original_price, :string, default: nil
  attr :badge, :string, default: nil
  attr :icon, :string, default: "📦"

  def product_card(assigns) do
    ~H"""
    <.capsule module={__MODULE__}>
      <div class="product-card">
        <div class="product-image">
          <%= if @badge do %>
            <span class="product-badge"><%= @badge %></span>
          <% end %>
          <span><%= @icon %></span>
        </div>
        <div class="product-content">
          <h3 class="product-title"><%= @title %></h3>
          <p class="product-description"><%= @description %></p>
          <div class="product-footer">
            <div>
              <span class="product-price"><%= @price %></span>
              <%= if @original_price do %>
                <span class="product-price-original"><%= @original_price %></span>
              <% end %>
            </div>
            <button class="product-button">Add to Cart</button>
          </div>
        </div>
      </div>
    </.capsule>
    """
  end
end
