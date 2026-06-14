// 공통 모듈(common modules) — 베어링 시트(bearing seat), 볼트 홀(bolt hole) 등 재사용 형상을 모읍니다.
//
// 용어
// 1. 공통 모듈(Common module)
// 2. 클리어런스 홀(Clearance hole)
// 3. 축 클램프 허브(Shaft clamp hub)
// 4. 보어(Bore)
// 5. 핀치 슬롯(Pinch slot)
// 6. 베어링 포켓(Bearing pocket)
// 7. 압입(Press fit)
// 8. 내륜(Inner race)
// 9. 외륜(Outer race)
// 10. 필렛(Fillet)
// 11. 스탠드오프(Standoff)

// 관통 볼트 홀(through bolt hole)은 체결 여유(clearance)를 반영합니다.
module bolt_hole(d, h, oversize = 0.4) {
    assert(d > 0, "bolt_hole(): d는 양수여야 합니다");
    assert(h > 0, "bolt_hole(): h는 양수여야 합니다");
    assert(oversize >= 0, "bolt_hole(): oversize는 0 이상이어야 합니다");

    cylinder(d = d + oversize, h = h);
}

// 출력축 핀치 클램프 허브(output shaft pinch clamp hub, printed)는 Ø shaft_d 축(shaft)을 보어(bore), 핀치 슬롯(pinch slot), 가로 볼트(cross screw)로 마찰 그립(friction grip)합니다.
//   직결 관절(direct-drive joint)에서 가동 링크(moving link)가 감속기 출력축(reducer output shaft, Ø10)을 잡는 표준 인터페이스(interface)입니다.
//   원점(origin)은 허브(hub) 바닥 중심이고, 보어(bore)는 +Z 방향입니다. h=높이(height), hub_d=외경(outer diameter), screw_d=핀치 볼트(pinch screw, M3)입니다.
module shaft_clamp_hub(shaft_d, hub_d, h, screw_d = 3, bore_clear = 0.2, slot_w = 1.4) {
    assert(shaft_d > 0, "shaft_clamp_hub(): shaft_d는 양수여야 합니다");
    assert(hub_d > shaft_d + bore_clear, "shaft_clamp_hub(): hub_d는 보어보다 커야 합니다");
    assert(h > 0, "shaft_clamp_hub(): h는 양수여야 합니다");
    assert(screw_d > 0, "shaft_clamp_hub(): screw_d는 양수여야 합니다");
    assert(bore_clear >= 0, "shaft_clamp_hub(): bore_clear는 0 이상이어야 합니다");
    assert(slot_w > 0, "shaft_clamp_hub(): slot_w는 양수여야 합니다");

    cut_overlap = 0.1;
    screw_offset_x_ratio = 0.30;
    nut_pocket_flat_d_ratio = 2.0;
    nut_pocket_depth = 2.6;
    nut_pocket_wall_margin = 2.4;

    difference() {
        cylinder(d = hub_d, h = h);
        // 축 보어(shaft bore)는 출력축(output shaft) 삽입 여유를 제공합니다.
        translate([0, 0, -cut_overlap])
            cylinder(d = shaft_d + bore_clear, h = h + 2 * cut_overlap);
        // 핀치 슬롯(pinch slot)은 보어(bore)에서 +X 외벽(outer wall)까지 열려 클램프 변형을 만듭니다.
        translate([0, -slot_w / 2, -cut_overlap])
            cube([hub_d / 2 + cut_overlap, slot_w, h + 2 * cut_overlap]);
        // 핀치 볼트(pinch screw)는 슬롯(slot)을 Y축(axis) 방향으로 가로질러 조입니다.
        translate([hub_d * screw_offset_x_ratio, -hub_d, h / 2]) rotate([-90, 0, 0])
            bolt_hole(d = screw_d, h = 2 * hub_d);
        // 너트 자리(nut pocket)는 반대쪽(far side)에서 핀치 볼트(pinch screw)를 받습니다.
        translate([hub_d * screw_offset_x_ratio, hub_d / 2 - nut_pocket_wall_margin, h / 2])
            rotate([-90, 0, 0])
                cylinder(d = screw_d * nut_pocket_flat_d_ratio, h = nut_pocket_depth, $fn = 6);
    }
}

