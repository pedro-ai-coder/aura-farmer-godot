# Real gameplay QA recorder

Review builds only. Recording is OFF after page load. No upload, backend, browser
identity, URL, credentials, player profile or save contents are recorded.

## Record and export
1. Open the protected QA preview while signed into your authorized Vercel account.
2. Start OBS / Game Bar / Android screen recording **before** clicking **Start QA**
   on the game's main menu. The bottom-left label changes to `QA REC` and `MARK 1`.
3. Select any of the six appearances and play normally. Do not change your play
   to help a bot. Choices and pause remain the normal game controls.
4. To add a synchronization point, pause, press **Sync mark**, then resume. Match
   the first video frame displaying the new MARK number to its `video_marker`
   record. The marker does not pause the game itself. Allow one rendered frame
   of alignment uncertainty, plus the external recorder's capture latency.
5. After defeat/victory (or while paused), press **Stop + export**. One ZIP contains
   the four files below. Allow browser downloads if prompted. If blocked, press
   the same button again; data remain in memory. **Clear** is available only after
   stopping. Download before reloading/closing the page; no recovery is promised.
6. Send the ZIP and externally recorded video together. The game does not record
   its screen. Android browser downloads and physical-device FPS need real-device
   validation; desktop emulation is not equivalent.

Retry starts another numbered run in the same session, preserving earlier records.
This dedicated review build starts with an in-memory default profile. It never
loads or writes production saves, unlocks, results or statistics. The original
production scene is unchanged. A temporary, separately named ZIP is removed after a Web
export request. Native review exports remain at the displayed local path.

## Files and fields (schema 1)
- `session.json`: exact build SHA from the exporter (unknown for an unprepared
  local build), actual engine, renderer surface type, viewport, 2 Hz target and
  memory limits. No calendar timestamps or personal/session identifiers.
- `session-trace.jsonl`: each line has `event`, monotonic `wall_ms` since Start QA,
  authoritative `active_s`, local sequential `run`, `wave`, `session_type`, `scenario_id`, and event `data`.
  Pauses, choices and background-tab suspension advance wall time, not game time.
  Match video time as `video_marker_time + (wall_ms-marker.wall_ms)/1000`;
  realign at later markers if the external recording drops frames.
- `session-summary.json`: sampled per-run/per-wave state, menu/pause wall durations,
  spawn and damage aggregates, frame-interval distribution, truncation and counts.
- This `README.md`.

`sample` records are at most 2 Hz of **wall time**, with no catch-up bursts. Counts
separate living active enemies from portal warnings; `normal_enemies` excludes
bosses and terminals. `enemy_types` includes pending portals. `nearby_260u` means
active centers within 260 world units: it does NOT mean all other ranged threats
are harmless or off-screen. `spawn_counts` is session-cumulative, not concurrent.
Kills and run metrics reset per run. XP includes actual collection, including the
boss-entry sweep. `xp` is current level progress; `total_xp` is cumulative run XP.

Authoritative callbacks log successful spawns/kills, actual HP loss and shield
absorption, effective healing, XP/level changes, committed upgrades, successful
Flex activation and run outcomes. Upgrade records carry canonical IDs, new levels,
rarity, replacement and actual equipment. Invalid choices are not acquisitions.
Enemy damage is aggregated by target type (no invented weapon attribution).
Damage-source keys use the existing kind and contact/hazard/direct context;
`unknown`/`unspecified` means the source was not supplied. Level-up HP changes are
in XP events; passive maximum-HP changes are visible in the next sample.

Mode records measure actual wall time in `choice`, `legendary`, `replace`, `paused`
and other menus. Wave/event-index/boss state is observed at process boundaries;
spawn events retain the exact authoritative active clock. `run_finished` records
normal outcomes; quitting to menu is a mode change, not a fabricated defeat.

Frame intervals use monotonic process-callback timestamps, including observer,
render/scheduler work and suspension. Histogram buckets are upper-inclusive;
last bucket exceeds 1000 ms. Per-mode histograms separate gameplay and menus. These are NOT GPU time, nor guaranteed presented-frame
intervals. Headless/accelerated fixtures are not FPS measurements. Observer timing
covers frame polling; callback hooks also appear in total game-process cost.

