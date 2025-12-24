defmodule PhoenixDemoWeb.Components.GlassmorphismCard do
  @moduledoc """
  Glassmorphism card component - a modern CSS effect with frosted glass appearance.
  """
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :app, strategy: :nesting

  @component_styles """
  .glass-card {
    background: rgba(255, 255, 255, 0.1);
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-radius: 1rem;
    padding: 2rem;
    box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
    transition: transform 0.3s ease, box-shadow 0.3s ease;
  }

  .glass-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 12px 40px 0 rgba(31, 38, 135, 0.5);
  }

  .glass-title {
    font-size: 1.5rem;
    font-weight: 700;
    color: rgba(255, 255, 255, 0.9);
    margin-bottom: 1rem;
    text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  }

  .glass-content {
    color: rgba(255, 255, 255, 0.8);
    line-height: 1.6;
  }

  .glass-badge {
    display: inline-block;
    background: rgba(255, 255, 255, 0.2);
    padding: 0.25rem 0.75rem;
    border-radius: 0.5rem;
    font-size: 0.875rem;
    font-weight: 500;
    margin-top: 1rem;
    border: 1px solid rgba(255, 255, 255, 0.3);
  }
  """

  attr :title, :string, required: true
  attr :badge, :string, default: nil
  slot :inner_block, required: true

  def glassmorphism_card(assigns) do
    ~H"""
    <.capsule module={__MODULE__}>
      <div class="glass-card">
        <h3 class="glass-title"><%= @title %></h3>
        <div class="glass-content">
          <%= render_slot(@inner_block) %>
        </div>
        <%= if @badge do %>
          <span class="glass-badge"><%= @badge %></span>
        <% end %>
      </div>
    </.capsule>
    """
  end
end
