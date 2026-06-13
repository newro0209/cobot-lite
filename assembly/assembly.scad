// 전체 조립 모델 (full assembly) — 간섭 확인 + 시각화
//
// 하부 회전·지지 구조를 제외한 2축 팔 체인.
// 좌표: 원점 = J2 축. x = 상완 현, y = 측판 스팬, z = 피치 평면 수직.
// 각도 규약: j2/j3 = 상완/하완 '현(chord)'의 월드 피치 (수평=0).
//   접힘각 = j3 - j2 ∈ [-132, -15] — 0°(현 일직선)가 특이점.
//
// CLI 간섭 검사:
//   check=2: 하완 그룹 ∩ 상완 그룹 (팔꿈치 접힘)
//   check=3: 링키지(크랭크+링크) ∩ 팔 구조
//   check=4: 리미트 스위치 몸체 ∩ 가동 구조 (장착 클리어런스)
//   → "Current top level object is empty" 또는 빈 STL = 통과
include <../lib/colors.scad>
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

/* ===== 좌표 헬퍼 (좌표 변환 — pitchv: 링크 앵커 등) ===== */
function pitchv(p, a) = [p[0] * cos(a) - p[2] * sin(a), p[1],
                         p[0] * sin(a) + p[2] * cos(a)];

/* ===== 리미트 스위치 배치 (롤러를 목표 위치에 두고 몸체를 +Y 측판에 눕힘) ===== */
// J3: 상완(팔꿈치축) 프레임. 롤러가 fold 평면서 forearm 베인 검출.
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
// J2: 고정프레임(월드). ⚠ 몸체·브래킷은 범위 외 베이스에 장착 — 여기선 인터페이스만.
module j2_switch() {
    vane_angle = 250;
    aim = 0;
    roller_local = [13.89, 6.96, 4.8];
    roller = [36 * cos(vane_angle - 5), 34, 36 * sin(vane_angle - 5)];
    switch_origin = [3.234, 0.272, 3.25];

    translate(roller) rotate([0, -aim, 0]) rotate([90, 0, 0])
        translate(-roller_local + switch_origin) kw12_limit_switch();
}

/* ===== 상완 그룹 (원점 = J2 축, x = 상완 현) ===== */
module ua_group(e = 0, hw = false) {
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
        upper_arm_plate(col = upper_arm_pos_color());
    mirror([0, 1, 0]) translate(plate_origin) rotate([90, 0, 0])
        upper_arm_plate(col = upper_arm_neg_color());

    // 상완 스탠드오프 M4 L60 ×2 — 구조재: 상시 표시
    for (x = standoff_x)
        translate([x, inner_y, arm_standoff_pos(length, bend_pos, bend_angle, kink_offset, x)])
            rotate([90, 0, 0])
                translate([0, 0, -0.7] + standoff_origin)
                    hex_standoff_m4_l60();

    if (hw) {
        // 팔꿈치 608ZZ ×2 (양 측판 외측 포켓 시트 — 대칭)
        translate([length, outer_y - bearing_608[2] + 0.7 * e, 0]) rotate([-90, 0, 0])
            translate(bearing_origin) bearing_608zz();
        translate([length, -outer_y + 0.7 * -e, 0]) rotate([-90, 0, 0])
            translate(bearing_origin) bearing_608zz();

        // 상완 스탠드오프 M4 L10 양측
        for (x = standoff_x)
            for (sy = [-1, 1])
                translate([x, sy * (outer_y + 0.3), arm_standoff_pos(length, bend_pos, bend_angle, kink_offset, x)])
                    rotate([sy * 90, 0, 0])
                        translate([0, 0, -e * 0.4] + cap_screw_origin) shcs_m4_l10();

        // J3 리미트 스위치 (상완 +Y 측판 — 롤러가 fold 평면서 forearm 베인 검출)
        j3_switch();
    }
}

/* ===== 하완 그룹 (원점 = 팔꿈치 축, x = 하완 현) — 혼 핀 = forearm 측판 일체 ===== */
module fa_group(e = 0, hw = false) {
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
    fa_out = inner_w / 2 + plate_t;
    hp = crank_radius * [cos(horn_angle), 0, sin(horn_angle)];
    pos_plate_origin = [0.8 * e + 75.686, inner_w / 2 + plate_t / 2, 1.054];
    neg_plate_origin = [0.8 * e + 75.686, -(inner_w / 2 + plate_t / 2), 1.054];
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
        forearm_plate(col = forearm_pos_color());
    translate(neg_plate_origin) rotate([90, 0, 0])
        forearm_plate(col = forearm_neg_color());

