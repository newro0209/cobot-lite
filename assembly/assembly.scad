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
//   → "Current top level object is empty" 또는 빈 STL = 통과
include <../config/parameters.scad>
include <../lib/colors.scad>
use <../lib/utils.scad>
use <../lib/vitamins.scad>
use <../parts/upper_arm.scad>
use <../parts/forearm.scad>
use <../parts/j3_crank.scad>
use <../parts/drive_link.scad>

/* ===== 단독 실행용 자세 (main.scad 경유 시 robot() 인자가 우선) ===== */
J2a = 30;   // 상완 현 피치, deg (월드, 0 = 수평)
J3a = -30;  // 하완 현 피치, deg (월드)
check = 0;

/* ===== 좌표 헬퍼 (좌표 변환 — pitchv: 링크 앵커 등) ===== */
function pitchv(p, a) = [p[0] * cos(a) - p[2] * sin(a), p[1],
                         p[0] * sin(a) + p[2] * cos(a)];

/* ===== 상완 그룹 (원점 = J2 축, x = 상완 현) ===== */
module ua_group(e = 0, hw = false) {
    upper_arm(col = C_UPPERARM_POS, col2 = C_UPPERARM_NEG);

    // 상완 스탠드오프 M4 L60 ×2 — 구조재: 상시 표시
    for (x = ua_standoff_xa)
        translate([x, ua_in_y, ua_standoff_pos(x)]) rotate([90, 0, 0])
            translate([0, 0, -0.7]) hex_standoff(m4_standoff_af, arm_inner_w);

    if (hw) {
        // 팔꿈치 608ZZ ×2 (양 측판 외측 포켓 시트 — 대칭)
        translate([L1, ua_out_y - BRG_608ZZ[2] + 0.7 * e, 0]) rotate([-90, 0, 0]) bearing(BRG_608ZZ);
        translate([L1, -ua_out_y + 0.7 * -e, 0]) rotate([-90, 0, 0]) bearing(BRG_608ZZ);

        // 상완 스탠드오프 M4 L10 양측
        for (x = ua_standoff_xa)
            for (sy = [-1, 1])
                translate([x, sy * (ua_out_y + 0.3), ua_standoff_pos(x)]) rotate([sy * 90, 0, 0]) translate([0, 0, -e * 0.4]) cap_screw(4, 10);

        // J3 리미트 스위치 (상완 +Y 측판 내면 — 레버 → forearm 베인)
        translate([L1 - elbow_ls_x, ua_in_y, 0]) rotate([90, 0, 0])
            limit_switch();
    }
}

/* ===== 하완 그룹 (원점 = 팔꿈치 축, x = 하완 현) — 혼 핀 = forearm 측판 일체 ===== */
module fa_group(e = 0, hw = false) {
    fa_out = forearm_inner_w / 2 + arm_plate_t;
    hp = crank_R * [cos(horn_phase), 0, sin(horn_phase)];

    translate([0.8 * e, 0, 0])
        forearm(col = C_FOREARM_POS, col2 = C_FOREARM_NEG);

    // 하완 스탠드오프 M3 L30 ×2 — 구조재: 상시 표시
    for (x = fa_standoff_xa)
        translate([0.8 * e + x, forearm_inner_w / 2, fa_standoff_pos(x)])
            rotate([90, 0, 0]) translate([0, 0, -0.7]) hex_standoff(m3_standoff_af, forearm_inner_w);

    if (hw) {
        // 팔꿈치 단일 통축 숄더 M8, L 80
        translate([0.8 * e, ua_out_y + washer_t + 0.5 * e, 0])
            rotate([90, 0, 0]) translate([0, 0, -e * 3.0])
                shoulder_bolt(8, elbow_pin_len);

        // 팔꿈치 플랜지 커플러 ×2 (하완 ±Y 측판 내면 ↔ 통축 볼트 grip)
        for (sy = [-1, 1])
            translate([0.8 * e, sy * forearm_inner_w / 2, 0])
                rotate([-sy * 90, 0, 0]) flange_coupler();

        // ±Y 갭 스페이서
        for (sy = [-1, 1])
            translate([0.8 * e, sy * (fa_out + 0.5 * e), 0])
                rotate([-sy * 90, 0, 0])
                    spacer(joint_spacer_od, 8.4, elbow_gap);

        // 락너트 ×1 (-Y 단, 통축 나사부)
        translate([0.8 * e, -(ua_out_y + washer_t) - 0.5 * e, 0])
            rotate([90, 0, 0]) lock_nut(m6_nut_af, 5, 6);

        // 혼 핀 숄더 M5, L 50
        translate([0.8 * e, 0, 0] + hp + [0, fa_out + washer_t + 0.5 * e, 0])
            rotate([90, 0, 0]) translate([0, 0, -e * 0.4])
                shoulder_bolt(5, horn_pin_len);

        translate([0.8 * e, 0, 0] + hp + [0, fa_out + 0.5 * e, 0])
            rotate([-90, 0, 0]) washer(5);
        translate([0.8 * e, 0, 0] + hp + [0, -fa_out - 0.5 * e, 0])
            rotate([90, 0, 0]) washer(5);
        translate([0.8 * e, 0, 0] + hp + [0, -fa_out - washer_t - 0.5 * e, 0])
            rotate([90, 0, 0]) lock_nut(m4_nut_af, 4, 5);

        // 하완 스탠드오프 M3 L10 양측
        for (x = fa_standoff_xa)
            for (sy = [-1, 1])
                translate([0.8 * e + x, sy * (fa_out + 0.3), fa_standoff_pos(x)])
                    rotate([sy * 90, 0, 0]) translate([0, 0, -e * 0.4]) cap_screw(3, 10);

        for (sy = [-1, 1])
            translate([0.8 * e, sy * (ua_out_y + washer_t / 2 + 0.25) + sy * 0.5 * e, 0])
                rotate([sy * 90, 0, 0]) washer(8);
    }
}

