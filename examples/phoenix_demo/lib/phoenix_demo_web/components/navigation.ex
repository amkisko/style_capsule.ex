defmodule PhoenixDemoWeb.Components.Navigation do
  @moduledoc """
  Navigation component for the demo app.
  """
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :app

  @component_styles """
  .nav {
    background: white;
    border-bottom: 1px solid #e2e8f0;
    padding: 1rem 0;
    margin-bottom: 2rem;
  }

  .nav-container {
    max-width: 1280px;
    margin: 0 auto;
    padding: 0 1rem;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .nav-brand {
    font-size: 1.5rem;
    font-weight: 700;
    color: #1a202c;
    text-decoration: none;
  }

  .nav-brand:hover {
    color: #667eea;
  }

  .nav-links {
    display: flex;
    gap: 2rem;
    list-style: none;
    margin: 0;
    padding: 0;
  }

  .nav-link {
    color: #4a5568;
    text-decoration: none;
    font-weight: 500;
    transition: color 0.2s;
    position: relative;
  }

  .nav-link:hover {
    color: #667eea;
  }

  .nav-link.active {
    color: #667eea;
  }

  .nav-link.active::after {
    content: '';
    position: absolute;
    bottom: -0.5rem;
    left: 0;
    right: 0;
    height: 2px;
    background: #667eea;
  }
  """

  def navigation(assigns) do
    # Ensure styles are registered before rendering
    # This is a function component, so we need to register styles explicitly
    if function_exported?(__MODULE__, :styles, 0) do
      styles = __MODULE__.styles()
      if styles && styles != "" do
        capsule_id = StyleCapsule.capsule_id(__MODULE__)
        spec = __MODULE__.style_capsule_spec()
        StyleCapsule.Phoenix.register_inline(styles, capsule_id,
          namespace: Map.get(spec, :namespace, :app),
          strategy: Map.get(spec, :strategy, :patch),
          cache_strategy: Map.get(spec, :cache_strategy, :none)
        )
      end
    end

    ~H"""
    <.capsule module={__MODULE__}>
      <nav class="nav">
        <div class="nav-container">
          <a href="/" class="nav-brand">StyleCapsule Demo</a>
          <ul class="nav-links">
            <li>
              <a href="/" class="nav-link" phx-click="nav" data-path="/">
                Home
              </a>
            </li>
            <li>
              <a href="/showcase" class="nav-link" phx-click="nav" data-path="/showcase">
                Showcase
              </a>
            </li>
            <li>
              <a href="/business" class="nav-link" phx-click="nav" data-path="/business">
                Business Cases
              </a>
            </li>
            <li>
              <a href="/features" class="nav-link" phx-click="nav" data-path="/features">
                Features
              </a>
            </li>
            <li>
              <a href="/namespaces" class="nav-link" phx-click="nav" data-path="/namespaces">
                Namespaces
              </a>
            </li>
          </ul>
        </div>
      </nav>
      <script>
        document.addEventListener('DOMContentLoaded', function() {
          const currentPath = window.location.pathname;
          document.querySelectorAll('.nav-link').forEach(function(link) {
            if (link.getAttribute('data-path') === currentPath ||
                (currentPath === '/' && link.getAttribute('data-path') === '/')) {
              link.classList.add('active');
            }
          });
        });
      </script>
    </.capsule>
    """
  end
end
