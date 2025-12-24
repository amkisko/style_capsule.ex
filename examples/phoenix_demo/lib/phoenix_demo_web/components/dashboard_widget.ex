defmodule PhoenixDemoWeb.Components.DashboardWidget do
  @moduledoc """
  Business case: Analytics dashboard widget.
  Shows metrics display with trend indicators.
  """
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :dashboard, strategy: :nesting

  @component_styles """
  .widget {
    background: white;
    border-radius: 0.75rem;
    padding: 1.5rem;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    border-left: 4px solid #667eea;
    transition: all 0.3s ease;
  }

  .widget:hover {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    transform: translateY(-2px);
  }

  .widget-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 1rem;
  }

  .widget-title {
    font-size: 0.875rem;
    font-weight: 600;
    color: #718096;
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }

  .widget-icon {
    width: 2.5rem;
    height: 2.5rem;
    border-radius: 0.5rem;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.25rem;
  }

  .widget-value {
    font-size: 2.5rem;
    font-weight: 700;
    color: #1a202c;
    margin-bottom: 0.5rem;
    line-height: 1;
  }

  .widget-trend {
    display: inline-flex;
    align-items: center;
    font-size: 0.875rem;
    font-weight: 600;
    padding: 0.25rem 0.5rem;
    border-radius: 0.25rem;
  }

  .widget-trend.up {
    color: #10b981;
    background: #d1fae5;
  }

  .widget-trend.down {
    color: #ef4444;
    background: #fee2e2;
  }

  .widget-trend::before {
    content: '';
    width: 0;
    height: 0;
    border-left: 4px solid transparent;
    border-right: 4px solid transparent;
    margin-right: 0.25rem;
  }

  .widget-trend.up::before {
    border-bottom: 6px solid #10b981;
  }

  .widget-trend.down::before {
    border-top: 6px solid #ef4444;
  }
  """

  attr :title, :string, required: true
  attr :value, :string, required: true
  attr :trend, :string, default: nil
  attr :trend_direction, :string, default: "up", values: ["up", "down"]
  attr :icon, :string, default: "📊"

  def dashboard_widget(assigns) do
    ~H"""
    <.capsule module={__MODULE__}>
      <div class="widget">
        <div class="widget-header">
          <div class="widget-title"><%= @title %></div>
          <div class="widget-icon"><%= @icon %></div>
        </div>
        <div class="widget-value"><%= @value %></div>
        <%= if @trend do %>
          <div class={"widget-trend #{@trend_direction}"}>
            <%= @trend %>
          </div>
        <% end %>
      </div>
    </.capsule>
    """
  end
end
