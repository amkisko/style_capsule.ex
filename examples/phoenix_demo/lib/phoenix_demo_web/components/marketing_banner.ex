defmodule PhoenixDemoWeb.Components.MarketingBanner do
  @moduledoc """
  Marketing banner component using :marketing namespace.
  """
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :marketing, strategy: :nesting

  @component_styles """
  .banner {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 3rem 2rem;
    border-radius: 1rem;
    text-align: center;
    position: relative;
    overflow: hidden;
  }

  .banner::before {
    content: '';
    position: absolute;
    top: -50%;
    right: -50%;
    width: 200%;
    height: 200%;
    background: radial-gradient(circle, rgba(255, 255, 255, 0.1) 0%, transparent 70%);
    animation: rotate 20s linear infinite;
  }

  @keyframes rotate {
    from { transform: rotate(0deg); }
    to { transform: rotate(360deg); }
  }

  .banner-title {
    font-size: 2.5rem;
    font-weight: 700;
    margin-bottom: 1rem;
    position: relative;
    z-index: 1;
  }

  .banner-subtitle {
    font-size: 1.25rem;
    opacity: 0.9;
    margin-bottom: 2rem;
    position: relative;
    z-index: 1;
  }

  .banner-cta {
    display: inline-block;
    background: white;
    color: #667eea;
    padding: 0.75rem 2rem;
    border-radius: 0.5rem;
    font-weight: 600;
    text-decoration: none;
    transition: transform 0.2s;
    position: relative;
    z-index: 1;
  }

  .banner-cta:hover {
    transform: scale(1.05);
  }
  """

  attr :title, :string, required: true
  attr :subtitle, :string, required: true
  attr :cta_text, :string, default: "Get Started"
  attr :cta_href, :string, default: "#"

  def marketing_banner(assigns) do
    ~H"""
    <.capsule module={__MODULE__}>
      <div class="banner">
        <h2 class="banner-title"><%= @title %></h2>
        <p class="banner-subtitle"><%= @subtitle %></p>
        <a href={@cta_href} class="banner-cta"><%= @cta_text %></a>
      </div>
    </.capsule>
    """
  end
end
