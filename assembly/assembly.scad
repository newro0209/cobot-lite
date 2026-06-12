// 전체 조립 모델 (full assembly) — 간섭 확인 + 시각화 (검수 기준 §12-1)
//
// 모듈형: robot(j1, j2, j3, j4, e, labels, lsize, hardware, label_detail)
// 컬러: 정적 부품 = 무채색 톤온톤, 동적 부품 = 카테고리별 톤온톤 (라벨 동색).
//
// CLI 간섭 검사 (자세는 -D J2a=... 로 지정):
//   openscad -D "check=1" -D "J2a=45" -D "J3a=-20" -o chk.stl assembly/assembly.scad
//   check=1: J2 회전 체인(액추에이터 포함) ∩ 고정부(베이스+턴테이블+어깨)
//   check=2: 하완 그룹 ∩ 상완 그룹 (3/4/5 = 하완/링크2/손목만)
//   → "Current top level object is empty" 또는 빈 STL = 통과
//
// 각도 규약: j2 = 상완 월드 피치(수평=0, 상향+), j3 = 하완 월드 피치.
// 평행사변형 기구학: 크랭크/혼 방향 = j3 + 90°, 손목은 항상 수평 (MEC-002).
// 가동 범위: j2 ∈ [-20°, +45°], j3 ∈ [-80°, +20°] (docs/design-notes.md §3)
include <../config/parameters.scad>
use <../lib/utils.scad>
use <../lib/vitamins.scad>
use <../parts/base.scad>
use <../parts/turntable.scad>
use <../parts/shoulder.scad>
use <../parts/upper_arm.scad>
use <../parts/j3_crank.scad>
use <../parts/forearm.scad>
use <../parts/drive_horn.scad>
use <../parts/rocker.scad>
use <../parts/wrist.scad>
use <../parts/tool_flange.scad>

/* ===== 단독 실행용 자세 (main.scad 경유 시 robot() 인자가 우선) ===== */
J1a = 0;    // 베이스 요(yaw), deg
J2a = 20;   // 어깨 피치, deg (월드 기준, 0 = 수평)
J3a = -40;  // 하완 피치, deg (월드 기준)
J4a = 0;    // 손목 롤, deg
check = 0;

/* ===== 카테고리 컬러 — lib/colors.scad ===== */
include <../lib/colors.scad>

/* ===== 파생 z 레벨 (base.scad / turntable.scad와 동일식, v0.15) ===== */
z_seat   = base_plate_t + j1_actuator_gap + motor_len_SF2424 + gbx_len_20to1
         + col_floor_t;                                  // 116
z_brg_lo = z_seat + col_core_h;                          // 146
col_top  = z_brg_lo + 2 * BRG_6810ZZ[2] + turntable_bearing_gap;   // 190
tt_top   = col_top + 2 + turntable_top_t;                // 200 (컵 숄더 2)
j2_z     = tt_top + j2_axis_h;                           // 290

/* ===== 링크 평면 (Y) ===== */
horn_in  = arm_inner_w / 2 + arm_plate_t + 3.5;    // 구동 혼/크랭크 암 내면
dl_y     = -(horn_in + crank_t + 0.5);             // 구동 링크 보스 내면
rocker_y = arm_inner_w / 2 + arm_plate_t + 1.5;    // 로커 허브 -Y면 (측판 외측)
pl1_y    = rocker_y + crank_t + 0.5;               // 링크 1 보스 내면 (47)
pl2_y    = pl1_y + BRG_625ZZ[2] + 4.5;             // 링크 2 보스 내면 (56.5)
ws_out   = forearm_inner_w / 2 + arm_plate_t + joint_side_tube + arm_plate_t; // 37

/* ===== 월드 좌표 헬퍼 (라벨 앵커 계산) ===== */
function rotz(p, a) = [p[0] * cos(a) - p[1] * sin(a),
                       p[0] * sin(a) + p[1] * cos(a), p[2]];
function pitchv(p, a) = [p[0] * cos(a) - p[2] * sin(a), p[1],
                         p[0] * sin(a) + p[2] * cos(a)];

// 상완 그룹 (상완 프레임 기준). e = 분해 거리 단위, hw = 베어링·체결류 목업
// (hw 기본 false — CLI 간섭 검사에서 면접촉 노이즈 배제)
module ua_group(j2 = J2a, j3 = J3a, e = 0, hw = false) {
    psi = j3 + 90 - j2;            // 크랭크/혼 방향 (상완 프레임)
    color(C_UPPERARM) upper_arm();
    color(C_VITAMIN) {
        translate([0, arm_inner_w / 2 + arm_plate_t, 0])
            rotate([90, 0, 0]) actuator_J2();
        translate([-rear_extension, -arm_inner_w / 2 - 2 * arm_plate_t, 0])
            rotate([90, 0, 0]) actuator_J3();
    }

