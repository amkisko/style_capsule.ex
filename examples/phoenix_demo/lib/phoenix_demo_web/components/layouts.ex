defmodule PhoenixDemoWeb.Layouts do
  use PhoenixDemoWeb, :html

  embed_templates "layouts/*"

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
    """
  end
end

