defmodule StyleCapsule.Cache do
  @moduledoc """
  Cache strategies for scoped CSS to improve performance.

  Supports multiple caching strategies:
  - `:none` - No caching (default)
  - `:time` - Time-based caching with TTL
  - Custom function - User-defined caching logic
  """

  @type cache_key :: binary()
  @type cache_value :: binary()
  @type cache_strategy ::
          :none
          | :time
          | :file
          | (binary(), binary(), atom() -> {cache_key(), boolean(), integer() | nil})

  @ets_table :style_capsule_css_cache

  @doc """
  Gets cached CSS or computes it using the provided function.

  ## Options

    * `:strategy` - Cache strategy (`:none`, `:time`, or a function). Defaults to `:none`.
    * `:ttl` - Time to live in milliseconds (for `:time` strategy). Defaults to 3600000 (1 hour).
    * `:namespace` - Namespace for cache key. Defaults to `:default`.

  ## Examples

      iex> compute_fn = fn -> "[data-capsule=\\"abc\\"] .test { color: red; }" end
      iex> StyleCapsule.Cache.get_or_compute("abc", "test", compute_fn, strategy: :time, ttl: 1000)
      "[data-capsule=\\"abc\\"] .test { color: red; }"

  """
  def get_or_compute(capsule_id, css_source, compute_fn, opts \\ []) do
    strategy = Keyword.get(opts, :strategy, :none)
    namespace = Keyword.get(opts, :namespace, :default)

    case strategy do
      :none ->
        compute_fn.()

      :time ->
        ttl = Keyword.get(opts, :ttl, 3_600_000)
        get_or_compute_time(capsule_id, css_source, namespace, compute_fn, ttl)

      :file ->
        get_or_compute_file(capsule_id, css_source, namespace, compute_fn, opts)

      fun when is_function(fun, 3) ->
        get_or_compute_custom(capsule_id, css_source, namespace, compute_fn, fun)

      other ->
        raise ArgumentError, "Unknown cache strategy: #{inspect(other)}"
    end
  end

  @doc """
  Clears the cache for a specific key or all keys.

  ## Examples

      iex> StyleCapsule.Cache.clear()
      :ok

      iex> StyleCapsule.Cache.clear("abc123")
      :ok

  """
  def clear(key \\ :all) do
    ensure_ets_table()

    case key do
      :all ->
        :ets.delete_all_objects(@ets_table)
        :ok

      key when is_binary(key) ->
        :ets.delete(@ets_table, key)
        :ok

      _ ->
        {:error, "Invalid cache key"}
    end
  end

  # Private functions

  @doc false
  defp get_or_compute_time(capsule_id, css_source, namespace, compute_fn, ttl) do
    ensure_ets_table()

    cache_key = build_cache_key(capsule_id, css_source, namespace)
    now = System.system_time(:millisecond)

    case :ets.lookup(@ets_table, cache_key) do
      [{^cache_key, css, expires_at}] when expires_at > now ->
        css

      _ ->
        css = compute_fn.()
        expires_at = now + ttl
        :ets.insert(@ets_table, {cache_key, css, expires_at})
        css
    end
  end

  @doc false
  defp get_or_compute_custom(capsule_id, css_source, namespace, compute_fn, cache_fun) do
    ensure_ets_table()

    {cache_key, should_cache, expires_at} = cache_fun.(css_source, capsule_id, namespace)

    if should_cache do
      now = System.system_time(:millisecond)

      case :ets.lookup(@ets_table, cache_key) do
        [{^cache_key, css, cached_expires_at}] when cached_expires_at > now ->
          css

        _ ->
          css = compute_fn.()
          :ets.insert(@ets_table, {cache_key, css, expires_at || :infinity})
          css
      end
    else
      compute_fn.()
    end
  end

  @doc false
  defp get_or_compute_file(capsule_id, _css_source, namespace, compute_fn, opts) do
    # For file-based caching, we always compute CSS and write it to disk.
    # The CSS itself is still returned so it can be used inline if desired.
    css = compute_fn.()

    file_opts =
      opts
      |> Keyword.take([:output_dir, :fallback_dir, :filename_pattern])
      |> Keyword.put(:namespace, namespace)

    _ = StyleCapsule.FileWriter.write(capsule_id, css, file_opts)

    css
  end

  @doc false
  defp build_cache_key(capsule_id, css_source, namespace) do
    hash =
      :crypto.hash(:sha256, "#{capsule_id}:#{namespace}:#{css_source}")
      |> Base.encode16(case: :lower)

    "style_capsule:#{hash}"
  end

  @doc false
  defp ensure_ets_table do
    case :ets.whereis(@ets_table) do
      :undefined ->
        :ets.new(@ets_table, [:named_table, :public, :set, {:read_concurrency, true}])

      _pid ->
        :ok
    end
  end
end
