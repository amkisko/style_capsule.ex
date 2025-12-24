defmodule PhoenixDemoWeb.Layouts do
  use PhoenixDemoWeb, :html

  embed_templates "layouts/*"

  @doc """
  Determines the namespace for the current page based on the route.
  Returns the namespace atom or nil if no specific namespace is needed.
  """
  def page_namespace(assigns) do
    # Try multiple methods to get the LiveView module
    module =
      cond do
        # Method 1: From socket.view (most reliable for LiveView)
        Map.has_key?(assigns, :socket) && is_map(assigns.socket) && Map.has_key?(assigns.socket, :view) ->
          assigns.socket.view

        # Method 2: From live_module assign
        Map.has_key?(assigns, :live_module) && not is_nil(assigns.live_module) ->
          assigns.live_module

        # Method 3: From URI path (fallback)
        true ->
          path = get_in(assigns, [:uri, :path]) || get_in(assigns, [:request_path]) || "/"
          case path do
            "/" -> PhoenixDemoWeb.PageLive
            "/showcase" -> PhoenixDemoWeb.ShowcaseLive
            "/features" -> PhoenixDemoWeb.FeaturesLive
            _ -> nil
          end
      end

    # Determine namespace from the LiveView module
    case module do
      PhoenixDemoWeb.PageLive -> :home
      PhoenixDemoWeb.ShowcaseLive -> :showcase
      PhoenixDemoWeb.FeaturesLive -> :features
      _ -> nil
    end
  end

  def global_styles do
    """
    * {
      box-sizing: border-box;
    }

    body {
      margin: 0;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
      font-size: 16px;
      line-height: 1.5;
      color: #1a202c;
      background: #f7fafc;
    }

    .container {
      max-width: 1200px;
      margin: 0 auto;
      padding: 0 1rem;
    }

    header {
      background: white;
      border-bottom: 1px solid #e2e8f0;
      padding: 1rem 0;
    }

    nav ul {
      list-style: none;
      margin: 0;
      padding: 0;
      display: flex;
      gap: 1.5rem;
    }

    nav a {
      color: #4a5568;
      text-decoration: none;
      font-weight: 500;
    }

    nav a:hover {
      color: #2d3748;
    }

    main {
      padding: 2rem 0;
    }

    h1 {
      font-size: 2rem;
      font-weight: 700;
      margin: 0 0 1.5rem 0;
      color: #1a202c;
    }

    .py-8 {
      padding-top: 2rem;
      padding-bottom: 2rem;
    }

    .mb-6 {
      margin-bottom: 1.5rem;
    }

    .space-y-6 > * + * {
      margin-top: 1.5rem;
    }

    .space-x-4 > * + * {
      margin-left: 1rem;
    }

    code {
      background: #edf2f7;
      padding: 0.125rem 0.375rem;
      border-radius: 0.25rem;
      font-family: "Monaco", "Menlo", "Ubuntu Mono", monospace;
      font-size: 0.875em;
      color: #e53e3e;
    }

    p {
      margin: 0 0 1rem 0;
    }

    p:last-child {
      margin-bottom: 0;
    }

    /* Utility classes */
    .max-w-6xl { max-width: 72rem; }
    .max-w-7xl { max-width: 80rem; }
    .mx-auto { margin-left: auto; margin-right: auto; }
    .px-4 { padding-left: 1rem; padding-right: 1rem; }
    .py-12 { padding-top: 3rem; padding-bottom: 3rem; }
    .mb-2 { margin-bottom: 0.5rem; }
    .mb-6 { margin-bottom: 1.5rem; }
    .mb-12 { margin-bottom: 3rem; }
    .mt-2 { margin-top: 0.5rem; }
    .mt-4 { margin-top: 1rem; }
    .text-4xl { font-size: 2.25rem; line-height: 2.5rem; }
    .text-2xl { font-size: 1.5rem; line-height: 2rem; }
    .text-lg { font-size: 1.125rem; line-height: 1.75rem; }
    .text-sm { font-size: 0.875rem; line-height: 1.25rem; }
    .text-xs { font-size: 0.75rem; line-height: 1rem; }
    .font-bold { font-weight: 700; }
    .font-semibold { font-weight: 600; }
    .text-gray-900 { color: #111827; }
    .text-gray-600 { color: #4b5563; }
    .text-gray-500 { color: #6b7280; }
    .text-white { color: #ffffff; }
    .text-white\/80 { color: rgba(255, 255, 255, 0.8); }
    .text-blue-600 { color: #2563eb; }
    .hover\:underline:hover { text-decoration: underline; }
    .grid { display: grid; }
    .grid-cols-1 { grid-template-columns: repeat(1, minmax(0, 1fr)); }
    .gap-4 { gap: 1rem; }
    .gap-6 { gap: 1.5rem; }
    .space-y-1 > * + * { margin-top: 0.25rem; }
    .space-y-2 > * + * { margin-top: 0.5rem; }
    .space-y-4 > * + * { margin-top: 1rem; }
    .space-x-4 > * + * { margin-left: 1rem; }
    .list-disc { list-style-type: disc; }
    .list-inside { list-style-position: inside; }
    .min-h-screen { min-height: 100vh; }
    .bg-gradient-to-br { background-image: linear-gradient(to bottom right, var(--tw-gradient-stops)); }
    .from-purple-400 { --tw-gradient-from: #a78bfa; --tw-gradient-stops: var(--tw-gradient-from), var(--tw-gradient-to, rgba(167, 139, 250, 0)); }
    .via-pink-500 { --tw-gradient-to: rgba(236, 72, 153, 0); --tw-gradient-stops: var(--tw-gradient-from), #ec4899, var(--tw-gradient-to); }
    .to-red-500 { --tw-gradient-to: #ef4444; }
    .bg-gray-50 { background-color: #f9fafb; }
    .bg-gray-100 { background-color: #f3f4f6; }
    .bg-gray-200 { background-color: #e5e7eb; }
    .bg-gray-900 { background-color: #111827; }
    .bg-white\/10 { background-color: rgba(255, 255, 255, 0.1); }
    .bg-white\/5 { background-color: rgba(255, 255, 255, 0.05); }
    .bg-white\/20 { background-color: rgba(255, 255, 255, 0.2); }
    .backdrop-blur-lg { backdrop-filter: blur(16px); }
    .rounded { border-radius: 0.25rem; }
    .rounded-lg { border-radius: 0.5rem; }
    .rounded-2xl { border-radius: 1rem; }
    .p-4 { padding: 1rem; }
    .p-8 { padding: 2rem; }
    .overflow-x-auto { overflow-x: auto; }
    .font-mono { font-family: ui-monospace, SFMono-Regular, "SF Mono", Menlo, Consolas, "Liberation Mono", monospace; }
    .text-purple-300 { color: #c4b5fd; }
    .text-yellow-300 { color: #fde047; }
    .text-green-300 { color: #86efac; }
    .text-blue-300 { color: #93c5fd; }
    .text-gray-100 { color: #f3f4f6; }
    .text-gray-400 { color: #9ca3af; }

    @media (min-width: 768px) {
      .md\:grid-cols-2 { grid-template-columns: repeat(2, minmax(0, 1fr)); }
      .md\:grid-cols-3 { grid-template-columns: repeat(3, minmax(0, 1fr)); }
    }

    @media (min-width: 1024px) {
      .lg\:grid-cols-3 { grid-template-columns: repeat(3, minmax(0, 1fr)); }
      .lg\:grid-cols-4 { grid-template-columns: repeat(4, minmax(0, 1fr)); }
    }
    """
  end
end
