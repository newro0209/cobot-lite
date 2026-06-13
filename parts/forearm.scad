// 하완 (forearm) — v0.18: 꺾임 빔 + 혼 핀 러그 일체 (별도 혼 부품 폐지)
// =====================================================================
// 측판 1형상 ×2 — 전 홀 관통 → 평행이동 장착 (플립 불요).
// 프로파일: 러그 hull (무릎 +z 볼록) + 혼 핀 러그(R36.5, horn_phase) — 측판이
//   곧 혼: 두 측판 사이 숄더 핀 M5가 평행사변형 힘을 받아 forearm 구동(대칭).
// 팔꿈치(0): 통축 클리어 ID 8 + 플랜지 커플러 M5×4 (하완이 커플러로 통축 볼트 grip → 함께 회전)
// 혼 핀(R36.5@horn_phase): 숄더 핀 M5 — 중앙 링크 625ZZ 구동
// 선단(225): 피벗 홀 ID 8 (공구 인터페이스 유보)
include <../config/parameters.scad>
use <../lib/utils.scad>

horn_pin = crank_R * [cos(horn_phase), sin(horn_phase)];  // (-33.1, 15.4)

module fa_plate2d() {
    difference() {
        fillet_concave2d()
        union() {
            bent_band2d([[0, 0], [fa_bend_pos * forearm_len, knee_h(forearm_len, fa_bend_pos, fa_bend_deg, fa_kink_off)], [forearm_len, 0]], shoulder_d_large + 4, fa_body_hw);
            // 혼 핀 러그 (팔꿈치 → 핀)
            hull() {
                circle(r = arm_lug_r);
                translate(horn_pin) circle(r = 9);
            }
            // J3 리미트 베인 탭 (forearm 일체 — 상완 측판 스위치 감지)
            rotate(elbow_vane_a) translate([0, -elbow_vane_w / 2])
                square([elbow_vane_r, elbow_vane_w]);
        }
        // 팔꿈치: 통축 클리어 ID 8 + 플랜지 커플러 M4×4 셀프태핑 (+Y판이 커플러로 볼트 grip)
        circle(d = shoulder_d_large + clearance_fit / 2);
        for (i = [0 : cpl_bolt_n - 1])
            rotate(45 + i * 360 / cpl_bolt_n)
                translate([cpl_bolt_r, 0]) circle(d = cpl_bolt_d - 0.5);
        // 혼 핀 M5
        translate(horn_pin) circle(d = shoulder_d_small + clearance_fit / 2);
        // 선단 ID 8 (공구 유보)
        translate([forearm_len, 0])
            circle(d = shoulder_d_large + clearance_fit / 2);
        // 스탠드오프 M3 ×2 (중심선 굴절 추종 — 밴드 내부 유지)
        for (x = fa_standoff_xa) translate([x, fa_standoff_pos(x)]) circle(d = m3_standoff_d);
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
