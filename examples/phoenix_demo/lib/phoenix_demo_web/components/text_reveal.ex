defmodule PhoenixDemoWeb.Components.TextReveal do
  @moduledoc """
  Text reveal animation with sliding effect.
  """
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :app

  @component_styles """
  .text-reveal {
    position: relative;
    overflow: hidden;
    display: inline-block;
  }

  .text-reveal-text {
    display: inline-block;
    transform: translateY(100%);
    animation: reveal 1s ease-out forwards;
  }

  .text-reveal-text:nth-child(1) { animation-delay: 0.1s; }
  .text-reveal-text:nth-child(2) { animation-delay: 0.2s; }
  .text-reveal-text:nth-child(3) { animation-delay: 0.3s; }
  .text-reveal-text:nth-child(4) { animation-delay: 0.4s; }
  .text-reveal-text:nth-child(5) { animation-delay: 0.5s; }
  .text-reveal-text:nth-child(6) { animation-delay: 0.6s; }
  .text-reveal-text:nth-child(7) { animation-delay: 0.7s; }
  .text-reveal-text:nth-child(8) { animation-delay: 0.8s; }
  .text-reveal-text:nth-child(9) { animation-delay: 0.9s; }
  .text-reveal-text:nth-child(10) { animation-delay: 1.0s; }

  @keyframes reveal {
    to {
      transform: translateY(0);
    }
  }

  .text-reveal-container {
    font-size: 2.5rem;
    font-weight: 700;
    color: #1a202c;
    text-align: center;
  }
  """

  attr :text, :string, required: true

  def text_reveal(assigns) do
    chars = String.graphemes(assigns.text)
    assigns = assign(assigns, :chars, chars)

    ~H"""
    <.capsule module={__MODULE__}>
      <div class="text-reveal-container">
        <div class="text-reveal">
          <%= for char <- @chars do %>
            <span class="text-reveal-text"><%= char %></span>
          <% end %>
        </div>
      </div>
    </.capsule>
    """
  end
end
