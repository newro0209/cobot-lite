
use <common.scad>

// 용어
// 1. 육각 스탠드오프(hex standoff)
// 2. 대변 거리(across flat)
// 3. 스탠드오프 길이(standoff length)

module hex_standoff_m3_l30(part_color = [0.74, 0.41, 0]) {
    hex_standoff(across_flat = 5.5,
                 standoff_len = 30,
                 part_color = part_color);
}

hex_standoff_m3_l30();