    // J3 크랭크 (어댑터 외면 -44의 출력축에 클램프)
    color(C_CRANK)
    translate([-rear_extension, -(arm_inner_w / 2 + 2 * arm_plate_t + 2) - 0.6 * e, 0])
        rotate([90, 0, 0]) rotate([0, 0, psi]) j3_crank();

    // 구동 링크 (크랭크 핀 ↔ 하완 혼 핀, 상완과 평행)
    color(C_DRIVELINK)
    translate([-rear_extension + j3_crank_len * cos(psi),
               dl_y - 1.2 * e,
               j3_crank_len * sin(psi)])
        rotate([90, 0, 0]) link_bar(rear_extension + L1);

    // 수동 평행사변형 링크 1 (어깨 앵커 핀 ↔ 로커 핀, 상완과 평행)
    color(C_LINK1)
    translate([pl_offset * sin(j2), pl1_y + 0.8 * e, pl_offset * cos(j2)])
        rotate([-90, 0, 0]) link_bar(L1);

    // 로커 (팔꿈치, 월드 수평 유지: 핀 = 항상 연직 상방)
    color(C_ROCKER)
    translate([L1, rocker_y + 1.4 * e, 0])
        rotate([-90, 0, 0]) rotate([0, 0, j2 - 90]) rocker();

    fa_off = 0.8 * e * [cos(j3 - j2), 0, sin(j3 - j2)]; // 하완 분해 방향 (상완 프레임)
    if (hw) {
        color(C_BEARING) {
            // 팔꿈치 608ZZ ×2 — 하완 측판 압입 (관절 반전, 하완 추종)
            for (y = [-(forearm_inner_w / 2 + arm_plate_t), forearm_inner_w / 2])
                translate([L1 + fa_off[0], y, fa_off[2]])
                    rotate([-90, 0, 0]) bearing(BRG_608ZZ);
            translate([L1, rocker_y + 1.4 * e, 0])
                rotate([-90, 0, 0]) bearing(BRG_608ZZ);    // 로커 허브 608ZZ
            // 구동 링크 625ZZ ×2 (크랭크 핀·혼 핀) — 링크 추종 -1.2e
            for (px = [-rear_extension, L1])
                translate([px + j3_crank_len * cos(psi),
                           dl_y - 4.5 - BRG_625ZZ[2] / 2 - 1.2 * e,
                           j3_crank_len * sin(psi)])
                    rotate([-90, 0, 0]) bearing(BRG_625ZZ);
            // 평행 링크 1 625ZZ ×2 (앵커 핀·로커 핀) — 링크 추종 +0.8e
            for (px = [0, L1])
                translate([px + pl_offset * sin(j2), pl1_y + 2 + 0.8 * e,
                           pl_offset * cos(j2)])
                    rotate([-90, 0, 0]) bearing(BRG_625ZZ);
        }
        color(C_BOLT) {
            // J2 아이들 스트리퍼 볼트 ⌀8×25 (부시 관통 → 어깨 608 내륜, 발출 -0.5e)
            translate([0, -40 - 0.5 * e, 0]) rotate([-90, 0, 0]) shoulder_bolt(8, 25);
            translate([0, -12, 0]) rotate([-90, 0, 0]) lock_nut(m6_nut_af, 5, 6);
            // 팔꿈치 스트리퍼 볼트 ⌀8 L68 (샤프트) + M6 나일론 락 너트 (로커측)
            translate([L1, -25 - 0.5 * e, 0]) rotate([-90, 0, 0]) shoulder_bolt(8, 68);
            translate([L1, 45 + 1.4 * e, 0]) rotate([-90, 0, 0]) lock_nut(m6_nut_af, 5, 6);
            // 크랭크 핀 ⌀5 (크랭크 추종 -0.6e) / 혼 핀 ⌀5 (하완 추종 fa_off)
            translate([-rear_extension + j3_crank_len * cos(psi), -63.5 - 0.6 * e,
                       j3_crank_len * sin(psi)])
                rotate([-90, 0, 0]) shoulder_bolt(5, 10);
            translate([L1 + j3_crank_len * cos(psi) + fa_off[0], -57.5,
                       j3_crank_len * sin(psi) + fa_off[2]])
                rotate([-90, 0, 0]) shoulder_bolt(5, 10);
            // 로커 핀 숄더 볼트 ⌀5 L24 (링크 1·2 적층, 로커 추종)
            translate([L1 + pl_offset * sin(j2), pl2_y + 10 + 1.4 * e,
                       pl_offset * cos(j2)])
                rotate([90, 0, 0]) shoulder_bolt(5, 24);
            // 상완 육각 스탠드오프 M6 AF13 ×3 + M6×12 양측 (v0.15 배치)
            for (p = [[-44, 14], [-44, -14], [160, 0]]) {
                translate([p[0], arm_inner_w / 2, p[1]])
                    rotate([90, 0, 0]) hex_standoff(hex_standoff_af, arm_inner_w);
                for (sy = [-1, 1])
                    translate([p[0], sy * (arm_inner_w / 2 + arm_plate_t + 0.3),
                               p[1]])
                        rotate([sy * 90, 0, 0]) machine_bolt(6, 10);
            }
            // J3 어댑터 M4 ×2 + 너트 / J2 베인 핀 M3 (측판 A 외면)
            for (s = [-1, 1])
                translate([-rear_extension + s * 27,
                           -(arm_inner_w / 2 + 2 * arm_plate_t) - 0.3, 0])
                    rotate([-90, 0, 0]) machine_bolt(4, 16);
            translate([vane_pin_x, -(arm_inner_w / 2 + arm_plate_t) - 0.3, 0])
                rotate([-90, 0, 0]) machine_bolt(3, 12);
        }
        color(C_WASHER) {
            translate([L1, -26.5 - 0.5 * e, 0])
                rotate([-90, 0, 0]) washer(8);                  // 팔꿈치 머리측
            translate([L1, 43.6 + 1.4 * e, 0])
                rotate([-90, 0, 0]) washer(8);                  // 너트측 (로커 추종)
        }
    }
}

