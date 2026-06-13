use <common.scad>

function shoulder_bolt_m8_l80_len() = 80;   // 핀 유효장 (mm)

module shoulder_bolt_m8_l80(col = [0.42, 0.42, 0.42]) {
    shoulder_bolt(8, shoulder_bolt_m8_l80_len(), col);
}

shoulder_bolt_m8_l80();
