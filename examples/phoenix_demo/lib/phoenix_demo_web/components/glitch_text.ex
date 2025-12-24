defmodule PhoenixDemoWeb.Components.GlitchText do
  @moduledoc """
  Glitch text effect with animated distortion.
  """
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :app

  @component_styles """
  .glitch-text {
    position: relative;
    font-size: 3rem;
    font-weight: 700;
    color: white;
    text-transform: uppercase;
    letter-spacing: 0.1em;
  }

  .glitch-text::before,
  .glitch-text::after {
    content: attr(data-text);
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
  }

  .glitch-text::before {
    left: 2px;
    text-shadow: -2px 0 #ff00c1;
    clip: rect(44px, 450px, 56px, 0);
    animation: glitch-anim 5s infinite linear alternate-reverse;
  }

  .glitch-text::after {
    left: -2px;
    text-shadow: -2px 0 #00fff9, 2px 2px #ff00c1;
    animation: glitch-anim2 1s infinite linear alternate-reverse;
  }

  @keyframes glitch-anim {
    0% {
      clip: rect(31px, 9999px, 94px, 0);
      transform: skew(0.5deg);
    }
    5% {
      clip: rect(42px, 9999px, 76px, 0);
      transform: skew(0.5deg);
    }
    10% {
      clip: rect(8px, 9999px, 99px, 0);
      transform: skew(0.5deg);
    }
    15% {
      clip: rect(42px, 9999px, 31px, 0);
      transform: skew(0.5deg);
    }
    20% {
      clip: rect(92px, 9999px, 98px, 0);
      transform: skew(0.5deg);
    }
    25% {
      clip: rect(9px, 9999px, 98px, 0);
      transform: skew(0.5deg);
    }
    30% {
      clip: rect(25px, 9999px, 97px, 0);
      transform: skew(0.5deg);
    }
    35% {
      clip: rect(87px, 9999px, 94px, 0);
      transform: skew(0.5deg);
    }
    40% {
      clip: rect(11px, 9999px, 16px, 0);
      transform: skew(0.5deg);
    }
    45% {
      clip: rect(66px, 9999px, 85px, 0);
      transform: skew(0.5deg);
    }
    50% {
      clip: rect(11px, 9999px, 9px, 0);
      transform: skew(0.5deg);
    }
    55% {
      clip: rect(88px, 9999px, 53px, 0);
      transform: skew(0.5deg);
    }
    60% {
      clip: rect(80px, 9999px, 5px, 0);
      transform: skew(0.5deg);
    }
    65% {
      clip: rect(37px, 9999px, 14px, 0);
      transform: skew(0.5deg);
    }
    70% {
      clip: rect(51px, 9999px, 57px, 0);
      transform: skew(0.5deg);
    }
    75% {
      clip: rect(10px, 9999px, 81px, 0);
      transform: skew(0.5deg);
    }
    80% {
      clip: rect(70px, 9999px, 57px, 0);
      transform: skew(0.5deg);
    }
    85% {
      clip: rect(6px, 9999px, 30px, 0);
      transform: skew(0.5deg);
    }
    90% {
      clip: rect(67px, 9999px, 73px, 0);
      transform: skew(0.5deg);
    }
    95% {
      clip: rect(23px, 9999px, 30px, 0);
      transform: skew(0.5deg);
    }
    100% {
      clip: rect(58px, 9999px, 73px, 0);
      transform: skew(0.5deg);
    }
  }

  @keyframes glitch-anim2 {
    0% {
      clip: rect(65px, 9999px, 100px, 0);
      transform: skew(0.5deg);
    }
    5% {
      clip: rect(96px, 9999px, 9px, 0);
      transform: skew(0.5deg);
    }
    10% {
      clip: rect(28px, 9999px, 84px, 0);
      transform: skew(0.5deg);
    }
    15% {
      clip: rect(66px, 9999px, 11px, 0);
      transform: skew(0.5deg);
    }
    20% {
      clip: rect(58px, 9999px, 14px, 0);
      transform: skew(0.5deg);
    }
    25% {
      clip: rect(11px, 9999px, 35px, 0);
      transform: skew(0.5deg);
    }
    30% {
      clip: rect(88px, 9999px, 2px, 0);
      transform: skew(0.5deg);
    }
    35% {
      clip: rect(36px, 9999px, 23px, 0);
      transform: skew(0.5deg);
    }
    40% {
      clip: rect(73px, 9999px, 85px, 0);
      transform: skew(0.5deg);
    }
    45% {
      clip: rect(3px, 9999px, 14px, 0);
      transform: skew(0.5deg);
    }
    50% {
      clip: rect(66px, 9999px, 50px, 0);
      transform: skew(0.5deg);
    }
    55% {
      clip: rect(40px, 9999px, 78px, 0);
      transform: skew(0.5deg);
    }
    60% {
      clip: rect(54px, 9999px, 32px, 0);
      transform: skew(0.5deg);
    }
    65% {
      clip: rect(32px, 9999px, 11px, 0);
      transform: skew(0.5deg);
    }
    70% {
      clip: rect(44px, 9999px, 78px, 0);
      transform: skew(0.5deg);
    }
    75% {
      clip: rect(21px, 9999px, 19px, 0);
      transform: skew(0.5deg);
    }
    80% {
      clip: rect(88px, 9999px, 29px, 0);
      transform: skew(0.5deg);
    }
    85% {
      clip: rect(58px, 9999px, 55px, 0);
      transform: skew(0.5deg);
    }
    90% {
      clip: rect(46px, 9999px, 38px, 0);
      transform: skew(0.5deg);
    }
    95% {
      clip: rect(95px, 9999px, 21px, 0);
      transform: skew(0.5deg);
    }
    100% {
      clip: rect(14px, 9999px, 99px, 0);
      transform: skew(0.5deg);
    }
  }
  """

  attr :text, :string, required: true

  def glitch_text(assigns) do
    ~H"""
    <.capsule module={__MODULE__}>
      <div class="glitch-text" data-text={@text}>
        <%= @text %>
      </div>
    </.capsule>
    """
  end
end
