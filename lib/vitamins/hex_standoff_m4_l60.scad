
use <common.scad>

// 용어
// 1. 육각 스탠드오프(hex standoff)
// 2. 대변 거리(across flat)
// 3. 스탠드오프 길이(standoff length)

// M4 L60 규격 기준 길이입니다.
function hex_standoff_m4_l60_len() = 60;

module hex_standoff_m4_l60(part_color = [0.74, 0.41, 0]) {
    hex_standoff(across_flat = 7,
                 standoff_len = hex_standoff_m4_l60_len(),
                 part_color = part_color);
}

hex_standoff_m4_l60();
