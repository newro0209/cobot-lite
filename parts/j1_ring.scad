// J1 베어링 링 (slew ring housing) — 6810ZZ 외륜 압입 (고정측)
// =====================================================================
// 베이스 상판에 M4 ×4 볼트온. 6810ZZ 외륜을 상부 시트(z13~20)에 압입,
// 내륜은 회전 터릿 보스(⌀50)가 받친다 — J1 모멘트 하중 경로:
//   암 → 터릿 → 보스(6810 내륜) → 볼 → 외륜 → 링 → 베이스.
// z 로컬 = 베이스 상면 0 기준:
//   0~3   바닥 플랜지 ⌀90 (M4 ×4, r39)
//   0~20  몸통 ⌀78
//   0~13  내경 ⌀51 (회전 보스·커플러 ⌀50 클리어 — 기어박스 축은 중심 통과)
//   13~20 6810 외륜 시트 ⌀64.85(-압입)
// 출력: 튜브 직립 — 서포트 불요 (MFG-003)
include <../config/parameters.scad>
use <../lib/utils.scad>

module j1_ring(col = undef) {
    seat_z = j1_ring_h - BRG_6810ZZ[2];          // 13
    apply_part_color(col) difference() {
        union() {
            cylinder(d = j1_ring_flange_od, h = 3);       // 베이스 플랜지
            cylinder(d = j1_ring_od, h = j1_ring_h);      // 몸통
        }
        // 6810 외륜 시트 (상부 z13~20)
        translate([0, 0, seat_z])
            cylinder(d = j1_ring_bore, h = BRG_6810ZZ[2] + 0.1);
        // 시트 아래 내경 (회전 보스/커플러 클리어, z0~13)
        translate([0, 0, -0.1])
            cylinder(d = j1_ring_inner, h = seat_z + 0.1);
        // 플랜지 M4 ×4
        for (a = [0, 90, 180, 270])
            rotate([0, 0, a]) translate([j1_ring_bolt_r, 0, -0.1])
                bolt_hole(4, 3.2);
    }
}

j1_ring();
