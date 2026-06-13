// 상완 (upper arm) — 꺾임 빔 + J3 크랭크 저널
// =====================================================================
// 측판 1형상 ×2 — 전 홀 관통 → 평행이동 장착 (플립 불요, 꺾임과 양립).
// 프로파일: 러그 3원 hull (무릎 +z 볼록) — 현(chord) = x축 0~L1.
// 홀 세트 (양 측판 동일):
//   J2 (0):    6805ZZ 압입 ID 37 — +Y: 크랭크 보스 OD 25 저널
//   팔꿈치(L1): 608ZZ 압입 ID 22 (통축 볼트 내륜 press → 하완과 회전, 외륜 고정)
//   스탠드오프 M4 ×2: 현 아래 벨트
//   J3 리미트 스위치 M2 ×2: +Y 측판 내면 (롤러가 fold 평면서 forearm 베인 감지)
//   J2 리미트 베인: J2 허브 근처 일체 탭 (고정프레임 스위치 감지 — 스위치는 범위 외 베이스)
use <../lib/utils.scad>
use <../lib/vitamins/bearing_608zz.scad>
use <../lib/vitamins/bearing_6805zz.scad>

// ── 공개 스펙 (assembly·하드웨어 배치가 참조) ──
function upper_arm_length()     = 210;          // 현(chord) 길이 L1
function upper_arm_plate_t()    = 9;            // 측판 두께
function upper_arm_bend()       = [8, 0.55, 0]; // [굴절각, 위치비, 보조 오프셋]
function upper_arm_standoff_x() = [0.30, 0.70]; // 스탠드오프 x (length 비율)

// 2D 관통 피처만 (베어링 포켓은 3D — bearing_pocket_cut)
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
            bent_band2d([[0, 0, bearing_6805[1] / 2 + body_hw],
                         [bend_pos * length, knee_h(length, bend_pos, bend_angle, kink_offset), body_hw],
                         [length, 0, body_hw]], fillet);

            //
            translate([length, 0]) circle(r = (bearing_608[1] / 2) + body_hw);

            // J2 리미트 베인 탭 (상완 일체 — J2축서 방사, 고정프레임 스위치 감지)
            rotate(vane_angle) translate([0, -vane_w / 2])
                square([vane_r, vane_w]);
        }

        // 스탠드오프 M4 ×2 (현 아래 벨트, 굴절 따라 상승 — 밴드 내부 유지)
        for (x = standoff_x)
            translate([x, arm_standoff_pos(length, bend_pos, bend_angle, kink_offset, x)])
                circle(d = standoff_d);
        // J3 리미트 스위치 M2 ×2 (몸체 중심 = (j3_ls_hole_x, j3_ls_hole_z), x 피치)
        for (s = [-1, 1])
            translate([switch_hole_x + s * hole_pitch / 2, switch_hole_z])
                circle(d = hole_d);
    }
}

// 출력/BOM 모듈 — 단일 측판. 조립 배치·색은 호출부(assembly)가 담당한다.
module upper_arm_plate(col = undef) {
    $fn = 64;
    bearing_608 = bearing_608zz_spec();
    bearing_6805 = bearing_6805zz_spec();
    length = upper_arm_length();
    plate_t = upper_arm_plate_t();
    plate_center = [length / 2, -6.705, plate_t / 2];
    translate(-plate_center)
        apply_part_color(col) difference() {
            linear_extrude(plate_t) ua_plate2d();
            // J2 6805ZZ 포켓 (외륜 고정, 내륜 = 크랭크 보스 저널 press)
            translate([0, 0, 0]) bearing_pocket_cut(bearing_6805, plate_t);
            // 팔꿈치 608ZZ 포켓 (외륜 고정, 내륜 = 통축 볼트 press)
            translate([length, 0, 0]) bearing_pocket_cut(bearing_608, plate_t);
        }
}

upper_arm_plate();
