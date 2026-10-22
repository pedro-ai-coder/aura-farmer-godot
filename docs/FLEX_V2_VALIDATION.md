# Signature Flex 2.0 implementation evidence

Authority: canonical GDD §7.2, approved in `f2ec242`. Phaser is unchanged. No tuning values or new artwork were introduced.

## Behavior

Sigma retains one live mark, retargets only after death on a successful primary hit, and counts shared primary activations once across paired attacks. The third success confirms one defense-respecting 0.75P Verdict without redirecting a lethal hit. Cool Kid replaces legacy immunity/contact aura with six scheduled directional beats, five-target beat limit, earned ENTER and contact-only 15% mitigation. Alpha retains three slams and taunt, adds contact-only 20% mitigation, named-shield absorption and the capped 5.50-second countershock with cover-safe push/boss stagger. All actions use simulation time and secondary damage paths.

Interim presentation uses existing keyboard attack poses for Cool Kid, readable geometric outlines, marked-target framing, countdown/progress and finisher text. The historical widened Cool Kid sheet is not repurposed as Alpha artwork. Dedicated signature art, visual/readability acceptance and physical-device checks remain open.

## Reproduction and automated coverage

Before implementation, official Godot 4.7.2 failed the new assertions for Cool Kid's approved name and contact-only mitigation: runtime still used legacy immunity. Signature regression cases now cover exact beat boundaries, stable target ties, five-target limits, missed-beat finisher power, one Verdict per activation/window, lethal third hits, death retargets, named-shield attribution, boss mitigation exclusions, countershock cap/push/stagger, pause, restart and lethal-Flex victory cleanup. Existing hero combat assertions were updated from the superseded Flex rules; hero traits remain covered.

## Ordinary-health observations

The existing avoidance controller, seed 451, normal HP, normal rewards, no forced damage/XP, no invulnerability and the approved ten-minute schedule produced the following. Raw output is in `FLEX_V2_RUNS.json`. These runs preceded only the additional lethal-Flex cleanup guard; that guard does not affect these pre-boss defeats.

| Hero | Survival (s) | Level | Kills | Flex uses | Secondary Flex damage | Contact damage prevented | Flex shield absorbed |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Sigma | 431.67 | 20 | 453 | 6 | 55.62 | 0 | 0 |
| Cool Kid | 303.62 | 15 | 281 | 3 | 0 | 0 | 0 |
| Alpha | 446.32 | 20 | 490 | 5 | 1714.14 | 4.08 | 60.37 |

Secondary damage excludes Sigma's primary +40% focus bonus. Prevention is additional Flex contact mitigation after existing defenses; absorption counts only Alpha's named Flex shield. Finisher events include misses. The controller avoids nearby enemies and does not optimize melee combo engagement: zero Cool Kid Flex damage is an observed controller result, not proof that the attacks cannot hit (the deterministic fixtures hit at the approved values).

None reached Big Hater. These observations do not establish three-hero balance, normal human win rates, boss viability, rendered performance or mobile readability. Preserve the GDD balance gate: no release acceptance claim or silent tuning. Continue with additional controller strategies/seeds, ordinary boss-reaching progression and desktop/mobile visual review before declaring the kits production-ready.
