// 타워 플레이트 (shoulder tower) — 동일 형상 ×2, 플립 장착
// =====================================================================
// 터릿 상면에 풋 브래킷으로 기립. J2/J3 액추에이터를 양측 외면에 직결
// (⌀22 보어 = 기어박스 파일럿, NEMA17 M3 ×4 — 내면 카운터보어로 머리 플러시:
//   -Y 갭은 J2 허브, +Y 갭은 크랭크가 0.5mm 간극으로 지나간다).
// 프로파일은 x = j2_fwd 대칭 → 플립(=x미러) 장착으로 카운터보어가
// 양 타워 모두 내면에 온다. 스위치 홀도 미러 쌍으로 양쪽 포함.
// 좌표: 2D (x, z) — 터릿 프레임 x(J1 축 원점), z = 터릿 상면 0
include <../config/parameters.scad>
use <../lib/utils.scad>

// J2 스위치 홀 기준점 (J2 축 극좌표) + x미러 쌍
ls_p = [j2_fwd + j2_vane_r * cos(j2_ls_a), tower_j2_h + j2_vane_r * sin(j2_ls_a)];

module tower_plate2d() {
    difference() {
        hull() {
            translate([j2_fwd - tower_base_w / 2, 0]) square([tower_base_w, 10]);
            translate([j2_fwd, tower_j2_h]) circle(r = tower_lug_r);
        }
        // J2/J3 액추에이터 인터페이스 (⌀22 파일럿 + NEMA17 M3 ×4)
        translate([j2_fwd, tower_j2_h]) {
            circle(d = nema17_pilot_d + clearance_fit);
            for (x = [-1, 1], y = [-1, 1])
                translate([x * nema17_hole_pitch / 2, y * nema17_hole_pitch / 2])
                    circle(d = nema17_bolt_d + bolt_hole_oversize);
        }
        // 스탠드오프 M6 ×3 (x대칭 배치)
        for (p = tower_standoffs) translate(p) circle(d = 6.6);
        // 풋 브래킷 M4 ×2/풋 (관통 + 외면 너트)
        for (fx = feet_x, sx = [-1, 1])
            translate([fx + sx * foot_bolt_pitch / 2, foot_bolt_z])
                circle(d = 4 + bolt_hole_oversize);
        // J2 리미트 스위치 M2 ×2 — 미러 쌍 (플립 장착 시 한 세트 사용)
        for (px = [ls_p[0], 2 * j2_fwd - ls_p[0]], s = [-1, 1])
            translate([px + s * ls_hole_pitch / 2, ls_p[1]])
                circle(d = ls_hole_d);
    }
}

// 카운터보어 면 = z7 (장착 시 내면이 되도록 플립 방향 선택)
module tower_plate(col = undef) {
    apply_part_color(col) difference() {
        linear_extrude(arm_plate_t) tower_plate2d();
        translate([j2_fwd, tower_j2_h, 0])
            for (x = [-1, 1], y = [-1, 1])
                translate([x * nema17_hole_pitch / 2,
                           y * nema17_hole_pitch / 2, arm_plate_t - 2.2])
                    cylinder(d = 6.5, h = 2.3);
    }
}

tower_plate();
