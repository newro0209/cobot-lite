// 턴테이블 베어링 스페이서 (spacer ring) — 6810ZZ ×2 외륜 이격 30mm 유지 (MEC-003)
// 베이스 칼럼 보어에 슬립 끼움 (압입 아님).
include <../config/parameters.scad>

module turntable_spacer() {
    difference() {
        cylinder(d = BRG_6810ZZ[1] + bearing_press_fit - clearance_fit,
                 h = turntable_bearing_gap);
        translate([0, 0, -0.1])
            cylinder(d = BRG_6810ZZ[0] + 4, h = turntable_bearing_gap + 0.2);
    }
}

turntable_spacer();
