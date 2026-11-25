# Six → Seven V3 Neon Impact — production acceptance record

Status: **APPROVED** for this exact VFX visual treatment by the creator; production release **PENDING** final CI, exported PCK inspection, and WebGL2 smoke verification.

## Provenance and scope
- Creator decision: 2026-11-24, in the CLUTCHPUNKS conversation: “Agora sim, este 67 tem impacto! ... podes integrar na versão de produção!”
- The original reviewed art implementation is the V3 head `7ab2b3109e0f0ac03bb7ee6d3c57989fb7d94766`, [PR #158](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/158).
- Readable [creator approval recorded on #158](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/158#issuecomment-7147920640).
- Review provenance: [#156](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/156) and [#157](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/157).
- Approved: the V3 Neon Impact sixth-hit warning, seventh-hit animation, ground shockwave and confirmed HP-loss contact treatment in **Solo**, preserving exactly the reviewed visual geometry.
- Not approved or changed: mechanical hit definition, damage, 90 U radius, two-second lockout, No U debuff rules, RNG, saved data, balance, other passives, future passives, third-party art or multiplayer semantics.
- Main source-control baseline before implementation: `34767716e1c9b5ecb6e7361e6aced6d13d052817`.

## Integration contract
The standard game boots the approved V3 renderer without a review feature or QA equipment grant. Its presentation subscribes once to the post-resolution `passive_burst_resolved` signal. Legacy Six → Seven rings are suppressed, but all other passive ground rings and warnings remain as before. V2 remains available only as the review baseline; QA map controls are gated by `six_to_seven_review` and not exposed in ordinary exports.

The ordinary Godot Web PCK must include both `scripts/vfx/six_to_seven_neon_impact.gd` and its V2 base class `scripts/vfx/six_to_seven.gd` but exclude `tests/*`, QA fixtures, review-only UI resources, and performance diagnostics. No modification of canonical assets is permitted.

## Release verification gates
- [ ] GitHub PR for normal production renderer passes mandatory Godot 4.7.2 validation.
- [ ] V2/V3 parity tests and the separate V2 comparison lab pass after the change to default V3.
- [ ] Ordinary PCK verifier reports both required script resources and no QA scenes, fixtures, or diagnostics.
- [ ] Normal-play WebGL2 preview: Garage → Solo → Ruin Alley and MSG Factory; obtain Six → Seven through standard legal upgrade offer, then verify 6/7 and true 90 U burst / HP-loss marks, pause, retry, Reduced Motion, and victory finish.
- [ ] Verify normal production deploy references the exact released commit SHA and usable live WebGL2 gameplay; Vercel READY alone is insufficient.
- [ ] Record tested SHA, engine, seed, command, platform, art/source hash and evidence in the designated append-only QA audit.

## Rollback
Before publication, record the previous production deployment and main SHA. If the approved VFX is missing or gameplay is affected, revert the focused release change / restore the previous known-good Vercel production deployment. Do not change gameplay behavior to hide a presentation failure.

## Follow-up
The P0 passive VFX family plan is [issue #160](https://github.com/pedro-ai-coder/aura-farmer-godot/issues/160), beginning with **No U**. All other visual treatments are **PROPOSED**. The runtime acceptance record is not a replacement for synchronization of the approval provenance with canonical art/governance records.
