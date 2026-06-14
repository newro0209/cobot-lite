// 전체 조립 모델(full assembly) — 간섭(interference) 확인과 시각화(visualization)에 사용합니다.
//
// 용어
// 1. 전체 조립체(Full assembly)
// 2. 간섭(Interference)
// 3. 좌표계(Coordinate system)
// 4. 현(Chord)
// 5. 피치(Pitch)
// 6. 접힘각(Fold angle)
// 7. 특이점(Singularity)
// 8. 링키지(Linkage)
// 9. 장착 클리어런스(Mounting clearance)
//
// 하부 회전·지지 구조를 제외한 2축 팔 체인.
// 좌표계(coordinate system): 원점(origin) = J2 축(axis). x = 상완 현(chord), y = 측판 스팬(side-plate span), z = 피치 평면(pitch plane) 수직.
// 각도 규약(angle convention): j2/j3 = 상완(upper arm)/하완(forearm) 현(chord)의 월드 피치(world pitch), 수평 = 0도.
//   접힘각(fold angle) = j3 - j2 ∈ [-132, -15] — 0도(현 일직선)가 특이점(singularity)입니다.
//
// 명령줄 인터페이스(CLI) 간섭 검사:
//   check=2: 하완 그룹(forearm group) ∩ 상완 그룹(upper-arm group), 팔꿈치 접힘(elbow fold)
//   check=3: 링키지(linkage, crank+link) ∩ 팔 구조(arm structure)
//   check=4: 리미트 스위치(limit switch) 몸체 ∩ 가동 구조(moving structure), 장착 클리어런스(mounting clearance)
//   "Current top level object is empty" 또는 빈 STL(STL) 출력이면 통과입니다.
use <../lib/utils.scad>
use <../lib/vitamins/bearing_608zz.scad>
use <../lib/vitamins/bearing_625zz.scad>
use <../lib/vitamins/flange_coupler_8mm.scad>
use <../lib/vitamins/hex_standoff_m4_l60.scad>
use <../lib/vitamins/hex_standoff_m3_l30.scad>
use <../lib/vitamins/kw12_limit_switch.scad>
use <../lib/vitamins/lock_nut_m4.scad>
use <../lib/vitamins/lock_nut_m6.scad>
use <../lib/vitamins/shcs_m3_l10.scad>
use <../lib/vitamins/shcs_m4_l10.scad>
use <../lib/vitamins/shoulder_bolt_m5_l12.scad>
use <../lib/vitamins/shoulder_bolt_m5_l50.scad>
use <../lib/vitamins/shoulder_bolt_m8_l80.scad>
use <../lib/vitamins/spacer_od12_id8_4_l6.scad>
use <../lib/vitamins/washer_m5.scad>
use <../lib/vitamins/washer_m8.scad>
use <../parts/upper_arm.scad>
use <../parts/forearm.scad>
use <../parts/j3_crank.scad>
use <../parts/drive_link.scad>

$fa = 6;
$fs = 0.8;

/* ===== 좌표 헬퍼(coordinate helper): 링크 앵커(link anchor) 등 좌표 변환(coordinate transform) ===== */
function pitch_vector(point, pitch_angle) =
    [point[0] * cos(pitch_angle) - point[2] * sin(pitch_angle), point[1],
     point[0] * sin(pitch_angle) + point[2] * cos(pitch_angle)];

/* ===== 리미트 스위치(limit switch) 배치: 롤러(roller)를 목표 위치에 두고 몸체를 +Y 측판(side plate)에 눕힙니다. ===== */
// J3: 상완(upper arm) 팔꿈치축(elbow axis) 프레임(frame)입니다. 롤러(roller)가 접힘 평면(fold plane)에서 하완 베인(forearm vane)을 검출합니다.
module j3_switch() {
    length = upper_arm_length();
    vane_angle = 320;
    aim = 0;
    roller_local = [13.89, 6.96, 4.8];
    roller = [length + 40 * cos(vane_angle - 130),
              30 - roller_local[2],
              40 * sin(vane_angle - 130)];
    switch_origin = [3.234, 0.272, 3.25];

