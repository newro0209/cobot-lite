use <common.scad>

function lock_nut_m6_t() = 5;   // 너트 높이 (mm)

module lock_nut_m6(col = [0.42, 0.42, 0.42]) {
    lock_nut(10, lock_nut_m6_t(), 6, col);
}

lock_nut_m6();
