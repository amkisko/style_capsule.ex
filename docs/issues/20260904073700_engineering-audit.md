# Engineering audit for 0.9.0

## Participants

Andrei Makarov

## Decisions

CSS scoping should match the Ruby sibling for :host(), :host-context(), bare :host descendants, @media, and @keyframes stops.

Href values in stylesheet links are HTML attributes and must be escaped.

CSS inserted into style tags must not contain a case-insensitive style tag closer.

capsule/1 must validate the wrapper tag before generating a capsule ID so a forbidden tag raises ArgumentError instead of CapsuleNotFoundError.

FileWriter must validate the capsule ID and refuse a filename that expands outside the output directory.

register_inline failures must surface. The previous rescue that always returned :ok is gone.

Telemetry execute calls on the CSS processor and file writer paths go through the existing safe_execute wrapper. No telemetry package is added.

ComponentRegistry stays as leftover public API. This library does not grow an Application supervisor only to start that Agent.

The Mix verify task still only checks writability. File cache strategy remains write-through. The compile registry path stays relative to the process working directory.

## Effects

CssProcessor now skips at-rule selectors and keyframe stops, translates host selectors before prefixing, and rejects a style tag closer or a non-binary CSS body.

Wrapper.validate_tag! rejects names that are not lowercase HTML names and rejects script, iframe, object, embed, link, meta, style, and base.

FileWriter expands the output path and raises when the filename leaves the directory.

Phoenix stylesheet href values are escaped. Precompiled URLs take the path after priv/static, or the basename when that marker is absent.

CompileRegistry stores Erlang terms in style_capsule_registry.etf instead of evaluating Elixir source.

Version is 0.9.0. CHANGELOG Unreleased is folded into that dated heading.

## Next

Publish 0.9.0 on Hex when asked. Do not tag or run usr/bin/release.exs until then.

Start ComponentRegistry only if a real caller needs the Agent at runtime.

Document or change Mix verify if operators need more than a writability check.

Consider a read hit for the file cache strategy if rebuild cost shows up in use.

## Source

Requested as an engineering audit, fix, and release preparation on main without a branch switch.

Related: usr/docs/changelogs/20260904073700_engineering-audit-0-9-0.md
