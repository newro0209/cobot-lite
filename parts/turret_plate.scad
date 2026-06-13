// 터릿 플레이트 (turret plate) — J1 회전 동체 (6810 내륜 보스 일체)
// =====================================================================
// 하면에 ⌀50 보스(z13~20) 일체 — 6810ZZ 내륜에 압입(회전 동체측 지지).
// 보스 하면(z13)에 기성 플랜지 커플러(⌀50, set screw)가 셀프태핑 M5 ×4(r18.5)
// 볼트온 → 기어박스 ⌀8 출력축을 grip (J1 토크: 축→커플러→보스→터릿).
// 상면: 타워 ×2를 풋 브래킷 ×4로 기립 (M4 관통 + 하면 너트).
//   풋 볼트 y = ±(타워 내면 - foot_bolt_inset) — 타워 내면 비대칭(-62/+63).
// J1 리미트 베인 = 외주 일체 탭 (r75, 평면 내 — 베이스 상면 스위치 감지)
// 좌표: J1 축 = 원점, +x = 전방 (J2 축 = x+30). 터릿 본체 z0~7, 보스 z(-7)~0.
include <../config/parameters.scad>
use <../lib/utils.scad>

module turret_plate2d() {
    difference() {
        union() {
            hull() {
                circle(r = 66);
                translate([j2_fwd, 0]) circle(r = 60);
            }
            // J1 리미트 베인 탭 (평면 내, 외주 돌출)
            rotate(j1_vane_a) translate([60, -elbow_vane_w / 2])
                square([j1_vane_r - 60, elbow_vane_w]);
        }
        // 타워 풋 M4 (관통 + 하면 너트) — 내면 비대칭 반영
        for (fx = feet_x, sx = [-1, 1])
            for (fy = [-(tower_in_neg - foot_bolt_inset),
                        tower_in_pos - foot_bolt_inset])
                translate([fx + sx * foot_bolt_pitch / 2, fy])
                    circle(d = 4 + bolt_hole_oversize);
    }
}

module turret_plate(col = undef) {
    apply_part_color(col) difference() {
        union() {
            linear_extrude(turret_t) turret_plate2d();
            // J1 보스 (6810 내륜, 하면 -z 돌출)
            translate([0, 0, -turret_boss_h])
                cylinder(d = j1_boss_d, h = turret_boss_h + 0.01);
        }
        // 축 관통 보어 (기어박스 ⌀8 출력축 팁)
        translate([0, 0, -turret_boss_h - 0.1])
            cylinder(d = cpl_bore + clearance_fit + 0.6,
                     h = turret_t + turret_boss_h + 0.2);
        // 커플러 플랜지 셀프태핑 M5 ×4 — 보스 하면(z=-turret_boss_h)에서 블라인드
        for (i = [0 : cpl_bolt_n - 1])
            rotate([0, 0, 45 + i * 360 / cpl_bolt_n])
                translate([cpl_bolt_r, 0, -turret_boss_h - 0.05])
                    cylinder(d = cpl_bolt_d - 0.5, h = 6);
    }
}

turret_plate();
