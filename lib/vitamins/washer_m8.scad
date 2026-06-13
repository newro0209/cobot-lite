use <common.scad>

function washer_m8_t() = 1.2;   // 두께 (mm)

module washer_m8(col = [0.50, 0.50, 0.50]) {
    washer(8, washer_m8_t(), col);
}

washer_m8();
