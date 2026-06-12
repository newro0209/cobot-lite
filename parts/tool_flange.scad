// 공구 플랜지 (tool flange) — 표준화 그리퍼 인터페이스 (GEN-004, PER-001)
// 허브 보스가 6805ZZ 내경에 직접 안착 (CON-003), 스템이 J4 기어박스
// 출력축(⌀8×20)에 M4 무두 볼트 ×2로 결합 (손목 측벽 액세스 홀).
// 좌표: z=0 = 디스크 하면(그리퍼 접합면), +Z 위.
include <../config/parameters.scad>
use <../lib/utils.scad>

stem_d  = 16;
stem_top = flange_t + BRG_6805ZZ[2] + (gbx_out_shaft_len + 5) - 2; // 하판 상면 위 노출 구간 (v0.13 L25 스탠드오프)
bore_depth = 12;

module tool_flange() {
    difference() {
        union() {
            // 디스크 — 하면(그리퍼 접합면) 모서리 챔퍼 2mm
            cylinder(d1 = flange_d - 4, d2 = flange_d, h = 2);
            translate([0, 0, 2]) cylinder(d = flange_d, h = flange_t - 2);
            translate([0, 0, flange_t]) bearing_boss(BRG_6805ZZ, BRG_6805ZZ[2]); // 6805 보스
            translate([0, 0, flange_t + BRG_6805ZZ[2]])
                cylinder(d = stem_d, h = stem_top - flange_t - BRG_6805ZZ[2]); // 스템
            // J4 리미트 베인 (디스크 림 반경 탭)
            translate([flange_d / 2 - 1, -4, 0]) cube([6, 8, flange_t]);
        }
        // J4 출력축 보어 (스템 상단에서) + 무두 볼트 M4 ×2 (90°)
        translate([0, 0, stem_top - bore_depth])
            cylinder(d = gbx_out_shaft_d + clearance_fit / 2, h = bore_depth + 0.1);
        for (a = [0, 90])
            rotate([0, 0, a])
                translate([stem_d / 2 - 7, 0, stem_top - bore_depth / 2])
                    rotate([0, 90, 0]) cylinder(d = set_screw_pilot_d, h = 8);
        // 그리퍼 체결 M4 ×4 (볼트 서클) + 상면 너트 포켓
        for (a = [0 : 90 : 270]) rotate([0, 0, a + 45]) {
            translate([flange_bc / 2, 0, -0.1]) bolt_hole(flange_bolt_d, flange_t + 0.2);
            translate([flange_bc / 2, 0, flange_t - 3.4]) nut_pocket(m4_nut_af, 3.5);
        }
        // 센터 홀 (배선/위치 결정)
        translate([0, 0, -0.1]) cylinder(d = 10, h = flange_t + 0.2);
    }
}

tool_flange();
