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
The ordinary game may save its normal progression; the recorder never reads or
writes that profile. A temporary, separately named ZIP is removed after a Web
export request. Native review exports remain at the displayed local path.

## Files and fields (schema 1)
- `session.json`: exact build SHA from the exporter (unknown for an unprepared
  local build), actual engine, renderer surface type, viewport, 2 Hz target and
  memory limits. No calendar timestamps or personal/session identifiers.
- `session-trace.jsonl`: each line has `event`, monotonic `wall_ms` since Start QA,
  authoritative `active_s`, local sequential `run`, `wave`, and event `data`.
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
