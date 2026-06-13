// 전체 조립 모델 (full assembly) — 간섭 확인 + 시각화
//
// v0.17 팔레타이저식 하부 구동:
//   고정부: 지면판 → 스탠드오프 L100 ×4 → 베이스판 (J1 액추에이터 매달림) → 링
//   J1 체인: 터릿(6810ZZ) → 타워 ×2 → J2/J3 액추에이터 (동축, 양측)
//   J2: -Y 타워 → J2 허브 → 상완. J3: +Y 타워 → 크랭크 → 링크 → 혼 → 하완
//   평행사변형: 크랭크 핀 월드각 = j3 + horn_phase = 혼 핀 월드각 (1:1 전달)
//   링크·혼 = 상완 포크 내부 (혼 22~29 / 링크 29.5~36.5 / 크랭크 45.5~52.5,
//   크랭크 핀만 상완 +Y 측판 J2부 아크 슬롯 통과)
//
// 좌표: 원점 = J1 축 ∩ 베이스판 상면. J2 축 = (j2_fwd, 0, 링 전고+타워 높이).
// 각도 규약: j1 = 요(+z), j2/j3 = 상완/하완 '현(chord)'의 월드 피치 (수평=0).
//   접힘각 = j3 - j2 ∈ [-132, -15] — 0°(현 일직선)가 특이점,
//   env_fold_max = -15°가 가드 (꺾임 빔이라 외관상 곧게 펴져도 현은 미일직선),
//   env_fold_min = -132°는 check=2 실측 (하완판 ↔ 상완 스탠드오프).
//
// CLI 간섭 검사 (자세는 -D J1a/J2a/J3a 파일 변수):
//   openscad -D "check=2" -D "J2a=30" -D "J3a=-60" -o chk.stl assembly/assembly.scad
//   check=2: 하완 그룹 ∩ 상완 그룹 (팔꿈치 접힘)
//   check=3: J1 체인 전체 ∩ 고정부(베이스판·링·스탠드오프)
//   check=4: 링키지(크랭크+링크) ∩ (터릿·타워 + 상완 + 하완)
//   check=5: 암(상완+하완+링키지) ∩ 터릿 그룹(타워 스탠드오프 포함)
//   → "Current top level object is empty" 또는 빈 STL = 통과 (hw 기본 false)
include <../config/parameters.scad>
include <../lib/colors.scad>
use <../lib/utils.scad>
use <../lib/vitamins.scad>
use <../parts/base_plate.scad>
use <../parts/j1_ring.scad>
use <../parts/turret_plate.scad>
use <../parts/tower_plate.scad>
use <../parts/foot_bracket.scad>
use <../parts/drive_hub.scad>
use <../parts/upper_arm.scad>
use <../parts/forearm.scad>
use <../parts/j3_crank.scad>
use <../parts/drive_link.scad>

/* ===== 단독 실행용 자세 (main.scad 경유 시 robot() 인자가 우선) ===== */
J1a = 0;    // 요, deg
J2a = 30;   // 상완 현 피치, deg (월드, 0 = 수평)
J3a = -30;  // 하완 현 피치, deg (월드)
check = 0;

/* ===== 파생 좌표 ===== */
zt = turret_z0 + turret_t;               // 터릿 상면 (타워 기립면) = 27
j2_axis = [j2_fwd, 0, zt + tower_j2_h];  // J2 축 월드 (j1=0 기준)

/* ===== 좌표 헬퍼 (라벨 앵커) ===== */
function pitchv(p, a) = [p[0] * cos(a) - p[2] * sin(a), p[1],
                         p[0] * sin(a) + p[2] * cos(a)];
function yawv(p, a) = [p[0] * cos(a) - p[1] * sin(a),
                       p[0] * sin(a) + p[1] * cos(a), p[2]];

/* ===== 고정부 (지면판 + 스탠드오프 + 베이스판 + 링 + J1 액추에이터) ===== */
module base_static(e = 0, hw = false) {
    // 색상 선택은 assembly 레이어에서 수행. parts는 전달받은 col만 적용.
    translate([0, 0, -arm_plate_t]) base_plate(col = C_BASE_CARRIER); // 캐리어판
    translate([0, 0, -2 * arm_plate_t - base_lift - 1.2 * e])
        base_plate(col = C_BASE_GROUND);                           // 지면판
    translate([0, 0, 0.3 * e]) j1_ring(col = C_BASE_RING);
    translate([0, 0, -arm_plate_t - 0.8 * e]) actuator_J1();
    // 코너 스탠드오프 M6 L100 ×4 — 구조재: 상시 표시 (간섭 검사 포함)
    for (x = [-1, 1], y = [-1, 1])
        translate([x * base_corner_off, y * base_corner_off,
                   -arm_plate_t - base_lift])
            hex_standoff(hex_standoff_af, base_lift);
    if (hw) {
        // 스탠드오프 M6×12 양단
        for (x = [-1, 1], y = [-1, 1]) {
            translate([x * base_corner_off, y * base_corner_off, 0.3])
                rotate([180, 0, 0]) machine_bolt(6, 10);
            translate([x * base_corner_off, y * base_corner_off,
                       -2 * arm_plate_t - base_lift - 0.3 - 1.2 * e])
                machine_bolt(6, 10);
        }
        // 링 플랜지 M4 ×4 (상면에서, 하면 너트)
        for (a = [0, 90, 180, 270])
            rotate([0, 0, a]) translate([j1_ring_bolt_r, 0, 3 + 0.3 * e])
                rotate([180, 0, 0]) machine_bolt(4, 12);
        // J1 리미트 스위치 (베이스판 상면 — 레버 ↑ 터릿 베인 감지)
        translate([0, -(turret_r - 8), 0.2 * e]) rotate([0, -90, 0])
            limit_switch();
    }
}

