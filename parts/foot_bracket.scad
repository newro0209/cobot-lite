// 타워 풋 브래킷 (foot bracket) — L자, ×4 동일
// =====================================================================
// 수직 레그 = 타워 내면에 M4 ×2 관통(타워 외면 너트),
// 수평 레그 = 터릿 상면에 M4 ×2 관통(터릿 하면 너트).
// 좌표: x = 폭 중심, y0 = 타워 내면 (+y 안쪽), z0 = 터릿 상면
// 출력: 측면 눕힘 — 서포트 불요 (MFG-003)
include <../config/parameters.scad>
use <../lib/utils.scad>

module foot_bracket(col = undef) {
    apply_part_color(col) difference() {
        union() {
            // 수직 레그 (타워 접촉면 y0)
            translate([-foot_w / 2, 0, 0])
                cube([foot_w, tower_foot_t, foot_leg_h]);
            // 수평 레그 (터릿 접촉면 z0)
            translate([-foot_w / 2, 0, 0])
                cube([foot_w, foot_leg_d, tower_foot_t]);
        }
        // 타워 체결 M4 ×2
        for (s = [-1, 1])
            translate([s * foot_bolt_pitch / 2, -0.1, foot_bolt_z])
                rotate([-90, 0, 0]) bolt_hole(4, tower_foot_t + 0.2);
        // 터릿 체결 M4 ×2
        for (s = [-1, 1])
            translate([s * foot_bolt_pitch / 2, foot_bolt_inset, -0.1])
                bolt_hole(4, tower_foot_t + 0.2);
    }
}

foot_bracket();
