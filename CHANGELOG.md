# CHANGELOG

## 0.9.0 (2026-09-04)

- Rename `StyleCapsule.Registry` to `StyleCapsule.StylesheetRegistry`; keep `StyleCapsule.Registry` as a deprecated delegate for this release
- Store the compile-time component registry as Erlang terms so build tasks no longer evaluate Elixir source
- Scope `:host()`, `:host-context()`, and `:host` descendants without doubling the capsule prefix
- Leave `@media` queries and keyframe stops unprefixed while scoping inner selectors
- Escape stylesheet href values in rendered link tags
- Reject CSS that contains a style tag closer
- Reject wrapper tags that are not ordinary HTML names
- Refuse file writes whose filename leaves the output directory
- Raise `ArgumentError` for an invalid capsule wrapper tag instead of `CapsuleNotFoundError`
- Surface `register_inline` failures instead of swallowing them
- Keep precompiled stylesheet URLs relative to `priv/static` when the build path is absolute
- Pin the documented Phoenix stack to Phoenix `~> 1.8` and LiveView `~> 1.1`

## 0.8.0

- Updated Phoenix stack dependency versions
- Silenced non-error test logging in test helper
- Fixed HEEx examples in phoenix_demo LiveView

## 0.7.0

- Added conditional namespace-based stylesheet loading via `:namespace` option in `render_precompiled_stylesheets/1`
- Fixed function component style registration - components without `render/1` now properly register styles at runtime
- Improved runtime registry path resolution for better reliability across different deployment scenarios
- Enhanced `precompiled_stylesheet_links/1` to support namespace filtering for page-specific CSS loading

## 0.6.0

- Introduced Phlex support into `StyleCapsule.PhlexComponent` module - `StyleCapsule.Component` is now exclusively for Phoenix LiveView components
- Added compile-time component registration via `StyleCapsule.CompileRegistry`
- Enhanced build task to discover and register missing components automatically
- Improved namespace isolation in generated CSS files
- Added configuration option to control CSS comments in generated files

## 0.5.1

- Fixed README documentation: corrected statement about Phoenix example apps availability
- Fixed incorrect path dependency example in README (removed extra `/style_capsule` segment)
- Fixed escaped quotes in code examples throughout README

## 0.5.0

- Initial public release of `style_capsule.ex`
- Attribute-based CSS scoping for Phoenix LiveView components and standalone Elixir apps
- Component-scoped CSS encapsulation using `[data-capsule="..."]` selectors
- Per-component-type scope IDs (shared across all instances)
- Automatic HTML wrapping with scoped elements
- CSS processor with support for regular selectors, pseudo-classes, `@media` queries, and component-scoped `:host` selectors
- Request/socket-scoped stylesheet registry with namespace support
- Multiple caching strategies: no caching, time-based, custom function, and file-based caching
- File-based caching with Mix tasks for build/clear/verify
- Security features: path traversal protection, CSS size limits (1MB), scope ID validation, filename validation
- Elixir >= 1.18 requirement
- Comprehensive test suite with property-based tests and integration tests
