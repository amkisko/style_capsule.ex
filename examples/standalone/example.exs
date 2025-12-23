# This example must be run from the project root using: mix run examples/standalone/example.exs
# It starts a simple web server on http://localhost:4000 to display the results
#
# Note: Requires plug and plug_cowboy dependencies. If not available, install them:
# mix deps.get

alias StyleCapsule.{Config, Cache}
require Plug.Conn

css = """
.card {
  padding: 16px;
  border-radius: 8px;
  background: #fff;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.08);
}

.card::before {
  content: "Standalone capsule demo";
  display: block;
  font-size: 12px;
  color: #718096;
  margin-bottom: 4px;
  text-transform: uppercase;
  letter-spacing: 0.08em;
}
.card__title {
  font-size: 20px;
  font-weight: 600;
  margin-bottom: 8px;
}
.card__body {
  font-size: 14px;
  color: #444;
}
"""

capsule_id = StyleCapsule.capsule_id(:standalone_card)
scoped_css = StyleCapsule.scope_css(css, capsule_id)

# Create a second capsule ID for demonstration
capsule_id2 = StyleCapsule.capsule_id(:standalone_card_2)
scoped_css2 = StyleCapsule.scope_css(css, capsule_id2)

html = """
<div class="card">
  <div class="card__title">Hello</div>
  <div class="card__body">Standalone StyleCapsule usage</div>
</div>
"""

wrapped_html = StyleCapsule.wrap(html, capsule_id, tag: :section, attrs: [class: "card-wrapper"])

# Create a second card with different content to show scoping isolation
html2 = """
<div class="card">
  <div class="card__title">Another Card</div>
  <div class="card__body">This card uses the same CSS classes but is scoped separately</div>
</div>
"""
wrapped_html2 = StyleCapsule.wrap(html2, capsule_id2, tag: :section, attrs: [class: "card-wrapper"])

compute_fn = fn -> StyleCapsule.scope_css(css, capsule_id) end

cached_css =
  Cache.get_or_compute(capsule_id, css, compute_fn,
    strategy: :time,
    ttl: Config.default_ttl(),
    namespace: Config.default_namespace()
  )

