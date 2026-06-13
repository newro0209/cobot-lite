// 베이스 플레이트 (base plate) — v0.17: 동일 플레이트 ×2
// =====================================================================
// 상판(z0 상면) = J1 베어링/액추에이터 캐리어, 하판 = 지면판(ground) —
// 같은 형상 1종 ×2 (지면판의 관통 홀은 미사용 — 동일 부품 원칙).
// 사이는 코너 육각 스탠드오프 M6 L100 ×4 (J1 액추에이터 매달림 91 수납).
// 중앙: J1 기어박스를 하면에 직결 (NEMA17 M3 ×4로 위치 — 중심은 커플러 ⌀24
//   관통 위해 ⌀25로 개방, ⌀22 파일럿 register 미사용. 볼트는 상면에서).
// 링 플랜지 M4 ×4 (r39, 위상 0/90/180/270 — NEMA 45° 위상과 분리).
// J1 리미트 스위치 M2 ×2 (-y측 r72, 터릿 베인 감지 — 레버형 KW12)
include <../config/parameters.scad>
use <../lib/utils.scad>

module base_plate2d() {
    difference() {
        offset(r = 8) square(base_size - 16, center = true);
        circle(d = cpl_body_od + clearance_fit + 0.6);         // J1 커플러 관통 ⌀25
        for (a = [45, 135, 225, 315])                          // NEMA17 M3 ×4
            rotate(a) translate([nema17_hole_pitch / 2 * sqrt(2), 0])
                circle(d = nema17_bolt_d + bolt_hole_oversize);
        for (a = [0, 90, 180, 270])                            // 링 플랜지 M4 ×4
            rotate(a) translate([j1_ring_bolt_r, 0])
                circle(d = 4 + bolt_hole_oversize);
        for (x = [-1, 1], y = [-1, 1])                         // 스탠드오프 M6 ×4
            translate([x * base_corner_off, y * base_corner_off])
                circle(d = 6.6);
        // J1 리미트 스위치 M2 ×2 (x 피치)
        for (s = [-1, 1])
            translate([s * ls_hole_pitch / 2, -(turret_r - 8)])
                circle(d = ls_hole_d);
    }
}

module base_plate(col = undef) {
    apply_part_color(col) linear_extrude(arm_plate_t) base_plate2d();
}

base_plate();
