// 전체 조립 모델 (full assembly) — 간섭 확인 + 시각화 (검수 기준 §12-1)
//
// 모듈형: robot(j1, j2, j3, j4, e, labels, lsize) — main.scad에서 자세/분해/라벨 제어.
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
// 가동 범위 (간섭 검사 결과, docs/design-notes.md §3):
//   j2 ∈ [-20°, +45°], j3 ∈ [-80°, +20°], 접힘각 j3-j2 ∈ [-95°, +40°]
include <../config/parameters.scad>
use <../lib/utils.scad>
use <../lib/vitamins.scad>
use <../parts/base.scad>
use <../parts/turntable.scad>
use <../parts/turntable_spacer.scad>
use <../parts/shoulder.scad>
use <../parts/pl_anchor.scad>
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

/* ===== 카테고리 컬러 — lib/colors.scad (정적: 무채색 / 동적: 카테고리 톤온톤) ===== */
include <../lib/colors.scad>

/* ===== 파생 z 레벨 (base.scad와 동일식) ===== */
z_flange    = base_plate_t + j1_actuator_gap + motor_len_SF2424 + gbx_len_20to1;
z_floor_top = z_flange + arm_plate_t;
z_brg_lo    = z_floor_top + col_open_h;
col_top     = z_brg_lo + 2 * BRG_6810ZZ[2] + turntable_bearing_gap;
tt_top      = col_top + turntable_top_t;
j2_z        = tt_top + j2_axis_h;

/* ===== 링크 평면 (Y) ===== */
horn_in   = arm_inner_w / 2 + arm_plate_t + 3.5;   // 구동 혼/크랭크 암 내면
dl_y      = -(horn_in + crank_t + 0.5);            // 구동 링크 보스 내면 (+와셔 간극)
rocker_y  = arm_inner_w / 2 + arm_plate_t + 1.5;   // 로커 허브 -Y면 (측판 B 외측)
pl1_y     = rocker_y + crank_t + 0.5;              // 링크 1 보스 내면
pl2_y     = pl1_y + BRG_625ZZ[2] + 4.5;            // 링크 2 보스 내면 (적층)

/* ===== 월드 좌표 헬퍼 (라벨 앵커 계산) ===== */
function rotz(p, a) = [p[0] * cos(a) - p[1] * sin(a),
                       p[0] * sin(a) + p[1] * cos(a), p[2]];
function pitchv(p, a) = [p[0] * cos(a) - p[2] * sin(a), p[1],
                         p[0] * sin(a) + p[2] * cos(a)];

// 상완 그룹 (상완 프레임 기준). e = 분해 거리 단위, hw = 베어링·체결류 목업
// (hw 기본 false — CLI 간섭 검사에서 베어링 보어/볼트 면접촉 노이즈 배제)
module ua_group(j2 = J2a, j3 = J3a, e = 0, hw = false) {
    psi = j3 + 90 - j2;            // 크랭크/혼 방향 (상완 프레임)
    color(C_UPPERARM) upper_arm();
    color(C_VITAMIN) {
        translate([0, arm_inner_w / 2 + arm_plate_t, 0])
            rotate([90, 0, 0]) actuator_J2();
        translate([-rear_extension, -arm_inner_w / 2, 0])
            rotate([90, 0, 0]) actuator_J3();
    }

    // J3 크랭크 (방향 = j3 + 90°, 상완 프레임 상대각)
    color(C_CRANK)
    translate([-rear_extension, -(arm_inner_w / 2 + arm_plate_t + 2) - 0.6 * e, 0])
        rotate([90, 0, 0]) rotate([0, 0, j3 + 90 - j2]) j3_crank();

    // 구동 링크 (크랭크 핀 ↔ 하완 혼 핀, 상완과 평행)
    color(C_DRIVELINK)
    translate([-rear_extension + j3_crank_len * cos(j3 + 90 - j2),
               dl_y - 1.2 * e,
               j3_crank_len * sin(j3 + 90 - j2)])
        rotate([90, 0, 0]) link_bar(rear_extension + L1);

    // 수동 평행사변형 링크 1 (어깨 정적 핀 ↔ 로커 핀, 상완과 평행)
    color(C_LINK1)
    translate([pl_offset * sin(j2), pl1_y + 0.8 * e, pl_offset * cos(j2)])
        rotate([-90, 0, 0]) link_bar(L1);

    // 로커 (팔꿈치, 월드 수평 유지: 핀 = 항상 연직 상방)
    color(C_ROCKER)
    translate([L1, rocker_y + 1.4 * e, 0])
        rotate([-90, 0, 0]) rotate([0, 0, j2 - 90]) rocker();

