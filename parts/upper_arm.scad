// 상완 (upper arm) — v0.17: 꺾임 빔(팔레타이저 오프셋) + 무모터 (J2/J3 하부)
// =====================================================================
// 측판 1형상 ×2 — 전 홀 관통 → 평행이동 장착 (플립 불요, 꺾임과 양립).
// 프로파일: 러그 3원 hull (무릎 +z 볼록, knee_h≈14.9) — 현(chord) = x축 0~L1.
// 홀 세트 (양 측판 동일):
//   J2 (0):    6805ZZ 압입 ⌀37 — -Y: J2 허브 보스 / +Y: 크랭크 보스 안착
//              + J2 허브 M4 셀프태핑 파일럿 ×3 (r24 — -Y측 사용)
//   팔꿈치(L1): 608ZZ 압입 ⌀22 (숄더 ⌀8×30 피벗 ×2)
//   스탠드오프 M6 ×3: z=-16 벨트 (현 아래)
//   J3 리미트 스위치 M2 ×2: (L1-45, 0) — +Y 측판 내면 (forearm 베인 감지)
//   ※ v0.18: 링크가 forearm 중앙으로 이동 → 크랭크 핀이 측판 미관통, 아크 슬롯 폐지
include <../config/parameters.scad>
use <../lib/utils.scad>

ua_standoffs = [[40, arm_standoff_z], [100, arm_standoff_z],
                [160, arm_standoff_z]];

module ua_plate2d() {
    difference() {
        bent_beam2d(L1, ua_bend_pos, ua_bend_deg, arm_lug_r);
        // J2: 6805ZZ 압입 + 허브 M4 파일럿 ×3
        circle(d = BRG_6805ZZ[1] + bearing_press_fit);
        for (a = [90, 210, 330])
            rotate(a) translate([hub_bolt_r_j2, 0])
                circle(d = set_screw_pilot_d);
        // 팔꿈치: 608ZZ 압입
        translate([L1, 0])
            circle(d = BRG_608ZZ[1] + bearing_press_fit);
        // 스탠드오프 M6 ×3
        for (p = ua_standoffs) translate(p) circle(d = 6.6);
        // J3 리미트 스위치 M2 ×2 (x 피치)
        for (s = [-1, 1])
            translate([L1 - elbow_ls_x + s * ls_hole_pitch / 2, 0])
                circle(d = ls_hole_d);
    }
}

module ua_plate(col = undef) {
    apply_part_color(col) linear_extrude(arm_plate_t) ua_plate2d();
}

// piece: "full"(측판 ×2 조립 배치) | "plate"(단품)
module upper_arm(piece = "full", col = undef, col2 = undef) {
    plate2_col = is_undef(col2) ? col : col2;
    if (piece == "full") {
        translate([0, ua_out_y, 0]) rotate([90, 0, 0]) ua_plate(col);        // +Y
        translate([0, -ua_in_y, 0]) rotate([90, 0, 0]) ua_plate(plate2_col); // -Y
    }
    else ua_plate(col);
}

upper_arm();
