defmodule PhoenixDemoWeb.ShowcaseLive do
  @moduledoc """
  Showcase page featuring modern CSS effects and animations.
  """
  use PhoenixDemoWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-purple-400 via-pink-500 to-red-500 py-12 px-4">
      <div class="max-w-6xl mx-auto">
        <PhoenixDemoWeb.Components.ShowcaseHeader.showcase_header
          title="Modern CSS Showcase"
          description="Advanced CSS effects and animations with StyleCapsule"
        />

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-12">
          <PhoenixDemoWeb.Components.GlassmorphismCard.glassmorphism_card
            title="Glassmorphism"
            badge="Modern"
          >
            <p>Frosted glass effect using backdrop-filter and rgba colors. Perfect for modern UI designs.</p>
          </PhoenixDemoWeb.Components.GlassmorphismCard.glassmorphism_card>

          <PhoenixDemoWeb.Components.AnimatedCard.animated_card
            icon="🎨"
            title="Animated Card"
          >
            <p>CSS keyframe animations with fade-in and shimmer effects. Smooth transitions on hover.</p>
          </PhoenixDemoWeb.Components.AnimatedCard.animated_card>

          <PhoenixDemoWeb.Components.HoverTiltCard.hover_tilt_card title="3D Tilt Effect">
            <p>Interactive card with 3D perspective transforms. Hover to see the tilt animation in action.</p>
          </PhoenixDemoWeb.Components.HoverTiltCard.hover_tilt_card>

          <PhoenixDemoWeb.Components.CardFlip.card_flip
            front_title="Flip Me!"
            back_title="Surprise!"
            front_content="Hover to flip"
            back_content="3D card flip effect"
          />

          <PhoenixDemoWeb.Components.ClipPathShape.clip_path_shape shape="star">
            <h3 class="text-xl font-bold mb-2">Star Shape</h3>
            <p>Custom shapes using CSS clip-path property</p>
          </PhoenixDemoWeb.Components.ClipPathShape.clip_path_shape>

          <PhoenixDemoWeb.Components.ParallaxCard.parallax_card title="Parallax Effect">
            <p>Animated background with parallax scrolling effect using CSS transforms.</p>
          </PhoenixDemoWeb.Components.ParallaxCard.parallax_card>
        </div>

        <div class="bg-white/10 backdrop-blur-lg rounded-2xl p-8 mb-12">
          <h2 class="text-2xl font-bold text-white mb-6 text-center">Text Effects</h2>
          <div class="space-y-8">
            <div class="text-center">
              <PhoenixDemoWeb.Components.NeonGlowText.neon_glow_text color="cyan">
                Neon Glow
              </PhoenixDemoWeb.Components.NeonGlowText.neon_glow_text>
              <p class="text-white/80 mt-2 text-sm">Animated neon text with flickering glow effect</p>
            </div>
            <div class="text-center">
              <PhoenixDemoWeb.Components.NeonGlowText.neon_glow_text color="pink">
                Pink Neon
              </PhoenixDemoWeb.Components.NeonGlowText.neon_glow_text>
            </div>
            <div class="text-center">
              <PhoenixDemoWeb.Components.TextReveal.text_reveal text="Reveal Animation" />
              <p class="text-white/80 mt-2 text-sm">Character-by-character reveal animation</p>
            </div>
            <div class="text-center bg-black/30 p-6 rounded-lg">
              <PhoenixDemoWeb.Components.GlitchText.glitch_text text="GLITCH EFFECT" />
              <p class="text-white/80 mt-2 text-sm">Distorted glitch animation with color shifts</p>
            </div>
          </div>
        </div>

        <div class="bg-white/10 backdrop-blur-lg rounded-2xl p-8 mb-12">
          <h2 class="text-2xl font-bold text-white mb-6 text-center">Gradient Buttons</h2>
          <div class="flex flex-wrap gap-4 justify-center">
            <PhoenixDemoWeb.Components.GradientButton.gradient_button variant="primary">
              Primary Gradient
            </PhoenixDemoWeb.Components.GradientButton.gradient_button>
            <PhoenixDemoWeb.Components.GradientButton.gradient_button variant="secondary">
              Secondary Gradient
            </PhoenixDemoWeb.Components.GradientButton.gradient_button>
            <PhoenixDemoWeb.Components.GradientButton.gradient_button variant="success">
              Success Gradient
            </PhoenixDemoWeb.Components.GradientButton.gradient_button>
          </div>
          <p class="text-white/80 mt-4 text-sm text-center">
            Buttons with animated gradient overlays. Uses <code class="bg-white/20 px-1 rounded">cache_strategy: :time</code> for time-based caching.
          </p>
        </div>

        <div class="bg-white/10 backdrop-blur-lg rounded-2xl p-8 mb-12">
          <h2 class="text-2xl font-bold text-white mb-6 text-center">Morphing Blob</h2>
          <PhoenixDemoWeb.Components.MorphingBlob.morphing_blob>
            <div>
              <h3 class="text-2xl font-bold mb-2">Fluid Shapes</h3>
              <p>Animated morphing blob with fluid transitions using CSS border-radius and transforms</p>
            </div>
          </PhoenixDemoWeb.Components.MorphingBlob.morphing_blob>
        </div>

        <div class="bg-white/10 backdrop-blur-lg rounded-2xl p-8 mb-12">
          <h2 class="text-2xl font-bold text-white mb-6 text-center">Loading Spinners</h2>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div class="text-center">
              <PhoenixDemoWeb.Components.LoadingSpinner.loading_spinner style="ring" />
              <p class="text-white/80 mt-2 text-sm">Ring Spinner</p>
            </div>
            <div class="text-center">
              <PhoenixDemoWeb.Components.LoadingSpinner.loading_spinner style="dots" />
              <p class="text-white/80 mt-2 text-sm">Bouncing Dots</p>
            </div>
            <div class="text-center">
              <PhoenixDemoWeb.Components.LoadingSpinner.loading_spinner style="pulse" />
              <p class="text-white/80 mt-2 text-sm">Pulse Effect</p>
            </div>
          </div>
        </div>

        <div class="bg-white/10 backdrop-blur-lg rounded-2xl p-8">
          <h2 class="text-2xl font-bold text-white mb-6 text-center">Component Features</h2>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div class="bg-white/5 rounded-lg p-4">
              <h3 class="text-lg font-semibold text-white mb-2">CSS Nesting Strategy</h3>
              <p class="text-white/80 text-sm">
                Glassmorphism cards use <code class="bg-white/20 px-1 rounded">strategy: :nesting</code> for modern browser support and faster rendering.
              </p>
            </div>
            <div class="bg-white/5 rounded-lg p-4">
              <h3 class="text-lg font-semibold text-white mb-2">Time-based Caching</h3>
              <p class="text-white/80 text-sm">
                Gradient buttons use <code class="bg-white/20 px-1 rounded">cache_strategy: :time</code> for optimal performance.
              </p>
            </div>
            <div class="bg-white/5 rounded-lg p-4">
              <h3 class="text-lg font-semibold text-white mb-2">Keyframe Animations</h3>
              <p class="text-white/80 text-sm">
                Multiple components showcase CSS @keyframes with various effects and transitions.
              </p>
            </div>
            <div class="bg-white/5 rounded-lg p-4">
              <h3 class="text-lg font-semibold text-white mb-2">3D Transforms</h3>
              <p class="text-white/80 text-sm">
                Cards with 3D perspective, tilt effects, and flip animations using CSS transforms.
              </p>
            </div>
            <div class="bg-white/5 rounded-lg p-4">
              <h3 class="text-lg font-semibold text-white mb-2">Clip Path Shapes</h3>
              <p class="text-white/80 text-sm">
                Custom geometric shapes using CSS clip-path for creative layouts.
              </p>
            </div>
            <div class="bg-white/5 rounded-lg p-4">
              <h3 class="text-lg font-semibold text-white mb-2">Text Effects</h3>
              <p class="text-white/80 text-sm">
                Neon glow, glitch, reveal, and gradient text animations with pure CSS.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
