// 공통 모듈 (common modules) — 베어링 시트, 볼트 홀 등
include <../config/parameters.scad>

// 관통 볼트 홀 (clearance hole)
module bolt_hole(d, h) {
    cylinder(d = d + bolt_hole_oversize, h = h);
}

// 베어링 포켓 컷 (3D 차집합) — 압입 개방면(z0)서 OD 시트, 반대면에 내륜 도피 턱.
//   brg = [ID, OD, W], t = 호스트 두께 (> W 여야 턱 생김). 좌표: z0 = 압입 개방면.
//   시트 = OD+압입(음수) 깊이 W → 외륜 압입. 도피 = (ID+OD)/2 (내륜 OD < 도피 < 외륜 OD)
//   → z=W 단차가 외륜 walk-out 정지 턱, 회전 내륜은 도피 보어 안에서 비접촉.
module bearing_pocket_cut(brg, t) {
    translate([0, 0, -0.1])                                   // 시트 (외륜 압입)
        cylinder(d = brg[1] + bearing_press_fit, h = brg[2] + 0.1);
    translate([0, 0, brg[2]])                                 // 내륜 도피 + 외륜 턱
        cylinder(d = (brg[0] + brg[1]) / 2, h = t - brg[2] + 0.2);
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

// 꺾임 무릎 변위 (팔레타이저 오프셋) = 굴절각 성분 + 보조 오프셋 성분.
//   각도 성분 ≈ pos·(1-pos)·L·tan(bend) (= link_kink_angle 기여),
//   koff = 중심선에 직접 더해지는 보조 오프셋 (= link_kink_offset).
//   bend=0 & koff=0 → 변위 0 = 직선 빔 (후방 호환).
function knee_h(L, pos, bend, koff = 0) = pos * (1 - pos) * L * tan(bend) + koff;

// 중심선 y — 꺾임 폴리라인 A(0,0)-무릎(pos·L, knee_h)-B(L,0) (보조 굴절 추종용).
//   kink 0 → 전 구간 0 (직선, 후방 호환)
function beam_cl_y(L, pos, bend, koff, x) =
    let (kx = pos * L, ky = knee_h(L, pos, bend, koff))
    x <= kx ? ky * x / kx : ky * (L - x) / (L - kx);

// 스탠드오프 위치(2D y = 부품 z): 현 기준 고정 오프셋을 중심선 굴절에 실어
//   등두께 밴드 내부에 유지 (벨트가 굴절 따라 올라감). kink 0 → 기존 위치.
function ua_standoff_pos(x) =
    arm_standoff_z + beam_cl_y(L1, ua_bend_pos, ua_bend_deg, ua_kink_off, x);
function fa_standoff_pos(x) =
    beam_cl_y(forearm_len, fa_bend_pos, fa_bend_deg, fa_kink_off, x);

// 오목 경계 필렛 (2D) — 모폴로지 클로징 offset(r=-f) ∘ offset(r=+f).
//   볼록 외곽은 보존하고 내측(허브↔몸체·굴절·러그 접합) 오목 모서리만 반경 f 라운드.
//   f=0 → 무변화. union 합성부에서 생기는 날카로운 안쪽 코너 제거에 공통 사용.
module fillet_concave2d(f = fillet_r) {
    offset(r = -f) offset(r = f) children();
}

// 다절점 등두께 굴절 밴드 2D — pts: 중심선 정점 리스트(첫·끝 = 허브 중심).
//   인접 정점쌍을 스타디움 hull로 이어 반폭 bw 등두께 띠 → 모든 굴절점에서
//   상·하단 외곽선이 동시에 같은 방향으로 꺾여 두께 일정.
//   양끝 허브 원 r(>bw) — 베어링·축 수용 위해 몸체보다 두꺼움.
//   fillet_concave2d(f): 허브↔몸체·굴절 내측 오목 경계만 반경 f 필렛.
//   정점이 일직선이면 직선 밴드 (후방 호환).
module bent_band2d(pts, r, bw = ua_body_hw) {
    n = len(pts);
    fillet_concave2d()
    union() {
        for (i = [0 : n - 2])
            hull() {
                translate(pts[i])     circle(r = bw);
                translate(pts[i + 1]) circle(r = bw);
            }
        translate(pts[0])     circle(r = r);
        translate(pts[n - 1]) circle(r = r);
    }
}

