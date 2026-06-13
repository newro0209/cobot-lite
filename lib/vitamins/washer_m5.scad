use <common.scad>

function washer_m5_t() = 1.2;   // 두께 (mm)

module washer_m5(col = [0.50, 0.50, 0.50]) {
    washer(5, washer_m5_t(), col);
}

washer_m5();