/* ===== J3 링키지 그룹 (원점 = J2 축 — 크랭크 + 구동 링크, 모두 중앙 y≈0) =====
   크랭크/혼 핀 월드각 a = j3 + horn_phase. 링크 = 상완 현과 평행 (길이 L1). */
module linkage_group(j2 = J2a, j3 = J3a, e = 0, hw = false) {
    a = j3 + horn_phase;
    cpin = crank_R * [cos(a), 0, sin(a)];

    // 크랭크 (중앙 디스크 z0=-Y, 보스 +Y) — J2축 회전 a
    rotate([0, -a, 0])
        translate([0, crank_disk_y0 + 1.2 * e, 0])
            rotate([-90, 0, 0]) j3_crank(col = C_J3_CRANK);

    // 구동 링크 (중앙 y0, 크랭크 핀 → 혼 핀, 현 평행)
    translate(cpin + [0, link_y0, 0]) rotate([0, -j2, 0]) rotate([-90, 0, 0]) drive_link(col = C_DRIVE_LINK);

    if (hw) {
        // 링크 625ZZ ×2
        translate(cpin + [0, link_y1 + 0.7 * e, 0]) rotate([90, 0, 0]) bearing(BRG_625ZZ);
        translate(cpin + pitchv([L1, 0, 0], j2) + [0, link_y0 + -0.7 * e, 0]) rotate([-90, 0, 0]) bearing(BRG_625ZZ);

        // 크랭크 핀 숄더 M5, L 12
        translate(cpin + [0, crank_disk_y0 + arm_plate_t + 0.9 * e, 0])
            rotate([90, 0, 0]) translate([0, 0, -e * 1.0])
                shoulder_bolt(5, 12);

        // 크랭크 핀 와셔 + M4 락너트
        translate(cpin + [0, link_y1 - BRG_625ZZ[2] - 0.5 * e, 0])
            rotate([90, 0, 0]) washer(5);
        translate(cpin + [0, link_y1 - BRG_625ZZ[2] - washer_t - 0.6 * e, 0])
            rotate([90, 0, 0]) lock_nut(m4_nut_af, 4, 5);
    }
}

/* ===== 암 체인 (J2 축 프레임: 상완 → 하완 + 링키지) ===== */
module arm_chain(j2 = J2a, j3 = J3a, e = 0, hw = false) {
    rotate([0, -j2, 0]) {
        ua_group(e, hw);
        translate([L1, 0, 0]) rotate([0, -(j3 - j2), 0])
            fa_group(e, hw);
    }
    linkage_group(j2, j3, e, hw);
}

/* ===== 전체 로봇 ===== */
module robot(j2 = J2a, j3 = J3a, e = 0, hardware = true) {
    fold = j3 - j2;
    if (fold < env_fold_min || fold > env_fold_max)
        echo(str("경고: 접힘각 j3-j2 = ", fold, "° — 엔벨로프 [",
                 env_fold_min, ", ", env_fold_max, "] 밖 (0° = 현 일직선 특이점)"));
    if (j2 < env_j2_min || j2 > env_j2_max)
        echo(str("경고: j2 = ", j2, "° — 권고 범위 [", env_j2_min, ", ", env_j2_max, "] 밖"));

    arm_chain(j2, j3, e, hardware);
}

/* ===== 디스패치 (단독 실행 / CLI 간섭 검사) ===== */
if (check == 2) {
    intersection() {
        rotate([0, -J2a, 0]) ua_group();
        rotate([0, -J2a, 0]) translate([L1, 0, 0])
            rotate([0, -(J3a - J2a), 0]) fa_group();
    }
} else if (check == 3) {
    intersection() {
        linkage_group(J2a, J3a);
        rotate([0, -J2a, 0]) {
            ua_group();
            translate([L1, 0, 0]) rotate([0, -(J3a - J2a), 0])
                fa_group();
        }
    }
} else if (check == 0) {
    robot(J2a, J3a);
}
