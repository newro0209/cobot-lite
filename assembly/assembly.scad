// 전체 조립 모델 (full assembly) — 간섭 확인 + 시각화 (검수 기준 §12-1)
//
// 모듈형: robot(j2, j3, e, labels, lsize, hardware, label_detail)
// 컬러: 동적 부품 = 카테고리별 톤온톤 (라벨 동색).
// 좌표: 원점 = J2 축 (베이스~어깨·손목 이후 제거 — 체인 = 상완→하완)
//
// J3 직결 (v0.16): A3(SF2423+MG17-G20) 기어박스 플랜지를 상완 -Y 측판
// 팔꿈치 외면에 직결, 출력축 ⌀8 → 팔꿈치 허브(하완 볼트온) 클램프.
// +Y측 아이들 피벗 = 상완 측판 608ZZ + 숄더 ⌀8×25 + 갭 스페이서 8.
// 평행사변형(크랭크·구동 링크·혼) 폐지 — psi 기구학 소멸.
//
// CLI 간섭 검사 (자세는 -D J2a=... 로 지정):
//   openscad -D "check=2" -D "J2a=45" -D "J3a=-20" -o chk.stl assembly/assembly.scad
//   check=2: 하완 그룹 ∩ 상완 그룹
//   → "Current top level object is empty" 또는 빈 STL = 통과
//
// 각도 규약: j2 = 상완 월드 피치(수평=0, 상향+), j3 = 하완 월드 피치.
// 가동 범위: 접힘각 j3-j2 ∈ [env_fold_min, env_fold_max] (직결 — 간섭 한계만)
include <../config/parameters.scad>
use <../lib/utils.scad>
use <../lib/vitamins.scad>
use <../parts/upper_arm.scad>
use <../parts/forearm.scad>
use <../parts/elbow_hub.scad>

/* ===== 단독 실행용 자세 (main.scad 경유 시 robot() 인자가 우선) ===== */
J2a = 20;   // 어깨 피치, deg (월드 기준, 0 = 수평)
J3a = -40;  // 하완 피치, deg (월드 기준)
check = 0;

/* ===== 카테고리 컬러 — lib/colors.scad ===== */
include <../lib/colors.scad>

/* ===== 팔꿈치 Y 스택 (J2 축 기준) ===== */
ua_in  = arm_inner_w / 2;              // 상완 측판 내면 30
ua_out = ua_in + arm_plate_t;          // 상완 측판 외면 37
fa_out = forearm_inner_w / 2 + arm_plate_t;   // 하완 측판 외면 22

/* ===== 좌표 헬퍼 (라벨 앵커 계산) ===== */
function pitchv(p, a) = [p[0] * cos(a) - p[2] * sin(a), p[1],
                         p[0] * sin(a) + p[2] * cos(a)];

// 상완 그룹 (상완 프레임 기준). e = 분해 거리 단위, hw = 베어링·체결류 목업
// (hw 기본 false — CLI 간섭 검사에서 면접촉 노이즈 배제)
module ua_group(j2 = J2a, j3 = J3a, e = 0, hw = false) {
    color(C_UPPERARM) upper_arm();
    // A3 액추에이터: 팔꿈치 -Y 측판 외면 직결, 출력축 +Y (보어 = 파일럿)
    color(C_VITAMIN)
    translate([L1, -ua_out - 0.6 * e, 0]) rotate([-90, 0, 0]) actuator_J3();

    if (hw) {
        color(C_BEARING)
        // 팔꿈치 아이들 608ZZ — 상완 +Y 측판 인-플레이트 압입
        translate([L1, ua_in, 0]) rotate([-90, 0, 0]) bearing(BRG_608ZZ);
        color(C_BOLT) {
            // 아이들 숄더 볼트 ⌀8×25 (+Y 외측에서) + M6 나일론 락 너트 (하완 내측)
            translate([L1, ua_out + 1.4 + 0.5 * e, 0])
                rotate([90, 0, 0]) shoulder_bolt(8, 25);
            translate([L1, forearm_inner_w / 2 - 1.2 - 0.5 * e, 0])
                rotate([90, 0, 0]) lock_nut(m6_nut_af, 5, 6);
            // 갭 스페이서 튜브 ⌀12×8 (숄더 위, 상완·하완 베어링 내륜 간격)
            translate([L1, ua_in, 0]) rotate([90, 0, 0])
                difference() {
                    cylinder(d = joint_spacer_od, h = elbow_gap);
                    translate([0, 0, -1]) cylinder(d = 8.4, h = elbow_gap + 2);
                }
            // 기어박스 플랜지 M3×8 ×4 (내면 카운터보어에서 플러시)
            for (sx = [-1, 1], sz = [-1, 1])
                translate([L1 + sx * nema17_hole_pitch / 2,
                           -(ua_in + 2.2) - 0.6 * e,
                           sz * nema17_hole_pitch / 2])
                    rotate([90, 0, 0]) machine_bolt(3, 8);
            // 상완 육각 스탠드오프 M6 AF13 ×3 + M6×12 양측
            for (p = [[40, 0], [100, 0], [160, 0]]) {
                translate([p[0], ua_in, p[1]])
                    rotate([90, 0, 0]) hex_standoff(hex_standoff_af, arm_inner_w);
                for (sy = [-1, 1])
                    translate([p[0], sy * (ua_out + 0.3), p[1]])
                        rotate([sy * 90, 0, 0]) machine_bolt(6, 10);
            }
        }
        color(C_WASHER) {
            translate([L1, ua_out + 1.4 + 0.5 * e, 0])
                rotate([90, 0, 0]) washer(8);            // 머리측 (측판 외면)
            translate([L1, forearm_inner_w / 2 - 0.5 * e, 0])
                rotate([90, 0, 0]) washer(8);            // 너트측 (하완 내측)
        }
    }
}

