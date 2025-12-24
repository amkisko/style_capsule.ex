defmodule PhoenixDemoWeb.Components.CardFlip do
  @moduledoc """
  Card with 3D flip effect on hover.
  """
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :app

  @component_styles """
  .flip-card {
    background-color: transparent;
    width: 100%;
    height: 300px;
    perspective: 1000px;
  }

  .flip-card-inner {
    position: relative;
    width: 100%;
    height: 100%;
    text-align: center;
    transition: transform 0.6s;
    transform-style: preserve-3d;
  }

  .flip-card:hover .flip-card-inner {
    transform: rotateY(180deg);
  }

  .flip-card-front,
  .flip-card-back {
    position: absolute;
    width: 100%;
    height: 100%;
    backface-visibility: hidden;
    border-radius: 1rem;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-direction: column;
    padding: 2rem;
  }

  .flip-card-front {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
  }

  .flip-card-back {
    background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
    color: white;
    transform: rotateY(180deg);
  }

  .flip-card-title {
    font-size: 1.5rem;
    font-weight: 700;
    margin-bottom: 1rem;
  }
  """

  attr :front_title, :string, required: true
  attr :back_title, :string, required: true
  attr :front_content, :string, default: nil
  attr :back_content, :string, default: nil

  def card_flip(assigns) do
    ~H"""
    <.capsule module={__MODULE__}>
      <div class="flip-card">
        <div class="flip-card-inner">
          <div class="flip-card-front">
            <h3 class="flip-card-title"><%= @front_title %></h3>
            <%= if @front_content do %>
              <p><%= @front_content %></p>
            <% end %>
          </div>
          <div class="flip-card-back">
            <h3 class="flip-card-title"><%= @back_title %></h3>
            <%= if @back_content do %>
              <p><%= @back_content %></p>
            <% end %>
          </div>
        </div>
      </div>
    </.capsule>
    """
  end
end
