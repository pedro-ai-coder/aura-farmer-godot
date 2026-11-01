# Passive, buff and upgrade feedback review

Baseline: production `59b2595885cb11342607fbcbbec24855de525935` (merged #99). Creator review required; no merge or production deployment is authorized.

## Review

A compact acknowledgment appears below the existing HP module. Actual counters and deadlines temporarily occupy the existing passive-slot tabs; level/rarity and full names remain in Build Inspection. No second HUD, particles or floating combat labels were added. Legendary events use the existing gold hierarchy. Reduced Motion removes the 4-unit entrance and expanding ring motion while retaining readable static information.

- [Desktop before/after](evidence/before-after-desktop.webp)
- [Mobile before/after](evidence/before-after-mobile.webp)
- [Mobile coverage](evidence/mobile-feedback.webp)
- [Desktop coverage](evidence/desktop-feedback.webp)
- [Timed expiry and stacks](evidence/timers-stacks.webp)
- [Four Legendary effects](evidence/legendary-effects.webp)
- [Dense combat and Reduced Motion](evidence/dense-reduced.webp)
- [Before/after video](evidence/before-after.mp4)
- [Build Inspection](evidence/build-inspection.webp)
- [Measurements](evidence/performance.json)
- [Capture provenance](evidence/provenance.json)

These are actual Godot 4.7.2 Compatibility captures of isolated, scripted canonical runs at 1600×900 and 844×390. Fixtures seed preceding gameplay history, then execute actual weapon collisions, triggers and confirmations. They never write toast strings/status counters into the presenter. Profiles are in-memory only. High-health targets/dense fixtures support repeatable comparison; recordings are not human play, browser testing or physical Android evidence. Movie Maker is an offline fixed-30 FPS capture at 1280×720, not a delivered FPS measurement.

## Coverage: all 23 offerable identities

| ID | Behavior | Runtime feedback / actual inspection value |
| --- | --- | --- |
| `main-character` | Persistent stat | Confirmed item/level; +6% weapon damage per level |
| `terminally-online` | Persistent stat | Confirmed item/level; +5% frequency per level, total cap stated |
| `built-different` | Persistent stat / HP | Actual added capacity, not a full heal; +8% max HP per level |
| `thick-skin` | Persistent stat | 3% reduction per level, multiplicative resistance stated |
| `caught-4k` | Persistent stat | +5% speed per level; canonical cap stated |
| `big-meme` | Persistent stat | +6% radius per level |
| `timeline` | Persistent ranged stat | +8% reach per level, projectile-speed relationship stated |
| `hands-on-sight` | Conditional damage | +7% per level only within 150 U; no permanent combat decoration |
| `cope-harder` | Shield support | +8% per level to granted Tank shields; no invented shield |
| `certified-w` | Healing/shield support | +6% per level; effective proc amounts already include support |
| `no-cap-streak` | Directional activation trigger | Actual 0–4/5 activation counter; fifth-activation damage cue; projectile pierce stated in inspection |
| `w-wifi` | Timed positional buff | Actual four-second zone and exact 160 U boundary; OUT outside zone; strongest-frequency rule |
| `let-him-cook` | Stacks / expiry | Actual 1–5/5, significant thresholds, three-second expiry after last primary hit |
| `homie-check` | Hit-triggered healing | Actual 0–7/8, six-second lockout and effective HP restored, full-HP heals silent |
| `big-chad` | Periodic shield | Actual capped grant, source duration/remaining shield; no zero-grant cue |
| `its-over` | Conditional damage | Actual 15/25% below 30% target HP; explicitly no execute |
| `aura-viral` | Flex-timed frequency | Successful Flex only; actual five-second deadline; strongest with Wi-Fi |
| `so-back` | Threshold healing/shield | Nonfatal threshold, effective five healing ticks, actual three-second shield |
| `six-to-seven` | Hit counter / burst | Actual 6/7 gold warning, real seventh-hit 90 U ring, two-second frozen recovery |
| `absolute-cinema` | Legendary permanent / Flex | +25% permanent; gold actual Flex +20% additive weapon-damage cue, not Flex damage |
| `w-squad` | Legendary support / Flex | +25% support in inspection; gold actual six-second +10% weapon-damage cue |
| `too-sigma` | Legendary threshold shield | Actual nonfatal grant/cap and five-second duration; no immunity or revive claim |
| `no-u` | Legendary periodic pulse | Real 200 U activation ring/gold cue; normal 20%/4s vs boss 10%/2s retained |

Future-only `get-ratiod`, `ego-check`, `uno-reverse`, `brainrot-rain`, `take-l` remain unavailable. Their existing icon resources are preserved.

## Contracts and implementation

`passive_feedback.gd` consumes confirmed commits and existing counters/timers. `passive_feedback_view.gd` extends the current Control hierarchy without input ownership. At most one acknowledgment is shown, six pending entries and four 280 ms ground cues are retained. Repeated progress/healing/absorption is coalesced. Display sampling is 10 Hz, with event invalidation and authoritative expiry wakeups. No model calculation, combat timer, cadence, damage, targeting, collision, RNG, save field or gameplay count changes.

Acquisition is acknowledged only after `_apply_card` commits. The descriptor is copied before the existing mutable replacement card is cleared. New item, level, weapon rarity promotion, replacement and effective fallback healing remain distinct. Passive rarity promotions and fallback shields are not implemented by the baseline; this presentation does not invent them. Weapon promotion reports the actual capped resulting level rather than promising a universal improvement. Pending choices and Legendary defer/reopen/replacement still freeze active-simulation time.

No art was generated or replaced. The existing approved registry supplies item icons; existing Archivo/OFL typography and navy/cream/gold colors are reused. Exact reused-icon and runtime-source hashes are recorded in provenance. No approved registry entries require supersession.

## Validation and acceptance

The automated suite covers exact state/RNG parity across all 23 IDs and six appearances, real confirmations/cancellation/replacement, clipped healing, shields at cap, fatal/nonfatal thresholds, actual stacks/expiry/lockouts, four Legendary contracts, pause/quit/retry/victory, Reduced Motion, full names and interference-free layout at all six GDD viewports. Existing #98 pickup/#99 weapon, profile, touch, fullscreen/DPR and full-run regressions remain mandatory.

The native cost comparison alternates the same dense fixture with the observer disabled/enabled. It is a software Mesa/llvmpipe cost check, not physical Pixel 8a frame-pacing acceptance. The creator's accepted Pixel 8a/Brave baseline is preserved as the target; the new preview still requires creator-device regression review.

Creator checklist:

- [ ] Acquisition and level change are obvious without hiding combat.
- [ ] Timed buffs, 6/7 and Cook expiry are readable at gameplay scale.
- [ ] Effective healing, shield generation and absorption remain distinct.
- [ ] Legendary acquisition/events feel stronger without obscuring danger.
- [ ] Reduced Motion and Pixel 8a/Brave responsiveness remain comfortable.

CI success is technical evidence, not creator visual approval. Preview and authoritative CI links are recorded in the PR at its exact tested SHA.

## Native performance sample

| Viewport | Simulation median ms, before → after | Skin/UI median ms, before → after | Software GPU median ms, before → after |
| --- | --- | --- | --- |
| 1600x900 | 1.76 → 1.73 | 0.91 → 0.91 | 27.16 → 27.92 |
| 844x390 | 1.57 → 1.47 | 0.84 → 0.86 | 15.11 → 13.33 |

Six alternating blocks per viewport, 360 measured frames per side. Heavy software/VM tails are preserved in the raw data. These figures do not establish physical-device frame pacing. The same legal five-passive build, targets and simulation inputs are used on both sides.
