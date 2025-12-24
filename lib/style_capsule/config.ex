defmodule StyleCapsule.Config do
  @moduledoc """
  Centralized configuration access for StyleCapsule.

  Provides a single source of truth for all configuration values with sensible defaults.
  """

  @doc """
  Returns the output directory for file-based caching.

  Defaults to `"priv/static/capsules"`.

  ## Configuration

      config :style_capsule, :output_dir, "custom/path/capsules"

  """
  @spec output_dir() :: binary()
  def output_dir do
    Application.get_env(:style_capsule, :output_dir, "priv/static/capsules")
  end

  @doc """
  Returns the fallback directory for file-based caching when output directory is not writable.

  Defaults to `Path.join(output_dir(), "fallback")`.

  ## Configuration

      config :style_capsule, :fallback_dir, "/tmp/style_capsule"

  """
  @spec fallback_dir() :: binary()
  def fallback_dir do
    Application.get_env(:style_capsule, :fallback_dir, Path.join(output_dir(), "fallback"))
  end

  @doc """
  Returns the default namespace for styles.

  Defaults to `:default`.

  ## Configuration

      config :style_capsule, :default_namespace, :app

  """
  @spec default_namespace() :: atom()
  def default_namespace do
    Application.get_env(:style_capsule, :default_namespace, :default)
  end

  @doc """
  Returns the default CSS scoping strategy.

  Defaults to `:patch`.

  ## Configuration

      config :style_capsule, :default_strategy, :nesting

  """
  @spec default_strategy() :: :patch | :nesting
  def default_strategy do
    Application.get_env(:style_capsule, :default_strategy, :patch)
  end

  @doc """
  Returns the default cache strategy.

  Defaults to `:none`.

  ## Configuration

      config :style_capsule, :default_cache_strategy, :time

  """
  @spec default_cache_strategy() :: :none | :time | :file | function()
  def default_cache_strategy do
    Application.get_env(:style_capsule, :default_cache_strategy, :none)
  end

  @doc """
  Returns the default TTL for time-based caching in milliseconds.

  Defaults to `3_600_000` (1 hour).

  ## Configuration

      config :style_capsule, :default_ttl, 1_800_000  # 30 minutes

  """
  @spec default_ttl() :: non_neg_integer()
  def default_ttl do
    Application.get_env(:style_capsule, :default_ttl, 3_600_000)
  end

  @doc """
  Returns the maximum allowed CSS size in bytes.

  Defaults to `1_000_000` (1 MB).

  ## Configuration

      config :style_capsule, :max_css_size, 500_000

  """
  @spec max_css_size() :: non_neg_integer()
  def max_css_size do
    Application.get_env(:style_capsule, :max_css_size, 1_000_000)
  end

  @doc """
  Returns whether to include comments in generated CSS files.

  Defaults to `true` (comments included for easier debugging).
  Set to `false` for production builds to reduce file size.

  ## Configuration

      config :style_capsule, :include_comments, false

  """
  @spec include_comments() :: boolean()
  def include_comments do
    Application.get_env(:style_capsule, :include_comments, true)
  end
end
