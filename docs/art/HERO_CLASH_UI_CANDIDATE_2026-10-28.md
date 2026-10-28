# Aura Farmer — Hero Clash UI Production Candidate (2026-10-28)

**Status: UNAPPROVED CREATOR REVIEW CANDIDATE.** Main source of truth: GDD V3.0 §§7–8.

The creator identified interface polish as the current M0 priority after the functional
gameplay recovery in PR #73 and the visual A/B/C exploration in PR #78.

The supplied Whiteout Survival gameplay video is an external reference for panel
depth, readable actions and celebratory rewards, not approval to copy its UI art,
systems, economic screens or dense strategy-game notifications. Other reference
lessons: Brawl Stars for distinctive mobile hierarchy and ability recognition,
Brotato for a compact combat HUD, and Swarm for high-density combat legibility.

## Proposed candidate implementation

- Archivo Black (display) and licensed Archivo (UI), byte-identical to existing
  A/C font sources in PR #78, separately packaged with SIL OFL and SHA-256.
- Original code-drawn solid-filled Hero Clash wordmark framed in Circuit-like
  navy/blue/gold shapes. Existing approved wordmark raster remains untouched.
- Menu hierarchy updated to display the brand and retain approved hero art.
- Circular live-input Flex dial with actual Aura progress and static gold halo
  when Aura is 100% and usable. Character Flex name appears outside the circle.
- Compact gameplay equipment uses approved icons and level marks. Build inspection
  retains full names. No simulated or hardcoded gameplay quantities.
- Upgrade and Legendary cards gain coherent rarity accents, icon backing and
  prominent selection text while preserving approved illustrations/offer rules.

## Preservation and approval

No changes to 19 original actor/world masters, 84 exact approved Clean Cut
source resources, 37 approved item icons, gameplay rules, input ownership,
balance, persistent profiles, backend or Phaser. Existing Barlow fonts are intact.
This branch tests an alternate interface *presentation*. It is not a new art
approval or authorization for public release. The creator must explicitly
approve the final logo/font supersession and update its art ledger/GDD before
a production merge.

## Verification to complete

Actual Godot screenshots at 1920x1080, 1600x900, 1280x720, 915x412,
844x390 and 390x844; actual live buttons, cards, six-choice Legendary,
charge/ready/active/recovery, text fit, and approved-art asset hash checks.
Normal WebGL2 gameplay and physical-device frame time/multitouch acceptance
remain separate, unresolved gates. CI screenshots are staged, not full runs.
