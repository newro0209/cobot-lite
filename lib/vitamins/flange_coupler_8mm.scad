use <common.scad>

function flange_coupler_8mm_h() = 13;   // 전체 높이 = 플랜지 3 + 보디 10

module flange_coupler_8mm(col = [0.72, 0.72, 0.74]) {
    flange_coupler(col, 12, 4, 4);
}

flange_coupler_8mm();
