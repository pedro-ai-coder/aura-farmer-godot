# State, layering and motion reference

**Art timing only:** values below mirror existing GDD Flex event timestamps. Animation ease/duration suggestions are presentation guidance; they do not pause, add hits, change cooldowns, or alter simulation timing.

## Player status and progression

Each hero has normal, damaged, critical, healing and shielded panel artwork. The state swaps accent/pattern and status copy while reusing the exact hero master. HP/current-max uses tabular numerals; shield is a separate blue outlined segment. Damage uses a short coral contour tick; healing a green plus/tick; critical has coral pulse and “CRITICAL HP” label. Reduce motion removes pulses, retaining static pattern/labels. XP/level and wave/time are separate controls. The XP bar never encodes Aura.

## Equipment

Weapon/passive slot templates have idle, selected, empty variants plus Common/Rare/Epic/Legendary frame marks. Rarity uses both unique `C`, `R`, `EP`, `LG` text and one/two/three/four ink notches; color reinforces the shape and text. Level badge is data-bound. Use 64px weapon / 48px passive samples at 1600 reference; the 64/48/32 detail exports are visual checks only, and assets are never overwritten by those scaled outputs.

## Flex state model

Common art states are Charging → Ready → Focused/Pressed → Active → Recovery → Ready; disabled is available for invalid/unavailable UI state. Ready has the explicit live label and does not depend on animation. During active use display simulation-driven remaining duration.

- **Sigma — Deadpan Verdict, 6 s:** activation briefly draws a target-lock and eye-judgment reticle; active feedback adds one target tick for each qualifying success, a clear `1/3` → `3/3` counter, then one focused `VERDICT!` strike. Use the target line/diamond as the payoff, not an area explosion. GDD’s targeting and damage rules remain authoritative.
- **Cool Kid — CTRL + CHAOS, 5 s:** blue/magenta keystroke trails, six discrete beat markers at GDD event times `0.35/1.05/1.75/2.45/3.15/3.85 s`, and the directional `ENTER!` finisher at `4.50 s`. Keep the approved blue-beanie silhouette agile; never use the historical enlarged Cool Kid Giga-Chad form.
- **Alpha Chad — Giga Chad Rampage, 6 s:** heavy gold shield entry; exactly three numbered impacts at `0/2/4 s`; visual shield absorption response; one `GIGA!` countershock at `5.50 s`. No fourth slam, forced boss displacement or invented damage.

Friendly action FX render beneath enemy attack telegraphs and hostile projectiles. Each VFX stays a separate vector layer; no full-screen white/red flashes. Reduced motion uses single-step outlines and retains all beat/count text.

## Boss warning and encounter

Warning-screen compositions correspond to entry, readable full state, and exit. Suggested broadcast presentation: 0.18 s ink reveal, hold for 1.2 s readable, 0.22 s cut-away to the compact event row. These are visual durations only; the GDD’s scheduled warning at 09:30 and Big Hater at 10:00 remain unchanged. The exit does not hide active hazard telegraphs.

Boss encounter has one HP bar/name/phase plate, a subordinate attack cue only while relevant, and a compact Berserk countdown (`12:00` onset, 120 seconds into boss combat). At 12:00 swap the same subline to `BERSERK`/`FULL HATER MODE`; avoid overlapping banner slabs. The boss remains recoverable; no automatic defeat or hard timeout is implied.

## Pause

Pause → Resume / Settings / Quit Run. Quit Run opens one confirmation over the dimmed paused world. Stay returns to the pause menu; Quit Run ends the run. Never leave an upgrade dialog under the pause confirmation. Focus, pressed and disabled assets change only the button layer. Text and actions remain live UI.

## Mobile joystick

Artwork uses an 80-reference-unit outer radius, 35-unit thumb radius and 119-unit saturation travel. Left/center/right images show contact position on free terrain; two-finger art shows the movement owner and an independent Flex touch. The drawings demonstrate appearance only. Hide ring/thumb when there is no active movement touch. Never let an interactive UI region start movement; second finger cannot steal the movement owner. Safe-area clamping and runtime pointer lifecycle await Godot validation.