    translate(roller) rotate([0, -aim, 0]) rotate([-90, 0, 0])
        translate(-roller_local + switch_origin) kw12_limit_switch();
}
// J2: 고정 프레임(fixed frame, world)입니다. 몸체(body)와 브래킷(bracket)은 범위 외 베이스(base)에 장착하므로 여기서는 인터페이스(interface)만 둡니다.
module j2_switch() {
    vane_angle = 250;
    aim = 0;
    roller_local = [13.89, 6.96, 4.8];
    roller = [36 * cos(vane_angle - 5), 34, 36 * sin(vane_angle - 5)];
    switch_origin = [3.234, 0.272, 3.25];

    translate(roller) rotate([0, -aim, 0]) rotate([90, 0, 0])
        translate(-roller_local + switch_origin) kw12_limit_switch();
}

/* ===== 상완 그룹(upper-arm group): 원점(origin) = J2 축(axis), x = 상완 현(chord) ===== */
module upper_arm_group(explode_distance = 0, hardware = false) {
    length = upper_arm_length();
    plate_t = upper_arm_plate_t();
    bearing_608 = bearing_608zz_spec();
    outer_y = 30 + plate_t;
    inner_y = outer_y - plate_t;
    bend_angle = upper_arm_bend()[0];
    bend_pos = upper_arm_bend()[1];
    kink_offset = upper_arm_bend()[2];
    standoff_x = [for (f = upper_arm_standoff_x()) f * length];
    standoff_span = hex_standoff_m4_l60_len();
    plate_origin = [length / 2, outer_y - plate_t / 2, -6.705];
    standoff_origin = [0, 0, standoff_span / 2];
    bearing_origin = [0, 0, bearing_608[2] / 2];
    cap_screw_origin = [0, 0, (shcs_m4_l10_len() - shcs_m4_l10_dia()) / 2];

    translate(plate_origin) rotate([90, 0, 0])
        upper_arm_plate(col = [0, 0, 1]);
    mirror([0, 1, 0]) translate(plate_origin) rotate([90, 0, 0])
        upper_arm_plate(col = [0, 0, 1] * 0.75);

    // 상완 스탠드오프(standoff) M4 L60 ×2는 구조재(structural member)이므로 상시 표시합니다.
    for (x = standoff_x)
        translate([x, inner_y, arm_standoff_pos(length, bend_pos, bend_angle, kink_offset, x)])
            rotate([90, 0, 0])
                translate([0, 0, -0.7] + standoff_origin)
                    hex_standoff_m4_l60();

    if (hardware) {
        // 팔꿈치 베어링(elbow bearing) 608ZZ ×2는 양 측판(side plate) 외측 포켓 시트(pocket seat)에 대칭 배치합니다.
        translate([length, outer_y - bearing_608[2] + 0.7 * explode_distance, 0]) rotate([-90, 0, 0])
            translate(bearing_origin) bearing_608zz();
        translate([length, -outer_y + 0.7 * -explode_distance, 0]) rotate([-90, 0, 0])
            translate(bearing_origin) bearing_608zz();

        // 상완 스탠드오프(standoff) M4 L10 양측 체결부입니다.
        for (x = standoff_x)
            for (side_y = [-1, 1])
                translate([x, side_y * (outer_y + 0.3), arm_standoff_pos(length, bend_pos, bend_angle, kink_offset, x)])
                    rotate([side_y * 90, 0, 0])
                        translate([0, 0, -explode_distance * 0.4] + cap_screw_origin) shcs_m4_l10();

        // J3 리미트 스위치(limit switch)는 상완 +Y 측판(side plate)에 놓고 롤러(roller)가 접힘 평면(fold plane)에서 하완 베인(forearm vane)을 검출합니다.
        j3_switch();
    }
}