/* ===== 터릿 그룹 (J1 체인 고정 구조: 터릿판·허브·타워·풋·J2/J3 액추에이터) ===== */
module turret_group(e = 0, hw = false) {
    // 터릿 (6810 내륜 보스 일체 — 보스는 -z로 6810/링 내부)
    translate([0, 0, turret_z0 + 0.6 * e]) turret_plate(col = C_TURRET_PLATE);
    // +Y 타워 (카운터보어 내면)
    translate([0, tower_in_pos + arm_plate_t + 0.5 * e, zt + 0.6 * e])
        rotate([90, 0, 0]) tower_plate(col = C_TOWER_POS);
    // -Y 타워 = 동일 부품 플립 (x = j2_fwd 수직축 180°)
    translate([j2_fwd, 0, 0]) rotate([0, 0, 180])
        translate([-j2_fwd, 0, 0])
            translate([0, tower_in_neg + arm_plate_t + 0.5 * e, zt + 0.6 * e])
                rotate([90, 0, 0]) tower_plate(col = C_TOWER_NEG);
    // 풋 브래킷 ×4
    for (fx = feet_x) {
        translate([fx, -tower_in_neg - 0.4 * e, zt + 0.6 * e])
            foot_bracket(col = C_FOOT_A);
        translate([fx, tower_in_pos + 0.4 * e, zt + 0.6 * e])
            rotate([0, 0, 180]) foot_bracket(col = C_FOOT_B);
    }
    // A2: -Y 타워 외면 직결, 출력축 +Y (J2 허브 클램프)
    translate(j2_axis + [0, -(tower_in_neg + arm_plate_t) - 0.8 * e, 0])
        rotate([-90, 0, 0]) actuator_J2();
    // A3: +Y 타워 외면 직결, 출력축 -Y (크랭크 클램프)
    translate(j2_axis + [0, tower_in_pos + arm_plate_t + 0.8 * e, 0])
        rotate([90, 0, 0]) actuator_J3();
    // 타워 스탠드오프 M6 L105 ×3 — 구조재: 상시 표시 (간섭 검사 포함)
    for (st = tower_standoffs)
        translate([st[0], -tower_in_neg, zt + st[1]])
            rotate([-90, 0, 0]) hex_standoff(hex_standoff_af, tower_span);
    if (hw) {
        // 6810ZZ J1 슬루 (링 외륜 ↔ 터릿 보스 내륜) — 링 시트 z13 고정
        translate([0, 0, j1_ring_h - BRG_6810ZZ[2] + 0.6 * e])
            bearing(BRG_6810ZZ);
        // J1 플랜지 커플러 (터릿 보스 하면 z13 ↔ 기어박스 ⌀8 축, 몸체 -z)
        translate([0, 0, turret_z0 - turret_boss_h - 0.4 * e]) flange_coupler();
            // 타워 스탠드오프 M6×12 양단
            for (st = tower_standoffs)
                for (sy = [-1, 1])
                    translate([st[0],
                               sy * (sy > 0 ? tower_in_pos : tower_in_neg)
                                   + sy * (arm_plate_t + 0.3),
                               zt + st[1]])
                        rotate([sy * 90, 0, 0]) machine_bolt(6, 10);
        // J2 리미트 스위치 (-Y 타워 내면 — 레버 → J2 허브 베인)
        translate(j2_axis + [0, -tower_in_neg, 0]
                  + j2_vane_r * [cos(j2_ls_a), 0, sin(j2_ls_a)])
            rotate([-90, 0, 0]) rotate([0, 0, j2_ls_a + 90]) limit_switch();
    }
}

/* ===== 상완 그룹 (원점 = J2 축, x = 상완 현) ===== */
module ua_group(e = 0, hw = false) {
    upper_arm(col = C_UPPERARM_POS, col2 = C_UPPERARM_NEG);
    // J2 허브 (-Y 갭, 상완 -Y 측판 외면 볼트온 + 6805 보스)
    translate([0, -(ua_out_y + arm_plate_t) - 0.5 * e, 0])
        rotate([-90, 0, 0]) drive_hub("j2", col = C_HUB_J2);
    // 상완 스탠드오프 M6 L75 ×3 — 구조재: 상시 표시 (간섭 검사 포함)
    for (x = [40, 100, 160])
        translate([x, ua_in_y, arm_standoff_z])
            rotate([90, 0, 0]) hex_standoff(hex_standoff_af, arm_inner_w);
    if (hw) {
        // J2 플랜지 커플러 (허브 외면 ↔ 기어박스 ⌀8 축)
        translate([0, -(ua_out_y + arm_plate_t) - 0.5 * e, 0])
            rotate([-90, 0, 0]) flange_coupler();
        {
            // J2 6805ZZ ×2 (-Y: 허브 보스 / +Y: 크랭크 보스 안착)
            translate([0, -ua_in_y, 0]) rotate([90, 0, 0])
                bearing(BRG_6805ZZ);
            translate([0, ua_out_y, 0]) rotate([90, 0, 0])
                bearing(BRG_6805ZZ);
            // 팔꿈치 608ZZ ×2 (숄더 ⌀8×25 피벗)
            translate([L1, -ua_in_y, 0]) rotate([90, 0, 0])
                bearing(BRG_608ZZ);
            translate([L1, ua_out_y, 0]) rotate([90, 0, 0])
                bearing(BRG_608ZZ);
        }
        {
            // 상완 스탠드오프 M6×12 양측
            for (x = [40, 100, 160])
                for (sy = [-1, 1])
                    translate([x, sy * (ua_out_y + 0.3), arm_standoff_z])
                        rotate([sy * 90, 0, 0]) machine_bolt(6, 10);
            // J2 허브 M4 FHCS ×3 (허브 외면 -y측에서 측판 셀프태핑)
            for (a = [90, 210, 330])
                translate([hub_bolt_r_j2 * cos(a),
                           -(ua_out_y + arm_plate_t) - 0.5 * e,
                           hub_bolt_r_j2 * sin(a)])
                    rotate([-90, 0, 0]) machine_bolt(4, 12);
        }
        // J3 리미트 스위치 (상완 +Y 측판 내면 — 레버 → forearm 베인)
        translate([L1 - elbow_ls_x, ua_in_y, 0]) rotate([90, 0, 0])
            limit_switch();
    }
}

