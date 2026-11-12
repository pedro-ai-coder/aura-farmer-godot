# Web platform helpers

**Context tier:** standard. **Scope:** `web/`.

## Purpose

Browser-facing support for Godot Web exports. It is not a parallel gameplay implementation; build/export orchestration lives in `scripts/build_web.sh`.

## Key files

- `./platform.js` — fullscreen, browser gesture, safe-area and canvas-raster handling.
- `./performance.js` — opt-in development performance recorder for review exports.
- `./aura.webmanifest` — Web app manifest.

## Contracts and risks

`platform.js` manages browser lifecycle and presentation dimensions; it must not own simulation time or gameplay RNG. `performance.js` is gated to development review behavior (including a `perf=1` query flag); its samples do not prove physical device latency or frame delivery. Preserve touch input scaling, safe areas and platform-specific gesture requirements. Never introduce third-party telemetry, backend or credentials without approval.

## Validation

Source-defined checks, **not executed here**:

```sh
node tests/test_web_platform.cjs
node tests/test_performance_web.cjs
```

For relevant changes, also inspect [scripts](../scripts/CONTEXT.md) and [tests](../tests/CONTEXT.md).
