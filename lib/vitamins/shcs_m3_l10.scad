use <common.scad>

function shcs_m3_l10_dia() = 3;    // 나사 호칭경 (mm)
function shcs_m3_l10_len() = 10;   // 나사 길이 (mm)

module shcs_m3_l10(col = [0.42, 0.42, 0.42]) {
    cap_screw(shcs_m3_l10_dia(), shcs_m3_l10_len(), col);
}

shcs_m3_l10();