// 하완 고정 체결 (fa_group 보조 — 스탠드오프 + 혼 FHCS + 관절 베어링·튜브)
module fa_fix_bolts(j2, j3, e) {
    fo2 = forearm_inner_w / 2 + arm_plate_t;
    for (x = [76, 160]) {
        color(C_BOLT) {
            translate([0.8 * e + x, forearm_inner_w / 2, 0])
                rotate([90, 0, 0])
                    hex_standoff(hex_standoff_af, forearm_inner_w);
            for (sy = [-1, 1])
                translate([0.8 * e + x, sy * (fo2 + 0.3), 0])
                    rotate([sy * 90, 0, 0]) machine_bolt(6, 10);
        }
    }
    // 구동 혼 M4 FHCS ×3 (-Y측에서 셀프태핑, 혼 추종)
    color(C_BOLT)
    for (a = [60, 180, 300])
        translate([0.8 * e + 17 * cos(a), -36 - 0.4 * e, 17 * sin(a)])
            rotate([-90, 0, 0]) machine_bolt(4, 14);
    // 손목 피치 608ZZ ×2 — 하완 측판 압입
    color(C_BEARING)
    for (y = [-fo2, forearm_inner_w / 2])
        translate([0.8 * e + forearm_len, y, 0])
            rotate([-90, 0, 0]) bearing(BRG_608ZZ);
    // 팔꿈치·손목 내측 스페이서 튜브 ⌀12 (숄더 볼트 위, 내륜 간격)
    color(C_BOLT)
    for (x = [0, forearm_len])
        translate([0.8 * e + x, forearm_inner_w / 2, 0]) rotate([90, 0, 0])
            difference() {
                cylinder(d = joint_spacer_od, h = forearm_inner_w);
                translate([0, 0, -1]) cylinder(d = 8.4, h = forearm_inner_w + 2);
            }
}

// 하완 그룹 (하완 프레임 기준)
// sel: 0=전체, 1=하완만, 2=링크2만, 3=손목 그룹만 (간섭 원인 분리용)
module fa_group(j2 = J2a, j3 = J3a, j4 = J4a, e = 0, sel = 0, hw = false) {
    if (sel == 0 || sel == 1) {
        color(C_FOREARM) translate([0.8 * e, 0, 0]) forearm();
        // 구동 혼 (볼트온, -Y 측판 외면 — 분해 시 하완 추종 + -Y 발출)
        color(C_FOREARM)
        translate([0.8 * e, -(forearm_inner_w / 2 + arm_plate_t) - 0.4 * e, 0])
            rotate([90, 0, 0]) rotate([0, 0, 90]) drive_horn();
        if (hw) fa_fix_bolts(j2, j3, e);
    }

    // 수동 평행사변형 링크 2 (로커 핀 ↔ 손목 혼 핀, 하완과 평행)
    if (sel == 0 || sel == 2)
        color(C_LINK2)
        translate([pl_offset * sin(j3), pl2_y + 1.8 * e, pl_offset * cos(j3)])
            rotate([-90, 0, 0]) link_bar(forearm_len);

