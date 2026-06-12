// 손목 (wrist) — v0.15 재설계: 동일 측판 ×2 + 바텀 플레이트 + 혼 패들
// =====================================================================
// 구성 (탑 플레이트 폐지 — 3종 평판):
//   [wr_side]   t7 동일 측판 ×2, y ±(30..37) — 피벗 ⌀8 + 스탠드오프 M6 ×2
//               (20,±30: 모터 존 x≥29 밖·하완 러그 스윕 r26 밖) + 혼 패들 M4
//               파일럿 ×4 + 바텀 에지 스크류 M3 ×4 (z 대칭 — 플립 장착 호환)
//   [wr_bottom] t7 수평판 (z -37..-30, x 28..90) — J4 액추에이터 직립 탑재
//               (NEMA17, 출력축 하향 관통) + 6805ZZ 동심 관통 압입(기어박스
//               플랜지면이 외륜 상면을 누름) + J4 리미트 M2 ×2 (하면)
//   [wr_horn]   혼 패들 t7 — 측판 외면 M4 ×2 + 너트, 핀(0, pl_offset) =
//               스트리퍼 5×20 + 튜브 ⌀8×15 (link2 평면). 양 측판 어느 쪽이든
//               장착 가능 (피벗 락너트 회피 — 역V 프로파일)
// J4 모터 직립 근거: 하완 빔(r26, 후방 상향)은 x<29 — 모터 존과 분리.
// 하중 경로: 페이로드 → 플랜지 → 6805(바텀) → 에지 스크류+스탠드오프 → 측판
//   → 피벗 ⌀8 스택 → 하완. 제조: 전 피스 평판 (GEN-002)
include <../config/parameters.scad>
use <../lib/utils.scad>

ws_in  = forearm_inner_w / 2 + arm_plate_t + joint_side_tube;   // 30
wb_top = -(arm_lug_r + 4);                                      // -30

// 측판 2D — z 대칭
module wr_side2d() {
    difference() {
        hull() {
            circle(14);
            for (s = [-1, 1]) translate([20, s * 30]) circle(8);
            translate([wb_x0, -37]) square([wb_x1 - wb_x0, 74]);
        }
        circle(d = shoulder_d_large + clearance_fit);            // 피벗 ⌀8
        for (s = [-1, 1]) translate([20, s * 30]) circle(d = 6.6);  // M6 ×2
        for (sx = [-1, 1], sz = [-1, 1])                         // 혼 패들 M4 ×4
            translate([sx * 10, sz * 22]) circle(d = 4.4);
        for (x = [46, 78], s = [-1, 1])                          // 바텀 에지 M3
            translate([x, s * 33.5]) circle(d = 3.4);
    }
}

module wr_side() { linear_extrude(arm_plate_t) wr_side2d(); }

// 바텀 플레이트 (로컬 z0 = 하면, xy = 월드 xy)
module wr_bottom() {
    difference() {
        linear_extrude(arm_plate_t)
            translate([wb_x0, -ws_in]) square([wb_x1 - wb_x0, 2 * ws_in]);
        // 6805ZZ 관통 압입 + J4 NEMA17 (동심, x = wrist_offset)
        translate([wrist_offset, 0, -0.1])
            cylinder(d = BRG_6805ZZ[1] + bearing_press_fit, h = arm_plate_t + 0.2);
        translate([wrist_offset, 0, -0.1]) nema17_mount(arm_plate_t + 0.2);
        // J4 리미트 M2 ×2 (하면 — 플랜지 에지 베인 감지)
        for (x = [75, 84.5])
            translate([x, 0, -0.1]) cylinder(d = ls_hole_d, h = arm_plate_t + 0.2);
        // 에지 스크류 파일럿 M3 ×4 (측면 에지 — CNC 2차 드릴)
        for (x = [46, 78], s = [-1, 1])
            translate([x, s * (ws_in + 0.1), arm_plate_t / 2])
                rotate([s * 90, 0, 0]) cylinder(d = m3_tap_d, h = 12);
    }
}

// 혼 패들 — 역V (피벗 락너트 r9 회피), 핀 보스 (0, pl_offset)
module wr_horn() {
    linear_extrude(arm_plate_t) difference() {
        hull() {
            for (s = [-1, 1]) translate([s * 10, 22]) circle(6);
            translate([0, pl_offset]) circle(8);
        }
        for (s = [-1, 1]) translate([s * 10, 22]) circle(d = 4.4);
        translate([0, pl_offset]) circle(d = set_screw_pilot_d);  // 핀 M4 파일럿
    }
}

// piece: "full" | "side" | "bottom" | "horn"
module wrist(piece = "full") {
    if (piece == "full") {
        translate([0, ws_in + arm_plate_t, 0]) rotate([90, 0, 0]) wr_side();  // +Y
        translate([0, -ws_in - arm_plate_t, 0]) rotate([-90, 0, 0]) wr_side();// -Y
        translate([0, 0, wb_top - arm_plate_t]) wr_bottom();
        // 혼 패들: +Y 측판 외면 (link2 평면 측)
        translate([0, ws_in + 2 * arm_plate_t, 0]) rotate([90, 0, 0]) wr_horn();
    }
    else if (piece == "side")   wr_side();
    else if (piece == "bottom") wr_bottom();
    else if (piece == "horn")   wr_horn();
}

wrist();
