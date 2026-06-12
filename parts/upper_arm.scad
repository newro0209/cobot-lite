// 상완 (upper arm) — v0.15: 단일 피스 동일 측판 ×2 + 볼트온 소부품
// =====================================================================
// 원칙: 측판 1형상 ×2 (A/B 구분 폐지 — 플립 장착 호환, 직선 빔 전제).
//   분할(맞대기+더블러) 폐기 — 단일 피스. 길이 ≈365 → FDM은 베드 대각 배치,
//   CNC는 평판 원소재 그대로 (MFG-004 재검토 항목, design-notes §4b)
// 공용 홀 세트 (양 측판 동일):
//   후방(-rear_extension): J3 모터 사각 통과 43.6² + 어댑터 M4 ×2 (±27, x축)
//   J2 축: ⌀22 보어 + NEMA17 M3 ×4 (내면 머리 카운터보어 — 플러시)
//   팔꿈치(L1): ⌀8 관통 / 스탠드오프 M6: (-44,±14),(160,0) / 베인 핀 M3 (56,0)
// 한쪽 전용 → 볼트온:
//   [ua_adapter] J3 모터 어댑터 — 사각 보스(홀 레지스터) + NEMA17 + M4 ×2
//                + J3 리미트 M2 ×2 (모터 측판 외면에 장착, 어느 쪽이든 가능)
//   [ua_bush]    J2 아이들 부시 — 플랜지 ⌀30 + 스피곳 ⌀22(보어 압입), ⌀8 관통
//                (반대쪽 측판의 ⌀22 보어를 아이들 피벗 ⌀8로 환원)
// J2 구동 측: 액추에이터가 측판 외면에 직결 (M3 ×4, 머리는 내면 카운터보어)
//   — 출력축 ⌀8이 어깨 클램프 디스크에 물림 (MEC-001b)
include <../config/parameters.scad>
use <../lib/utils.scad>
use <../lib/vitamins.scad>

pa_in  = -arm_inner_w / 2;  pa_out = pa_in - arm_plate_t;
pb_in  =  arm_inner_w / 2;  pb_out = pb_in + arm_plate_t;
rear_lug_x = -rear_extension;
rear_lug_R = arm_lug_r + 8;       // 34 — 사각 통과 홀 수용
ua_standoffs = [[-44, 14], [-44, -14], [160, 0]];

// 측판 2D — z 대칭 (플립 장착 동형 보장)
module ua_plate2d() {
    difference() {
        hull() {
            // 후방 러그: 상하 평탄(±26) + 후방 45° 양면 챔퍼
            // (J2 ±45° 회전 시 챔퍼가 수직 — 어깨 플랜지 클리어, v0.14 근거)
            translate([rear_lug_x, 0]) intersection() {
                circle(r = rear_lug_R);
                polygon([[-34, 0], [-8, -26], [40, -26], [40, 26], [-8, 26]]);
            }
            circle(r = arm_lug_r);
            translate([L1, 0]) circle(r = arm_lug_r);
        }
        // J3 모터 사각 통과 (42각 + 1.6 — 코너 대각 59.4 대응, v0.14)
        translate([rear_lug_x, 0]) square(motor_frame + 1.6, center = true);
        // J3 어댑터 M4 ×2 (x축 쌍 — 챔퍼/사각 사이 잔존 띠)
        for (s = [-1, 1])
            translate([rear_lug_x + s * 27, 0]) circle(d = 4.4);
        // J2 축: ⌀22 보어 (구동측 = 액추에이터 파일럿 / 아이들측 = 부시 압입)
        circle(d = BRG_608ZZ[1] + bearing_press_fit);
        for (x = [-1, 1], y = [-1, 1])                       // NEMA17 M3 ×4
            translate([x * nema17_hole_pitch / 2, y * nema17_hole_pitch / 2])
                circle(d = nema17_bolt_d + bolt_hole_oversize);
        // 팔꿈치 ⌀8 관통
        translate([L1, 0]) circle(d = shoulder_d_large + clearance_fit);
        // 스탠드오프 M6 + J2 리미트 베인 핀 M3 (어깨 키프아웃 환형 기준)
        for (p = ua_standoffs) translate(p) circle(d = 6.6);
        translate([vane_pin_x, 0]) circle(d = m3_tap_d);
    }
}

// 측판 (extrude z 0..7, z7 면 = 장착 포즈에서 내면 — M3 머리 카운터보어)
module ua_plate() {
    difference() {
        linear_extrude(arm_plate_t) ua_plate2d();
        for (x = [-1, 1], y = [-1, 1])
            translate([x * nema17_hole_pitch / 2, y * nema17_hole_pitch / 2,
                       arm_plate_t - 2.2])
                cylinder(d = 6.5, h = 2.3);
    }
}

// J3 모터 어댑터 — z0 = 장착면(측판 외면 접촉), 사각 보스 +z 삽입
module ua_adapter() {
    difference() {
        union() {
            cylinder(r = 31, h = arm_plate_t);
            translate([0, 0, arm_plate_t - 0.1])
                linear_extrude(2.1)
                    square(motor_frame + 1.6 - clearance_fit, center = true);
        }
        translate([0, 0, -0.1]) nema17_mount(arm_plate_t + 2.3);
        for (s = [-1, 1])
            translate([s * 27, 0, -0.1]) bolt_hole(4, arm_plate_t + 0.2);
        // J3 리미트 스위치 M2 ×2 (크랭크 베인 감지 — 어댑터 외면 상부)
        for (s = [-1, 1])
            translate([s * ls_hole_pitch / 2, 24, -0.1])
                cylinder(d = ls_hole_d, h = arm_plate_t + 2.3);
    }
}

// J2 아이들 부시 — z0 = 플랜지 외면, 스피곳 +z (보어 압입)
module ua_bush() {
    difference() {
        union() {
            cylinder(d = 30, h = 3);
            cylinder(d = BRG_608ZZ[1] + bearing_press_fit, h = 3 + arm_plate_t);
        }
        translate([0, 0, -0.1])
            cylinder(d = shoulder_d_large + clearance_fit, h = 3 + arm_plate_t + 0.2);
    }
}

// piece: "full" | "plate" | "adapter" | "bush"
module upper_arm(piece = "full") {
    if (piece == "full") {
        translate([0, pb_out, 0]) rotate([90, 0, 0]) ua_plate();    // +Y (구동측)
        translate([0, pa_out, 0]) rotate([-90, 0, 0]) ua_plate();   // -Y (z 미러)
        // J3 어댑터: -Y 측판 외면 (보스가 사각 홀에 +Y 삽입, M3 머리는 홀 공동 내)
        translate([rear_lug_x, pa_out - arm_plate_t, 0])
            rotate([-90, 0, 0]) ua_adapter();
        // J2 아이들 부시: -Y 축 (스피곳이 보어에 +Y 압입)
        translate([0, pa_out - 3, 0]) rotate([-90, 0, 0]) ua_bush();
    }
    else if (piece == "plate")   ua_plate();
    else if (piece == "adapter") ua_adapter();
    else if (piece == "bush")    ua_bush();
}

// 비주얼 참조 (STL 제외)
%translate([0, pb_out, 0]) rotate([90, 0, 0]) actuator_J2();
%translate([rear_lug_x, pa_out - arm_plate_t, 0]) rotate([90, 0, 0]) actuator_J3();

upper_arm();