// 하완 고정 체결 (fa_group 보조 — 스탠드오프 + 허브 FHCS + 관절 베어링)
module fa_hw(e) {
    fo2 = forearm_inner_w / 2 + arm_plate_t;
    color(C_BEARING)
    // 팔꿈치 608ZZ ×2 — 하완 측판 압입 (-Y: 기어박스 축 파일럿 / +Y: 아이들)
    for (y = [-fo2, forearm_inner_w / 2])
        translate([0.8 * e, y, 0]) rotate([-90, 0, 0]) bearing(BRG_608ZZ);
    color(C_BOLT) {
        for (x = [76, 160]) {
            translate([0.8 * e + x, forearm_inner_w / 2, 0])
                rotate([90, 0, 0])
                    hex_standoff(hex_standoff_af, forearm_inner_w);
            for (sy = [-1, 1])
                translate([0.8 * e + x, sy * (fo2 + 0.3), 0])
                    rotate([sy * 90, 0, 0]) machine_bolt(6, 10);
        }
        // 팔꿈치 허브 M4 FHCS ×3 (-Y측에서 셀프태핑, 허브 추종)
        for (a = [60, 180, 300])
            translate([0.8 * e + elbow_hub_bolt_r * cos(a),
                       -fo2 - elbow_hub_t - 0.4 * e,
                       elbow_hub_bolt_r * sin(a)])
                rotate([-90, 0, 0]) machine_bolt(4, 12);
    }
}

// 하완 그룹 (하완 프레임 기준)
module fa_group(j2 = J2a, j3 = J3a, e = 0, hw = false) {
    color(C_FOREARM) translate([0.8 * e, 0, 0]) forearm();
    // 팔꿈치 허브 (볼트온, -Y 측판 외면 갭 수납 — 분해 시 하완 추종 + -Y 발출)
    color(C_FOREARM)
    translate([0.8 * e, -fa_out - 0.4 * e, 0]) rotate([90, 0, 0]) elbow_hub();
    if (hw) fa_hw(e);
}

// J2 축 기준 회전 체인 전체
module j2_chain(j2 = J2a, j3 = J3a, e = 0, hw = false) {
    rotate([0, -j2, 0]) {
        ua_group(j2, j3, e, hw);
        translate([L1, 0, 0]) rotate([0, -(j3 - j2), 0])
            fa_group(j2, j3, e, hw);
    }
}

// 부품 라벨 (지시선 + 빌보드, 월드 프레임) — 순번 = 조립 순서
module robot_labels(j2, j3, e, lsize, detail = false, hw = false) {
    O    = [0, 0, 0];
    adir = [cos(j2), 0, sin(j2)];
    fdir = [cos(j3), 0, sin(j3)];
    Ew   = O + L1 * adir;
    faw  = 0.8 * e * fdir;

    // ── 카테고리 톤온톤 ──
    leader_label(O + 0.45 * L1 * adir + [0, 36, 10], [-10, 35, 35],
                 "01 upper arm (plate x2 identical, L1=225)", lsize, C_UPPERARM);
    leader_label(Ew + faw + 0.5 * forearm_len * fdir + [0, -22, 0],
                 [10, -45, 25], "02 forearm (plate x2 identical, 225)",
                 lsize, C_FOREARM);
    leader_label(Ew + faw + [0, -fa_out - elbow_hub_t / 2 - 0.4 * e, -14],
                 [-18, -38, -28], "03 elbow hub (d44, shaft clamp)",
                 lsize, C_FOREARM);