    // 하완 스탠드오프 M3 L30 ×2 — 구조재: 상시 표시
    for (x = standoff_x)
        translate([0.8 * e + x, inner_w / 2, arm_standoff_pos(length, bend_pos, bend_angle, kink_offset, x)])
            rotate([90, 0, 0])
                translate([0, 0, -0.7] + standoff_origin)
                    hex_standoff_m3_l30();

    if (hw) {
        // 팔꿈치 단일 통축 숄더 M8, L 80
        translate([0.8 * e, upper_outer_y + washer_t + 0.5 * e, 0])
            rotate([90, 0, 0]) translate([0, 0, -e * 3.0] + shoulder_m8_origin)
                shoulder_bolt_m8_l80();

        // 팔꿈치 플랜지 커플러 ×2 (하완 ±Y 측판 내면 ↔ 통축 볼트 grip)
        for (sy = [-1, 1])
            translate([0.8 * e, sy * inner_w / 2, 0])
                rotate([-sy * 90, 0, 0]) translate(flange_origin) flange_coupler_8mm();

        // ±Y 갭 스페이서
        for (sy = [-1, 1])
            translate([0.8 * e, sy * (fa_out + 0.5 * e), 0])
                rotate([-sy * 90, 0, 0])
                    translate(spacer_origin)
                    spacer_od12_id8_4_l6();

        // 락너트 ×1 (-Y 단, 통축 나사부)
        translate([0.8 * e, -(upper_outer_y + washer_t) - 0.5 * e, 0])
            rotate([90, 0, 0]) translate(lock_nut_m6_origin)
                lock_nut_m6();

        // 혼 핀 숄더 M5, L 50
        translate([0.8 * e, 0, 0] + hp + [0, fa_out + washer_t + 0.5 * e, 0])
            rotate([90, 0, 0]) translate([0, 0, -e * 0.4] + shoulder_m5_origin)
                shoulder_bolt_m5_l50();

        translate([0.8 * e, 0, 0] + hp + [0, fa_out + 0.5 * e, 0])
            rotate([-90, 0, 0]) translate(washer_origin) washer_m5();
        translate([0.8 * e, 0, 0] + hp + [0, -fa_out - 0.5 * e, 0])
            rotate([90, 0, 0]) translate(washer_origin) washer_m5();
        translate([0.8 * e, 0, 0] + hp + [0, -fa_out - washer_t - 0.5 * e, 0])
            rotate([90, 0, 0]) translate(lock_nut_m4_origin)
                lock_nut_m4();

        // 하완 스탠드오프 M3 L10 양측
        for (x = standoff_x)
            for (sy = [-1, 1])
                translate([0.8 * e + x, sy * (fa_out + 0.3), arm_standoff_pos(length, bend_pos, bend_angle, kink_offset, x)])
                    rotate([sy * 90, 0, 0])
                        translate([0, 0, -e * 0.4] + cap_screw_origin)
                            shcs_m3_l10();

        for (sy = [-1, 1])
            translate([0.8 * e, sy * (upper_outer_y + washer_t / 2 + 0.25) + sy * 0.5 * e, 0])
                rotate([sy * 90, 0, 0]) translate(washer_origin) washer_m8();
    }
}

/* ===== J3 링키지 그룹 (원점 = J2 축 — 크랭크 + 구동 링크, 모두 중앙 y≈0) =====
   크랭크/혼 핀 월드각 a = j3 + horn_phase. 링크 = 상완 현과 평행 (길이 L1). */
module linkage_group(j2 = 30, j3 = -30, e = 0, hw = false) {
    length = upper_arm_length();
    plate_t = drive_link_plate_t();
    bearing_625 = bearing_625zz_spec();
    crank_radius = j3_crank_radius();
    horn_angle = forearm_horn_angle();
    washer_t = washer_m5_t();
    link_y0 = -plate_t / 2;
    link_y1 = plate_t / 2;
    crank_disk_y0 = link_y1 + washer_t;
    a = j3 + horn_angle;
    cpin = crank_radius * [cos(a), 0, sin(a)];
    crank_origin = [(max(j3_crank_disk_d() / 2, crank_radius + 8) - j3_crank_disk_d() / 2) / 2, 0, plate_t / 2];
    drive_origin = [drive_link_length() / 2, -15, plate_t / 2];
    bearing_origin = [0, 0, bearing_625[2] / 2];
    shoulder_m5_l12_origin = [0, 0, shoulder_bolt_m5_l12_len() / 2];
    washer_origin = [0, 0, washer_t / 2];
    lock_nut_m4_origin = [0, 0, lock_nut_m4_t() * 0.75];

