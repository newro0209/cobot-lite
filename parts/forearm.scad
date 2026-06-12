// 하완 (forearm) — v0.16: 동일 측판 ×2 (A/B 구분 폐지, 직선 빔)
// =====================================================================
// 측판 1형상 ×2, t7 = 608ZZ 폭. 양단 608ZZ 관통 압입 (팔꿈치 베어링은
// 하완 측판에 — -Y측은 기어박스 축 파일럿 지지, +Y측은 아이들 피벗).
// 팔꿈치 허브(elbow_hub): 볼트온 — M4 셀프태핑 ×3 (elbow_hub_bolt_r, 120°
// — 어느 측판이든 장착 가능, J3 직결 토크 전달 ≈ 4.3N·m / r17 전단 분담)
// 제조: 평판 — FDM 평면(길이 277 → 베드 대각 배치) / CNC 2.5D (GEN-002)
include <../config/parameters.scad>
use <../lib/utils.scad>

fi = forearm_inner_w / 2;
fo = fi + arm_plate_t;
flen = forearm_len;
fa_standoffs = [76, 160];

// 측판 2D — z 대칭
module fa_plate2d() {
    difference() {
        hull() {
            circle(r = arm_lug_r);
            translate([flen, 0]) circle(r = arm_lug_r);
        }
        for (x = [0, flen])                                  // 608ZZ 관통 압입
            translate([x, 0]) circle(d = BRG_608ZZ[1] + bearing_press_fit);
        for (x = fa_standoffs) translate([x, 0]) circle(d = 6.6);   // M6 ×2
        // 팔꿈치 허브 M4 셀프태핑 ×3 (120° 위상 — z 대칭 세트)
        for (a = [180, 300, 60])
            rotate(a) translate([elbow_hub_bolt_r, 0]) circle(d = set_screw_pilot_d);
    }
}

module fa_plate() { linear_extrude(arm_plate_t) fa_plate2d(); }

// piece: "full"(조립 표시) | "plate"(단품)
module forearm(piece = "full") {
    if (piece == "full") {
        translate([0, fo, 0]) rotate([90, 0, 0]) fa_plate();     // +Y
        translate([0, -fo, 0]) rotate([-90, 0, 0]) fa_plate();   // -Y (z 미러)
    }
    else fa_plate();
}

forearm();