// 베어링 포켓 컷(bearing pocket cut, 3D 차집합)은 압입 개방면(press-fit open face, z0)에 외경 시트(OD seat)를 만들고 반대면에 내륜 도피 턱(inner-race relief shoulder)을 둡니다.
//   bearing_spec = [내경(ID), 외경(OD), 폭(W)], thickness = 호스트 두께(host thickness), z0 = 압입 개방면(press-fit open face)입니다.
//   시트(seat)는 외경(OD)+압입(press fit, 음수) 깊이 W로 외륜(outer race)을 압입합니다.
//   도피 보어(relief bore)는 (ID+OD)/2로 두어 내륜 외경(inner-race OD)보다 크고 외륜 외경(outer-race OD)보다 작게 유지합니다.
//   z=W 단차(shoulder)는 외륜(outer race) 이탈(walk-out)을 막고, 회전 내륜(rotating inner race)은 도피 보어(relief bore) 안에서 비접촉 상태를 유지합니다.
module bearing_pocket_cut(bearing_spec, thickness, press_fit = -0.15) {
    assert(len(bearing_spec) == 3, "bearing_pocket_cut(): bearing_spec은 [ID, OD, W] 형식이어야 합니다");
    assert(bearing_spec[0] > 0 && bearing_spec[1] > 0 && bearing_spec[2] > 0, "bearing_pocket_cut(): 베어링 치수는 양수여야 합니다");
    assert(bearing_spec[1] > bearing_spec[0], "bearing_pocket_cut(): OD는 ID보다 커야 합니다");
    assert(thickness >= bearing_spec[2], "bearing_pocket_cut(): thickness는 베어링 폭 이상이어야 합니다");
    assert(bearing_spec[1] + press_fit > 0, "bearing_pocket_cut(): 압입 후 시트 지름은 양수여야 합니다");

    cut_overlap = 0.1;

    translate([0, 0, -cut_overlap])                           // 시트(seat)는 외륜(outer race) 압입(press fit)을 담당합니다.
        cylinder(d = bearing_spec[1] + press_fit, h = bearing_spec[2] + cut_overlap);
    translate([0, 0, bearing_spec[2]])                                 // 내륜 도피(inner-race relief)와 외륜 턱(outer-race shoulder)입니다.
        cylinder(d = (bearing_spec[0] + bearing_spec[1]) / 2,
                 h = thickness - bearing_spec[2] + 2 * cut_overlap);
}

// NEMA 17 모터 마운트 홀 패턴(motor mount hole pattern)은 CON-004 SF24 42각 NEMA 17 호환 치수입니다.
// h = 판 두께(plate thickness)입니다.
module nema17_mount(h, pilot_d = 22, clearance = 0.3, hole_pitch = 31, bolt_d = 3) {
    assert(h > 0, "nema17_mount(): h는 양수여야 합니다");
    assert(pilot_d > 0, "nema17_mount(): pilot_d는 양수여야 합니다");
    assert(clearance >= 0, "nema17_mount(): clearance는 0 이상이어야 합니다");
    assert(hole_pitch > 0, "nema17_mount(): hole_pitch는 양수여야 합니다");
    assert(bolt_d > 0, "nema17_mount(): bolt_d는 양수여야 합니다");

    union() {
        cylinder(d = pilot_d + clearance, h = h);
        for (x = [-1, 1], y = [-1, 1])
            translate([x * hole_pitch / 2, y * hole_pitch / 2, 0])
                bolt_hole(d = bolt_d, h = h);
    }
}

// 케이블 가이드 클립(cable guide clip, ELE-005)은 외면 부착형 C-클립(C-clip)이며 cable_d는 케이블 다발 직경(cable bundle diameter)입니다.
module cable_clip(cable_d = 8, t = 4) {
    assert(cable_d > 0, "cable_clip(): cable_d는 양수여야 합니다");
    assert(t > 0, "cable_clip(): t는 양수여야 합니다");

    wall_thickness = 2.5;
    opening_width_ratio = 0.7;
    cut_overlap = 0.1;

    difference() {
        cylinder(d = cable_d + 2 * wall_thickness, h = t);
        translate([0, 0, -cut_overlap])
            cylinder(d = cable_d, h = t + 2 * cut_overlap);
        // 삽입 개구(insertion opening)는 케이블 직경(cable diameter)의 70% 폭으로 두어 탈착성과 보유력을 균형시킵니다.
        translate([0, -cable_d * opening_width_ratio / 2, -cut_overlap])
            cube([cable_d, cable_d * opening_width_ratio, t + 2 * cut_overlap]);
    }
}

