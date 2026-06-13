use <common.scad>

function lock_nut_m4_t() = 4;   // 너트 높이 (mm)

module lock_nut_m4(col = [0.42, 0.42, 0.42]) {
    lock_nut(7, lock_nut_m4_t(), 5, col);
}

lock_nut_m4();
