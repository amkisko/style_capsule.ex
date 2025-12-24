defmodule PhoenixDemoWeb.Components.AnalyticsChart do
  @moduledoc """
  Analytics chart component using :analytics namespace.
  """
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :analytics, cache_strategy: :file

  @component_styles """
  .chart-container {
    background: white;
    border-radius: 0.75rem;
    padding: 1.5rem;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  }

  .chart-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1.5rem;
  }

  .chart-title {
    font-size: 1.25rem;
    font-weight: 600;
    color: #1a202c;
  }

  .chart-period {
    font-size: 0.875rem;
    color: #718096;
  }

  .chart-placeholder {
    height: 200px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius: 0.5rem;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 1.5rem;
    position: relative;
    overflow: hidden;
  }

  .chart-placeholder::before {
    content: '';
    position: absolute;
    top: 0;
    left: -100%;
    width: 100%;
    height: 100%;
    background: linear-gradient(
      90deg,
      transparent,
      rgba(255, 255, 255, 0.2),
      transparent
    );
    animation: shimmer 2s infinite;
  }

  @keyframes shimmer {
    0% { left: -100%; }
    100% { left: 100%; }
  }

  .chart-legend {
    display: flex;
    gap: 1.5rem;
    margin-top: 1rem;
    flex-wrap: wrap;
  }

  .chart-legend-item {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    font-size: 0.875rem;
    color: #4a5568;
  }

  .chart-legend-color {
    width: 12px;
    height: 12px;
    border-radius: 2px;
  }

  .chart-legend-color.primary {
    background: #667eea;
  }

  .chart-legend-color.secondary {
    background: #f5576c;
  }

  .chart-legend-color.success {
    background: #10b981;
  }
  """

  attr :title, :string, required: true
  attr :period, :string, default: "Last 30 days"
  attr :data, :list, default: []

  def analytics_chart(assigns) do
    ~H"""
    <.capsule module={__MODULE__}>
      <div class="chart-container">
        <div class="chart-header">
          <h3 class="chart-title"><%= @title %></h3>
          <span class="chart-period"><%= @period %></span>
        </div>
        <div class="chart-placeholder">
          📊 Chart Visualization
        </div>
        <div class="chart-legend">
          <div class="chart-legend-item">
            <span class="chart-legend-color primary"></span>
            <span>Visits</span>
          </div>
          <div class="chart-legend-item">
            <span class="chart-legend-color secondary"></span>
            <span>Page Views</span>
          </div>
          <div class="chart-legend-item">
            <span class="chart-legend-color success"></span>
            <span>Conversions</span>
          </div>
        </div>
      </div>
    </.capsule>
    """
  end
end