/* ===== 하완 그룹 (원점 = 팔꿈치 축, x = 하완 현) — 혼 핀 = forearm 측판 일체 ===== */
module fa_group(e = 0, hw = false) {
    fa_out = forearm_inner_w / 2 + arm_plate_t;     // 22
    hp = crank_R * [cos(horn_phase), 0, sin(horn_phase)];  // 혼 핀 (forearm 프레임, y0)
    translate([0.8 * e, 0, 0]) forearm(col = C_FOREARM_POS, col2 = C_FOREARM_NEG);
    // 하완 스탠드오프 M6 L30 ×2 — 구조재: 상시 표시 (간섭 검사 포함)
    for (x = [76, 160])
        translate([0.8 * e + x, forearm_inner_w / 2, 0])
            rotate([90, 0, 0]) hex_standoff(hex_standoff_af, forearm_inner_w);
    if (hw) {
        {
            // 팔꿈치 숄더 ⌀8×30 ×2 (양측 — 하완에 너트 고정, 상완 608ZZ 위 회전)
            translate([0.8 * e, ua_out_y + washer_t + 0.5 * e, 0])
                rotate([90, 0, 0]) shoulder_bolt(8, 30);
            translate([0.8 * e, -(ua_out_y + washer_t) - 0.5 * e, 0])
                rotate([-90, 0, 0]) shoulder_bolt(8, 30);
            // ±Y 갭 스페이서 ⌀12×8 (하완판 ↔ 상완 608ZZ 내륜)
            for (sy = [-1, 1])
                translate([0.8 * e, sy * (fa_out + 0.5 * e), 0])
                    rotate([sy * 90, 0, 0])
                        difference() {
                            cylinder(d = joint_spacer_od, h = elbow_gap);
                            translate([0, 0, -1]) cylinder(d = 8.4, h = elbow_gap + 2);
                        }
            for (sy = [-1, 1])
                translate([0.8 * e, sy * (forearm_inner_w / 2 - 1.2), 0])
                    rotate([sy * 90, 0, 0]) lock_nut(m6_nut_af, 5, 6);
            // 혼 핀 ⌀5×30 (forearm 채널 가로지름 — 머리 +Y판 외, 너트 -Y)
            translate([0.8 * e, 0, 0] + hp + [0, fa_out - washer_t, 0])
                rotate([-90, 0, 0]) shoulder_bolt(5, 30);
            // 혼 핀 스페이서 ⌀8×12.5 ×2 (링크 625ZZ ↔ 양 측판)
            for (sy = [-1, 1])
                translate([0.8 * e, 0, 0] + hp
                          + [0, sy * (BRG_625ZZ[2] / 2 + 0.3), 0])
                    rotate([sy * 90, 0, 0])
                        difference() {
                            cylinder(d = 8, h = horn_pin_spacer);
                            translate([0, 0, -1]) cylinder(d = 5.4, h = horn_pin_spacer + 2);
                        }
            // 하완 스탠드오프 M6×12 양측
            for (x = [76, 160])
                for (sy = [-1, 1])
                    translate([0.8 * e + x, sy * (fa_out + 0.3), 0])
                        rotate([sy * 90, 0, 0]) machine_bolt(6, 10);
        }
        for (sy = [-1, 1])
            translate([0.8 * e, sy * (ua_out_y + washer_t / 2 + 0.25)
                                + sy * 0.5 * e, 0])
                rotate([sy * 90, 0, 0]) washer(8);
    }
}

/* ===== J3 링키지 그룹 (원점 = J2 축 — 크랭크 + 구동 링크, 모두 중앙 y≈0) =====
   크랭크/혼 핀 월드각 a = j3 + horn_phase. 링크 = 상완 현과 평행 (길이 L1),
   forearm 중앙면(y0) 주행. 크랭크 = 중앙 디스크 + 보스 +Y(6805 통과)+커플러. */
module linkage_group(j2 = J2a, j3 = J3a, e = 0, hw = false) {
    a = j3 + horn_phase;
    cpin = crank_R * [cos(a), 0, sin(a)];          // 크랭크 핀 월드 (J2 프레임, y0)
    // 크랭크 (중앙 디스크 z0=-Y, 보스 +Y) — J2축 회전 a
    rotate([0, -a, 0]) translate([0, crank_y0 + 0.9 * e, 0])
        rotate([-90, 0, 0]) j3_crank(col = C_J3_CRANK);
    // 구동 링크 (중앙 y0, 크랭크 핀 → 혼 핀, 현 평행)
    translate(cpin + [0, link_y0 + 0.7 * e, 0])
        rotate([0, -j2, 0]) rotate([-90, 0, 0]) drive_link(col = C_DRIVE_LINK);
    if (hw) {
        // J3 플랜지 커플러 (크랭크 외단 플랜지 world y44 ↔ 기어박스 ⌀8 축, 몸체 +Y)
        rotate([0, -a, 0]) translate([0, ua_out_y + crank_ofl_t + 0.9 * e, 0])
            rotate([90, 0, 0]) flange_coupler();
        {
            // 링크 625ZZ ×2 (크랭크 핀단 +Y / 혼 핀단 중앙)
            translate(cpin + [0, link_y1 + 0.7 * e, 0]) rotate([90, 0, 0])
                bearing(BRG_625ZZ);
            translate(cpin + pitchv([L1, 0, 0], j2) + [0, link_y0 + 0.7 * e, 0])
                rotate([90, 0, 0]) bearing(BRG_625ZZ);
        }
        // 크랭크 핀 숄더 ⌀5×16 (디스크 -Y면 → 중앙 링크)
        translate(cpin + [0, crank_y0 + 0.9 * e, 0])
            rotate([-90, 0, 0]) shoulder_bolt(5, 16);
    }
}

