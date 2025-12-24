defmodule PhoenixDemoWeb.Components.GradientButton do
  @moduledoc """
  Gradient button with animated hover effects.
  Showcases CSS gradients and transitions.
  """
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :app, cache_strategy: :time

  @component_styles """
  .gradient-btn {
    position: relative;
    padding: 0.75rem 2rem;
    border: none;
    border-radius: 0.5rem;
    font-weight: 600;
    font-size: 1rem;
    color: white;
    cursor: pointer;
    overflow: hidden;
    transition: all 0.3s ease;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    box-shadow: 0 4px 15px 0 rgba(102, 126, 234, 0.4);
  }

  .gradient-btn::before {
    content: '';
    position: absolute;
    top: 0;
    left: -100%;
    width: 100%;
    height: 100%;
    background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
    transition: left 0.5s ease;
    z-index: -1;
  }

  .gradient-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px 0 rgba(102, 126, 234, 0.6);
  }

  .gradient-btn:hover::before {
    left: 0;
  }

  .gradient-btn:active {
    transform: translateY(0);
  }

  .gradient-btn.secondary {
    background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
    box-shadow: 0 4px 15px 0 rgba(245, 87, 108, 0.4);
  }

  .gradient-btn.secondary::before {
    background: linear-gradient(135deg, #f5576c 0%, #f093fb 100%);
  }

  .gradient-btn.secondary:hover {
    box-shadow: 0 6px 20px 0 rgba(245, 87, 108, 0.6);
  }

  .gradient-btn.success {
    background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
    box-shadow: 0 4px 15px 0 rgba(79, 172, 254, 0.4);
  }

  .gradient-btn.success::before {
    background: linear-gradient(135deg, #00f2fe 0%, #4facfe 100%);
  }

  .gradient-btn.success:hover {
    box-shadow: 0 6px 20px 0 rgba(79, 172, 254, 0.6);
  }
  """

  attr :variant, :string, default: "primary", values: ["primary", "secondary", "success"]
  attr :type, :string, default: "button"
  slot :inner_block, required: true

  def gradient_button(assigns) do
    ~H"""
    <.capsule module={__MODULE__}>
      <button class={"gradient-btn #{@variant}"} type={@type}>
        <%= render_slot(@inner_block) %>
      </button>
    </.capsule>
    """
  end
end