    // 베어링·체결류 (상완 구간) — 분해 시 부모 부품 오프셋 추종:
    // 크랭크 -0.6e / 구동 링크 -1.2e / 링크1 +0.8e / 로커 +1.4e / 하완 +0.8e(fa축)
    fa_off = 0.8 * e * [cos(j3 - j2), 0, sin(j3 - j2)]; // 하완 분해 방향 (상완 프레임)
    if (hw) {
        color(C_BEARING) {
            // 팔꿈치 608ZZ ×2 — **하완 측판 압입** (v0.13 관절 반전, 하완 추종)
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
            // 평행 링크 1 625ZZ ×2 (정적 핀·로커 핀) — 링크 추종 +0.8e
            for (px = [0, L1])
                translate([px + pl_offset * sin(j2), pl1_y + 2 + 0.8 * e,
                           pl_offset * cos(j2)])
                    rotate([-90, 0, 0]) bearing(BRG_625ZZ);
        }
        color(C_BOLT) {
            // J2 아이들 숄더 볼트 ⌀8 (머리 -Y, 텅 M6 체결) — 발출 -0.5e
            translate([0, -38 - 0.5 * e, 0]) rotate([-90, 0, 0]) shoulder_bolt(8, 26);
            // 팔꿈치 스트리퍼 볼트 ⌀8 L68 (샤프트, 발출 -0.5e)
            //  + M6 나일론 락 너트 (회전 축단 — 로커측 +1.4e)
            translate([L1, -25 - 0.5 * e, 0]) rotate([-90, 0, 0]) shoulder_bolt(8, 68);
            translate([L1, 45 + 1.4 * e, 0]) rotate([-90, 0, 0]) lock_nut(m6_nut_af, 5, 6);
            // 크랭크 핀 ⌀5 (크랭크 추종 -0.6e) / 혼 핀 ⌀5 (하완 추종 fa_off)
            translate([-rear_extension + j3_crank_len * cos(psi), -56.5 - 0.6 * e,
                       j3_crank_len * sin(psi)])
                rotate([-90, 0, 0]) shoulder_bolt(5, 10);
            translate([L1 + j3_crank_len * cos(psi) + fa_off[0], -57.5,
                       j3_crank_len * sin(psi) + fa_off[2]])
                rotate([-90, 0, 0]) shoulder_bolt(5, 10);
            // 로커 핀 숄더 볼트 ⌀5 L24 (링크 1·2 적층, 로커 추종, 머리 +Y 외측)
            // 머리 위치 = 링크 2 보스 외측단 (pl2_y + 보스 9 + 여유)
            translate([L1 + pl_offset * sin(j2), pl2_y + 10 + 1.4 * e,
                       pl_offset * cos(j2)])
                rotate([90, 0, 0]) shoulder_bolt(5, 24);
            // 상완 육각 스탠드오프 M6 AF13 ×2 + M6×12 양측 (간격 결정, v0.13)
            for (p = [[-108, 0], [160, 9]]) {
                color(C_BOLT) translate([p[0], arm_inner_w / 2, p[1]])
                    rotate([90, 0, 0]) hex_standoff(hex_standoff_af, arm_inner_w);
                for (sy = [-1, 1])
                    translate([p[0], sy * (arm_inner_w / 2 + arm_plate_t + 0.3),
                               p[1]])
                        rotate([sy * 90, 0, 0]) machine_bolt(6, 10);
            }
            // 스플라이스 더블러 M4 ×8 (양 측판, 중심선 추종 — ua_cz는 upper_arm)
            for (x = ua_splice, dz = [-10, 10], sy = [-1, 1])
                translate([x, sy * (arm_inner_w / 2 + arm_plate_t + 0.3),
                           ua_cz(x) + dz])
                    rotate([sy * 90, 0, 0]) machine_bolt(4, 14);
        }
        color(C_WASHER) {
            translate([L1, -26.5 - 0.5 * e, 0])
                rotate([-90, 0, 0]) washer(8);                  // 팔꿈치 머리측 (볼트 추종)
            translate([L1, 43.6 + 1.4 * e, 0])
                rotate([-90, 0, 0]) washer(8);                  // 너트측 (로커 추종)
        }
    }
}