/* ===== 암 체인 (J2 축 프레임: 상완 → 하완 + 링키지) ===== */
module arm_chain(j2 = J2a, j3 = J3a, e = 0, hw = false) {
    rotate([0, -j2, 0]) {
        ua_group(e, hw);
        translate([L1, 0, 0]) rotate([0, -(j3 - j2), 0]) fa_group(e, hw);
    }
    linkage_group(j2, j3, e, hw);
}

/* ===== 부품 라벨 (지시선 + 빌보드, 월드 프레임) ===== */
module robot_labels(j1, j2, j3, e, lsize, detail = false, hw = false) {
    a    = j3 + horn_phase;
    J2w  = j2_axis;
    Ew   = j2_axis + pitchv(yawv([L1, 0, 0], j1), j2);   // 팔꿈치 월드
    adir = yawv(pitchv([1, 0, 0], j2), j1);
    fdir = yawv(pitchv([1, 0, 0], j3), j1);
    cpin = crank_R * [cos(a), 0, sin(a)];
    hpw  = Ew + yawv(pitchv([crank_R * cos(horn_phase), 0,
                              crank_R * sin(horn_phase)], j3), j1);
    fa_out = forearm_inner_w / 2 + arm_plate_t;

    leader_label([0.6 * base_size / 2, 0.4 * base_size / 2, -arm_plate_t],
                 [30, 25, -20], "01 base plate x2 (ground+carrier, 200sq)",
                 lsize, C_BASE);
    leader_label([0, -28, 10], [-35, -40, 8],
                 "02 J1 ring (6810 inner boss)", lsize, C_BASE);
    leader_label(yawv([-55, 25, turret_z0 + 3 + 0.6 * e], j1), [-30, 35, 20],
                 "03 turret plate (6810 press, J1 vane)", lsize, C_TOWER);
    leader_label(yawv([j2_fwd - 20, -49 - 0.5 * e, zt + 45 + 0.6 * e], j1),
                 [-35, -35, 18], "04 tower plate x2 (flip pair)",
                 lsize, C_TOWER);
    leader_label(J2w + 0.45 * L1 * adir + [0, 30, 14], [-12, 38, 30],
                 "05 upper arm (plate x2, bend 15deg)", lsize, C_UPPERARM);
    leader_label(Ew + 0.5 * forearm_len * fdir + [0, -20, 0], [12, -42, 22],
                 "06 forearm (plate x2, bend 30deg)", lsize, C_FOREARM);
    leader_label(J2w + yawv(pitchv([crank_R, 0, 0], a)
                            + [0, crank_y0 + 3 + 0.9 * e, 0], j1),
                 [24, 36, 22], "08 J3 crank (center disc + long boss)",
                 lsize, C_LINKAGE);
    leader_label(J2w + yawv(pitchv([crank_R, 0, 0], a)
                            + 0.5 * L1 * pitchv([1, 0, 0], j2)
                            + [0, link_y0 + 3 + 0.7 * e, 0], j1),
                 [10, 40, 30], "09 drive link (625 x2, L=225)",
                 lsize, C_LINKAGE);

