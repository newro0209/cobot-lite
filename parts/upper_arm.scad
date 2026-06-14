// 상완(upper arm) — 꺾임 빔(bent beam)과 J3 크랭크 저널(crank journal)입니다.
// =====================================================================
//
// 용어
// 1. 상완(Upper arm)
// 2. 꺾임 빔(Bent beam)
// 3. 크랭크 저널(Crank journal)
// 4. 측판(Side plate)
// 5. 프로파일(Profile)
// 6. 러그(Lug)
// 7. 현(Chord)
// 8. 압입(Press fit)
// 9. 내륜(Inner race)
// 10. 외륜(Outer race)
// 11. 리미트 베인(Limit vane)
//
// 측판(side plate) 1형상 ×2입니다. 전 홀(through hole)이 관통되어 평행이동 장착(translation mounting)만 필요하고 플립(flip)은 필요 없습니다.
// 프로파일(profile)은 러그(lug) 3원 헐(hull)이며 무릎(knee) +z 볼록 형상입니다. 현(chord)은 x축 0~L1입니다.
// 홀 세트(hole set)는 양 측판(side plate)에 동일하게 적용합니다.
//   J2 (0): 6805ZZ 압입(press fit) ID 37, +Y에는 크랭크 보스(crank boss) OD 25 저널(journal)이 놓입니다.
//   팔꿈치(elbow, L1): 608ZZ 압입(press fit) ID 22, 통축 볼트(through bolt)가 내륜(inner race)을 압입해 하완(forearm)과 회전하고 외륜(outer race)은 고정됩니다.
//   스탠드오프(standoff) M4 ×2: 현(chord) 아래 벨트(belt) 경로를 유지합니다.
//   J3 리미트 스위치(limit switch) M2 ×2: +Y 측판(side plate) 내면에서 롤러(roller)가 접힘 평면(fold plane)의 하완 베인(forearm vane)을 감지합니다.
//   J2 리미트 베인(limit vane): J2 허브(hub) 근처 일체 탭(tab)이며 고정 프레임(fixed frame) 스위치가 감지합니다. 스위치는 범위 외 베이스(base)에 둡니다.
use <../lib/utils.scad>
use <../lib/vitamins/bearing_608zz.scad>
use <../lib/vitamins/bearing_6805zz.scad>

// ── 공개 스펙(public specification): 조립체(assembly)와 하드웨어 배치(hardware placement)가 참조합니다. ──
function upper_arm_length()     = 210;          // 현(chord) 길이 L1입니다.
function upper_arm_plate_t()    = 9;            // 측판 두께(side-plate thickness)입니다.
function upper_arm_bend()       = [8, 0.55, 0]; // [굴절각(bend angle), 위치비(position ratio), 보조 오프셋(auxiliary offset)]입니다.
function upper_arm_standoff_x() = [0.30, 0.70]; // 스탠드오프(standoff) x는 length 비율(length ratio)입니다.

// 2D 관통 피처(through feature)만 정의합니다. 베어링 포켓(bearing pocket)은 3D 차집합(cut)인 bearing_pocket_cut에서 처리합니다.
module ua_plate2d() {
    length = upper_arm_length();
    bearing_608 = bearing_608zz_spec();
    bearing_6805 = bearing_6805zz_spec();
    bend_angle = upper_arm_bend()[0];
    bend_pos = upper_arm_bend()[1];
    kink_offset = upper_arm_bend()[2];
    fillet = 16;
    body_hw = 16;
    standoff_d = 4.5;
    standoff_x = [for (f = upper_arm_standoff_x()) f * length];
    vane_angle = 250;
    vane_r = 44;
    vane_w = 8;
    hole_pitch = 9.5;
    hole_d = 2.6;
    roller_local = [13.89, 6.96, 4.8];
    elbow_vane_angle = 320;
    switch_roller = [length + 40 * cos(elbow_vane_angle - 130),
                     30 - roller_local[2],
                     40 * sin(elbow_vane_angle - 130)];
    switch_hole_x = switch_roller[0] - roller_local[0];
    switch_hole_z = switch_roller[2] - roller_local[1];

    difference() {
        fillet_concave2d()
        union() {
            bent_band2d(nodes = [[0, 0, bearing_6805[1] / 2 + body_hw],
                                 [bend_pos * length,
                                  knee_h(length = length,
                                         bend_position = bend_pos,
                                         bend_angle = bend_angle,
                                         kink_offset = kink_offset),
                                  body_hw],
                                 [length, 0, body_hw]],
                        fillet_r = fillet);

            // 팔꿈치 허브(elbow hub)는 608ZZ 포켓(pocket) 주변의 외곽 강성을 확보합니다.
            translate([length, 0]) circle(r = (bearing_608[1] / 2) + body_hw);

            // J2 리미트 베인 탭(limit-vane tab)은 상완(upper arm) 일체형이며 J2 축(axis)에서 방사(radial) 방향으로 뻗어 고정 프레임(fixed frame) 스위치가 감지합니다.
            rotate(vane_angle) translate([0, -vane_w / 2])
                square([vane_r, vane_w]);
        }

        // 스탠드오프(standoff) M4 ×2는 현(chord) 아래 벨트(belt)를 따라가며 굴절(bend)에 맞춰 상승해 밴드(band) 내부에 남습니다.
        for (x = standoff_x)
            translate([x, arm_standoff_pos(length = length,
                                           bend_position = bend_pos,
                                           bend_angle = bend_angle,
                                           kink_offset = kink_offset,
                                           x = x)])
                circle(d = standoff_d);
        // J3 리미트 스위치(limit switch) M2 ×2는 몸체 중심(body center)을 기준으로 x 피치(x pitch)를 맞춥니다.
        for (s = [-1, 1])
            translate([switch_hole_x + s * hole_pitch / 2, switch_hole_z])
                circle(d = hole_d);
    }
}

// 출력(output)과 자재 명세서(BOM)용 단일 측판(side plate)입니다. 조립 배치(assembly placement)와 색(color)은 호출부가 담당합니다.
module upper_arm_plate(col = [0, 0.35, 1]) {
    $fn = 64;
    bearing_608 = bearing_608zz_spec();
    bearing_6805 = bearing_6805zz_spec();
    length = upper_arm_length();
    plate_t = upper_arm_plate_t();
    plate_center = [length / 2, -6.705, plate_t / 2];
    translate(-plate_center)
        color(col) difference() {
            linear_extrude(plate_t) ua_plate2d();
            // J2 6805ZZ 포켓(pocket)은 외륜(outer race)을 고정하고 내륜(inner race)은 크랭크 보스 저널(crank boss journal)에 압입(press fit)됩니다.
            translate([0, 0, 0]) bearing_pocket_cut(bearing_spec = bearing_6805, thickness = plate_t);
            // 팔꿈치 608ZZ 포켓(elbow pocket)은 외륜(outer race)을 고정하고 내륜(inner race)은 통축 볼트(through bolt)에 압입(press fit)됩니다.
            translate([length, 0, 0]) bearing_pocket_cut(bearing_spec = bearing_608, thickness = plate_t);
        }
}

upper_arm_plate();
