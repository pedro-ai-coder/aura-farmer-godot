# Web export and Vercel — first playable preview

The Godot edition can export a **single-threaded** Web build. The project uses the Compatibility renderer. The same canonical GDD remains the product/feature authority.

## Build command

`bash scripts/build_web.sh`

The reproducible script downloads the official Godot 4.7.2 Linux editor and official export template archive from GitHub, verifies published SHA-256 checksums, extracts Web templates, imports Godot resources, and exports `build/web/index.html` plus JS/WASM/PCK assets.

This command uses public upstream downloads and does **not** introduce commercial infrastructure. **Caution:** the official export template archive is approximately **1.28 GB**, even though only Web templates are extracted. This may take significant build bandwidth and exceed Vercel Hobby resource/time allowances. This first rollout is experimental: do not report it as deployed or green until the actual remote build and browser load both succeed. Reuse build caches or shift export into a separate free GitHub workflow if the full archive cannot be fetched within Vercel limits.

## Vercel configuration

Root directory `./`, framework **Other**, output directory `build/web`, build command `bash scripts/build_web.sh`, no npm package manager or environment secrets. These settings are pinned in `vercel.json` and override dashboard settings on Git deployments. Keep this Vercel project **separate** from the Phaser production project.

The Web preset in `export_presets.cfg` sets `variant/thread_support=false`; the build does not require cross-origin isolation headers. Preserve the WASM MIME type and static assets. Avoid hosting unrelated third-party scripts inside the game iframe.

## Validation and limitations

- GitHub CI checks Godot import/rules/scene smoke; it **does not yet export the Web build**.
- Test locally, after installing Godot 4.7.2 and its matching Web export templates:

```bash
mkdir -p build/web
godot --headless --path . --import
godot --headless --path . --export-release Web build/web/index.html
python3 -m http.server 8000 --directory build/web
```

Visit http://localhost:8000, choose one of three heroes, move, collect XP and activate Flex. Test desktop, Android browser and iOS Safari, and verify .wasm/.pck fetches in browser network tools.

This vertical slice has placeholder visuals, simplified enemy AI, reduced passive implementations and separate experimental Godot local save. It is not the final GDD solo demo, nor proof of Android/iOS native app support.

## Status and gates

Confirm Vercel build logs, output files and a playable browser URL before claiming Web release. Restore or fix build steps in this PR if they fail. Platform parity and final art remain separate scoped PRs. No autonomous paid upgrades or deployments to the Phaser project.
