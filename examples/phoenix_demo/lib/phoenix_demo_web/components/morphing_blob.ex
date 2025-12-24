defmodule PhoenixDemoWeb.Components.MorphingBlob do
  @moduledoc """
  Morphing blob animation component with fluid shapes.
  """
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :app

  @component_styles """
  .blob-container {
    position: relative;
    width: 100%;
    height: 300px;
    overflow: hidden;
    border-radius: 1rem;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  }

  .blob {
    position: absolute;
    border-radius: 30% 70% 70% 30% / 30% 30% 70% 70%;
    background: rgba(255, 255, 255, 0.2);
    animation: morph 8s ease-in-out infinite;
    filter: blur(40px);
  }

  .blob:nth-child(1) {
    width: 200px;
    height: 200px;
    top: 10%;
    left: 10%;
    animation-delay: 0s;
  }

  .blob:nth-child(2) {
    width: 150px;
    height: 150px;
    top: 50%;
    right: 10%;
    animation-delay: 2s;
    border-radius: 60% 40% 30% 70% / 60% 30% 70% 40%;
  }

  .blob:nth-child(3) {
    width: 180px;
    height: 180px;
    bottom: 10%;
    left: 50%;
    animation-delay: 4s;
    border-radius: 40% 60% 70% 30% / 40% 70% 30% 60%;
  }

  @keyframes morph {
    0%, 100% {
      border-radius: 30% 70% 70% 30% / 30% 30% 70% 70%;
      transform: translate(0, 0) rotate(0deg);
    }
    25% {
      border-radius: 60% 40% 30% 70% / 60% 30% 70% 40%;
      transform: translate(20px, -20px) rotate(90deg);
    }
    50% {
      border-radius: 40% 60% 70% 30% / 40% 70% 30% 60%;
      transform: translate(-20px, 20px) rotate(180deg);
    }
    75% {
      border-radius: 70% 30% 60% 40% / 30% 60% 40% 70%;
      transform: translate(10px, 10px) rotate(270deg);
    }
  }

  .blob-content {
    position: relative;
    z-index: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    height: 100%;
    color: white;
    text-align: center;
    padding: 2rem;
  }
  """

  def morphing_blob(assigns) do
    ~H"""
    <.capsule module={__MODULE__}>
      <div class="blob-container">
        <div class="blob"></div>
        <div class="blob"></div>
        <div class="blob"></div>
        <div class="blob-content">
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </.capsule>
    """
  end
end