# Create HTML page
html_page = """
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>StyleCapsule Standalone Example</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
      max-width: 1200px;
      margin: 0 auto;
      padding: 20px;
      background: #f5f5f5;
      color: #333;
      line-height: 1.6;
    }
    h1 {
      color: #333;
      border-bottom: 2px solid #4CAF50;
      padding-bottom: 10px;
      margin-top: 0;
    }
    h2 {
      color: #555;
      margin-top: 30px;
      border-left: 4px solid #4CAF50;
      padding-left: 10px;
    }
    .section {
      background: white;
      padding: 20px;
      margin: 20px 0;
      border-radius: 8px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
      color: #333;
    }
    .section ul {
      color: #333;
    }
    .section li {
      color: #333;
      margin: 8px 0;
    }
    pre {
      background: #f8f8f8;
      padding: 15px;
      border-radius: 4px;
      overflow-x: auto;
      border: 1px solid #ddd;
      color: #333;
    }
    code {
      font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
      font-size: 13px;
      color: #d63384;
      background: #f8f8f8;
      padding: 2px 4px;
      border-radius: 3px;
    }
    pre code {
      color: #333;
      background: transparent;
      padding: 0;
    }
    .demo {
      border: 2px dashed #ddd;
      padding: 20px;
      margin: 20px 0;
      background: #fafafa;
      min-height: 100px;
    }
    /* Scoped CSS for Card 1 */
    #{scoped_css}
    /* Scoped CSS for Card 2 */
    #{scoped_css2}
    .card-wrapper {
      margin: 20px 0;
    }
    /* Additional styles for demo section */
    .demo h3 {
      color: #666;
      font-size: 16px;
      margin: 20px 0 10px 0;
      font-weight: 600;
    }
    .demo p {
      color: #333;
      margin: 10px 0;
    }
  </style>
</head>
<body>
  <h1>🎨 StyleCapsule Standalone Example</h1>

  <div class="section">
    <h2>1. Original CSS</h2>
    <pre><code>#{String.replace(css, "<", "&lt;")}</code></pre>
  </div>

  <div class="section">
    <h2>2. Scoped CSS (with data-capsule attribute)</h2>
    <pre><code>#{String.replace(scoped_css, "<", "&lt;")}</code></pre>
  </div>

  <div class="section">
    <h2>3. Original HTML</h2>
    <pre><code>#{String.replace(html, "<", "&lt;")}</code></pre>
  </div>

  <div class="section">
    <h2>4. Wrapped HTML (with data-capsule attribute)</h2>
    <pre><code>#{String.replace(wrapped_html, "<", "&lt;")}</code></pre>
  </div>

  <div class="section">
    <h2>5. Live Demo (rendered with scoped CSS)</h2>
    <p><em>This demonstrates the scoped CSS in action. The cards below should have white background, padding, border-radius, and shadow. Notice how both cards use the same CSS classes but are scoped independently.</em></p>
    <div class="demo">
      <h3 style="color: #666; margin-top: 0;">Card 1 (Capsule ID: #{capsule_id})</h3>
      #{wrapped_html}
      <h3 style="color: #666; margin-top: 20px;">Card 2 (Capsule ID: #{capsule_id2})</h3>
      <p style="color: #999; font-size: 12px; margin: 10px 0;"><em>Note: Card 2 uses a different capsule ID, so it won't be styled by the scoped CSS above. This demonstrates style isolation.</em></p>
      #{wrapped_html2}
    </div>
    <p><small><strong>Note:</strong> Each card is wrapped in a <code>&lt;section data-capsule="..."&gt;</code> element, and the CSS is scoped to only apply within elements matching that specific capsule ID. This prevents style leakage between components.</small></p>
  </div>

  <div class="section">
    <h2>6. Cached CSS (time-based cache)</h2>
    <pre><code>#{String.replace(cached_css, "<", "&lt;")}</code></pre>
  </div>

  <div class="section">
    <h2>7. Configuration</h2>
    <ul>
      <li><strong>Capsule ID:</strong> <code>#{capsule_id}</code></li>
      <li><strong>Output directory:</strong> <code>#{Config.output_dir()}</code></li>
      <li><strong>Fallback directory:</strong> <code>#{Config.fallback_dir()}</code></li>
      <li><strong>Default namespace:</strong> <code>#{Config.default_namespace()}</code></li>
      <li><strong>Default TTL:</strong> <code>#{Config.default_ttl()}ms</code></li>
    </ul>
  </div>
</body>
</html>
"""

# Simple Plug router
defmodule StyleCapsuleExample.Router do
  use Plug.Router

  plug Plug.Logger
  plug :match
  plug :dispatch

  get "/" do
    send_html(conn, unquote(Macro.escape(html_page)))
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end

  defp send_html(conn, html) do
    conn
    |> Plug.Conn.put_resp_content_type("text/html")
    |> Plug.Conn.send_resp(200, html)
  end
end

# Start the server
IO.puts("""
╔══════════════════════════════════════════════════════════════╗
║  StyleCapsule Standalone Example Server                     ║
╚══════════════════════════════════════════════════════════════╝

🚀 Starting web server on http://localhost:4000
📖 Open your browser and visit: http://localhost:4000

Press Ctrl+C to stop the server.
""")

case Code.ensure_loaded(Plug.Cowboy) do
  {:module, _} ->
    {:ok, _} = Plug.Cowboy.http(StyleCapsuleExample.Router, [], port: 4000)
    # Keep the process alive
    Process.sleep(:infinity)

  {:error, _} ->
    IO.puts("""
    ❌ Error: Plug.Cowboy is not available.

    Please install the required dependencies:
      mix deps.get

    Or add to your mix.exs:
      {:plug, "~> 1.14", optional: true}
      {:plug_cowboy, "~> 2.6", optional: true}
    """)
    System.halt(1)
end
