// J3 크랭크 (crank) — 중앙 디스크 + 긴 보스(+Y 6805 통과) + 커플러 결합 플랜지
// =====================================================================
// 링크를 forearm 중앙(y=0)에 두기 위해 크랭크를 J2축 중앙 근처로 이동:
//   z0 디스크(⌀52, world y4.7~11.7) — 핀(R36.5, z0=-Y면)이 중앙 링크에 결합.
//   ⌀25 보스(world y11.7~37) — 상완 +Y 측판 6805ZZ 내륜 안착(world 30~37).
//   외단 플랜지(⌀52, world y37~44) — 기성 플랜지 커플러(⌀50) 셀프태핑 M5 ×4(r18.5)
//     볼트온 → 기어박스 ⌀8 축 grip (J3 토크: 축→커플러→보스→디스크→핀).
// 디스크는 6805(y37)에서 보면 캔틸레버(~25mm) — 사용자 승인 (단일 중앙 링크).
// 좌표: 부품 z0 = 디스크 -Y면(핀측). 출력: 보스 직립, 디스크 바닥 — 서포트 불요.
include <../config/parameters.scad>
use <../lib/utils.scad>

module crank2d() {
    union() {
        circle(d = crank_hub_d);
        hull() {
            circle(d = crank_hub_d * 0.7);
            translate([crank_R, 0]) circle(r = 8);
        }
    }
}

module j3_crank(col = undef) {
    boss_top = arm_plate_t + crank_boss_len;          // 32.3 (보스 외단 = world y37)
    ofl_top  = boss_top + crank_ofl_t;                // 39.3 (플랜지 외단 = world y44)
    apply_part_color(col) difference() {
        union() {
            linear_extrude(arm_plate_t) crank2d();    // 디스크 (z0~7)
            translate([0, 0, arm_plate_t])            // ⌀25 보스 (6805 내륜)
                cylinder(d = crank_boss_od - bearing_press_fit, h = crank_boss_len);
            translate([0, 0, boss_top])               // 외단 커플러 결합 플랜지 ⌀52
                cylinder(d = crank_hub_d, h = crank_ofl_t);
        }
        // 중앙 보어 (기어박스 축 ⌀8 + 커플러 볼트 도피) 관통
        translate([0, 0, -0.1]) cylinder(d = crank_boss_id, h = ofl_top + 0.2);
        // 커플러 플랜지 셀프태핑 M5 ×4 — 외단 플랜지면(z=ofl_top)에서 블라인드
        for (i = [0 : cpl_bolt_n - 1])
            rotate([0, 0, 45 + i * 360 / cpl_bolt_n])
                translate([cpl_bolt_r, 0, ofl_top - 6])
                    cylinder(d = cpl_bolt_d - 0.5, h = 6.1);
        // 핀 ⌀5 스너그 + 머리 카운터보어 (z0 = -Y면, 링크측)
        translate([crank_R, 0, -0.1])
            cylinder(d = shoulder_d_small + clearance_fit / 2, h = arm_plate_t + 0.2);
        translate([crank_R, 0, -0.05]) cylinder(d = 8.8, h = 4.5);
    }
}

j3_crank();
