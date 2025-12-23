# StyleCapsule Benchmarks

This directory contains performance benchmarks for StyleCapsule operations.

## Running Benchmarks

### Using Mix Task (Recommended)

```bash
# Run all benchmarks
mix style_capsule.bench

# Run specific benchmark suite
mix style_capsule.bench css_processor
mix style_capsule.bench id_generation
mix style_capsule.bench cache
mix style_capsule.bench file_writer
```

### Direct Execution

You can also run benchmarks directly using `elixir`:

```bash
elixir benchmarks/all.exs
elixir benchmarks/css_processor.exs
elixir benchmarks/id_generation.exs
elixir benchmarks/cache.exs
elixir benchmarks/file_writer.exs
```

## Benchmark Suites

### `all.exs`
Comprehensive benchmark suite covering all major operations:
- ID generation
- CSS scoping (patch and nesting strategies)
- Cache operations
- File writing

### `css_processor.exs`
CSS processing performance with different:
- CSS sizes (small, medium, large, very large)
- Scoping strategies (`:patch` vs `:nesting`)

### `id_generation.exs`
Capsule ID generation performance:
- Generation from modules
- Generation from terms
- Generation with prefixes
- Generation with custom lengths
- ID validation

### `cache.exs`
Cache strategy performance:
- No caching (`:none`)
- Time-based caching (hits and misses)
- Custom function caching
- Cache clearing operations

### `file_writer.exs`
File writing performance:
- Different CSS sizes
- Custom filename patterns
- Namespace handling

## Output

Each benchmark generates:
- **Console output**: Real-time statistics and comparisons
- **HTML reports**: Detailed reports saved to `benchmarks/output/` directory

Open the HTML files in a browser for detailed performance analysis with:
- Execution time statistics
- Memory usage metrics
- Comparison charts
- Extended statistics

## Interpreting Results

- **IPS (Iterations Per Second)**: Higher is better
- **Average**: Mean execution time
- **Median**: Middle value (less affected by outliers)
- **99th %ile**: 99% of runs are faster than this
- **Memory**: Memory usage per operation

## Performance Targets

Based on typical usage:
- **ID generation**: Should be < 1μs per operation ✅ (Actual: ~0.64μs)
- **CSS scoping (small)**: Should be < 10μs per operation ✅ (Actual: 1.40-4.80μs)
- **CSS scoping (large)**: Should be < 100μs per operation ✅
- **Cache hit**: Should be < 1μs per operation ⚠️ (Actual: ~1.71μs, still excellent)
- **File write**: Depends on filesystem, typically < 1ms ✅ (Actual: ~85μs)

**Note**: Nesting strategy is ~3.4x faster than patch strategy (1.40μs vs 4.80μs), making it the preferred choice when browser support is available.

## Continuous Benchmarking

For CI/CD integration, you can add benchmark checks:

```bash
# Run benchmarks and check for regressions
mix style_capsule.bench all
```

Consider setting up automated benchmarking in CI to detect performance regressions.

