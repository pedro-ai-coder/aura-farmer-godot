# Report-driven combat feedback

This implements the next presentation-only batch of the 2026-11-15 animation audit, alongside the creator-approved six-hero composition. It does not claim the entire 22-item plan or competitor-level artistic acceptance is complete.

## Sound

`combat_audio.gd` synthesizes eleven short original PCM transient families once per active audio scene group. It uses fixed math, never the gameplay RNG. No paid service, downloaded sample, new backend or telemetry is involved. Eight reusable voices have same-family rate limits and bounded priority replacement. Hostile warnings outrank friendly cues; player damage/Flex and contacts have distinct priorities. Resources retire with the final audio scene, and existing Sound/volume controls apply through the Master bus.

The weapon presentation observer emits an attack-motion sound once the actual projectile/area resolves, not merely because a windup deadline elapsed. Cancelled future attacks stay silent. Real HP/shield changes produce contact/blocked cues. Existing signature-strike calls drive the actual six beats, three slams and finishers without adding events. Successful Flex activation, player damage/absorption and actual pickup cues also have sounds. Enemy warning phases and future `attack_pose.impact` models produce a bounded warning cue. Paused/modal states suspend active voices and reject new cues.

Ordinary headless gameplay checks do not allocate/play mixer voices; dedicated audio checks explicitly enable real AudioStreamPlayer playback. Actual audiovisual verification must use rendered native/Web recording and non-silent decoded audio, not headless test counts. The short procedural sound palette remains open to subjective refinement; this is not a claim of final audio mastering or music production.

## Crowd readability

Boss, elite and damageable terminal-objective bars stay visible. Ordinary full-health bars are omitted unless the enemy was recently hit; damaged enemies retain their bars. Only drawing changes: HP, healing, enemy selection, hazards, attack geometry, collision, damage, progression and RNG remain authoritative and unchanged. This reduces the repeated green-bar layer without hiding hostile telegraphs, priority targets or boss state.

## Remaining work

Sigma's actual No Cap projectile now samples the text-free cap region from its already prepared approved v2 atlas, without allocating another texture or changing shot models/trajectories. Generic Vixen body playback skips the baked muzzle-flash drawings; muzzle effects belong to actual weapon-event overlays. The approved PNGs themselves are unchanged.

Additional directional torso art, complete per-frame hand/muzzle registration, retouched inbetweens and secondary motion, full player/hostile silhouette hierarchy, sustained Web/mobile trials, human readability review and final artistic/audio acceptance remain explicit unfinished audit items. Source PNGs are unchanged; no missing authored directions are inferred from runtime code. Merge and publication remain separate decisions.
