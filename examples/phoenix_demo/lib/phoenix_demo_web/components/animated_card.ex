defmodule PhoenixDemoWeb.Components.AnimatedCard do
  @moduledoc """
  Animated card with CSS keyframe animations.
  Demonstrates advanced CSS animations with StyleCapsule.
  """
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :app

  @component_styles """
  @keyframes fadeInUp {
    from {
      opacity: 0;
      transform: translateY(20px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  @keyframes shimmer {
    0% {
      background-position: -1000px 0;
    }
    100% {
      background-position: 1000px 0;
    }
  }

  .animated-card {
    background: white;
    border-radius: 1rem;
    padding: 2rem;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    animation: fadeInUp 0.6s ease-out;
    position: relative;
    overflow: hidden;
    transition: transform 0.3s ease, box-shadow 0.3s ease;
  }

  .animated-card::before {
    content: '';
    position: absolute;
    top: 0;
    left: -100%;
    width: 100%;
    height: 100%;
    background: linear-gradient(
      90deg,
      transparent,
      rgba(255, 255, 255, 0.4),
      transparent
    );
    background-size: 1000px 100%;
    animation: shimmer 2s infinite;
  }

  .animated-card:hover {
    transform: scale(1.02);
    box-shadow: 0 8px 12px rgba(0, 0, 0, 0.15);
  }

  .animated-card:hover::before {
    left: 100%;
  }

  .animated-icon {
    width: 3rem;
    height: 3rem;
    border-radius: 50%;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 1rem;
    animation: pulse 2s infinite;
  }

  @keyframes pulse {
    0%, 100% {
      transform: scale(1);
      opacity: 1;
    }
    50% {
      transform: scale(1.1);
      opacity: 0.8;
    }
  }

  .animated-title {
    font-size: 1.5rem;
    font-weight: 700;
    color: #1a202c;
    margin-bottom: 0.5rem;
  }

  .animated-content {
    color: #4a5568;
    line-height: 1.6;
  }
  """

  attr :icon, :string, default: "✨"
  attr :title, :string, required: true
  slot :inner_block, required: true

  def animated_card(assigns) do
    ~H"""
    <.capsule module={__MODULE__}>
      <div class="animated-card">
        <div class="animated-icon"><%= @icon %></div>
        <h3 class="animated-title"><%= @title %></h3>
        <div class="animated-content">
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </.capsule>
    """
  end
end
