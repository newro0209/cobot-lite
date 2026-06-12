// 상완 (upper arm) — v0.16: J3 팔꿈치 직결 — 후방 연장·어댑터 폐지
// =====================================================================
// 원칙: 측판 1형상 ×2 (A/B 구분 폐지 — 플립 장착 호환, 직선 빔 전제).
// 공용 홀 세트 (양 측판 동일, J2·팔꿈치 양단 동일 인터페이스):
//   J2 축(0) / 팔꿈치(L1): ⌀22 보어 + NEMA17 M3 ×4 (내면 머리 카운터보어)
//     - 팔꿈치 -Y측: 기어박스 플랜지 직결 (보어 = 파일럿)
//     - 팔꿈치 +Y측: 608ZZ 인-플레이트 압입 (아이들 피벗, 숄더 ⌀8×25)
//     - J2: 장착 인터페이스만 잔존 (J2 액추에이터 제거)
//   스탠드오프 M6: (40,0),(100,0),(160,0)
//   리미트 스위치 M2 ×2: (L1-elbow_ls_x, 0) x축 피치 — 허브 베인 감지 (-Y 내면)
include <../config/parameters.scad>
use <../lib/utils.scad>
use <../lib/vitamins.scad>

pa_in  = -arm_inner_w / 2;  pa_out = pa_in - arm_plate_t;
pb_in  =  arm_inner_w / 2;  pb_out = pb_in + arm_plate_t;
ua_standoffs = [[40, 0], [100, 0], [160, 0]];

// 관절 인터페이스 홀 세트 2D (J2·팔꿈치 공용): ⌀22 보어 + NEMA17 M3 ×4
module ua_joint_holes2d() {
    circle(d = BRG_608ZZ[1] + bearing_press_fit);   // 보어 (파일럿/608 압입 겸용)
    for (x = [-1, 1], y = [-1, 1])
        translate([x * nema17_hole_pitch / 2, y * nema17_hole_pitch / 2])
            circle(d = nema17_bolt_d + bolt_hole_oversize);
}

// 측판 2D — z 대칭 (플립 장착 동형 보장)
module ua_plate2d() {
    difference() {
        hull() {
            circle(r = arm_lug_r);
            translate([L1, 0]) circle(r = arm_lug_r);
        }
        ua_joint_holes2d();                          // J2 축
        translate([L1, 0]) ua_joint_holes2d();       // 팔꿈치 (직결 인터페이스)
        for (p = ua_standoffs) translate(p) circle(d = 6.6);   // 스탠드오프 M6
        // J3 리미트 스위치 M2 ×2 (x축 피치 — z=0 선상, z 대칭 유지)
        for (s = [-1, 1])
            translate([L1 - elbow_ls_x + s * ls_hole_pitch / 2, 0])
                circle(d = ls_hole_d);
    }
}

// 측판 (extrude z 0..7, z7 면 = 장착 포즈에서 내면 — M3 머리 카운터보어)
module ua_plate() {
    difference() {
        linear_extrude(arm_plate_t) ua_plate2d();
        for (jx = [0, L1], x = [-1, 1], y = [-1, 1])
            translate([jx + x * nema17_hole_pitch / 2,
                       y * nema17_hole_pitch / 2, arm_plate_t - 2.2])
                cylinder(d = 6.5, h = 2.3);
    }
}

// piece: "full" | "plate"
module upper_arm(piece = "full") {
    if (piece == "full") {
        translate([0, pb_out, 0]) rotate([90, 0, 0]) ua_plate();    // +Y
        translate([0, pa_out, 0]) rotate([-90, 0, 0]) ua_plate();   // -Y (z 미러)
    }
    else ua_plate();
}

// 비주얼 참조 (STL 제외) — J3 액추에이터: 팔꿈치 -Y 측판 외면 직결, 출력축 +Y
%translate([L1, pa_out, 0]) rotate([-90, 0, 0]) actuator_J3();

upper_arm();