    // 손목 (수동 평행사변형이 수평 유지, MEC-002)
    if (sel == 0 || sel == 3)
    translate([forearm_len + 2.4 * e, 0, 0]) rotate([0, j3, 0]) {
        color(C_WRIST) wrist();
        // J4 액추에이터 — 바텀 플레이트 위 직립, 출력축 하향
        color(C_VITAMIN)
        translate([wrist_offset, 0, -(arm_lug_r + 4) + 0.8 * e])
            rotate([180, 0, 0]) actuator_J4();
        // 공구 플랜지 — 바텀 6805에 스템 안착 (디스크 상면 ↔ 바텀 하면 갭 1.5)
        color(C_FLANGE)
        translate([wrist_offset, 0,
                   -(arm_lug_r + 4) - arm_plate_t - 1.5 - flange_t - 0.8 * e])
            rotate([0, 0, j4]) tool_flange();
        // 페이로드 참조 (1kg 그리퍼+공작물, PER-001)
        %translate([wrist_offset, 0, -135 - 0.8 * e]) cylinder(d = 50, h = 85);

        if (hw) {
            color(C_BEARING)
                translate([wrist_offset, 0, -(arm_lug_r + 4) - arm_plate_t])
                    bearing(BRG_6805ZZ);                     // 플랜지 허브 6805ZZ
            color(C_BOLT) {
                // 손목 피치 스트리퍼 볼트 ⌀8 L80 (샤프트) + M6 나일론 락 너트
                translate([0, -43, 0]) rotate([-90, 0, 0]) shoulder_bolt(8, 80);
                translate([0, 38, 0]) rotate([-90, 0, 0]) lock_nut(m6_nut_af, 5, 6);
                // 손목 혼 핀 ⌀5×20 + 튜브 ⌀8×15 (패들 외면 → link2 평면)
                translate([0, ws_out + arm_plate_t, pl_offset])
                    rotate([-90, 0, 0]) shoulder_bolt(5, 20);
                translate([0, ws_out + arm_plate_t, pl_offset])
                    rotate([-90, 0, 0]) difference() {
                        cylinder(d = 8, h = 15);
                        translate([0, 0, -1]) cylinder(d = 5.4, h = 17);
                    }
                // 혼 패들 M4 ×2 + 너트
                for (s = [-1, 1])
                    translate([s * 10, ws_out + arm_plate_t + 0.3, 22])
                        rotate([90, 0, 0]) machine_bolt(4, 16);
                // 손목 스탠드오프 M6 AF13 L60 ×2 + M6×10 양측
                for (sz = [-1, 1]) {
                    translate([20, ws_out - arm_plate_t, sz * 30])
                        rotate([90, 0, 0])
                            hex_standoff(hex_standoff_af, 2 * (ws_out - arm_plate_t));
                    for (sy = [-1, 1])
                        translate([20, sy * (ws_out + 0.3), sz * 30])
                            rotate([sy * 90, 0, 0]) machine_bolt(6, 10);
                }
            }
            color(C_WASHER) translate([0, -44.5, 0]) rotate([-90, 0, 0]) washer(8);
        }
    }

    // 평행 링크 2 625ZZ ×2 (로커 핀·손목 혼 핀) — 링크 2 추종 +1.8e
    if (hw && (sel == 0 || sel == 2))
        color(C_BEARING)
        for (px = [0, forearm_len])
            translate([px + pl_offset * sin(j3), pl2_y + 2 + 1.8 * e,
                       pl_offset * cos(j3)])
                rotate([-90, 0, 0]) bearing(BRG_625ZZ);
}

// J2 축 기준 회전 체인 전체
module j2_chain(j2 = J2a, j3 = J3a, j4 = J4a, e = 0, hw = false) {
    rotate([0, -j2, 0]) {
        ua_group(j2, j3, e, hw);
        translate([L1, 0, 0]) rotate([0, -(j3 - j2), 0])
            fa_group(j2, j3, j4, e, 0, hw);
    }
}

// 고정부 (J1 프레임 — 턴테이블·어깨는 J1과 함께 회전)
module statics(e = 0, hw = false) {
    color(C_TURNTABLE) translate([0, 0, tt_top + 0.6 * e]) turntable();
    color(C_SHOULDER) translate([0, 0, j2_z + 1.2 * e]) shoulder();

