defmodule StyleCapsule.CacheTest do
  use ExUnit.Case, async: false
  doctest StyleCapsule.Cache

  alias StyleCapsule.Cache

  setup do
    Cache.clear()
    :ok
  end

  describe "get_or_compute/5 with :none strategy" do
    test "always computes" do
      compute_fn = fn -> "computed" end
      result1 = Cache.get_or_compute("abc", "css", compute_fn, strategy: :none)
      result2 = Cache.get_or_compute("abc", "css", compute_fn, strategy: :none)

      assert result1 == "computed"
      assert result2 == "computed"
    end
  end

  describe "get_or_compute/5 with :time strategy" do
    test "caches for TTL duration" do
      compute_count = Agent.start_link(fn -> 0 end)
      {_, agent} = compute_count

      compute_fn = fn ->
        Agent.update(agent, fn count -> count + 1 end)
        "computed"
      end

      result1 = Cache.get_or_compute("abc", "css", compute_fn, strategy: :time, ttl: 1000)
      result2 = Cache.get_or_compute("abc", "css", compute_fn, strategy: :time, ttl: 1000)

      assert result1 == "computed"
      assert result2 == "computed"

      # Should only compute once
      count = Agent.get(agent, fn count -> count end)
      assert count == 1
    end

    test "expires after TTL" do
      compute_count = Agent.start_link(fn -> 0 end)
      {_, agent} = compute_count

      compute_fn = fn ->
        Agent.update(agent, fn count -> count + 1 end)
        "computed"
      end

      Cache.get_or_compute("abc", "css", compute_fn, strategy: :time, ttl: 10)
      Process.sleep(20)
      Cache.get_or_compute("abc", "css", compute_fn, strategy: :time, ttl: 10)

      count = Agent.get(agent, fn count -> count end)
      assert count == 2
    end
  end

  describe "clear/1" do
    test "clears all cache" do
      compute_fn = fn -> "computed" end
      Cache.get_or_compute("abc", "css", compute_fn, strategy: :time, ttl: 1000)
      Cache.clear()

      # Cache should be empty, so should compute again
      compute_count = Agent.start_link(fn -> 0 end)
      {_, agent} = compute_count

      compute_fn2 = fn ->
        Agent.update(agent, fn count -> count + 1 end)
        "computed"
      end

      Cache.get_or_compute("abc", "css", compute_fn2, strategy: :time, ttl: 1000)
      count = Agent.get(agent, fn count -> count end)
      assert count == 1
    end
  end
end