    // ── 세부 라벨 (detail): 서브 피처 + 하드웨어 ──
    if (detail) {
        ds = lsize * 0.78;
        sub = [
            [O + 0.18 * L1 * adir + [0, -36, 0], [-25, -35, 18],
             "01a side plate A=B (t7, joint iface x2)", C_UPPERARM],
            [Ew + [0, -ua_in - 0.6 * e, -10], [-22, -34, 26],
             "01b gearbox pilot bore d22 + NEMA17 (direct)", C_UPPERARM],
            [Ew + faw + pitchv([elbow_vane_r, 0, 0], j3 + elbow_vane_a)
                 + [0, -fa_out - 0.4 * e, 0], [-26, -30, -20],
             "03a limit vane (r48, hub-integral)", C_FOREARM],
        ];
        for (L = sub) leader_label(L[0], L[1], L[2], ds, L[3]);

        // 하드웨어 인스턴스 (구매품 무채 톤온톤) — hw 표시 시에만
        if (hw) {
            hwl = [
                [Ew + [0, ua_out + 8 + 0.5 * e, 0], [26, 30, -28],
                 "H01 stripper 8x25 elbow idle (shaft)", C_BOLT],
                [Ew + [0, ua_in + 3.5, 6], [-6, 46, 44],
                 "H02 608ZZ elbow ua idle", C_BEARING],
                [Ew + [0, -fa_out + 3.5, 6], [-20, -42, 36],
                 "H03 608ZZ elbow fa drive (shaft pilot)", C_BEARING],
                [Ew + [0, forearm_inner_w / 2 + 3.5, -6], [14, 40, -30],
                 "H04 608ZZ elbow fa idle", C_BEARING],
                [Ew + [0, forearm_inner_w / 2 - 4 - 0.5 * e, 0], [30, 24, 30],
                 "H05 M6 lock nut elbow (nylock)", C_BOLT],
                [Ew + [0, ua_in - elbow_gap / 2, 0], [22, 34, 16],
                 "H06 spacer tube 12x8 (gap)", C_BOLT],
                [Ew + [0, -(ua_in + 6) - 0.6 * e, 16], [-24, -30, 30],
                 "H07 M3x4 gearbox flange (fix)", C_BOLT],
                [Ew + faw + [0, -fa_out - elbow_hub_t - 0.4 * e,
                             -elbow_hub_bolt_r], [-30, -26, -16],
                 "H08 M4x3 FHCS hub mount (fix)", C_BOLT],
                [O + pitchv([100, 0, 0], j2) + [0, 24, 0], [-16, 40, 28],
                 "H09 hex standoff M6x3 arm (fix)", C_BOLT],
                [Ew + faw + pitchv([76, 0, 0], j3) + [0, 20, 0], [10, 36, 18],
                 "H10 hex standoff M6x2 forearm (fix)", C_BOLT],
            ];
            for (L = hwl) leader_label(L[0], L[1], L[2], ds, L[3]);
        }

        // 액추에이터 (모터+기어박스) — 팔꿈치 직결
        leader_label(Ew + [0, -ua_out - 40 - 0.6 * e, 0],
                     [-26, -36, 26], "A3 SF2423+MG17-G20 (J3 elbow direct)",
                     ds, C_VITAMIN);
    }
}

// 전체 로봇. e = 분해 거리 단위(mm), labels = 라벨, hardware = 체결류 목업
module robot(j2 = J2a, j3 = J3a,
             e = 0, labels = false, lsize = 3.2, hardware = true,
             label_detail = false) {
    hw = hardware;
    if (j3 - j2 < env_fold_min || j3 - j2 > env_fold_max)
        echo(str("경고: 접힘각 j3-j2 = ", j3 - j2, "° — 운용 엔벨로프 [",
                 env_fold_min, ", ", env_fold_max,
                 "] 밖 (간섭 위험 — 스탠드오프(160,0) 한계 ±149°)"));
    j2_chain(j2, j3, e, hw);
    if (labels) robot_labels(j2, j3, e, lsize, label_detail, hw);
}

/* ===== 디스패치 (단독 실행 / CLI 간섭 검사) ===== */
if (check == 2) {
    intersection() {
        rotate([0, -J2a, 0]) ua_group(J2a, J3a);
        rotate([0, -J2a, 0]) translate([L1, 0, 0])
            rotate([0, -(J3a - J2a), 0]) fa_group(J2a, J3a);
    }
} else if (check == 0) {
    robot(J2a, J3a, labels = true);
}
// check == 1 (구 체인∩고정부)은 베이스~어깨 제거로 폐지 — 빈 출력 = 통과