    if (hw) {
        color(C_BEARING) {
            // 턴테이블 6810ZZ ×2 (베이스 포스트 랜드): 하부 0.2e / 상부 0.5e
            translate([0, 0, z_brg_lo + 0.2 * e]) bearing(BRG_6810ZZ);
            translate([0, 0, col_top - BRG_6810ZZ[2] + 0.5 * e]) bearing(BRG_6810ZZ);
            // J2 아이들 608ZZ ×2 (-Y 어깨 측판 관통 압입) — 어깨 추종 1.2e
            for (y = [-tongue_w / 2, -tongue_w / 2 + BRG_608ZZ[2]])
                translate([0, y, j2_z + 1.2 * e])
                    rotate([-90, 0, 0]) bearing(BRG_608ZZ);
        }
        color(C_BOLT) {
            // 어깨 풋 탭 M5 ×4 (탭+플랜지+턴테이블 디스크 일괄 클램프) + 플랜지 M5 ×2
            for (x = [-1, 1], y = [-1, 1])
                translate([x * shoulder_mount_px / 2, y * shoulder_mount_py / 2,
                           j2_z - j2_axis_h + 24 + 1.2 * e])
                    rotate([180, 0, 0]) machine_bolt(5, 35);
            for (y = [-1, 1])
                translate([0, y * 25, j2_z - j2_axis_h + 8 + 1.2 * e])
                    rotate([180, 0, 0]) machine_bolt(5, 20);
            // 어깨 스탠드오프 M6 AF13 L30 ×4 + M6×12 양측 (머리 카운터보어 플러시)
            for (sx = [-1, 1], sz = [-1, 1]) {
                translate([sx * 32, tongue_w / 2 - sh_plate_t, j2_z + sz * 50 + 1.2 * e])
                    rotate([90, 0, 0])
                        hex_standoff(hex_standoff_af, fork_standoff_len);
                for (sy = [-1, 1])
                    translate([sx * 32, sy * (tongue_w / 2 - 6), j2_z + sz * 50 + 1.2 * e])
                        rotate([sy * 90, 0, 0]) machine_bolt(6, 12);
            }
            // 클램프 디스크 M4 FHCS ×4 (포크 내측에서 +Y 체결)
            for (a = [45 : 90 : 359])
                translate([13 * cos(a), 9 - 0.3, j2_z + 13 * sin(a) + 1.2 * e])
                    rotate([-90, 0, 0]) machine_bolt(4, 18);
            // 앵커 M4 ×2 + 스페이서 튜브 ⌀8×10 + 정적 핀 (스트리퍼 5×10 + 튜브 ⌀8×4)
            for (p = [[-40, -5], [-33, 23]]) {
                translate([p[0], 50 + 0.3, j2_z + p[1] + 1.6 * e])
                    rotate([90, 0, 0]) machine_bolt(4, 25);
                translate([p[0], tongue_w / 2, j2_z + p[1] + 1.6 * e])
                    rotate([-90, 0, 0]) difference() {
                        cylinder(d = 8, h = 10);
                        translate([0, 0, -1]) cylinder(d = 4.4, h = 12);
                    }
            }
            translate([0, 56, j2_z + pl_offset + 1.6 * e])
                rotate([90, 0, 0]) shoulder_bolt(5, 10);
            // J1 스템·J4 결합 무두 볼트는 액세스 홀 내부 — 목업 생략
        }
    }
}

// 부품 라벨 (지시선 + 빌보드, 월드 프레임) — 순번 = 조립 순서
module robot_labels(j1, j2, j3, j4, e, lsize, detail = false, hw = false) {
    O    = [0, 0, j2_z + 2.0 * e];
    adir = [cos(j2), 0, sin(j2)];
    fdir = [cos(j3), 0, sin(j3)];
    psi  = j3 + 90;
    Ew   = O + L1 * adir;
    Ww   = Ew + (forearm_len + 2.4 * e) * fdir;
    faw  = 0.8 * e * fdir;

    // ── 정적 (무채색 톤온톤) ──
    leader_label([70, 0, 12], [30, -20, 30],
                 "01 base (J1 post 6810ZZx2)", lsize, C_BASE);
    leader_label([0, -26, z_seat - 3], [-35, -30, -10],
                 "02 J1 mount disc (NEMA17)", lsize, C_BASE);
    leader_label(rotz([0, 50, tt_top + 0.6 * e], j1), [25, 25, 30],
                 "03 turntable (cup+stem)", lsize, C_TURNTABLE);
    leader_label(rotz([0, -34, j2_z - 50 + 1.2 * e], j1), [10, -45, 5],
                 "04 shoulder (plate x2 identical)", lsize, C_SHOULDER);

