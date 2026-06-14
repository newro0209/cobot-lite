
use <common.scad>

// 용어:
// 1. 육각소켓머리 캡나사(socket head cap screw)
// 2. 나사 호칭경(nominal screw diameter)
// 3. 나사 길이(screw length)
// 4. 조립 코드(assembly code)

function shcs_m4_l10_d() = 4;      // 나사 호칭경(nominal screw diameter), mm
function shcs_m4_l10_dia() = shcs_m4_l10_d(); // 기존 조립 코드(assembly code) 호환용
function shcs_m4_l10_len() = 10;   // 나사 길이(screw length), mm

module shcs_m4_l10(part_color = [0.74, 0.41, 0]) {
    cap_screw(d = shcs_m4_l10_d(),
              screw_len = shcs_m4_l10_len(),
              part_color = part_color);
}

shcs_m4_l10();
