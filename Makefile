.PHONY: release lint test

release:
	elixir usr/bin/release.exs

lint:
	mix format --check-formatted
	mix credo --strict

test: lint
	mix test
