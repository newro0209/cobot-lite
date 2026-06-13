// J3 크랭크 (crank) — 중앙 디스크 + 보스 OD 25(+Y 6805 저널) + 외단 플랜지
// =====================================================================
// 평행사변형 평면 = forearm 중앙(y=0). 크랭크 = J2축 회전 a = j3 + horn_phase.
//   디스크 OD 52(world y4.7~11.7) — 핀(R36.5, z0=-Y면)이 중앙 링크 625ZZ에 결합.
//   보스 OD 25 — +Y 측판 6805ZZ 내륜 안착.
//   외단 플랜지 — 기성 플랜지 커플러 M4 ×4 볼트온.
// 좌표: 부품 z0 = 디스크 -Y면(핀측, world y4.7). 출력: 보스 직립, 디스크 바닥 — 서포트 불요.
include <../config/parameters.scad>
use <../lib/utils.scad>

module crank2d() {
    fillet_concave2d()
    union() {
        circle(d = crank_disk_d);
        hull() {
            circle(d = crank_disk_d * 0.7);
            translate([crank_R, 0]) circle(r = 8);
        }
    }
}

module j3_crank(col = undef) {
    boss_len  = (crank_flange_y0 - crank_disk_y0) - arm_plate_t;
    flange_z0 = arm_plate_t + boss_len;
    flange_top = flange_z0 + arm_plate_t;
    apply_part_color(col) difference() {
        union() {
            linear_extrude(arm_plate_t) crank2d();
        }
        // 중앙 경량 보어 (관통)
        translate([0, 0, -0.1]) cylinder(d = crank_boss_id, h = flange_top + 0.2);
        // 핀 숄더 보어 (관통)
        translate([crank_R, 0, -0.1])
            cylinder(d = shoulder_d_small + clearance_fit / 2, h = arm_plate_t + 0.2);
    }
}

j3_crank();
