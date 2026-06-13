use <common.scad>

function shoulder_bolt_m5_l50_len() = 50;   // 핀 유효장 (mm)

module shoulder_bolt_m5_l50(col = [0.42, 0.42, 0.42]) {
    shoulder_bolt(5, shoulder_bolt_m5_l50_len(), col);
}

shoulder_bolt_m5_l50();
