// 하완 (forearm) — v0.18: 꺾임 빔 + 혼 핀 러그 일체 (별도 혼 부품 폐지)
// =====================================================================
// 측판 1형상 ×2 — 전 홀 관통 → 평행이동 장착 (플립 불요).
// 프로파일: 러그 hull (무릎 +z 볼록) + 혼 핀 러그(R36.5, horn_phase) — 측판이
//   곧 혼: 두 측판 사이 ⌀5 숄더 핀이 평행사변형 힘을 받아 forearm 구동(대칭).
// 팔꿈치(0): ⌀8×30 숄더 볼트 ×2 통과 (너트 고정 — 상완 측판 608ZZ 위 회전)
// 혼 핀(R36.5@horn_phase): ⌀5 숄더 핀 — 중앙 링크 625ZZ 구동
// 선단(225): ⌀8 피벗 홀 (공구 인터페이스 유보)
include <../config/parameters.scad>
use <../lib/utils.scad>

fa_standoffs = [76, 160];
horn_pin = crank_R * [cos(horn_phase), sin(horn_phase)];  // (-33.1, 15.4)

module fa_plate2d() {
    difference() {
        union() {
            bent_beam2d(forearm_len, fa_bend_pos, fa_bend_deg, arm_lug_r);
            // 혼 핀 러그 (팔꿈치 → 핀)
            hull() {
                circle(r = arm_lug_r);
                translate(horn_pin) circle(r = 9);
            }
            // J3 리미트 베인 탭 (forearm 일체 — 상완 측판 스위치 감지)
            rotate(elbow_vane_a) translate([0, -elbow_vane_w / 2])
                square([elbow_vane_r, elbow_vane_w]);
        }
        // 팔꿈치 ⌀8 + 혼 핀 ⌀5
        circle(d = shoulder_d_large + clearance_fit / 2);
        translate(horn_pin) circle(d = shoulder_d_small + clearance_fit / 2);
        // 선단 ⌀8 (공구 유보)
        translate([forearm_len, 0])
            circle(d = shoulder_d_large + clearance_fit / 2);
        // 스탠드오프 M6 ×2
        for (x = fa_standoffs) translate([x, 0]) circle(d = 6.6);
    }
}

module fa_plate(col = undef) {
    apply_part_color(col) linear_extrude(arm_plate_t) fa_plate2d();
}

// piece: "full"(측판 ×2 조립 배치) | "plate"(단품)
module forearm(piece = "full", col = undef, col2 = undef) {
    plate2_col = is_undef(col2) ? col : col2;
    if (piece == "full") {
        translate([0, forearm_inner_w / 2 + arm_plate_t, 0])
            rotate([90, 0, 0]) fa_plate(col);                         // +Y
        translate([0, -forearm_inner_w / 2, 0])
            rotate([90, 0, 0]) fa_plate(plate2_col);                  // -Y
    }
    else fa_plate(col);
}

forearm();
