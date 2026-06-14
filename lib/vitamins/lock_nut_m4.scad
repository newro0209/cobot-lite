
use <common.scad>

// 용어
// 1. 잠금 너트(lock nut)
// 2. 대변 거리(across flat)
// 3. 보어(bore)

// M4 규격 기준 높이입니다.
function lock_nut_m4_t() = 4;

module lock_nut_m4(part_color = [0.74, 0.41, 0]) {
    lock_nut(across_flat = 7,
             thickness = lock_nut_m4_t(),
             bore = 5,
             part_color = part_color);
}

lock_nut_m4();