Trace storage stops at 8 MiB or 32,768 records and shows `FULL — EXPORT`. No ring
buffer silently drops the beginning. Summary marks truncation and stop reason;
playing continues normally. Export may briefly allocate another bounded copy;
export is available only outside active gameplay. No recording survives reload.

## Deterministic QA Scenario Mode (review exports only)

The **QA Scenario** button appears next to **Start QA** in authorized review builds.
It is absent from normal production Web/Android/iOS exports.

1. First export and clear any existing recording; the scenario launcher does not
   silently replace a current human gameplay recording.
2. Click **QA Scenario** while in the menu/hero selection or paused.
3. Explicitly check **QA Mode Enabled**. Select Wave 1, 3, 4, 5 or Big Hater;
   choose Sigma, Cool Kid or Alpha Chad; original/female appearance; Balanced,
   Damage or Survival legal equipment; and a reproducible numeric RNG seed.
4. Optionally check **Record telemetry** and select diagnostic overlays.
   They are all off by default. Click **START SYNTHETIC SCENARIO**.
5. The game displays **QA / SYNTHETIC SCENARIO** throughout the run. This is
   a **controlled synthetic starting fixture**, not a run you organically
   reached. It does not fabricate historical kills, event victories, XP grants
   or surviving waves. Stage-consistent levels/XP/equipment and the canonical
   boss entry are prepared explicitly; existing cooldowns and enemy schedules
   then execute normally.
6. Pause and **Stop + export** to download a four-file ZIP with
   `session_type=qa_scenario`, seed, exact selected build, source SHA,
   scenario ID and simulation start time. Keep external video markers as in
   the normal recorder flow. Normal recordings remain `normal_run`.

Five canonical time fixtures: Wave 1 0:00, Wave 3 4:00, Wave 4 6:00
(Legendary window), Wave 5 8:00 (preselected legal Legendary), and
Big Hater 10:00 (real boss enemy with canonical HP/attack logic).

**Important limits:** This is a deterministic *starting-state* reproducer,
not a replay of a historical progression path. Wave 3/4/5 and boss fixtures
do not assert that a real player could reach their synthetic builds or
health under ordinary survival conditions. They must not be pooled into
normal-health difficulty/balance statistics. Event bosses from completed
prior wave windows are not manufactured. Noncanonical stress configurations
are deliberately outside this initial QA scope.

Overlays: living nearby enemies and composition, actual world collision
radii/covers, active passive timers and stats, and engine FPS/render counters.
They are read-only, and all have separate toggles. Performance values are
not physical-device proof.

The synthetic mode is *not* a cheat code. QA code only exists in the
`qa_review` scene and dedicated review Web export; production pack checks
fail closed if any `qa/` resources leak.

## Wave 5 visual/space A/B candidate (EXPERIMENTAL, not canon)

For an apples-to-apples review, select **Wave 5 / 8:00**, Sigma, Balanced,
seed 451, and enable telemetry. Run it once with the **EXPERIMENTAL WAVE 5**
checkbox **OFF** (canonical baseline), export the ZIP, then repeat with it
**ON** (candidate), export another ZIP. Record both sessions externally.

The checkbox is unavailable for other waves. In the candidate, the approved
Ruin Alley backdrop and two solid covers remain at the same locations. The
*actual legal floor polygon* is uniformly expanded by sqrt(1.25) about the
arena center, giving approximately 25% more traversable space (the exact
walkable area depends on collider clearance and the unchanged covers).
The green outline marks the candidate boundary and the amber outline marks
the canonical boundary. The floor extension is a **QA geometry proposal**,
not new final-map art. Do not judge graphic polish from this overlay.

The existing three-frame attack poses are displayed for longer, cosmetic
contacts fade over 0.32s instead of 0.18s, and gesture visibility persists
longer. Damage, weapon cadence, projectiles, hitboxes, enemy HP, waves,
bosses, awards and the weapon rarity system remain canonical.
The recorder's scenario configuration contains `experiment_id` and
`arena_polygon_area_factor`, so the samples cannot be mistaken for normal
runs or aggregated with canonical baseline metrics.

The candidate is OFF by default and is limited to QA review exports; ordinary
play restores exact canonical geometry and presentation on every new run.
Changes require explicit creator approval before GDD or production adoption.
