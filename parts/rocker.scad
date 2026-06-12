// 팔꿈치 로커 (elbow rocker) — 수동 평행사변형 스테이지 1↔2 중계 (MEC-002)
// 팔꿈치 8mm 숄더 볼트 +Y 연장부에 608ZZ로 자유 회전 (CON-001/002).
// 핀(반경 pl_offset)에 링크 1·2 베어링을 동일 5mm 숄더 볼트로 적층.
// 좌표: 허브 축 = Z (조립 시 +Y), 핀 = +X 방향.
include <../config/parameters.scad>
use <../lib/utils.scad>

hub_w = BRG_608ZZ[2] + 5;   // 608 포켓 + 도피 웹

module rocker() {
    difference() {
        union() {
            cylinder(d = BRG_608ZZ[1] + 10, h = hub_w);            // 허브
            hull() {                                                // 암
                cylinder(d = BRG_608ZZ[1] + 10, h = crank_t);
                translate([pl_offset, 0, 0]) cylinder(d = 14, h = crank_t);
            }
        }
        // 608ZZ 포켓 (z0 면 = 조립 시 -Y측) + 내륜 도피
        translate([0, 0, -0.1])
            bearing_seat([BRG_608ZZ[0], BRG_608ZZ[1], BRG_608ZZ[2] + 0.1]);
        translate([0, 0, -0.1])
            cylinder(d = (BRG_608ZZ[0] + BRG_608ZZ[1]) / 2, h = hub_w + 0.2);
        // 링크 핀: M4 파일럿
        translate([pl_offset, 0, -0.1])
            cylinder(d = set_screw_pilot_d, h = crank_t + 0.2);
    }
}

rocker();
