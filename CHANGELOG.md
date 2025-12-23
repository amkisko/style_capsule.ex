# CHANGELOG

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
