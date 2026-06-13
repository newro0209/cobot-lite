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
// d = 숄더 직경 (shoulder_d_large)
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

// 선택 색상 래퍼. parts 레이어는 상수를 모르고 전달받은 col만 적용한다.
module apply_part_color(col = undef) {
    if (is_undef(col)) children();
    else color(col) children();
}

// 지시선(leader) + 빌보드(billboard) 라벨 — 프리뷰용, $vpr 카메라 추종
// p = 앵커(부품 측), v = 지시선 벡터 (라벨은 p+v 위치)
// 주의: 상위 프레임이 회전된 경우 빌보드가 카메라를 향하지 않음 — 월드 프레임에서 호출할 것
module leader_label(p, v, txt, size = 3.2, col = "white", line_d = 1.4) {
    color(col) {
        hull() {
            translate(p) sphere(d = line_d, $fn = 12);
            translate(p + v) sphere(d = line_d, $fn = 12);
        }
        translate(p + v) rotate($vpr) translate([2, -size / 2, 0])
            linear_extrude(0.6) text(txt, size = size);
    }
}

// 꺾임 무릎 높이 (팔레타이저 오프셋) — pos·(1-pos)·L·tan(bend) 근사 정의
function knee_h(L, pos, bend) = pos * (1 - pos) * L * tan(bend);

// 꺾임 빔 측판 외형 2D — 러그 3원 hull (무릎 = 현 위쪽 +y).
// 창 없는 충전 단면: 볼록 껍질이라 현 아래 모서리는 직선 (스탠드오프 벨트)
module bent_beam2d(L, pos, bend, r) {
    hull() {
        circle(r = r);
        translate([pos * L, knee_h(L, pos, bend)]) circle(r = r);
        translate([L, 0]) circle(r = r);
    }
}

// 환형 섹터 2D (아크 슬롯 차집합용) — a0 → a1 (deg, 반시계)
module annulus_sector2d(r_in, r_out, a0, a1) {
    n = max(8, ceil(64 * (a1 - a0) / 360));
    polygon(concat(
        [for (i = [0 : n]) let (a = a0 + (a1 - a0) * i / n)
            r_out * [cos(a), sin(a)]],
        [for (i = [n : -1 : 0]) let (a = a0 + (a1 - a0) * i / n)
            r_in * [cos(a), sin(a)]]));
}

// 플랜지 커플러 장착 컷 (구동 부품 z0 자유면, 차집합용) — 분할 클램프 대체.
// 평 플랜지(스피곳 없음) → 중앙 축-팁 도피(관통) + 플랜지 셀프태핑 볼트 ×n(블라인드)
module coupler_mount_cut(plate_t) {
    translate([0, 0, -0.1])
        cylinder(d = cpl_bore + clearance_fit + 0.6, h = plate_t + 0.2); // 축 팁
    bdepth = min(plate_t - 1, 6);
    for (i = [0 : cpl_bolt_n - 1])
        rotate([0, 0, 45 + i * 360 / cpl_bolt_n])
            translate([cpl_bolt_r, 0, -0.05])
                cylinder(d = cpl_bolt_d - 0.4, h = bdepth + 0.05);  // M3 셀프태핑
}

// 축 클램프 슬릿 + M3 핀치 볼트 (차집합용) — [유산: 분할 클램프 방식, 현재 미사용]
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