// 꺾임 무릎 변위(knee offset, palletizer offset)는 굴절각 성분(bend-angle component)과 보조 오프셋 성분(auxiliary-offset component)의 합입니다.
//   각도 성분(angle component) ≈ pos·(1-pos)·L·tan(bend)이며 link_kink_angle 기여분입니다.
//   koff는 중심선(centerline)에 직접 더해지는 보조 오프셋(auxiliary offset)이며 link_kink_offset에 해당합니다.
//   bend=0 및 koff=0이면 변위(offset) 0인 직선 빔(straight beam)으로 남아 후방 호환(backward compatible)됩니다.
function knee_h(length, bend_position, bend_angle, kink_offset = 0) =
    assert(length > 0, "knee_h(): length는 양수여야 합니다")
    assert(bend_position >= 0 && bend_position <= 1, "knee_h(): bend_position은 0 이상 1 이하여야 합니다")
    bend_position * (1 - bend_position) * length * tan(bend_angle) + kink_offset;

// 중심선(centerline) y는 꺾임 폴리라인(bent polyline) A(0,0)-무릎(knee, pos·L, knee_h)-B(L,0)을 따릅니다.
//   kink 0이면 전 구간이 0인 직선(straight line)으로 남아 후방 호환(backward compatible)됩니다.
function beam_centerline_y(length, bend_position, bend_angle, kink_offset, x) =
    assert(length > 0, "beam_centerline_y(): length는 양수여야 합니다")
    assert(bend_position > 0 && bend_position < 1, "beam_centerline_y(): bend_position은 0보다 크고 1보다 작아야 합니다")
    let (knee_x = bend_position * length,
         knee_y = knee_h(length = length,
                         bend_position = bend_position,
                         bend_angle = bend_angle,
                         kink_offset = kink_offset))
    x <= knee_x ? knee_y * x / knee_x : knee_y * (length - x) / (length - knee_x);

// 스탠드오프 위치(standoff position, 2D y = 부품 z)는 현(chord) 기준 고정 오프셋(fixed offset)을 중심선 굴절(centerline bend)에 실어 등두께 밴드(constant-thickness band) 내부에 유지합니다.
//   벨트(belt)가 굴절(bend)을 따라 올라가며, kink 0이면 기존 위치(original position)를 유지합니다.
function arm_standoff_pos(length, bend_position, bend_angle, kink_offset, x, base = 0) =
    base + beam_centerline_y(length = length,
                             bend_position = bend_position,
                             bend_angle = bend_angle,
                             kink_offset = kink_offset,
                             x = x);

// 오목 경계 필렛(concave-boundary fillet, 2D)은 모폴로지 클로징(morphological closing) offset(r=-f) ∘ offset(r=+f)를 사용합니다.
//   볼록 외곽(convex outline)은 보존하고 내측 허브-몸체(hub-body), 굴절(bend), 러그 접합(lug joint)의 오목 모서리(concave corner)만 반경(radius) f로 라운드(round)합니다.
//   f=0이면 무변화(no-op)입니다. 유니언(union) 합성부에서 생기는 날카로운 안쪽 코너(inner corner)를 제거하는 공통 처리입니다.
module fillet_concave2d(f = 6) {
    assert(f >= 0, "fillet_concave2d(): f는 0 이상이어야 합니다");

    offset(r = -f) offset(r = f) children();
}

// 노드 접근자(node accessor)입니다. node = [x, y, r]는 중심선 정점(centerline vertex)과 해당 점의 반폭/반경(half-width/radius)을 담습니다.
function node_xy(node) = [node[0], node[1]];
function node_r(node)  = node[2];

// 다절점 굴절 밴드(multi-node bent band, 2D)는 nodes: [x, y, r] 정점 리스트(vertex list)를 받으며 첫·끝은 허브 중심(hub center)입니다.
//   인접 정점쌍(adjacent vertex pair)을 스타디움 헐(stadium hull)로 이어 띠(band)를 만들고 각 점의 반경(radius) r로 폭(width)을 결정합니다.
//   양끝 허브 반경(hub radius)은 몸체 반폭(body half-width)보다 크게 두어 베어링(bearing)과 축(shaft)을 수용합니다.
//   fillet_concave2d(fillet_r)는 허브-몸체(hub-body)와 굴절(bend) 내측의 오목 경계(concave boundary)에만 반경 필렛(radius fillet)을 적용합니다.
//   정점(vertex)이 일직선이면 직선 밴드(straight band)로 남아 후방 호환(backward compatible)됩니다.
module bent_band2d(nodes, fillet_r = 0) {
    node_count = len(nodes);

    assert(node_count >= 2, "bent_band2d(): nodes는 2개 이상이어야 합니다");
    assert(fillet_r >= 0, "bent_band2d(): fillet_r는 0 이상이어야 합니다");

    fillet_concave2d(f = fillet_r)
    union() {
        for (i = [0 : node_count - 2])
            hull() {
                translate(node_xy(nodes[i]))
                    circle(r = node_r(nodes[i]));

                translate(node_xy(nodes[i + 1]))
                    circle(r = node_r(nodes[i + 1]));
            }
    }
}

