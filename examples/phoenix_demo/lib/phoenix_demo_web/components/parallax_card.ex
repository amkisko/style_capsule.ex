defmodule PhoenixDemoWeb.Components.ParallaxCard do
  @moduledoc """
  Card with parallax scrolling effect using CSS transforms.
  """
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :app

  @component_styles """
  .parallax-container {
    position: relative;
    overflow: hidden;
    border-radius: 1rem;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 300px;
  }

  .parallax-bg {
    position: absolute;
    top: -50%;
    left: -50%;
    width: 200%;
    height: 200%;
    background: radial-gradient(circle, rgba(255, 255, 255, 0.1) 1px, transparent 1px);
    background-size: 50px 50px;
    animation: parallax-move 20s linear infinite;
  }

  @keyframes parallax-move {
    0% {
      transform: translate(0, 0);
    }
    100% {
      transform: translate(50px, 50px);
    }
  }

  .parallax-content {
    position: relative;
    z-index: 1;
    padding: 2rem;
    color: white;
    text-align: center;
  }

  .parallax-title {
    font-size: 2rem;
    font-weight: 700;
    margin-bottom: 1rem;
  }
  """

  attr :title, :string, required: true
  slot :inner_block, required: true

  def parallax_card(assigns) do
    ~H"""
    <.capsule module={__MODULE__}>
      <div class="parallax-container">
        <div class="parallax-bg"></div>
        <div class="parallax-content">
          <h3 class="parallax-title"><%= @title %></h3>
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </.capsule>
    """
  end
end