// 하완 고정 체결 (fa_group 보조 — 스탠드오프 + 혼 마운트 + 관절 베어링)
module fa_fix_bolts(j2, j3, e) {
    fo2 = forearm_inner_w / 2 + arm_plate_t;
    // 하완 육각 스탠드오프 M6 AF13 ×2 + M6×12 양측 (v0.13)
    for (x = [76, 160]) {
        color(C_BOLT) {
            translate([0.8 * e + x, forearm_inner_w / 2, fa_cz_asm(x)])
                rotate([90, 0, 0])
                    hex_standoff(hex_standoff_af, forearm_inner_w);
            for (sy = [-1, 1])
                translate([0.8 * e + x, sy * (fo2 + 0.3), fa_cz_asm(x)])
                    rotate([sy * 90, 0, 0]) machine_bolt(6, 10);
        }
    }
    // 구동 혼 M4 ×3 (SHCS, 고정) — -Y측에서 체결, 혼 추종
    color(C_BOLT)
    for (a = [60, 180, 300])
        translate([0.8 * e + 17 * cos(a), -40 - 0.4 * e, 17 * sin(a)])
            rotate([-90, 0, 0]) machine_bolt(4, 18);
    // 손목 피치 608ZZ ×2 — 하완 측판 압입 (v0.13 관절 반전)
    color(C_BEARING)
    for (y = [-fo2, forearm_inner_w / 2])
        translate([0.8 * e + forearm_len, y, 0])
            rotate([-90, 0, 0]) bearing(BRG_608ZZ);
    // 팔꿈치·손목 내측 스페이서 튜브 ⌀12 (숄더 볼트 위, 내륜 간격)
    color(C_BOLT) {
        translate([0.8 * e, forearm_inner_w / 2, 0]) rotate([90, 0, 0])
            difference() {
                cylinder(d = joint_spacer_od, h = forearm_inner_w);
                translate([0, 0, -1]) cylinder(d = 8.4, h = forearm_inner_w + 2);
            }
        translate([0.8 * e + forearm_len, forearm_inner_w / 2, 0])
            rotate([90, 0, 0]) difference() {
                cylinder(d = joint_spacer_od, h = forearm_inner_w);
                translate([0, 0, -1]) cylinder(d = 8.4, h = forearm_inner_w + 2);
            }
    }
}
// 하완 꺾임 중심선 (forearm.scad fa_cz와 동기)
function fa_cz_asm(x) =
    let (kx = forearm_len * fa_bend_pos,
         kh = forearm_len * fa_bend_pos * (1 - fa_bend_pos) * tan(fa_bend_deg))
    x < kx ? kh * x / kx : kh * (forearm_len - x) / (forearm_len - kx);