    // ── 동적 (카테고리 톤온톤) ──
    leader_label(rotz(O + 0.55 * L1 * adir + [0, 36, 10], j1), [-10, 35, 35],
                 "05 upper arm (plate x2 identical, L1=225)", lsize, C_UPPERARM);
    leader_label(rotz(O + pitchv([-rear_extension, 0, 0], j2)
                      + [0, -55 - 0.6 * e, 0], j1), [-30, -30, 25],
                 "06 J3 crank (r=40)", lsize, C_CRANK);
    leader_label(rotz(O + pitchv([-rear_extension, 0, 0], j2)
                      + j3_crank_len * [cos(psi), 0, sin(psi)]
                      + 0.35 * (rear_extension + L1) * adir
                      + [0, dl_y - 4.5 - 1.2 * e, 0], j1), [-15, -40, -30],
                 "07 drive link (305)", lsize, C_DRIVELINK);
    leader_label(rotz(O + [0, pl1_y + 4.5 + 0.8 * e, pl_offset] + 0.45 * L1 * adir,
                      j1), [-15, 40, 35],
                 "08 link 1 (225)", lsize, C_LINK1);
    leader_label(rotz(Ew + [0, rocker_y + 6 + 1.4 * e, 15], j1), [20, 45, 40],
                 "09 rocker (608ZZ)", lsize, C_ROCKER);
    leader_label(rotz(Ew + [0, pl2_y + 4.5 + 1.8 * e, pl_offset]
                      + 0.5 * forearm_len * fdir, j1), [15, 40, 30],
                 "10 link 2 (225)", lsize, C_LINK2);
    leader_label(rotz(Ew + faw + 0.5 * forearm_len * fdir + [0, -22, 0], j1),
                 [10, -45, 25], "11 forearm (plate x2 identical, 225)", lsize, C_FOREARM);
    leader_label(rotz(Ww + [20, 34, 10], j1), [25, 35, 15],
                 "12 wrist (side x2 identical)", lsize, C_WRIST);
    leader_label(rotz(Ww + [wrist_offset + 22, 0, -44 - 0.8 * e], j1),
                 [35, 15, -15], "13 tool flange (BC32 M4x4)", lsize, C_FLANGE);

