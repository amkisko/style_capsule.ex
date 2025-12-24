defmodule PhoenixDemoWeb.Components.HoverTiltCard do
  @moduledoc """
  Card with 3D tilt effect on hover using CSS transforms.
  """
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :app

  @component_styles """
  .tilt-card {
    background: white;
    border-radius: 1rem;
    padding: 2rem;
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
    transition: transform 0.3s ease, box-shadow 0.3s ease;
    transform-style: preserve-3d;
    perspective: 1000px;
  }

  .tilt-card:hover {
    transform: perspective(1000px) rotateX(5deg) rotateY(5deg) scale(1.02);
    box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
  }

  .tilt-card-title {
    font-size: 1.5rem;
    font-weight: 700;
    margin-bottom: 1rem;
    color: #1a202c;
  }

  .tilt-card-content {
    color: #4a5568;
    line-height: 1.6;
  }
  """

  attr :title, :string, required: true
  slot :inner_block, required: true

  def hover_tilt_card(assigns) do
    ~H"""
    <.capsule module={__MODULE__}>
      <div class="tilt-card">
        <h3 class="tilt-card-title"><%= @title %></h3>
        <div class="tilt-card-content">
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </.capsule>
    """
  end
end