/* ===== 하완 그룹(forearm group): 원점(origin) = 팔꿈치 축(elbow axis), x = 하완 현(chord). 혼 핀(horn pin)은 하완 측판(forearm side plate) 일체입니다. ===== */
module forearm_group(explode_distance = 0, hardware = false) {
    length = forearm_length();
    plate_t = forearm_plate_t();
    inner_w = 30;
    upper_outer_y = 30 + plate_t;
    arm_inner_w = 60;
    washer_t = washer_m8_t();
    bend_angle = forearm_bend()[0];
    bend_pos = forearm_bend()[1];
    kink_offset = forearm_bend()[2];
    standoff_x = [for (f = forearm_standoff_x()) f * length];
    crank_radius = forearm_crank_radius();
    horn_angle = forearm_horn_angle();
    elbow_pin_len = shoulder_bolt_m8_l80_len();
    horn_pin_len = shoulder_bolt_m5_l50_len();
    elbow_gap = (arm_inner_w - inner_w) / 2 - plate_t;
    forearm_outer_y = inner_w / 2 + plate_t;
    horn_pin_vector = crank_radius * [cos(horn_angle), 0, sin(horn_angle)];
    pos_plate_origin = [0.8 * explode_distance + 75.686, inner_w / 2 + plate_t / 2, 1.054];
    neg_plate_origin = [0.8 * explode_distance + 75.686, -(inner_w / 2 + plate_t / 2), 1.054];
    standoff_origin = [0, 0, inner_w / 2];
    shoulder_m8_origin = [0, 0, elbow_pin_len / 2];
    shoulder_m5_origin = [0, 0, horn_pin_len / 2];
    flange_origin = [0, 0, -flange_coupler_8mm_h() / 2];
    spacer_origin = [0, 0, elbow_gap / 2];
    lock_nut_m6_origin = [0, 0, lock_nut_m6_t() * 0.75];
    lock_nut_m4_origin = [0, 0, lock_nut_m4_t() * 0.75];
    washer_origin = [0, 0, washer_t / 2];
    cap_screw_origin = [0, 0, (shcs_m3_l10_len() - shcs_m3_l10_dia()) / 2];

    translate(pos_plate_origin) rotate([90, 0, 0])
        forearm_plate();
    translate(neg_plate_origin) rotate([90, 0, 0])
        forearm_plate();

    // 하완 스탠드오프(standoff) M3 L30 ×2는 구조재(structural member)이므로 상시 표시합니다.
    for (x = standoff_x)
        translate([0.8 * explode_distance + x, inner_w / 2, arm_standoff_pos(length, bend_pos, bend_angle, kink_offset, x)])
            rotate([90, 0, 0])
                translate([0, 0, -0.7] + standoff_origin)
                    hex_standoff_m3_l30();

    if (hardware) {
        // 팔꿈치 단일 통축(through shaft) 숄더 볼트(shoulder bolt) M8 L80입니다.
        translate([0.8 * explode_distance, upper_outer_y + washer_t + 0.5 * explode_distance, 0])
            rotate([90, 0, 0]) translate([0, 0, -explode_distance * 3.0] + shoulder_m8_origin)
                shoulder_bolt_m8_l80();

        // 팔꿈치 플랜지 커플러(flange coupler) ×2는 하완 ±Y 측판(side plate) 내면과 통축 볼트(through bolt) 그립(grip)을 연결합니다.
        for (side_y = [-1, 1])
            translate([0.8 * explode_distance, side_y * inner_w / 2, 0])
                rotate([-side_y * 90, 0, 0]) translate(flange_origin) flange_coupler_8mm();

        // ±Y 갭 스페이서(gap spacer)입니다.
        for (side_y = [-1, 1])
            translate([0.8 * explode_distance, side_y * (forearm_outer_y + 0.5 * explode_distance), 0])
                rotate([-side_y * 90, 0, 0])
                    translate(spacer_origin)
                    spacer_od12_id8_4_l6();

        // 락너트(lock nut) ×1은 -Y 단 통축 나사부(threaded section)에 배치합니다.
        translate([0.8 * explode_distance, -(upper_outer_y + washer_t) - 0.5 * explode_distance, 0])
            rotate([90, 0, 0]) translate(lock_nut_m6_origin)
                lock_nut_m6();

        // 혼 핀(horn pin) 숄더 볼트(shoulder bolt) M5 L50입니다.
        translate([0.8 * explode_distance, 0, 0] + horn_pin_vector + [0, forearm_outer_y + washer_t + 0.5 * explode_distance, 0])
            rotate([90, 0, 0]) translate([0, 0, -explode_distance * 0.4] + shoulder_m5_origin)
                shoulder_bolt_m5_l50();

        translate([0.8 * explode_distance, 0, 0] + horn_pin_vector + [0, forearm_outer_y + 0.5 * explode_distance, 0])
            rotate([-90, 0, 0]) translate(washer_origin) washer_m5();
        translate([0.8 * explode_distance, 0, 0] + horn_pin_vector + [0, -forearm_outer_y - 0.5 * explode_distance, 0])
            rotate([90, 0, 0]) translate(washer_origin) washer_m5();
        translate([0.8 * explode_distance, 0, 0] + horn_pin_vector + [0, -forearm_outer_y - washer_t - 0.5 * explode_distance, 0])
            rotate([90, 0, 0]) translate(lock_nut_m4_origin)
                lock_nut_m4();

        // 하완 스탠드오프(standoff) M3 L10 양측 체결부입니다.
        for (x = standoff_x)
            for (side_y = [-1, 1])
                translate([0.8 * explode_distance + x, side_y * (forearm_outer_y + 0.3), arm_standoff_pos(length, bend_pos, bend_angle, kink_offset, x)])
                    rotate([side_y * 90, 0, 0])
                        translate([0, 0, -explode_distance * 0.4] + cap_screw_origin)
                            shcs_m3_l10();

        for (side_y = [-1, 1])
            translate([0.8 * explode_distance, side_y * (upper_outer_y + washer_t / 2 + 0.25) + side_y * 0.5 * explode_distance, 0])
                rotate([side_y * 90, 0, 0]) translate(washer_origin) washer_m8();
    }
}

