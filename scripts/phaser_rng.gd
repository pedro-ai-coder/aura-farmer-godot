class_name PhaserRng
extends RefCounted

## Exact Mulberry32 sequence used by Phaser simulation/world.ts.
## All truncation is explicit so GDScript int64 reproduces JS bitwise int32.
var state: int = 451
var seed: int = 451:
    set(value):
        seed = value
        state = value & 0xffffffff

func randf() -> float:
    state = (state + 0x6d2b79f5) & 0xffffffff
    var value: int = state
    value = ((value ^ (value >> 15)) * (value | 1)) & 0xffffffff
    value = (value ^ ((value + (((value ^ (value >> 7)) * (value | 61)) & 0xffffffff)) & 0xffffffff)) & 0xffffffff
    return float((value ^ (value >> 14)) & 0xffffffff) / 4294967296.0

func randi_range(minimum: int, maximum: int) -> int:
    # An unqualified randf() resolves to Godot's global built-in here.
    # Explicit dispatch is required to consume this seeded Mulberry32 stream.
    return minimum + int(floor(self.randf() * float(maximum - minimum + 1)))
