# QA modal input regression

## Cause and reproduction

The modal's CanvasLayer only establishes rendering/input hit-test order. The
ordinary presentation remains alive underneath it. `arcade_presentation.gd`
refreshes its focus ring from `solo_run.gd`'s 100 ms text refresh and schedules
focus back onto a normal-game button whenever focus belongs to another UI.
This steals focus from the QA seed field and cancels a QA button press before
its release. Instantaneous Chromium clicks missed the refresh boundary.
Separately, the normal run's `_input` consumes Enter before the seed editor can
handle it, starting gameplay underneath the dialog.

The new `tests/qa_recorder/test_ui.gd` sends actual Viewport pointer events,
refreshes the normal presentation between press and release, and asserts the
whole modal becomes invisible. It also verifies seed focus survives a refresh,
Enter cannot start gameplay, Escape closes with editor focus, RNG/profile state
is unchanged, and ordinary UI visibility returns. Running this test against the
three original QA scripts from commit `934faed` fails; the corrected scripts pass.

## Review-only fix

- Hide the ordinary UI CanvasLayer while the modal is open; restore its previous
  visibility and focus on close. The simulation, recorder and canonical scripts
  are unchanged. This also removes underlying controls from focus traversal.
- Gate the review subclass's canonical input handlers while the modal is open.
- Keep Tab traversal within the form, release hidden focus and close popups.
- Preserve fixed header/footer and resize only when the viewport changes.
- Expose bounded read-only input/closure counters and actual child visibility;
  show the build SHA prefix in the QA status line.

## Browser evidence

`tests/qa_recorder/web_test.cjs` uses real canvas pointer/keyboard actions, with
350 ms button presses spanning several refreshes. It covers 1600x900, 1050x810,
1280x720 and 844x390, plus DPR 1.25 and 2; scroll/Cancel, scroll/Close, seed focus,
Enter, Escape, repeated cycles, Wave 5 launch and a fresh normal recording/ZIP.
Screenshots and runtime videos are uploaded by the existing QA Web Evidence
workflow. Passive video annotations show pointer coordinates and keyboard keys.
Fullscreen and browser zoom support are recorded in the per-run JSON; changing
DPR is not claimed as browser zoom or physical mobile performance.

## Creator acceptance

1. Use the exact deployment URL supplied on PR #105, not an older bookmark or
   mutable branch alias. Confirm the BUILD prefix matches that PR's tested SHA.
2. Open QA Scenario, scroll down, and click/hold/release CANCEL normally. Repeat
   with header CLOSE, then focus the seed and press Escape. All must close.
3. Repeat at your usual browser zoom and fullscreen setting. Enable QA, select
   Wave 5, and START SCENARIO. Confirm the SYNTHETIC label.
4. In a fresh normal session, use Start QA, play, pause, Sync mark and Stop +
   export. Existing recording data blocks scenario replacement until exported
   and explicitly cleared.
5. If any step still fails, provide the visible BUILD prefix, browser/version,
   viewport/zoom and a short screen recording. Passing CI does not override a
   creator-reported failure.

The export already disables PWA service workers and uses SHA-named game assets;
HTML/build metadata require cache revalidation. A unique new deployment origin
cannot inherit a service worker from the previous deployment's origin. Old
preview URLs intentionally remain old builds; no claim is made that bookmarks
can be prevented from opening them. No merge or production deployment authorized.