/* ===== J3 링키지 그룹(linkage group): 원점(origin) = J2 축(axis), 크랭크(crank)와 구동 링크(drive link)는 모두 중앙 y≈0에 둡니다. =====
   크랭크 핀(crank pin)과 혼 핀(horn pin)의 월드각(world angle) a = j3 + 혼 위상(horn phase)입니다.
   링크(link)는 상완 현(upper-arm chord)과 평행(parallel)이고 길이는 L1입니다. */
module linkage_group(j2 = 30, j3 = -30, explode_distance = 0, hardware = false) {
    length = upper_arm_length();
    plate_t = drive_link_plate_t();
    bearing_625 = bearing_625zz_spec();
    crank_radius = j3_crank_radius();
    horn_angle = forearm_horn_angle();
    washer_t = washer_m5_t();
    link_y0 = -plate_t / 2;
    link_y1 = plate_t / 2;
    crank_disk_y0 = link_y1 + washer_t;
    crank_angle = j3 + horn_angle;
    crank_pin_vector = crank_radius * [cos(crank_angle), 0, sin(crank_angle)];
    crank_origin = [(max(j3_crank_disk_d() / 2, crank_radius + 8) - j3_crank_disk_d() / 2) / 2, 0, plate_t / 2];
    drive_origin = [drive_link_length() / 2, -15, plate_t / 2];
    bearing_origin = [0, 0, bearing_625[2] / 2];
    shoulder_m5_l12_origin = [0, 0, shoulder_bolt_m5_l12_len() / 2];
    washer_origin = [0, 0, washer_t / 2];
    lock_nut_m4_origin = [0, 0, lock_nut_m4_t() * 0.75];

    // 크랭크(crank)는 중앙 디스크(center disk) z0=-Y, 보스(boss) +Y 방향으로 두고 J2 축(axis)을 기준으로 회전합니다.
    rotate([0, -crank_angle, 0])
        translate([0, crank_disk_y0 + 1.2 * explode_distance, 0])
            rotate([-90, 0, 0]) translate(crank_origin) j3_crank();

    // 구동 링크(drive link)는 중앙 y0에서 크랭크 핀(crank pin)과 혼 핀(horn pin)을 현(chord) 평행으로 잇습니다.
    translate(crank_pin_vector + [0, link_y0, 0]) rotate([0, -j2, 0]) rotate([-90, 0, 0])
        translate(drive_origin) drive_link();