    // 크랭크 (중앙 디스크 z0=-Y, 보스 +Y) — J2축 회전 a
    rotate([0, -a, 0])
        translate([0, crank_disk_y0 + 1.2 * e, 0])
            rotate([-90, 0, 0]) translate(crank_origin) j3_crank(col = j3_crank_color());

    // 구동 링크 (중앙 y0, 크랭크 핀 → 혼 핀, 현 평행)
    translate(cpin + [0, link_y0, 0]) rotate([0, -j2, 0]) rotate([-90, 0, 0])
        translate(drive_origin) drive_link(col = drive_link_color());

    if (hw) {
        // 링크 625ZZ ×2
        translate(cpin + [0, link_y1 + 0.7 * e, 0]) rotate([90, 0, 0])
            translate(bearing_origin) bearing_625zz();
        translate(cpin + pitchv([length, 0, 0], j2) + [0, link_y0 + -0.7 * e, 0]) rotate([-90, 0, 0])
            translate(bearing_origin) bearing_625zz();

        // 크랭크 핀 숄더 M5, L 12
        translate(cpin + [0, crank_disk_y0 + plate_t + 0.9 * e, 0])
            rotate([90, 0, 0]) translate([0, 0, -e * 1.0] + shoulder_m5_l12_origin)
                shoulder_bolt_m5_l12();

        // 크랭크 핀 와셔 + M4 락너트
        translate(cpin + [0, link_y1 - bearing_625[2] - 0.5 * e, 0])
            rotate([90, 0, 0]) translate(washer_origin) washer_m5();
        translate(cpin + [0, link_y1 - bearing_625[2] - washer_t - 0.6 * e, 0])
            rotate([90, 0, 0]) translate(lock_nut_m4_origin)
                lock_nut_m4();
    }
}

/* ===== 암 체인 (J2 축 프레임: 상완 → 하완 + 링키지) ===== */
module arm_chain(j2 = 30, j3 = -30, e = 0, hw = false) {
    length = upper_arm_length();

    rotate([0, -j2, 0]) {
        ua_group(e, hw);
        translate([length, 0, 0]) rotate([0, -(j3 - j2), 0])
            fa_group(e, hw);
    }
    linkage_group(j2, j3, e, hw);
    // J2 리미트 스위치 — 고정프레임(상완 회전과 무관). 브래킷은 범위 외 베이스.
    if (hw) j2_switch();
}

/* ===== 전체 로봇 ===== */
module robot(j2 = 30, j3 = -30, e = 0, hardware = true) {
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

    arm_chain(j2, j3, e, hardware);
}

/* ===== 디스패치 (단독 실행 / CLI 간섭 검사) ===== */
module assembly_dispatch(j2 = 30, j3 = -30, check_mode = 0) {
    $fn = 64;
    length = upper_arm_length();

    if (check_mode == 2) {
        intersection() {
            rotate([0, -j2, 0]) ua_group();
            rotate([0, -j2, 0]) translate([length, 0, 0])
                rotate([0, -(j3 - j2), 0]) fa_group();
        }
    } else if (check_mode == 3) {
        intersection() {
            linkage_group(j2, j3);
            rotate([0, -j2, 0]) {
                ua_group();
                translate([length, 0, 0]) rotate([0, -(j3 - j2), 0])
                    fa_group();
            }
        }
    } else if (check_mode == 4) {
        // 스위치 몸체 ∩ 가동 구조 (장착 클리어런스) — 현재 자세 기준, 자세 스윕은 -D로
        union() {
            intersection() {
                translate([length, 0, 0]) rotate([0, -(j3 - j2), 0]) fa_group();
            }
            intersection() {
                rotate([0, -j2, 0]) ua_group();
            }
        }
    } else if (check_mode == 0) {
        robot(j2, j3);
    }
}

assembly_dispatch(j2 = is_undef(J2a) ? 30 : J2a,
                  j3 = is_undef(J3a) ? -30 : J3a,
                  check_mode = is_undef(check) ? 0 : check);
