use <common.scad>

function hex_standoff_m4_l60_len() = 60;   // 스탠드오프 길이 (mm)

module hex_standoff_m4_l60(col = [0.42, 0.42, 0.42]) {
    hex_standoff(7, hex_standoff_m4_l60_len(), col);
}

hex_standoff_m4_l60();