    // ── 세부 라벨 (detail): 서브 피처 + 하드웨어 ──
    if (detail) {
        ds = lsize * 0.78;
        Cp  = O + pitchv([-rear_extension, 0, 0], j2);            // J3 크랭크 축
        Pc  = Cp + j3_crank_len * [cos(psi), 0, sin(psi)];        // 크랭크 핀
        Ph  = Ew + j3_crank_len * [cos(psi), 0, sin(psi)];        // 구동 혼 핀
        Pr  = Ew + pl_offset * [0, 0, 1];                          // 로커 핀
        Pw  = Ww + pl_offset * [0, 0, 1];                          // 손목 혼 핀

        sub = [
            // 어깨 (동일 측판 + 볼트온 소부품)
            [[0, 22, j2_z + 30 + 1.2 * e],   [-18, 36, 40], "04a side plate x2 (t14)", C_SHOULDER],
            [[0, 12, j2_z + 1.2 * e],        [-26, 30, -16], "04b clamp disc (slit+M3 pinch)", C_SHOULDER],
            [[0, 43, j2_z + pl_offset + 1.6 * e], [-22, 28, 28], "04c anchor (M4x2+tube)", C_SHOULDER],
            [[42, -28, j2_z - j2_axis_h + 6 + 1.2 * e], [22, -30, 8], "04d base flange (tab slot)", C_SHOULDER],
            [[34, -52, j2_z + 40 + 1.2 * e], [16, -34, 26], "04e J2 limit pad (M2x2)", C_SHOULDER],
            // 상완
            [O + pitchv([-40, 0, 0], j2) + [0, -36, 0], [-25, -35, 18], "05a side plate A=B (t7)", C_UPPERARM],
            [Cp + [0, -42, 8],   [-22, -34, 26], "05b J3 motor adapter (boss+M4x2)", C_UPPERARM],
            [O + [0, -40, -6],   [-24, -32, -20], "05c idle bush (flange+spigot)", C_UPPERARM],
            [O + pitchv([vane_pin_x, 0, 0], j2) + [0, -40, 0], [-8, -36, -24], "05d vane pin M3 (J2 limit)", C_UPPERARM],
            // 하완/혼
            [Ph + faw + (Ew - Ph) * 0.3 + [0, -40, 0], [-12, -33, 26], "11a drive horn (bolt-on FHCS x3)", C_FOREARM],
            // 손목
            [Ww + [0, -33, 6],   [-22, -36, 14], "12a side plate x2 (t7)", C_WRIST],
            [Ww + [0, 42, pl_offset - 10], [16, 33, 26], "12b horn paddle (M4x2)", C_WRIST],
            [Ww + [wrist_offset + 20, -24, -34], [24, -26, -12], "12c bottom plate (J4 NEMA+6805)", C_WRIST],
            [Ww + [20, 36, 30],  [12, 30, 24],  "12d hex standoff M6 L60 x2", C_WRIST],
            // 플랜지
            [Ww + [wrist_offset + flange_d / 2 - 3, 0, -42 - 0.8 * e], [26, -18, -12], "13a edge chamfer", C_FLANGE],
            [Ww + [wrist_offset + 10, 6, -34 - 0.8 * e], [30, 16, 6], "13b hub stem (6805 bore)", C_FLANGE],
        ];
        for (L = sub) leader_label(rotz(L[0], j1), L[1], L[2], ds, L[3]);

        // 하드웨어 인스턴스 (구매품 무채 톤온톤) — hw 표시 시에만
        if (hw) {
            hwl = [
                [[33, 0, z_brg_lo + 3 + 0.2 * e],  [38, -16, -10], "H01 6810ZZ lower", C_BEARING],
                [[33, 0, col_top - 4 + 0.5 * e],   [42, -14, 8],   "H02 6810ZZ upper", C_BEARING],
                [[0, -27, j2_z + 9 + 1.2 * e],  [-16, -42, 30], "H03 608ZZ J2 in", C_BEARING],
                [[0, -19, j2_z + 9 + 1.2 * e],  [-4, -46, 40],  "H04 608ZZ J2 out", C_BEARING],
                [O + [0, -42 - 0.5 * e, -2],    [-26, -34, -22], "H05 stripper 8x25 J2 idle (shaft)", C_BOLT],
                [O + [0, -12, 6],               [-30, -28, 18],  "H06 M6 lock nut J2 (nylock)", C_BOLT],
                [[0, 58, j2_z + pl_offset + 1.6 * e], [-12, 34, 18], "H07 stripper 5x10 anchor pin + tube 8x4", C_BOLT],
                [Ew + [0, -29 - 0.5 * e, -6],  [-26, -30, -28], "H08 stripper 8x68 elbow (shaft)", C_BOLT],
                [Ew + [0, -12, 6],   [-20, -42, 36],  "H09 608ZZ elbow in", C_BEARING],
                [Ew + [0, 12, 6],    [-6, 46, 44],    "H10 608ZZ elbow out", C_BEARING],
                [Ew + [0, 35 + 1.4 * e, 5],    [10, 50, 36],  "H11 608ZZ rocker", C_BEARING],
                [Ew + [0, 48 + 1.4 * e, 0],    [34, 26, -38], "H12 M6 lock nut elbow (nylock)", C_BOLT],
                [Pc + [0, -66 - 0.6 * e, 0],   [-32, -22, -14], "H13 stripper 5x10 crank (shaft)", C_BOLT],
                [Pc + [0, -54 - 1.2 * e, 0],   [-26, -30, 14],  "H14 625ZZ dlink crank", C_BEARING],
                [Ph + [0, -54 - 1.2 * e, 0],   [-10, -34, -22], "H15 625ZZ dlink horn", C_BEARING],
                [Ph + faw + [0, -60, 0],       [-22, -28, -34], "H16 stripper 5x10 horn (shaft)", C_BOLT],
                [O + [0, 49 + 0.8 * e, pl_offset],  [-18, 38, 30], "H17 625ZZ link1 gnd", C_BEARING],
                [Pr + [0, 49 + 0.8 * e, 0],    [4, 44, 42],   "H18 625ZZ link1 rkr", C_BEARING],
                [Pr + [0, pl2_y + 4.5 + 1.8 * e, 0], [18, 40, 30], "H19 625ZZ link2 rkr", C_BEARING],
                [Pr + [0, pl2_y + 9 + 1.4 * e, 0],   [32, 34, 16], "H20 stripper 5x24 rocker (shaft)", C_BOLT],
                [Pw + [0, pl2_y + 4.5 + 1.8 * e, 0], [16, 40, 28], "H21 625ZZ link2 wrist", C_BEARING],
                [Pw + [0, ws_out + 12, 0],           [30, 34, 14], "H22 stripper 5x20 whorn + tube 8x15", C_BOLT],
                [Ww + [0, -29, -4],  [-22, -32, -20], "H23 stripper 8x80 wrist (shaft)", C_BOLT],
                [Ww + [0, -12, 7],   [-14, -40, 30],  "H24 608ZZ wrist in", C_BEARING],
                [Ww + [0, 12, 7],    [-2, 42, 38],    "H25 608ZZ wrist out", C_BEARING],
                [Ww + [0, 39, 0],    [12, 44, -18],   "H26 M6 lock nut wrist (nylock)", C_BOLT],
                [Ww + [wrist_offset - 13, -9, -34], [-28, -28, -10], "H27 6805ZZ flange hub", C_BEARING],
                [[32, 25, j2_z + 50 + 1.2 * e], [28, 30, 22], "H28 hex standoff M6x4 shoulder (fix)", C_BOLT],
                [O + [0, 8, 10], [-26, 30, 36], "H29 M4 FHCS x4 clamp disc (fix)", C_BOLT],
                [Ew + faw + pitchv([76, 0, 0], j3) + [0, 20, 0],
                     [10, 36, 18], "H30 hex standoff M6x2 forearm (fix)", C_BOLT],
                [Ew + faw + pitchv([-15, 0, 9], j3) + [0, -38 - 0.4 * e, 0],
                     [-30, -26, 10], "H31 M4x3 FHCS horn mount (fix)", C_BOLT],
                [O + pitchv([-44, 0, 14], j2) + [0, 24, 0],
                     [-16, 40, 28], "H32 hex standoff M6x3 arm (fix)", C_BOLT],
                [Cp + [0, -48, 14], [-24, -30, 30], "H33 M4x2 adapter+nut (fix)", C_BOLT],
                [O + pitchv([vane_pin_x, 0, 0], j2) + [0, -41, 0],
                     [-4, -38, -28], "H34 M3 vane pin (J2 limit)", C_BOLT],
                [[-40, 48, j2_z - 5 + 1.6 * e], [-28, 26, 12], "H35 M4x2 SHCS + tube anchor (fix)", C_BOLT],
                [[40, 25, j2_z - j2_axis_h + 24 + 1.2 * e], [30, 24, 12],
                     "H36 M5x4 tab bolt thru turntable (fix)", C_BOLT],
                [[0, 25, j2_z - j2_axis_h + 8 + 1.2 * e], [-22, 28, 8],
                     "H37 M5x2 flange bolt (fix)", C_BOLT],
                [[30, 30, z_seat + 8], [36, 24, 14], "H38 set screw M4x2 J1 stem (fix)", C_BOLT],
                [Ww + [wrist_offset, 20, -42], [20, 38, -8], "H39 set screw M4x2 J4 hub (fix)", C_BOLT],
                [Ww + [20, 40, -30], [24, 32, -16], "H40 M3x4 bottom edge screw (fix)", C_BOLT],
            ];
            for (L = hwl) leader_label(rotz(L[0], j1), L[1], L[2], ds, L[3]);
            leader_label([base_bolt_pitch / 2, base_bolt_pitch / 2, 12],
                         [26, 18, 22], "H41 M5x4 bolt base anchor (fix)", ds, C_BOLT);
        }

        // 액추에이터 (모터+기어박스)
        act = [
            [O + [0, 110, 0],  [22, 42, 30],  "A2 SF2424+MG17-G20 (J2)"],
            [O + pitchv([-rear_extension, 0, 0], j2) + [0, 48, 0],
                 [-26, 36, 26], "A3 SF2423+MG17-G20 (J3)"],
            [Ww + [wrist_offset, 0, 28], [26, 24, 30], "A4 SF2422+MG17-G5 (J4)"],
        ];
        for (L = act) leader_label(rotz(L[0], j1), L[1], L[2], ds, C_VITAMIN);
        leader_label([0, -24, z_seat - 40], [-34, -28, -6],
                     "A1 SF2424+MG17-G20 (J1)", ds, C_VITAMIN);
    }
}

