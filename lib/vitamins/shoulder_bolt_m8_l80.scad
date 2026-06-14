
use <common.scad>

// 용어
// 1. 숄더 볼트(shoulder bolt)
// 2. 숄더 길이(shoulder length)
// 3. 유효장(effective length)

function shoulder_bolt_m8_l80_len() = 80;   // 핀 유효장(effective length), mm

module shoulder_bolt_m8_l80(part_color = [0.74, 0.41, 0]) {
    shoulder_bolt(d = 8,
                  shoulder_len = shoulder_bolt_m8_l80_len(),
                  part_color = part_color);
}

shoulder_bolt_m8_l80();