    if (detail) {
        ds = lsize * 0.78;
        detail_leader_d = 0.45;
        sub = [
            // P01: carrier base plate, 200sq x t7, z=-arm_plate_t
            [[48, 32, -arm_plate_t / 2], [26, 22, -12], "P01", C_BASE],
            // P02: ground base plate, 200sq x t7, z=-2*t-base_lift
            [[-48, -32, -2 * arm_plate_t - base_lift], [-32, -22, -12], "P02", C_BASE],
            // P03: J1 ring housing, OD78/90 flange, 6810 seat z13..20
            [[0, -j1_ring_od / 2, 10], [-26, -28, 14], "P03", C_BASE],
            // P04: turret plate, t7 + d50 lower boss + J1 vane
            [yawv([-30, 30, turret_z0 + turret_t], j1), [-24, 30, 16], "P04", C_TOWER],
            // P05: +Y tower plate, t7, NEMA17 pilot d22
            [yawv([j2_fwd, tower_in_pos + arm_plate_t, zt + tower_j2_h], j1),
             [20, 32, 28], "P05", C_TOWER],
            // P06: -Y tower plate, t7, flipped pair
            [yawv([j2_fwd, tower_in_neg + arm_plate_t, zt + tower_j2_h], j1),
             [-26, -32, 24], "P06", C_TOWER],
            // P07: foot bracket x=feet_x[0], -Y side, L bracket t=tower_foot_t
            [yawv([feet_x[0], -tower_in_neg, zt + 10], j1), [-30, -18, 10], "P07", C_TOWER],
            // P08: foot bracket x=feet_x[1], -Y side, L bracket t=tower_foot_t
            [yawv([feet_x[1], -tower_in_neg, zt + 10], j1), [24, -18, 10], "P08", C_TOWER],
            // P09: foot bracket x=feet_x[0], +Y side, L bracket t=tower_foot_t
            [yawv([feet_x[0], tower_in_pos, zt + 10], j1), [-30, 18, 10], "P09", C_TOWER],
            // P10: foot bracket x=feet_x[1], +Y side, L bracket t=tower_foot_t
            [yawv([feet_x[1], tower_in_pos, zt + 10], j1), [24, 18, 10], "P10", C_TOWER],
            // P11: upper arm +Y side plate, L1=225, bend=15deg, t7
            [J2w + yawv([0.30 * L1, ua_out_y, 6], j1), [-18, 32, 18], "P11", C_UPPERARM],
            // P12: upper arm -Y side plate, L1=225, bend=15deg, t7
            [J2w + yawv([0.30 * L1, -ua_in_y, -6], j1), [-22, -32, -18], "P12", C_UPPERARM],
            // P13: J2 hub d56, 6805 boss, vane r47
            [J2w + yawv([0, -(ua_out_y + 4) - 0.5 * e, -12], j1),
             [-26, -34, -20], "P13",
             C_UPPERARM],
            // P14: forearm +Y side plate, L=275, bend=30deg, t7
            [Ew + 0.34 * forearm_len * fdir + yawv([0, fa_out, 0], j1),
             [18, 34, 14], "P14", C_FOREARM],
            // P15: forearm -Y side plate, L=275, bend=30deg, t7
            [Ew + 0.34 * forearm_len * fdir + yawv([0, -forearm_inner_w / 2, 0], j1),
             [20, -34, -14], "P15", C_FOREARM],
            // P16: J3 crank, d52 disc + d25 long boss + coupler flange
            [J2w + yawv(cpin + [0, crank_y0 + 3 + 0.9 * e, 0], j1),
             [28, 30, 18], "P16", C_LINKAGE],
            // P17: drive link, L=225, 625ZZ pockets both ends
            [J2w + yawv(cpin + 0.5 * L1 * pitchv([1, 0, 0], j2)
                        + [0, link_y0 + 3 + 0.7 * e, 0], j1),
             [16, 36, 24], "P17", C_LINKAGE],
            // F01: turret boss d50, 6810 inner race interface
            [yawv([0, 0, turret_z0 - 4 - 0.4 * e], j1), [40, -28, -14],
             "F01", C_TOWER],
            // F02: horn pin feature, R36.5 at horn_phase=155deg, forearm-integral
            [hpw + yawv([0, 0, 6], j1), [-18, 36, 26], "F02", C_FOREARM],
            // F03: forearm J3 limit vane, r=elbow_vane_r, width=elbow_vane_w
            [Ew + yawv(pitchv([elbow_vane_r, 0, 0], j3 + elbow_vane_a), j1),
             [24, -28, 18], "F03", C_FOREARM],
            // U01: utils/bearing_seat concept, J1 6810 outer seat d64.85 x w10
            [[0, 0, j1_ring_h - BRG_6810ZZ[2] + 5], [36, 10, 16], "U01", C_BEARING],
            // U02: utils/bearing_seat concept, upper arm 6805 seats d37 x2
            [J2w + yawv([0, 0, 14], j1), [-12, 28, 30], "U02", C_BEARING],
            // U03: utils/bearing_seat concept, elbow 608 seats d22 x2
            [Ew + yawv([0, 0, 16], j1), [-12, 30, 28], "U03", C_BEARING],
            // U04: utils/bearing_pocket concept, drive link 625 pockets d16 x2
            [J2w + yawv(cpin + [0, link_y0 + 6 + 0.7 * e, 0], j1),
             [32, 18, 16], "U04", C_BEARING],
            // U05: utils/bolt_hole pattern, base M6 standoff holes d6.6 x4
            [[base_corner_off, base_corner_off, -arm_plate_t / 2], [20, 20, 14], "U05", C_BOLT],
            // U06: utils/bolt_hole pattern, ring flange M4 holes r39 x4
            [[j1_ring_bolt_r, 0, 2], [24, 8, 16], "U06", C_BOLT],
            // U07: utils/coupler_mount_cut, J2 hub shaft/coupler clearance
            [J2w + yawv([0, -(ua_out_y + arm_plate_t + 1), 0], j1),
             [-30, -22, 18], "U07", C_COUPLER],
            // U08: utils/coupler_mount_cut, J3 crank flange mount M5 x4
            [J2w + yawv(cpin + [0, ua_out_y + crank_ofl_t + 0.9 * e, 0], j1),
             [30, 22, 18], "U08", C_COUPLER],
            // U09: utils/nut_pocket equivalent, drive link nut pockets d12 both ends
            [J2w + yawv(cpin + pitchv([L1, 0, 0], j2)
                        + [0, link_y0 + 3 + 0.7 * e, 0], j1),
             [30, -12, 20], "U09", C_BOLT],
            // U10: utils/cable_clip body, cable_d=8/t=6 in cable_clip_part
            [J2w + yawv([0.55 * L1, -ua_in_y - 12, 18], j1),
             [-18, -24, 22], "U10", C_CLIP],
        ];
        for (L = sub) leader_label(L[0], L[1], L[2], ds, L[3], detail_leader_d);

        stl = [
            // ST01: base standoff M6 L100, x=-base_corner_off y=-base_corner_off
            [[-base_corner_off, -base_corner_off, -arm_plate_t - base_lift / 2], [-18, -18, 12], "ST01", C_BOLT],
            // ST02: base standoff M6 L100, x=-base_corner_off y=+base_corner_off
            [[-base_corner_off, base_corner_off, -arm_plate_t - base_lift / 2], [-18, 18, 12], "ST02", C_BOLT],
            // ST03: base standoff M6 L100, x=+base_corner_off y=-base_corner_off
            [[base_corner_off, -base_corner_off, -arm_plate_t - base_lift / 2], [18, -18, 12], "ST03", C_BOLT],
            // ST04: base standoff M6 L100, x=+base_corner_off y=+base_corner_off
            [[base_corner_off, base_corner_off, -arm_plate_t - base_lift / 2], [18, 18, 12], "ST04", C_BOLT],
            // ST05: tower standoff M6 L105, p=tower_standoffs[0]
            [yawv([tower_standoffs[0][0], 0, zt + tower_standoffs[0][1]], j1), [-26, 0, 20], "ST05", C_BOLT],
            // ST06: tower standoff M6 L105, p=tower_standoffs[1]
            [yawv([tower_standoffs[1][0], 0, zt + tower_standoffs[1][1]], j1), [24, 0, 20], "ST06", C_BOLT],
            // ST07: tower standoff M6 L105, p=tower_standoffs[2]
            [yawv([tower_standoffs[2][0], 0, zt + tower_standoffs[2][1]], j1), [24, 0, -18], "ST07", C_BOLT],
            // ST08: upper arm standoff M6 L75, x=40
            [J2w + yawv([40, ua_in_y, arm_standoff_z], j1), [-18, 24, 14], "ST08", C_BOLT],
            // ST09: upper arm standoff M6 L75, x=100
            [J2w + yawv([100, ua_in_y, arm_standoff_z], j1), [0, 26, 14], "ST09", C_BOLT],
            // ST10: upper arm standoff M6 L75, x=160
            [J2w + yawv([160, ua_in_y, arm_standoff_z], j1), [18, 24, 14], "ST10", C_BOLT],
            // ST11: forearm standoff M6 L30, x=76
            [Ew + yawv(pitchv([76, 0, 0], j3) + [0, forearm_inner_w / 2, 0], j1),
             [16, 22, 12], "ST11", C_BOLT],
            // ST12: forearm standoff M6 L30, x=160
            [Ew + yawv(pitchv([160, 0, 0], j3) + [0, forearm_inner_w / 2, 0], j1),
             [18, 22, 12], "ST12", C_BOLT],
        ];
        for (L = stl) leader_label(L[0], L[1], L[2], ds, L[3], detail_leader_d);

        // A1: SF2422+MG17-G20 actuator, J1 hang under carrier plate
        leader_label([0, 0, -arm_plate_t - 60 - 0.8 * e], [-40, -28, -10],
                     "A1", ds, C_VITAMIN, detail_leader_d);
        // A2: SF2424+MG17-G20 actuator, J2 -Y tower, output +Y
        leader_label(J2w + yawv([0, -(tower_in_neg + 35) - 0.8 * e, 0], j1),
                     [-30, -34, 22], "A2",
                     ds, C_VITAMIN, detail_leader_d);
        // A3: SF2423+MG17-G20 actuator, J3 +Y tower, output -Y
        leader_label(J2w + yawv([0, tower_in_pos + 35 + 0.8 * e, 0], j1),
                     [26, 34, 22], "A3",
                     ds, C_VITAMIN, detail_leader_d);

        if (hw) {
            hwl = [
                // B01: 6810ZZ J1 slew bearing, d50/65 x 10
                [yawv([0, 0, turret_z0 + 3.5 + 0.6 * e], j1), [44, 24, 18],
                 "B01", C_BEARING],
                // B02: 6805ZZ J2 hub side bearing, d25/37 x 7
                [J2w + yawv([0, -ua_in_y, 6], j1), [-16, -40, 34], "B02", C_BEARING],
                // B03: 6805ZZ crank boss side bearing, d25/37 x 7
                [J2w + yawv([0, ua_out_y + 3.5, 6], j1), [-8, 44, 40], "B03", C_BEARING],
                // B04: 608ZZ elbow -Y bearing, d8/22 x 7
                [Ew + yawv([0, -ua_in_y, 6], j1), [-16, -38, 28], "B04", C_BEARING],
                // B05: 608ZZ elbow +Y bearing, d8/22 x 7
                [Ew + yawv([0, ua_out_y + 3.5, 6], j1), [12, 40, 32], "B05", C_BEARING],
                // B06: 625ZZ drive link crank-end bearing, d5/16 x 5
                [J2w + yawv(cpin + [0, link_y1 + 2 + 0.7 * e, 0], j1),
                 [30, 28, 26], "B06", C_BEARING],
                // B07: 625ZZ drive link horn-end bearing, d5/16 x 5
                [J2w + yawv(cpin + pitchv([L1, 0, 0], j2)
                            + [0, link_y0 + 2 + 0.7 * e, 0], j1),
                 [22, 32, 26], "B07", C_BEARING],
                // C01: J1 flange coupler, bore d8, body d25, flange d50
                [yawv([0, 0, turret_z0 - turret_boss_h - 3 - 0.4 * e], j1),
                 [34, -20, -12], "C01", C_COUPLER],
                // C02: J2 flange coupler, bore d8, body d25, flange d50
                [J2w + yawv([0, -(ua_out_y + arm_plate_t + 3) - 0.5 * e, 0], j1),
                 [-30, -22, 20], "C02", C_COUPLER],
                // C03: J3 flange coupler, bore d8, body d25, flange d50
                [J2w + yawv(cpin + [0, ua_out_y + crank_ofl_t + 3 + 0.9 * e, 0], j1),
                 [30, 22, 20], "C03", C_COUPLER],
                // SH01: elbow shoulder bolt d8 x 30, +Y side
                [Ew + yawv([0, ua_out_y + washer_t + 3 + 0.5 * e, 0], j1),
                 [28, 30, -24], "SH01", C_BOLT],
                // SH02: elbow shoulder bolt d8 x 30, -Y side
                [Ew + yawv([0, -(ua_out_y + washer_t + 3) - 0.5 * e, 0], j1),
                 [26, -30, -24], "SH02", C_BOLT],
                // SH03: horn pin shoulder bolt d5 x 30, forearm channel
                [hpw + yawv([0, fa_out - washer_t, 0], j1), [26, 18, 20], "SH03", C_BOLT],
                // SH04: crank pin shoulder bolt d5 x 16, crank disc to link
                [J2w + yawv(cpin + [0, crank_y0 + 2 + 0.9 * e, 0], j1),
                 [26, -18, 18], "SH04", C_BOLT],
                // SP01: elbow gap spacer d12 x 8, +Y side
                [Ew + yawv([0, fa_out + 0.5 * e, 0], j1), [20, 18, 14], "SP01", C_BOLT],
                // SP02: elbow gap spacer d12 x 8, -Y side
                [Ew + yawv([0, -fa_out - 0.5 * e, 0], j1), [20, -18, 14], "SP02", C_BOLT],
                // SP03: horn pin spacer d8 x horn_pin_spacer, +Y side
                [hpw + yawv([0, BRG_625ZZ[2] / 2 + 0.3, 0], j1), [22, 16, 14], "SP03", C_BOLT],
                // SP04: horn pin spacer d8 x horn_pin_spacer, -Y side
                [hpw + yawv([0, -(BRG_625ZZ[2] / 2 + 0.3), 0], j1), [22, -16, 14], "SP04", C_BOLT],
                // N01: M6 lock nut, +Y forearm side
                [Ew + yawv([0, forearm_inner_w / 2 - 1.2, 0], j1), [-22, 20, -14], "N01", C_BOLT],
                // N02: M6 lock nut, -Y forearm side
                [Ew + yawv([0, -(forearm_inner_w / 2 - 1.2), 0], j1), [-22, -20, -14], "N02", C_BOLT],
                // W01: washer d8, +Y elbow side, t=washer_t
                [Ew + yawv([0, ua_out_y + washer_t / 2 + 0.25 + 0.5 * e, 0], j1),
                 [18, 24, -18], "W01", C_WASHER],
                // W02: washer d8, -Y elbow side, t=washer_t
                [Ew + yawv([0, -(ua_out_y + washer_t / 2 + 0.25) - 0.5 * e, 0], j1),
                 [18, -24, -18], "W02", C_WASHER],
            ];
            for (L = hwl) leader_label(L[0], L[1], L[2], ds, L[3], detail_leader_d);

            bolts = [
                // BT01: base standoff top bolt M6 x 10, corner -x -y
                [[-base_corner_off, -base_corner_off, 0.3], [-14, -14, 18], "BT01", C_BOLT],
                // BT02: base standoff bottom bolt M6 x 10, corner -x -y
                [[-base_corner_off, -base_corner_off, -2 * arm_plate_t - base_lift - 0.3], [-14, -14, -18], "BT02", C_BOLT],
                // BT03: base standoff top bolt M6 x 10, corner -x +y
                [[-base_corner_off, base_corner_off, 0.3], [-14, 14, 18], "BT03", C_BOLT],
                // BT04: base standoff bottom bolt M6 x 10, corner -x +y
                [[-base_corner_off, base_corner_off, -2 * arm_plate_t - base_lift - 0.3], [-14, 14, -18], "BT04", C_BOLT],
                // BT05: base standoff top bolt M6 x 10, corner +x -y
                [[base_corner_off, -base_corner_off, 0.3], [14, -14, 18], "BT05", C_BOLT],
                // BT06: base standoff bottom bolt M6 x 10, corner +x -y
                [[base_corner_off, -base_corner_off, -2 * arm_plate_t - base_lift - 0.3], [14, -14, -18], "BT06", C_BOLT],
                // BT07: base standoff top bolt M6 x 10, corner +x +y
                [[base_corner_off, base_corner_off, 0.3], [14, 14, 18], "BT07", C_BOLT],
                // BT08: base standoff bottom bolt M6 x 10, corner +x +y
                [[base_corner_off, base_corner_off, -2 * arm_plate_t - base_lift - 0.3], [14, 14, -18], "BT08", C_BOLT],
                // BT09: J1 ring flange bolt M4 x 12, angle 0deg
                [[j1_ring_bolt_r, 0, 3 + 0.3 * e], [22, 0, 16], "BT09", C_BOLT],
                // BT10: J1 ring flange bolt M4 x 12, angle 90deg
                [[0, j1_ring_bolt_r, 3 + 0.3 * e], [0, 22, 16], "BT10", C_BOLT],
                // BT11: J1 ring flange bolt M4 x 12, angle 180deg
                [[-j1_ring_bolt_r, 0, 3 + 0.3 * e], [-22, 0, 16], "BT11", C_BOLT],
                // BT12: J1 ring flange bolt M4 x 12, angle 270deg
                [[0, -j1_ring_bolt_r, 3 + 0.3 * e], [0, -22, 16], "BT12", C_BOLT],
                // BT13: tower standoff bolt M6 x 10, standoff 0 -Y
                [yawv([tower_standoffs[0][0], -tower_in_neg - arm_plate_t, zt + tower_standoffs[0][1]], j1), [-18, -14, 18], "BT13", C_BOLT],
                // BT14: tower standoff bolt M6 x 10, standoff 0 +Y
                [yawv([tower_standoffs[0][0], tower_in_pos + arm_plate_t, zt + tower_standoffs[0][1]], j1), [-18, 14, 18], "BT14", C_BOLT],
                // BT15: tower standoff bolt M6 x 10, standoff 1 -Y
                [yawv([tower_standoffs[1][0], -tower_in_neg - arm_plate_t, zt + tower_standoffs[1][1]], j1), [18, -14, 18], "BT15", C_BOLT],
                // BT16: tower standoff bolt M6 x 10, standoff 1 +Y
                [yawv([tower_standoffs[1][0], tower_in_pos + arm_plate_t, zt + tower_standoffs[1][1]], j1), [18, 14, 18], "BT16", C_BOLT],
                // BT17: tower standoff bolt M6 x 10, standoff 2 -Y
                [yawv([tower_standoffs[2][0], -tower_in_neg - arm_plate_t, zt + tower_standoffs[2][1]], j1), [18, -14, -18], "BT17", C_BOLT],
                // BT18: tower standoff bolt M6 x 10, standoff 2 +Y
                [yawv([tower_standoffs[2][0], tower_in_pos + arm_plate_t, zt + tower_standoffs[2][1]], j1), [18, 14, -18], "BT18", C_BOLT],
                // BT19: upper arm standoff bolt M6 x 10, x=40 -Y
                [J2w + yawv([40, -(ua_out_y + 0.3), arm_standoff_z], j1), [-16, -18, 14], "BT19", C_BOLT],
                // BT20: upper arm standoff bolt M6 x 10, x=40 +Y
                [J2w + yawv([40, ua_out_y + 0.3, arm_standoff_z], j1), [-16, 18, 14], "BT20", C_BOLT],
                // BT21: upper arm standoff bolt M6 x 10, x=100 -Y
                [J2w + yawv([100, -(ua_out_y + 0.3), arm_standoff_z], j1), [0, -18, 14], "BT21", C_BOLT],
                // BT22: upper arm standoff bolt M6 x 10, x=100 +Y
                [J2w + yawv([100, ua_out_y + 0.3, arm_standoff_z], j1), [0, 18, 14], "BT22", C_BOLT],
                // BT23: upper arm standoff bolt M6 x 10, x=160 -Y
                [J2w + yawv([160, -(ua_out_y + 0.3), arm_standoff_z], j1), [16, -18, 14], "BT23", C_BOLT],
                // BT24: upper arm standoff bolt M6 x 10, x=160 +Y
                [J2w + yawv([160, ua_out_y + 0.3, arm_standoff_z], j1), [16, 18, 14], "BT24", C_BOLT],
                // BT25: J2 hub bolt M4 x 12, angle 90deg
                [J2w + yawv([hub_bolt_r_j2 * cos(90), -(ua_out_y + arm_plate_t) - 0.5 * e, hub_bolt_r_j2 * sin(90)], j1), [-20, -18, 18], "BT25", C_BOLT],
                // BT26: J2 hub bolt M4 x 12, angle 210deg
                [J2w + yawv([hub_bolt_r_j2 * cos(210), -(ua_out_y + arm_plate_t) - 0.5 * e, hub_bolt_r_j2 * sin(210)], j1), [-22, -18, -14], "BT26", C_BOLT],
                // BT27: J2 hub bolt M4 x 12, angle 330deg
                [J2w + yawv([hub_bolt_r_j2 * cos(330), -(ua_out_y + arm_plate_t) - 0.5 * e, hub_bolt_r_j2 * sin(330)], j1), [18, -18, -14], "BT27", C_BOLT],
                // BT28: forearm standoff bolt M6 x 10, x=76 -Y
                [Ew + yawv(pitchv([76, 0, 0], j3) + [0, -fa_out - 0.3, 0], j1), [16, -18, 14], "BT28", C_BOLT],
                // BT29: forearm standoff bolt M6 x 10, x=76 +Y
                [Ew + yawv(pitchv([76, 0, 0], j3) + [0, fa_out + 0.3, 0], j1), [16, 18, 14], "BT29", C_BOLT],
                // BT30: forearm standoff bolt M6 x 10, x=160 -Y
                [Ew + yawv(pitchv([160, 0, 0], j3) + [0, -fa_out - 0.3, 0], j1), [18, -18, 14], "BT30", C_BOLT],
                // BT31: forearm standoff bolt M6 x 10, x=160 +Y
                [Ew + yawv(pitchv([160, 0, 0], j3) + [0, fa_out + 0.3, 0], j1), [18, 18, 14], "BT31", C_BOLT],
            ];
            for (L = bolts) leader_label(L[0], L[1], L[2], ds, L[3], detail_leader_d);

            // 리미트 스위치 ×3 (적색 강조 — 레버형 KW12, 베인 감지)
            lsl = [
                // LS1: KW12 J1 limit switch, base plate top, lever up
                [yawv([0, -(turret_r - 8), 14], j1), [10, -34, 30],
                 "LS1", C_SWITCH],
                // LS2: KW12 J2 limit switch, -Y tower inner face
                [J2w + yawv([0, -tower_in_neg - 4, -j2_vane_r * 0.5], j1),
                 [-26, -30, -22], "LS2", C_SWITCH],
                // LS3: KW12 J3 limit switch, upper arm +Y plate
                [Ew + yawv([-elbow_ls_x, ua_in_y + 4, 0], j1), [18, 34, 20],
                 "LS3", C_SWITCH],
            ];
            for (L = lsl) leader_label(L[0], L[1], L[2], ds, L[3], detail_leader_d);
        }
    }
}

