# State and motion atlas

## Joystick

Layer `ring-idle` / `ring-pressed` behind `thumb-idle` / `thumb-pressed`. Optional activation ripple is brief, fades with the contact transition and never implies a permanent joystick. The actual thumb offset is normalized/clamped by runtime; sample comps illustrate position only. Hide when no eligible movement pointer. Reduced motion uses static rings.

## Flex, 3×7 states

Each hero has charging, ready, focused, pressed, active, recovery and disabled circular artwork with one ring state. Do not add a second READY indicator. Sigma uses gold target/eye with angular precision ticks (6 s, three confirmed hits, one Verdict). Cool Kid uses blue/magenta CTRL/ENTER marks and directional strokes (5 s, six beats, ENTER! at 4.50 s). Alpha uses shield/fist block and heavy gold accent (6 s, shield and three slams at 0/2/4 s, one countershock at 5.50 s). State durations and counters are live data; never infer or change simulation timing from animation.

## Cards and hero choice

Weapon blue vs passive gold tag carries type by color and text. Hover adds shallow top light; focus has visible blue dashed keyline; selected adds gold full-weight stroke and check; pressed compresses/shadows; disabled desaturates with explicit copy when used. Current→new is side-by-side text with a directional arrow and exact data-bound values. Confirmation is a distinct flow state. Hero selection enlarges and outlines the selected MVP hero; role/name/starter/Flex are always text-and-icon paired.

## High-density layers

Friendly projectiles/pickups remain narrow and bright; enemy attacks use coral outlined geometric telegraph with dash pattern, placed above ambient friendly marks. Keep hero and boss silhouettes visible; avoid screen-wide flashes.
