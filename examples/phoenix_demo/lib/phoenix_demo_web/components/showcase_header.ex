defmodule PhoenixDemoWeb.Components.ShowcaseHeader do
  @moduledoc """
  Header component for the showcase page.
  Uses :showcase namespace with file caching.
  """
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :showcase, cache_strategy: :file

  @component_styles """
  .showcase-header {
    background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
    border-radius: 1rem;
    padding: 3rem 2rem;
    text-align: center;
    color: white;
    margin-bottom: 2rem;
    position: relative;
    overflow: hidden;
  }

  .showcase-header::before {
    content: '';
    position: absolute;
    top: -50%;
    left: -50%;
    width: 200%;
    height: 200%;
    background: radial-gradient(circle, rgba(255, 255, 255, 0.1) 1px, transparent 1px);
    background-size: 50px 50px;
    animation: showcase-shimmer 20s linear infinite;
  }

  @keyframes showcase-shimmer {
    0% { transform: translate(0, 0); }
    100% { transform: translate(50px, 50px); }
  }

  .showcase-header-content {
    position: relative;
    z-index: 1;
  }

  .showcase-header-title {
    font-size: 2.5rem;
    font-weight: 700;
    margin-bottom: 0.5rem;
    text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
  }

  .showcase-header-description {
    font-size: 1.125rem;
    opacity: 0.95;
  }
  """

  attr :title, :string, required: true
  attr :description, :string, required: true

  def showcase_header(assigns) do
    ~H"""
    <.capsule module={__MODULE__}>
      <div class="showcase-header">
        <div class="showcase-header-content">
          <h1 class="showcase-header-title"><%= @title %></h1>
          <p class="showcase-header-description"><%= @description %></p>
        </div>
      </div>
    </.capsule>
    """
  end
end
