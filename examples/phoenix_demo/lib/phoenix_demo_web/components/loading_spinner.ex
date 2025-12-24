defmodule PhoenixDemoWeb.Components.LoadingSpinner do
  @moduledoc """
  Animated loading spinner with multiple styles.
  """
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :app

  @component_styles """
  .spinner {
    width: 60px;
    height: 60px;
    margin: 2rem auto;
    position: relative;
  }

  .spinner-ring {
    width: 100%;
    height: 100%;
    border: 4px solid rgba(102, 126, 234, 0.2);
    border-top-color: #667eea;
    border-radius: 50%;
    animation: spin 1s linear infinite;
  }

  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }

  .spinner-dots {
    display: flex;
    gap: 8px;
    justify-content: center;
    align-items: center;
  }

  .spinner-dot {
    width: 12px;
    height: 12px;
    border-radius: 50%;
    background: #667eea;
    animation: bounce 1.4s ease-in-out infinite both;
  }

  .spinner-dot:nth-child(1) { animation-delay: -0.32s; }
  .spinner-dot:nth-child(2) { animation-delay: -0.16s; }

  @keyframes bounce {
    0%, 80%, 100% {
      transform: scale(0);
    }
    40% {
      transform: scale(1);
    }
  }

  .spinner-pulse {
    width: 60px;
    height: 60px;
    border-radius: 50%;
    background: #667eea;
    animation: pulse 1.5s ease-in-out infinite;
  }

  @keyframes pulse {
    0%, 100% {
      transform: scale(0);
      opacity: 1;
    }
    50% {
      transform: scale(1);
      opacity: 0.5;
    }
  }
  """

  attr :style, :string, default: "ring", values: ["ring", "dots", "pulse"]

  def loading_spinner(assigns) do
    ~H"""
    <.capsule module={__MODULE__}>
      <div class="spinner">
        <%= cond do %>
          <% @style == "ring" -> %>
            <div class="spinner-ring"></div>
          <% @style == "dots" -> %>
            <div class="spinner-dots">
              <div class="spinner-dot"></div>
              <div class="spinner-dot"></div>
              <div class="spinner-dot"></div>
            </div>
          <% true -> %>
            <div class="spinner-pulse"></div>
        <% end %>
      </div>
    </.capsule>
    """
  end
end
