// 공구 플랜지 (tool flange) — v0.15 재설계 (GEN-004, PER-001)
// =====================================================================
// 디스크 + 허브 스템 보스: 스템이 손목 바텀 플레이트의 6805ZZ 내경에 직접
// 안착 (CON-003). J4 기어박스 출력축(⌀8, 하향)이 스템·디스크 보어 관통 —
// M4 무두 볼트 ×2 (디스크 측면 반경 방향, 개방 공간에서 직접 접근).
// 그리퍼: BC32 M4 ×4 (상면 너트 포켓 — 바텀 플레이트와 1.5mm 갭에 선삽입)
// 좌표: z0 = 디스크 하면(그리퍼 접합면), +Z 위. 출력: 하면 베드 (서포트리스)
include <../config/parameters.scad>
use <../lib/utils.scad>

module tool_flange() {
    difference() {
        union() {
            // 디스크 — 하면 모서리 챔퍼 2mm
            cylinder(d1 = flange_d - 4, d2 = flange_d, h = 2);
            translate([0, 0, 2]) cylinder(d = flange_d, h = flange_t - 2);
            // 허브 스템 보스 (6805ZZ 내경 직접 안착)
            translate([0, 0, flange_t])
                cylinder(d = BRG_6805ZZ[0] - bearing_press_fit, h = BRG_6805ZZ[2] + 1);
        }
        // 출력축 ⌀8 보어 (관통)
        translate([0, 0, -0.1])
            cylinder(d = gbx_out_shaft_d + clearance_fit,
                     h = flange_t + BRG_6805ZZ[2] + 1.2);
        // M4 무두 파일럿 ×2 (디스크 반경 방향, 90° 위상)
        for (a = [0, 90]) rotate(a)
            translate([0, 0, 4]) rotate([0, 90, 0])
                cylinder(d = set_screw_pilot_d, h = flange_d);
        // 그리퍼 BC32 M4 ×4 + 상면 너트 포켓
        for (a = [45 : 90 : 359]) rotate(a) translate([flange_bc / 2, 0, 0]) {
            translate([0, 0, -0.1]) bolt_hole(flange_bolt_d, flange_t + 0.2);
            translate([0, 0, flange_t - 3.2]) nut_pocket(m4_nut_af, 3.3);
        }
    }
}

tool_flange();
