defmodule PhoenixDemoWeb.Components.FeaturesIntro do
  @moduledoc """
  Introduction component for the features page.
  Uses :features namespace with file caching.
  """
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :features, cache_strategy: :file

  @component_styles """
  .features-intro {
    background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
    border-radius: 1rem;
    padding: 3rem 2rem;
    color: white;
    margin-bottom: 3rem;
    box-shadow: 0 10px 25px rgba(79, 172, 254, 0.3);
  }

  .features-intro-title {
    font-size: 2.5rem;
    font-weight: 700;
    margin-bottom: 1rem;
    text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  }

  .features-intro-description {
    font-size: 1.125rem;
    opacity: 0.95;
    line-height: 1.6;
    max-width: 800px;
    margin: 0 auto;
  }

  .features-intro-badge {
    display: inline-block;
    background: rgba(255, 255, 255, 0.2);
    padding: 0.375rem 0.75rem;
    border-radius: 0.5rem;
    font-size: 0.875rem;
    font-weight: 500;
    margin-top: 1.5rem;
    backdrop-filter: blur(10px);
  }
  """

  attr :title, :string, required: true
  attr :description, :string, required: true

  def features_intro(assigns) do
    ~H"""
    <.capsule module={__MODULE__}>
      <div class="features-intro">
        <h1 class="features-intro-title"><%= @title %></h1>
        <p class="features-intro-description"><%= @description %></p>
        <span class="features-intro-badge">Namespace: :features</span>
      </div>
    </.capsule>
    """
  end
end
