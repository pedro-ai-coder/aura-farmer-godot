# Clean Cut runtime lettering

- **Display:** Barlow Condensed Bold (700), short headings and item identities.
- **UI:** Barlow Medium (500), SemiBold (600), Bold (700), descriptions, actions and tabular numerals.
- **License:** SIL Open Font License 1.1, included in `OFL.txt` and Web exports. Unmodified binaries from the Google Fonts repository, `ofl/barlow` and `ofl/barlowcondensed`. Exact binary hashes and URLs are in `manifest.json`.
- **Controlled symbols:** existing packaged Inter Body supplies missing symbols such as →; it is not the body/display face. Its existing OFL is also included in Web exports. OS fallback is disabled on the packaged fonts.
- No runtime download, browser CSS, synthetic italic, font generation or raster lettering is required. Four small static TTFs avoid variable-font setup and cover Latin/Latin Extended UI.

`res://scripts/clean_cut_typography.gd` owns cached FontVariations, role tokens, tabular-number features and the shared default Theme. See `docs/recovery/TYPOGRAPHY_RECOVERY_REPORT.md` for usage, sizing and evidence.
