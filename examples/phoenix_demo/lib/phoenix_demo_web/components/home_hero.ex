defmodule PhoenixDemoWeb.Components.HomeHero do
  @moduledoc """
  Hero section component for the home page.
  Uses :home namespace with file caching.
  """
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :home, cache_strategy: :file

  @component_styles """
  .home-hero {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius: 1rem;
    padding: 4rem 2rem;
    text-align: center;
    color: white;
    margin-bottom: 3rem;
  }

  .home-hero-title {
    font-size: 3rem;
    font-weight: 700;
    margin-bottom: 1rem;
    text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  }

  .home-hero-subtitle {
    font-size: 1.25rem;
    opacity: 0.9;
    margin-bottom: 2rem;
  }

  .home-hero-badge {
    display: inline-block;
    background: rgba(255, 255, 255, 0.2);
    padding: 0.5rem 1rem;
    border-radius: 2rem;
    font-size: 0.875rem;
    font-weight: 500;
    backdrop-filter: blur(10px);
  }
  """

  attr :title, :string, required: true
  attr :subtitle, :string, required: true
  slot :inner_block

  def home_hero(assigns) do
    ~H"""
    <.capsule module={__MODULE__}>
      <div class="home-hero">
        <h1 class="home-hero-title"><%= @title %></h1>
        <p class="home-hero-subtitle"><%= @subtitle %></p>
        <%= if assigns[:inner_block] do %>
          <div class="home-hero-badge">
            <%= render_slot(@inner_block) %>
          </div>
        <% end %>
      </div>
    </.capsule>
    """
  end
end