// 전체 로봇. e = 분해 거리 단위(mm), labels = 라벨, hardware = 체결류 목업
module robot(j1 = J1a, j2 = J2a, j3 = J3a, j4 = J4a,
             e = 0, labels = false, lsize = 3.2, hardware = true,
             label_detail = false) {
    hw = hardware;
    if (j3 - j2 < env_fold_min || j3 - j2 > env_fold_max)
        echo(str("경고: 접힘각 j3-j2 = ", j3 - j2, "° — 운용 엔벨로프 [",
                 env_fold_min, ", ", env_fold_max,
                 "] 밖 (특이점/간섭 위험, design-notes §3)"));
    color(C_BASE) base();
    color(C_BASE) translate([0, 0, z_seat - col_floor_t + 0.3 * e]) j1_disc();
    if (hw) color(C_BOLT)
        for (x = [-1, 1], y = [-1, 1])
            translate([x * base_bolt_pitch / 2, y * base_bolt_pitch / 2,
                       base_plate_t])
                rotate([180, 0, 0]) machine_bolt(5, 12);
    rotate([0, 0, j1]) {
        statics(e, hw);
        translate([0, 0, j2_z + 2.0 * e]) j2_chain(j2, j3, j4, e, hw);
    }
    if (labels) robot_labels(j1, j2, j3, j4, e, lsize, label_detail, hw);
}

/* ===== 디스패치 (단독 실행 / CLI 간섭 검사) ===== */
if (check == 1) {
    intersection() {
        rotate([0, 0, J1a]) translate([0, 0, j2_z]) j2_chain(J2a, J3a, J4a);
        union() { base(); rotate([0, 0, J1a]) statics(); }
    }
} else if (check >= 2 && check <= 5) {
    intersection() {
        rotate([0, -J2a, 0]) ua_group(J2a, J3a);
        rotate([0, -J2a, 0]) translate([L1, 0, 0])
            rotate([0, -(J3a - J2a), 0]) fa_group(J2a, J3a, J4a, 0, check - 2);
    }
} else {
    robot(J1a, J2a, J3a, J4a, labels = true);
}