    if (hardware) {
        // 링크 베어링(link bearing) 625ZZ ×2입니다.
        translate(crank_pin_vector + [0, link_y1 + 0.7 * explode_distance, 0]) rotate([90, 0, 0])
            translate(bearing_origin) bearing_625zz();
        translate(crank_pin_vector + pitch_vector([length, 0, 0], j2) + [0, link_y0 + -0.7 * explode_distance, 0]) rotate([-90, 0, 0])
            translate(bearing_origin) bearing_625zz();

        // 크랭크 핀(crank pin) 숄더 볼트(shoulder bolt) M5 L12입니다.
        translate(crank_pin_vector + [0, crank_disk_y0 + plate_t + 0.9 * explode_distance, 0])
            rotate([90, 0, 0]) translate([0, 0, -explode_distance * 1.0] + shoulder_m5_l12_origin)
                shoulder_bolt_m5_l12();

        // 크랭크 핀(crank pin) 와셔(washer)와 M4 락너트(lock nut)입니다.
        translate(crank_pin_vector + [0, link_y1 - bearing_625[2] - 0.5 * explode_distance, 0])
            rotate([90, 0, 0]) translate(washer_origin) washer_m5();
        translate(crank_pin_vector + [0, link_y1 - bearing_625[2] - washer_t - 0.6 * explode_distance, 0])
            rotate([90, 0, 0]) translate(lock_nut_m4_origin)
                lock_nut_m4();
    }
}

/* ===== 암 체인(arm chain): J2 축 프레임(axis frame)에서 상완(upper arm) → 하완(forearm) + 링키지(linkage)를 배치합니다. ===== */
module arm_chain(j2 = 30, j3 = -30, explode_distance = 0, hardware = false) {
    length = upper_arm_length();

    rotate([0, -j2, 0]) {
        upper_arm_group(explode_distance = explode_distance, hardware = hardware);
        translate([length, 0, 0]) rotate([0, -(j3 - j2), 0])
            forearm_group(explode_distance = explode_distance, hardware = hardware);
    }
    linkage_group(j2 = j2, j3 = j3, explode_distance = explode_distance, hardware = hardware);
    // J2 리미트 스위치(limit switch)는 고정 프레임(fixed frame)에 속해 상완 회전과 무관합니다. 브래킷(bracket)은 범위 외 베이스(base)에 둡니다.
    if (hardware) j2_switch();
}

/* ===== 전체 로봇(robot) ===== */
module robot(j2 = 30, j3 = -30, explode_distance = 0, hardware = true) {
    $fn = 64;
    fold_min = -132;
    fold_max = -15;
    j2_min = 0;
    j2_max = 75;
    fold = j3 - j2;
    if (fold < fold_min || fold > fold_max)
        echo(str("경고: 접힘각 j3-j2 = ", fold, "° — 엔벨로프 [",
                 fold_min, ", ", fold_max, "] 밖 (0° = 현 일직선 특이점)"));
    if (j2 < j2_min || j2 > j2_max)
        echo(str("경고: j2 = ", j2, "° — 권고 범위 [", j2_min, ", ", j2_max, "] 밖"));

    arm_chain(j2 = j2, j3 = j3, explode_distance = explode_distance, hardware = hardware);
}

/* ===== 디스패치(dispatch): 단독 실행과 명령줄 인터페이스(CLI) 간섭 검사(interference check) ===== */
module assembly_dispatch(j2 = 30, j3 = -30, check_mode = 0) {
    $fn = 64;
    length = upper_arm_length();

    if (check_mode == 2) {
        intersection() {
            rotate([0, -j2, 0]) upper_arm_group();
            rotate([0, -j2, 0]) translate([length, 0, 0])
                rotate([0, -(j3 - j2), 0]) forearm_group();
        }
    } else if (check_mode == 3) {
        intersection() {
            linkage_group(j2 = j2, j3 = j3);
            rotate([0, -j2, 0]) {
                upper_arm_group();
                translate([length, 0, 0]) rotate([0, -(j3 - j2), 0])
                    forearm_group();
            }
        }
    } else if (check_mode == 4) {
        // 스위치 몸체(switch body) ∩ 가동 구조(moving structure)로 장착 클리어런스(mounting clearance)를 현재 자세(pose) 기준에서 확인합니다. 자세 스윕(pose sweep)은 -D로 지정합니다.
        union() {
            intersection() {
                rotate([0, -j2, 0]) j3_switch();
                rotate([0, -j2, 0]) translate([length, 0, 0])
                    rotate([0, -(j3 - j2), 0]) forearm_group();
            }
            intersection() {
                j2_switch();
                rotate([0, -j2, 0]) upper_arm_group();
            }
        }
    } else if (check_mode == 0) {
        robot(j2 = j2, j3 = j3);
    }
}

assembly_dispatch(j2 = is_undef(J2a) ? 30 : J2a,
                  j3 = is_undef(J3a) ? -30 : J3a,
                  check_mode = is_undef(check) ? 0 : check);
