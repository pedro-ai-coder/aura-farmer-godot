# Level Zero — private integrated review provenance

**Status:** EXPERIMENTAL; NOT GDD V4 approved; NOT final approved art.

This draft branch is based on runtime Level Zero PR #110 at immutable
`513f3283652a6d5b1c4520a92c662a0ec89157d8`, which itself is based on PR #108. The creator-supplied
**Codex local commit** `35bb6bde73169c5de9a70ca630c2706cd17c6ba1`
was replayed as the 11 exact patch hunks from the creator-provided
`0001-fix-unblock-Level-Zero-input-and-Windows-local-testi.patch`.
These changes fix Windows local launch, intro focus, and input regressions.
The patch was applied only to matching exact source hunk contexts.

The candidate factory background, corner poster foreground and static
Hater Imitation sprite preserve source hashes from Art Pipeline PR #6
at source commit `128948546f5b49f126e707445f5334ebaeea5ae7`.
Art Pipeline remains the provenance authority; these assets are candidates,
not final approvals. Background uses three byte-preserving source shards
which are reconstructed by `scripts/reconstitute_level_zero_art.py` before
Godot Web import. No gameplay mechanics, RNG, save, camera world geometry or
regular Ruin Alley approved content has changed.

## Review gates
- [ ] Native Godot 4.7.2 tests from this exact combined SHA
- [ ] Confirm intro / 3 waves / boss slam+beam / win+loss
- [ ] Confirm factory and Hater Imitation appear, not placeholders
- [ ] Compare crop and touch readability at desktop and mobile-landscape sizes
- [ ] Confirm `/` normal Ruin Alley and save compatibility
- [ ] Confirm private protected WebGL2 preview renders interactively

No merge, production deploy, canon approval or paid-service creation.
Only an explicitly authorized **private Vercel preview** may be created.
