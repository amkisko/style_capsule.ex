# Safe compile registry

## Decisions

Compile registry data is persisted as an Erlang external term and decoded with the safe option. Decoded content must satisfy the registry schema before use. Writes use a same-directory temporary file and atomic rename.

Executable .exs evaluation and the home-directory lookup fallback were removed. Registry lookup stays within the current project and build context.

## Effects

Tampering with registry data can no longer execute Elixir code during compilation or registry reads. A regression test supplies a malicious executable-looking registry and verifies that it is rejected without side effects.

mix quality passed Credo, Dialyzer with zero errors, and 25 doctests, 4 properties, and 229 tests. mix hex.audit reported no retired packages.

## Next

- Version the term schema before adding fields that cannot be safely ignored.
- Continue treating all registry bytes as untrusted build input.

## Source

- lib/style_capsule/compile_registry.ex
- test/style_capsule/compile_registry_test.exs
