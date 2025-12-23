defmodule PhoenixDemoWeb.StaticPaths do
  # Include "capsules" so file-based cached CSS from StyleCapsule can be served
  # from "priv/static/capsules" at "/capsules/..." URLs.
  def static_paths, do: ~w(assets fonts images capsules favicon.ico robots.txt)
end