// 하완 그룹 (하완 프레임 기준)
// sel: 0=전체, 1=하완만, 2=링크2만, 3=손목 그룹만 (간섭 원인 분리용)
module fa_group(j2 = J2a, j3 = J3a, j4 = J4a, e = 0, sel = 0, hw = false) {
    if (sel == 0 || sel == 1) {
        color(C_FOREARM) translate([0.8 * e, 0, 0]) forearm();
        // 구동 혼 (볼트온, 측판 A' 외면 — 분해 시 하완 추종 + -Y 발출)
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
        color(C_VITAMIN)
        translate([wrist_offset, 0, -(arm_lug_r + 4) + 0.8 * e])
            rotate([180, 0, 0]) actuator_J4();
        // 공구 플랜지 (J4 롤) — 손목 하판 6805에 보스 안착 (v0.13 노출 26)
        color(C_FLANGE)
        translate([wrist_offset, 0,
                   -(arm_lug_r + 4) - arm_plate_t - (gbx_out_shaft_len + 5)
                   - (flange_t + BRG_6805ZZ[2]) - 0.8 * e])
            rotate([0, 0, j4]) tool_flange();
        // 페이로드 참조 (1kg 그리퍼+공작물, PER-001)
        %translate([wrist_offset, 0, -170 - 0.8 * e]) cylinder(d = 50, h = 85);

        // 손목 베어링·체결류 (608ZZ는 하완 측판 — fa_fix_bolts에서)
        if (hw) {
            color(C_BEARING)
                // 플랜지 허브 6805ZZ (하판 관통 압입)
                translate([wrist_offset, 0,
                           -(arm_lug_r + 4) - arm_plate_t
                           - (gbx_out_shaft_len + 5) - BRG_6805ZZ[2]])
                    bearing(BRG_6805ZZ);
            color(C_BOLT) {
                // 손목 피치 스트리퍼 볼트 ⌀8 L80 (샤프트) + M6 나일론 락 너트
                translate([0, -43, 0]) rotate([-90, 0, 0]) shoulder_bolt(8, 80);
                translate([0, 38, 0]) rotate([-90, 0, 0]) lock_nut(m6_nut_af, 5, 6);
                // 손목 혼 핀 스트리퍼 볼트 ⌀5 L25 (샤프트, side_b 관통)
                translate([0, 28, pl_offset])
                    rotate([-90, 0, 0]) shoulder_bolt(5, 25);
                // 손목 스탠드오프 M6 AF13 ×3 + M6×12 (top↔bottom)
                for (p = [[28, 22], [72, 22], [50, -22]]) {
                    translate([p[0], p[1],
                               -(arm_lug_r + 4) - arm_plate_t
                               - (gbx_out_shaft_len + 5)])
                        hex_standoff(hex_standoff_af, gbx_out_shaft_len + 5);
                    translate([p[0], p[1], -(arm_lug_r + 4) + 0.3])
                        rotate([180, 0, 0]) machine_bolt(6, 10);
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

// 고정부 (J1 프레임)
module statics(e = 0, hw = false) {
    color(C_TURNTABLE) translate([0, 0, z_floor_top + 1 + 0.6 * e]) turntable();
    color(C_SPACER) translate([0, 0, z_brg_lo + BRG_6810ZZ[2] + 0.35 * e])
        turntable_spacer();
    color(C_SHOULDER) translate([0, 0, j2_z + 1.2 * e]) shoulder();
    // 평행사변형 정적 핀 앵커 (어깨에 M3 ×2 체결 — 분할 출력 부품)
    color(C_ANCHOR) translate([0, 0, j2_z + 1.6 * e]) pl_anchor();

    // 베어링·체결류 (고정부) — 분해 시 스택 순서대로 z 추종
    if (hw) {
        color(C_BEARING) {
            // 턴테이블 6810ZZ ×2 (베이스 칼럼): 하부 0.2e / 상부 0.5e
            translate([0, 0, z_brg_lo + 0.2 * e]) bearing(BRG_6810ZZ);
            translate([0, 0, z_brg_lo + BRG_6810ZZ[2] + turntable_bearing_gap
                       + 0.5 * e]) bearing(BRG_6810ZZ);
            // J2 아이들 608ZZ ×2 (어깨 텅 포켓, -Y측) — 어깨 추종 1.2e
            for (y = [-tongue_w / 2, -tongue_w / 2 + BRG_608ZZ[2]])
                translate([0, y, j2_z + 1.2 * e])
                    rotate([-90, 0, 0]) bearing(BRG_608ZZ);
        }
        // 평행사변형 정적 핀: 스트리퍼 볼트 ⌀5 (샤프트) — 앵커 추종 1.6e
        color(C_BOLT)
            translate([0, 51, j2_z + pl_offset + 1.6 * e])
                rotate([90, 0, 0]) shoulder_bolt(5, 12);
        // 고정 볼트 (SHCS): 턴테이블-어깨 M5 ×4 / 앵커 M3 ×2
        // + 어깨 스택 = 육각 스탠드오프 M6 AF13 ×3 + M6×12 양측 (v0.13)
        color(C_BOLT) {
            for (x = [-1, 1], y = [-1, 1])
                translate([x * shoulder_mount_px / 2, y * shoulder_mount_py / 2,
                           j2_z - j2_axis_h + turntable_top_t + 1.2 * e])
                    rotate([180, 0, 0]) machine_bolt(5, 14);
            for (p = [[-12, 20], [12, 20], [0, -40]]) {
                translate([p[0], tongue_w / 2 - 14, j2_z + p[1] + 1.2 * e])
                    rotate([90, 0, 0])
                        hex_standoff(hex_standoff_af, fork_standoff_len);
                for (sy = [-1, 1])
                    translate([p[0], sy * (tongue_w / 2 + 0.3),
                               j2_z + p[1] + 1.2 * e])
                        rotate([sy * 90, 0, 0]) machine_bolt(6, 10);
            }
            for (x = [-6, 6])
                translate([x, 23.4, j2_z + 36.2 + 1.6 * e])
                    rotate([180, 0, 0]) machine_bolt(3, 12);
        }
    }
}

// 부품 라벨 (지시선 + 빌보드, 월드 프레임에서 계산 — docs/design-notes.md)
// 순번 = 조립 순서 (베이스 → 턴테이블 스택 → 암 체인 → 말단).
// 표기 = "순번 부품명 (핵심 규격)" — 카테고리 색 = 부품 색과 동일.
// detail = 서브 피처(측판·니·혼·플레이트 등) + 하드웨어(H#) 라벨 추가
module robot_labels(j1, j2, j3, j4, e, lsize, detail = false, hw = false) {
    O    = [0, 0, j2_z + 2.0 * e];                 // J2 축 (분해 반영)
    adir = [cos(j2), 0, sin(j2)];                  // 상완 방향 단위 벡터
    fdir = [cos(j3), 0, sin(j3)];                  // 하완 방향 단위 벡터
    psi  = j3 + 90;                                // 크랭크/혼 방향 (월드)
    Ew   = O + L1 * adir;                          // 팔꿈치 축
    Ww   = Ew + (forearm_len + 2.4 * e) * fdir;    // 손목 피치 피벗 (손목 분해 추종)
    faw  = 0.8 * e * fdir;                         // 하완 몸체 분해 오프셋 (월드)

    // ── 정적 (무채색 톤온톤) ──
    leader_label([70, 0, 12], [30, -20, 30],
                 "01 base (J1 6810ZZx2)", lsize, C_BASE);
    leader_label(rotz([0, 50, tt_top + 0.6 * e], j1), [25, 25, 30],
                 "02 turntable", lsize, C_TURNTABLE);
    leader_label(rotz([33, 0, z_brg_lo + BRG_6810ZZ[2] + 15 + 0.35 * e], j1),
                 [45, 20, 20], "03 brg spacer (30mm)", lsize, C_SPACER);
    leader_label(rotz([0, -34, j2_z - 50 + 1.2 * e], j1), [10, -45, 5],
                 "04 shoulder (J2 tongue)", lsize, C_SHOULDER);

    // ── 동적 (카테고리 톤온톤) ──
    leader_label(rotz(O + 0.55 * L1 * adir + [0, 36, 10], j1), [-10, 35, 35],
                 "05 upper arm (L1=225)", lsize, C_UPPERARM);
    leader_label(rotz(O + pitchv([-rear_extension, 0, 0], j2)
                      + [0, -48 - 0.6 * e, 0], j1), [-30, -30, 25],
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
                 [10, -45, 25], "11 forearm (225)", lsize, C_FOREARM);
    leader_label(rotz(Ww + [wrist_offset, 29, -45], j1), [25, 35, 15],
                 "12 wrist (J4 6805ZZ)", lsize, C_WRIST);
    leader_label(rotz(Ww + [wrist_offset + 22, 0, -75 - 0.8 * e], j1),
                 [35, 15, -15], "13 tool flange (BC32 M4x4)", lsize, C_FLANGE);

    // ── 세부 라벨 (detail = true): 서브 피처 전수 + 하드웨어 인스턴스 전수 ──
    // 데이터 구동: [위치(월드, J1 회전 전), 지시선 벡터, 텍스트, 색]
    if (detail) {
        ds = lsize * 0.78;
        Cp  = O + pitchv([-rear_extension, 0, 0], j2);            // J3 크랭크 축
        Pc  = Cp + j3_crank_len * [cos(psi), 0, sin(psi)];        // 크랭크 핀
        Ph  = Ew + j3_crank_len * [cos(psi), 0, sin(psi)];        // 구동 혼 핀
        Pr  = Ew + pl_offset * [0, 0, 1];                          // 로커 핀 (연직 상방)
        Pw  = Ww + pl_offset * [0, 0, 1];                          // 손목 혼 핀

        // 서브 피처 (부모 카테고리 색)
        sub = [
            // 어깨/앵커
            [[0, 36, j2_z + pl_offset + 1.6 * e], [-22, 28, 28], "04a pl anchor (M3x2)", C_ANCHOR],
            [[0, 28, j2_z + 14 + 1.2 * e],            [-18, 36, 40], "04b shaft clamp+slit", C_SHOULDER],
            [[-18, -25, j2_z - 30 + 1.2 * e],         [-30, -34, 6], "04c tongue plates x2+boss", C_SHOULDER],
            [[42, -28, j2_z - j2_axis_h + 6 + 1.2 * e], [22, -30, 8], "04d base flange", C_SHOULDER],
            // 상완
            [O + pitchv([-40, 0, 0], j2) + [0, -36, 0], [-25, -35, 18], "05a side plate A", C_UPPERARM],
            [O + pitchv([35, 0, 8], j2) + [0, 36, 0],   [-8, 34, 30],   "05b side plate B", C_UPPERARM],
            [O + pitchv([L1 * ua_bend_pos, 0, 36], j2) + [0, 18, 0], [0, 28, 30], "05c beam knee", C_UPPERARM],
            [O + pitchv([ua_split_x, 0, 8], j2) + [0, -25, 0], [3, -33, 22], "05d splice doubler x2 (M4x8)", C_UPPERARM],
            [O + pitchv([0, 0, -13], j2) + [0, -40, 0],  [-22, -30, -18], "05e idle c'bore", C_UPPERARM],
            [O + pitchv([160, 0, 9], j2) + [0, 32, 0], [8, 30, 36], "05f hex standoff M6 x2", C_UPPERARM],
            [O + pitchv([ua_split_x, 0, 20], j2) + [0, 25, 0], [-4, 40, 44], "05g butt split line", C_UPPERARM],
            [O + pitchv([-rear_extension - arm_lug_r - 8, 0, 0], j2), [-30, -22, 16], "05h open plate frame", C_UPPERARM],
            // 크랭크 (-0.6e 추종)
            [Cp + [0, -44 - 0.6 * e, -7],  [-30, -28, -16], "06a hub clamp M3", C_CRANK],
            // 하완 (몸체 분해 faw 추종)
            [Ph + faw + (Ew - Ph) * 0.3 + [0, -40, 0], [-12, -33, 26], "11a drive horn (bolt-on M4x3)", C_FOREARM],
            [Ew + faw + pitchv([-17, 0, 0], j3) + [0, -25, 0], [-26, -28, 22], "11b horn mount+register", C_FOREARM],
            [Ew + faw + pitchv([forearm_len * fa_bend_pos, 0, 14], j3) + [0, -18, 0], [6, -30, 26], "11c beam knee", C_FOREARM],
            [Ew + faw + pitchv([70, 0, -16], j3) + [0, -22, 0], [-4, -36, 8], "11d side plate A", C_FOREARM],
            [Ew + faw + pitchv([forearm_len - 70, 0, 20], j3) + [0, 16, 0], [12, 34, 24], "11e web", C_FOREARM],
            // 손목
            [Ww + [0, 34, pl_offset - 8], [16, 33, 26], "12a horn (side plate B)", C_WRIST],
            [Ww + [0, -33, 6],   [-22, -36, 14], "12b side plate A", C_WRIST],
            [Ww + [50, 22, -48], [-14, 30, -30], "12c hex standoff M6 x3", C_WRIST],
            [Ww + [20, 24, -33], [26, 30, 10],  "12d top plate (J4 NEMA)", C_WRIST],
            [Ww + [wrist_offset + 20, -24, -66], [24, -26, -12], "12e bottom plate (6805)", C_WRIST],
            [Ww + [8, -28, -50], [-16, -34, -8], "12f open frame", C_WRIST],
            [Ww + [-6, 30, -32], [-26, 24, -20], "12g tab joint M3", C_WRIST],
            // 플랜지
            [Ww + [wrist_offset + flange_d / 2 - 3, 0, -74 - 0.8 * e], [26, -18, -12], "13a edge chamfer", C_FLANGE],
            [Ww + [wrist_offset + 8, 6, -52 - 0.8 * e], [30, 16, -2], "13b hub stem", C_FLANGE],
        ];
        for (L = sub) leader_label(rotz(L[0], j1), L[1], L[2], ds, L[3]);

        // 하드웨어 인스턴스 전수 (구매품 무채 톤온톤) — hw 표시 시에만.
        // H01~: 베어링/볼트/너트/와셔 개별. 동축 적층은 지시선 방향으로 분리
        if (hw) {
            hwl = [
                // J1 칼럼 (정적 — 분해 시 스택 z 추종)
                [[33, 0, z_brg_lo + 3 + 0.2 * e],  [38, -16, -10], "H01 6810ZZ lower", C_BEARING],
                [[33, 0, z_brg_lo + 40 + 0.5 * e], [42, -14, 8],   "H02 6810ZZ upper", C_BEARING],
                // J2 아이들 (어깨 텅 추종 1.2e)
                [[0, -27, j2_z + 9 + 1.2 * e],  [-16, -42, 30], "H03 608ZZ J2 in", C_BEARING],
                [[0, -19, j2_z + 9 + 1.2 * e],  [-4, -46, 40],  "H04 608ZZ J2 out", C_BEARING],
                [O + [0, -44 - 0.5 * e, -2],    [-26, -34, -22], "H05 stripper 8x26 J2 (shaft)", C_BOLT],
                // 정적 핀 (앵커 추종 1.6e)
                [[0, 53, j2_z + pl_offset + 1.6 * e], [-12, 34, 18], "H06 stripper 5x12 anchor (shaft)", C_BOLT],
                // 팔꿈치 스택 (-Y → +Y 순; 볼트/머리 와셔 -0.5e, 로커측 +1.4e)
                [Ew + [0, -29 - 0.5 * e, -6],  [-26, -30, -28], "H07 stripper 8x68 elbow (shaft)", C_BOLT],
                [Ew + [0, -26 - 0.5 * e, 5],   [-34, -24, 10],  "H08 washer 8 head", C_WASHER],
                [Ew + [0, -12, 6],   [-20, -42, 36],  "H09 608ZZ elbow in", C_BEARING],
                [Ew + [0, 12, 6],    [-6, 46, 44],    "H10 608ZZ elbow out", C_BEARING],
                [Ew + [0, 35 + 1.4 * e, 5],    [10, 50, 36],  "H11 608ZZ rocker", C_BEARING],
                [Ew + [0, 44 + 1.4 * e, -3],   [24, 38, -24], "H12 washer 8 nut", C_WASHER],
                [Ew + [0, 48 + 1.4 * e, 0],    [34, 26, -38], "H13 M6 lock nut (nylock)", C_BOLT],
                // J3 구동계 핀/베어링 (크랭크 -0.6e / 링크 -1.2e / 혼 faw)
                [Pc + [0, -59 - 0.6 * e, 0],   [-32, -22, -14], "H14 stripper 5x10 crank (shaft)", C_BOLT],
                [Pc + [0, -54 - 1.2 * e, 0],   [-26, -30, 14],  "H15 625ZZ dlink crank", C_BEARING],
                [Ph + [0, -54 - 1.2 * e, 0],   [-10, -34, -22], "H16 625ZZ dlink horn", C_BEARING],
                [Ph + faw + [0, -60, 0],       [-22, -28, -34], "H17 stripper 5x10 horn (shaft)", C_BOLT],
                // 평행사변형 핀/베어링 (링크1 +0.8e / 링크2 +1.8e / 로커 +1.4e)
                [O + [0, 46 + 0.8 * e, pl_offset],  [-18, 38, 30], "H18 625ZZ link1 gnd", C_BEARING],
                [Pr + [0, 46 + 0.8 * e, 0],    [4, 44, 42],   "H19 625ZZ link1 rkr", C_BEARING],
                [Pr + [0, pl2_y + 4.5 + 1.8 * e, 0], [18, 40, 30], "H20 625ZZ link2 rkr", C_BEARING],
                [Pr + [0, pl2_y + 9 + 1.4 * e, 0],   [32, 34, 16], "H21 stripper 5x24 rocker (shaft)", C_BOLT],
                [Pw + [0, pl2_y + 4.5 + 1.8 * e, 0], [16, 40, 28], "H22 625ZZ link2 wrist", C_BEARING],
                [Pw + [0, pl2_y + 9, 0],             [30, 34, 14], "H23 stripper 5x25 whorn (shaft)", C_BOLT],
                // 손목 스택
                [Ww + [0, -29, -4],  [-22, -32, -20], "H24 stripper 8x46 wrist (shaft)", C_BOLT],
                [Ww + [0, -27, 6],   [-32, -26, 12],  "H25 washer 8 wrist", C_WASHER],
                [Ww + [0, -12, 7],   [-14, -40, 30],  "H26 608ZZ wrist in", C_BEARING],
                [Ww + [0, 12, 7],    [-2, 42, 38],    "H27 608ZZ wrist out", C_BEARING],
                [Ww + [0, 26, 0],    [12, 44, -18],   "H28 M6 lock nut (nylock)", C_BOLT],
                // J4 플랜지 허브
                [Ww + [wrist_offset - 13, -9, -68], [-28, -28, -10], "H29 6805ZZ", C_BEARING],
                // 고정 볼트 세트 (SHCS/무두 — 체결 전용, 샤프트 아님)
                [[12, 27, j2_z + 20 + 1.2 * e], [28, 30, 22], "H30 hex standoff M6x3 shoulder (fix)", C_BOLT],
                [[10, -33, j2_z - 86 + 1.2 * e], [-22, -30, -14], "H41 M4x2 SHCS tab pin (fix)", C_BOLT],
                [O + pitchv([ua_split_x, 0, 0], j2) + [0, -25, 0],
                     [-6, -34, -26], "H31 M4x8 SHCS splice (fix)", C_BOLT],
                [Ew + faw + pitchv([76, 0, 8], j3) + [0, 20, 0],
                     [10, 36, 18], "H32 hex standoff M6x2 forearm (fix)", C_BOLT],
                [Ew + faw + pitchv([-15, 0, 9], j3) + [0, -42 - 0.4 * e, 0],
                     [-30, -26, 10], "H33 M4x3 FHCS horn mount (fix)", C_BOLT],
                [O + pitchv([-108, 0, 0], j2) + [0, 24, 0],
                     [-16, 40, 28], "H34 hex standoff M6x2 arm (fix)", C_BOLT],
                [[6, 23, j2_z + 40 + 1.6 * e], [22, 26, 34], "H35 M3x2 SHCS anchor (fix)", C_BOLT],
                [[40, 25, j2_z - j2_axis_h + 12 + 1.2 * e], [30, 24, 12],
                     "H36 M5x4 SHCS flange (fix)", C_BOLT],
                [[30, 30, z_floor_top + 8], [36, 24, 14], "H37 set screw M4x2 J1 hub (fix)", C_BOLT],
                [Ww + [wrist_offset, 30, -50], [20, 38, -8], "H38 set screw M4x2 J4 hub (fix)", C_BOLT],
                [[0, 26, j2_z + 15 + 1.2 * e], [-24, 34, 44], "H39 M3 pinch x3 clamp (fix)", C_BOLT],
            ];
            for (L = hwl) leader_label(rotz(L[0], j1), L[1], L[2], ds, L[3]);
            // 베이스 고정 볼트 (정적 — J1 비회전이라 rotz 제외)
            leader_label([base_bolt_pitch / 2, base_bolt_pitch / 2, 12],
                         [26, 18, 22], "H40 M5x4 bolt base anchor (fix)", ds, C_BOLT);
        }

        // 액추에이터 (모터+기어박스) — 구매품 다크 톤
        act = [
            [O + [0, 110, 0],  [22, 42, 30],  "A2 SF2424+MG17-G20 (J2)"],
            [O + pitchv([-rear_extension, 0, 0], j2) + [0, 48, 0],
                 [-26, 36, 26], "A3 SF2423+MG17-G20 (J3)"],
            [Ww + [wrist_offset, 0, 28], [26, 24, 30], "A4 SF2422+MG17-G5 (J4)"],
        ];
        for (L = act) leader_label(rotz(L[0], j1), L[1], L[2], ds, C_VITAMIN);
        // J1 액추에이터 (베이스 칼럼 내 — 정적, rotz 제외)
        leader_label([0, -24, z_flange - 40], [-34, -28, -6],
                     "A1 SF2424+MG17-G20 (J1)", ds, C_VITAMIN);
    }
}

// 전체 로봇. e = 분해 거리 단위(mm, 0 = 조립), labels = 지시선 라벨 표시,
// hardware = 베어링·볼트·너트·와셔 목업 — 분해 뷰에서도 부모 부품의
// 분해 오프셋을 추종해 동일 표시 (라벨 동기)
module robot(j1 = J1a, j2 = J2a, j3 = J3a, j4 = J4a,
             e = 0, labels = false, lsize = 3.2, hardware = true,
             label_detail = false) {
    hw = hardware;
    // 운용 엔벨로프 (특이점 회피, parameters.scad):
    //   env_fold_min(-75) = 평행사변형 전동각 한계 (특이점 -90°)
    //   env_fold_max(-3)  = 완전 신장 특이점(0°) 회피
    // 기계적 간섭 한계는 [-95, +40] (간섭 검사 근거)
    if (j3 - j2 < env_fold_min || j3 - j2 > env_fold_max)
        echo(str("경고: 접힘각 j3-j2 = ", j3 - j2, "° — 운용 엔벨로프 [",
                 env_fold_min, ", ", env_fold_max,
                 "] 밖 (특이점/간섭 위험, design-notes §3)"));
    color(C_BASE) base();
    // 작업대 고정 M5 ×4 (SHCS, MEC-005 — J1 비회전)
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
    // J2 회전 체인 ∩ 고정부
    intersection() {
        rotate([0, 0, J1a]) translate([0, 0, j2_z]) j2_chain(J2a, J3a, J4a);
        union() { base(); rotate([0, 0, J1a]) statics(); }
    }
} else if (check >= 2 && check <= 5) {
    // 하완 그룹 ∩ 상완 그룹. check 3/4/5 = 하완/링크2/손목만
    intersection() {
        rotate([0, -J2a, 0]) ua_group(J2a, J3a);
        rotate([0, -J2a, 0]) translate([L1, 0, 0])
            rotate([0, -(J3a - J2a), 0]) fa_group(J2a, J3a, J4a, 0, check - 2);
    }
} else {
    robot(J1a, J2a, J3a, J4a, labels = true);
}