/* ===== 전체 로봇 ===== */
module robot(j1 = J1a, j2 = J2a, j3 = J3a,
             e = 0, labels = false, lsize = 3.2, hardware = true,
             label_detail = false) {
    hw = hardware;
    fold = j3 - j2;
    if (fold < env_fold_min || fold > env_fold_max)
        echo(str("경고: 접힘각 j3-j2 = ", fold, "° — 엔벨로프 [",
                 env_fold_min, ", ", env_fold_max,
                 "] 밖 (0° = 현 일직선 특이점, 하한 = 간섭 한계)"));
    if (j2 < env_j2_min || j2 > env_j2_max)
        echo(str("경고: j2 = ", j2, "° — 권고 범위 [", env_j2_min, ", ",
                 env_j2_max, "] 밖"));
    if (abs(j1) > env_j1)
        echo(str("경고: j1 = ", j1, "° — 권고 범위 ±", env_j1, " 밖"));

    base_static(e, hw);
    rotate([0, 0, j1]) {
        turret_group(e, hw);
        translate(j2_axis) arm_chain(j2, j3, e, hw);
    }
    if (labels) robot_labels(j1, j2, j3, e, lsize, label_detail, hw);
}

/* ===== 디스패치 (단독 실행 / CLI 간섭 검사) ===== */
if (check == 2) {
    // 팔꿈치 접힘: 상완 ∩ 하완
    intersection() {
        rotate([0, -J2a, 0]) ua_group();
        rotate([0, -J2a, 0]) translate([L1, 0, 0])
            rotate([0, -(J3a - J2a), 0]) fa_group();
    }
} else if (check == 3) {
    // J1 체인 전체 ∩ 고정부 (스탠드오프 포함 — hw=true)
    intersection() {
        base_static(0, true);
        rotate([0, 0, J1a]) {
            turret_group();
            translate(j2_axis) arm_chain(J2a, J3a);
        }
    }
} else if (check == 4) {
    // 링키지 ∩ (터릿·타워 + 상완 + 하완)
    intersection() {
        translate(j2_axis) linkage_group(J2a, J3a);
        union() {
            turret_group();
            translate(j2_axis) rotate([0, -J2a, 0]) {
                ua_group();
                translate([L1, 0, 0]) rotate([0, -(J3a - J2a), 0]) fa_group();
            }
        }
    }
} else if (check == 5) {
    // 암 전체 ∩ 터릿 그룹 (타워 스탠드오프 포함 — hw=true)
    intersection() {
        turret_group(0, true);
        translate(j2_axis) arm_chain(J2a, J3a);
    }
} else if (check == 0) {
    robot(J1a, J2a, J3a, labels = true);
}
