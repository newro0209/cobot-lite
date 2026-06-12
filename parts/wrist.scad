// 손목 (wrist) — 순수 플레이트 아키텍처 (v0.13, MEC-002, GEN-003)
// =====================================================================
// 구성 (벽·박스·텅 폐기 — 전부 평판 + 표준 스탠드오프):
//   [side_a/-Y, side_b/+Y] t7 측판, y ±(30..37) — 하완 측판(±22.3) 외측에서
//       ⌀8 숄더 볼트 스택으로 결합 (베어링은 하완 플레이트에 — v0.13 관절 반전).
//       side_b는 혼 일체 (핀 = 5mm 숄더 볼트, 플레이트 관통 + 너트)
//   [top]    t7 수평판 — J4 NEMA17(출력 하향) + 측판 탭 슬롯 ×4 + M3 ×2
//   [bottom] t7 수평판 — 6805ZZ **관통 압입**(폭 7 = 판 두께) + J4 리미트 홀
//   스탠드오프: M4 ×4 + 튜브 ⌀10×26 (top↔bottom 모서리) — 측면 완전 개방
//       (무두 볼트 접근·배선·경량)
// 수동 평행사변형(MEC-002)이 본체(수평) 유지. 하중: 페이로드 → 플랜지 →
//   6805(bottom) → 스탠드오프 → top → 측판 → 손목 볼트 → 하완
// 제조: 전 피스 평판 — FDM 평면 / CNC 2.5D (GEN-002)
include <../config/parameters.scad>
use <../lib/utils.scad>
use <../lib/vitamins.scad>

side_in  = arm_inner_w / 2;                 // 측판 내면 |Y| = 30
top_z    = -(arm_lug_r + 4);                // 상판 상면 (하완 러그 스윕 아래)
top_b    = top_z - arm_plate_t;             // 상판 하면
bot_t    = top_b - (gbx_out_shaft_len + 5); // 하판 상면 = 표준 스탠드오프 L25
bot_b    = bot_t - arm_plate_t;             // 하판 하면
hx0 = -16;  hx1 = wrist_offset + 26;        // 수평판 X 범위
// 두꺼운 육각 스탠드오프 M6 AF13 ×3 (v0.13 — 4점 → 3점 축소)
standoffs = [[28, 22], [72, 22], [50, -22]];
tab_xs = [-12, 6];                          // 측판 탭 발 x 시작 (폭 10)

// 측판 2D (XZ): 피벗 러그 + 푸터 + 탭 발
module w_side2d(horn = false) {
    union() {
        hull() {
            circle(r = arm_lug_r);
            translate([-16, top_z - 0.1]) square([38, 4]);
        }
        if (horn) hull() {                   // 혼 (링크 2 핀, MEC-002)
            translate([0, pl_offset]) circle(d = 14);
            translate([0, 24]) circle(d = 22);
        }
        for (t = tab_xs)                     // 탭 발 (상판 슬롯 결합)
            translate([t, top_z - arm_plate_t - 0.1]) square([10, arm_plate_t + 4]);
    }
}

module w_side(y0, horn = false) {
    difference() {
        translate([0, y0 + arm_plate_t, 0]) rotate([90, 0, 0])
            linear_extrude(arm_plate_t) difference() {
                w_side2d(horn);
                circle(d = shoulder_d_large + clearance_fit);   // 손목 볼트 ⌀8
                if (horn) translate([0, pl_offset])
                    circle(d = shoulder_d_small + clearance_fit); // 혼 핀 ⌀5 관통
                translate([14, -16]) circle(d = 12);            // 경량창
            }
        // 탭 M3 파일럿 (하단 에지 — 상판에서 수직 체결)
        for (t = tab_xs)
            translate([t + 5, y0 + arm_plate_t / 2, top_b - 8])
                cylinder(d = m3_tap_d, h = 8.1);
    }
}

// ── 상판: NEMA17 + 측판 탭 슬롯 + 스탠드오프 ──
module w_top() {
    difference() {
        translate([(hx0 + hx1) / 2, 0, top_b]) linear_extrude(arm_plate_t)
            offset(r = 5) square([hx1 - hx0 - 10, 2 * side_in + 2 * arm_plate_t - 10],
                                 center = true);
        // J4 NEMA17 (기어박스 플랜지 상면 안착, 출력 하향)
        translate([wrist_offset, 0, top_b - 0.1]) nema17_mount(arm_plate_t + 0.2);
        // 측판 탭 슬롯 ×4 + M3 ×2/측판
        for (sy = [-1, 1], t = tab_xs) {
            translate([t - 0.15, sy * side_in - 0.15 - (sy < 0 ? arm_plate_t : 0),
                       top_b - 0.1])
                cube([10.3, arm_plate_t + 0.3, arm_plate_t + 0.2]);
            translate([t + 5, sy * (side_in + arm_plate_t / 2), top_b - 0.1])
                bolt_hole(3, arm_plate_t + 0.2);
        }
        // 스탠드오프 M6 ×3
        for (p = standoffs)
            translate([p[0], p[1], top_b - 0.1]) bolt_hole(6, arm_plate_t + 0.2);
    }
}

// ── 하판: 6805ZZ 관통 압입 + J4 리미트 ──
module w_bottom() {
    difference() {
        translate([(hx0 + hx1) / 2, 0, bot_b]) linear_extrude(arm_plate_t)
            offset(r = 5) square([hx1 - hx0 - 10, 2 * side_in + 2 * arm_plate_t - 10],
                                 center = true);
        // 6805ZZ 관통 압입 (폭 7 = 판 두께, CON-003)
        translate([wrist_offset, 0, bot_b - 0.1])
            cylinder(d = BRG_6805ZZ[1] + bearing_press_fit, h = arm_plate_t + 0.2);
        for (p = standoffs)
            translate([p[0], p[1], bot_b - 0.1]) bolt_hole(6, arm_plate_t + 0.2);
        // J4 리미트 스위치 M2 ×2 (하면 — 플랜지 림 베인 감지, ELE-004)
        translate([wrist_offset + 14, side_in - 4, bot_b - 0.1])
            rotate([0, 0, 90]) ls_mount_holes(arm_plate_t + 0.2);
    }
}

// part: "full"(조립 표시) | "side_a" | "side_b" | "top" | "bottom"
module wrist(part = "full") {
    if (part == "full") {
        w_side(-side_in - arm_plate_t);
        w_side(side_in, horn = true);
        w_top(); w_bottom();
    }
    else if (part == "side_a") w_side(-side_in - arm_plate_t);
    else if (part == "side_b") w_side(side_in, horn = true);
    else if (part == "top") w_top();
    else if (part == "bottom") w_bottom();
}

// 비주얼 참조 (STL 제외)
%translate([wrist_offset, 0, top_z]) rotate([180, 0, 0]) actuator_J4();

wrist();
