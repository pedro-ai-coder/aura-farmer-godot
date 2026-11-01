extends RefCounted

## Source registration for the exact hash-pinned V2 PNG. It contains 51
## unevenly spaced poses (7/7/7/8/6/8/8), not a regular 128x96 grid.
## Keep seven logical slots per state so canonical Sigma playback is unchanged.
## Regions exclude neighbouring bodies; original PNG bytes remain untouched.
const SOURCE_RECTS: Array[Rect2i] = [
    # Idle
    Rect2i(22, 0, 112, 112),
    Rect2i(150, 0, 111, 112),
    Rect2i(271, 0, 115, 112),
    Rect2i(393, 0, 113, 112),
    Rect2i(515, 0, 114, 112),
    Rect2i(643, 0, 113, 112),
    Rect2i(769, 0, 112, 112),
    # Run front
    Rect2i(19, 118, 108, 90),
    Rect2i(148, 118, 106, 89),
    Rect2i(271, 116, 108, 88),
    Rect2i(396, 115, 106, 91),
    Rect2i(524, 116, 103, 91),
    Rect2i(647, 117, 106, 90),
    Rect2i(771, 118, 107, 90),
    # Run side
    Rect2i(22, 212, 110, 89),
    Rect2i(146, 213, 108, 89),
    Rect2i(270, 211, 109, 87),
    Rect2i(394, 212, 108, 90),
    Rect2i(517, 212, 110, 90),
    Rect2i(643, 212, 109, 90),
    Rect2i(768, 213, 110, 90),
    # Attack
    Rect2i(15, 303, 98, 89),
    Rect2i(124, 303, 101, 89),
    Rect2i(230, 304, 112, 87),
    Rect2i(342, 306, 110, 85),
    Rect2i(452, 304, 113, 88),
    Rect2i(565, 305, 103, 87),
    Rect2i(668, 305, 100, 87),
    Rect2i(775, 305, 97, 87),
    # Hurt
    Rect2i(32, 395, 91, 86),
    Rect2i(171, 395, 94, 87),
    Rect2i(311, 395, 102, 86),
    Rect2i(460, 395, 99, 85),
    Rect2i(614, 401, 89, 79),
    Rect2i(774, 409, 85, 71),
    # Flex
    Rect2i(0, 482, 117, 105),
    Rect2i(117, 482, 107, 105),
    Rect2i(224, 482, 109, 105),
    Rect2i(333, 482, 109, 105),
    Rect2i(442, 482, 116, 105),
    Rect2i(558, 482, 112, 105),
    Rect2i(670, 482, 110, 105),
    Rect2i(780, 482, 116, 105),
    # Defeat
    Rect2i(7, 589, 88, 78),
    Rect2i(118, 590, 95, 79),
    Rect2i(227, 599, 92, 71),
    Rect2i(327, 612, 99, 55),
    Rect2i(437, 621, 107, 46),
    Rect2i(551, 624, 110, 43),
    Rect2i(666, 625, 110, 42),
    Rect2i(784, 627, 105, 40),
]

const SLOT_SOURCES: Array[int] = [
    0, 1, 2, 3, 4, 5, 6,
    7, 8, 9, 10, 11, 12, 13,
    14, 15, 16, 17, 18, 19, 20,
    21, 22, 23, 24, 25, 27, 28,
    29, 30, 31, 32, 33, 34, 34,
    35, 36, 37, 38, 39, 40, 42,
    43, 44, 45, 46, 47, 49, 50,
]

static func source_rect(slot: int) -> Rect2:
    return Rect2(SOURCE_RECTS[SLOT_SOURCES[clampi(slot, 0, 48)]])
