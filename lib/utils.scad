// 공통 모듈 (common modules) — 베어링 시트, 볼트 홀 등
include <../config/parameters.scad>

// 베어링 시트 (bearing seat): 압입 공차 적용 포켓
// brg = [내경, 외경, 폭] (예: BRG_608ZZ)
module bearing_seat(brg) {
    cylinder(d = brg[1] + bearing_press_fit, h = brg[2]);
}

// 베어링 시트 + 내륜 도피 홀 (관통)
// wall = 시트 아래 받침 두께
module bearing_pocket(brg, wall = 2) {
    union() {
        translate([0, 0, wall]) bearing_seat(brg);
        // 내륜 접촉 방지: 내경보다 크고 외경보다 작은 도피 홀
        cylinder(d = (brg[0] + brg[1]) / 2, h = wall + 0.1);
    }
}

// 관통 볼트 홀 (clearance hole)
module bolt_hole(d, h) {
    cylinder(d = d + bolt_hole_oversize, h = h);
}

// NEMA 17 모터 마운트 홀 패턴 (CON-004: SF24 = 42각 NEMA 17 호환)
// h = 판 두께
module nema17_mount(h) {
    union() {
        cylinder(d = nema17_pilot_d + clearance_fit, h = h);
        for (x = [-1, 1], y = [-1, 1])
            translate([x * nema17_hole_pitch / 2, y * nema17_hole_pitch / 2, 0])
                bolt_hole(nema17_bolt_d, h);
    }
}

// 숄더 볼트 피벗 홀 (CON-001)
// d = 숄더 직경 (shoulder_d_small | shoulder_d_large)
module pivot_hole(d, h) {
    cylinder(d = d + clearance_fit, h = h);
}

// 베어링 보스 (bearing boss): 출력물 허브에 베어링 내경 직접 안착 (CON-003)
// 내경 기준 압입 — bearing_press_fit(음수)만큼 키운다
module bearing_boss(brg, h) {
    cylinder(d = brg[0] - bearing_press_fit, h = h);
}

// 육각 너트 포켓 (nut pocket) — 차집합용. af = 평면폭(across flats)
module nut_pocket(af, t) {
    cylinder(d = (af + clearance_fit) / cos(30), h = t, $fn = 6);
}

// 리미트 스위치 장착 홀 쌍 (ELE-004) — 차집합용, X축 방향 피치
module ls_mount_holes(h) {
    for (x = [-1, 1])
        translate([x * ls_hole_pitch / 2, 0, 0])
            cylinder(d = ls_hole_d, h = h);
}

// 케이블 가이드 클립 (ELE-005) — 외면 부착형 C-클립, cable_d 다발 직경
module cable_clip(cable_d = 8, t = 4) {
    wall = 2.5;
    difference() {
        cylinder(d = cable_d + 2 * wall, h = t);
        translate([0, 0, -0.1]) cylinder(d = cable_d, h = t + 0.2);
        // 삽입 개구 (개구 폭 = 케이블 직경의 70%)
        translate([0, -cable_d * 0.35, -0.1])
            cube([cable_d, cable_d * 0.7, t + 0.2]);
    }
}

// 평행/구동 링크 바 (625ZZ 양단, MEC-002/MEC-001a)
// len = 피벗 간 거리. 보스 상면에서 베어링 압입, 하면 내륜 도피 홀.
module link_bar(len) {
    boss_t = BRG_625ZZ[2] + 4;
    difference() {
        union() {
            translate([0, -link_bar_w / 2, (boss_t - link_bar_t) / 2])
                cube([len, link_bar_w, link_bar_t]);
            for (x = [0, len])
                translate([x, 0, 0]) cylinder(d = link_boss_d, h = boss_t);
        }
        for (x = [0, len]) {
            translate([x, 0, boss_t - BRG_625ZZ[2]])
                bearing_seat([BRG_625ZZ[0], BRG_625ZZ[1], BRG_625ZZ[2] + 0.1]);
            translate([x, 0, -0.1])
                cylinder(d = (BRG_625ZZ[0] + BRG_625ZZ[1]) / 2, h = boss_t + 0.2);
        }
    }
}

// 지시선(leader) + 빌보드(billboard) 라벨 — 프리뷰용, $vpr 카메라 추종
// p = 앵커(부품 측), v = 지시선 벡터 (라벨은 p+v 위치)
// 주의: 상위 프레임이 회전된 경우 빌보드가 카메라를 향하지 않음 — 월드 프레임에서 호출할 것
module leader_label(p, v, txt, size = 3.2, col = "white") {
    color(col) {
        hull() {
            translate(p) sphere(d = 1.4, $fn = 12);
            translate(p + v) sphere(d = 1.4, $fn = 12);
        }
        translate(p + v) rotate($vpr) translate([2, -size / 2, 0])
            linear_extrude(0.6) text(txt, size = size);
    }
}

// 축 클램프 슬릿 + M3 핀치 볼트 (차집합용)
// bore_d = 클램프 보어, depth = 보어 깊이, body_d = 보스 외경
module shaft_clamp_cut(bore_d, depth, body_d) {
    union() {
        cylinder(d = bore_d + clearance_fit / 2, h = depth);
        // 슬릿
        translate([-1, 0, -0.1]) cube([2, body_d / 2 + 1, depth + 0.1]);
        // M3 핀치 볼트 (슬릿 직교) — 보어 반경과 보스 반경 사이
        translate([0, (bore_d / 2 + body_d / 2) / 2 + 1, depth / 2])
            rotate([0, 90, 0])
                translate([0, 0, -body_d / 2 - 1])
                    bolt_hole(3, body_d + 2);
    }
}
