class_name RecoveryRules
extends RefCounted

## Canonical Appendix C.2, approved 22 October. One shared seeded draw per eligible kill.
const SAFE_SPOT := Vector2(1100,565)
const SAFE_RADIUS := 68.0
const SPECIAL_LIMIT := 5
static func special_for(roll: float, elite: bool) -> String:
    var snack := 0.20 if elite else 0.05
    var magnet := 0.08 if elite else 0.02
    return "snack" if roll < snack else ("magnet" if roll < snack + magnet else "")
static func pickup_radius(kind: String) -> float:
    return 56.0 if kind == "snack" else (72.0 if kind == "magnet" else 45.0)
