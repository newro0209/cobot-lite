
use <common.scad>

// 용어:
// 1. 풀림방지 너트(lock nut)
// 2. 대변거리(across flat)
// 3. 관통 구멍(bore)
// 4. 너트 높이(nut thickness)

function lock_nut_m6_t() = 5;   // M6 풀림방지 너트(lock nut)의 너트 높이(nut thickness), mm

module lock_nut_m6(part_color = [0.74, 0.41, 0]) {
    lock_nut(across_flat = 10,
             thickness = lock_nut_m6_t(),
             bore = 6,
             part_color = part_color);
}

lock_nut_m6();
