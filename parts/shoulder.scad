// 어깨 (shoulder) — 2-플레이트 구성 (v0.12, MEC-001)
// =====================================================================
// 단순화 이력: 일체형(새깅·5축) → 라미네이트 5피스(v0.10, 코어가 솔리드
// 슬래브 과설계) → **플레이트 2장 + 일체 스페이서 보스(v0.12)**.
// 포크 내폭(tongue_w)은 솔리드가 아니라 보스 4개가 잡는다 — 사이 공간 개방
// (배선 통로 + 경량).
// 제조 (GEN-002): 전 피스 평면 출력(FDM 서포트리스) / 평판 2.5D 절삭(CNC).
//   에지 홀 3곳(핀치 M3·리미트 M2 ×2·앵커 M3 ×2)만 2차 드릴
// 구성:
//   [plate_a] t14 (-Y) — 608ZZ ×2 관통 시트(스택=판 두께) + M6 너트 포켓(내면)
//   [plate_b] t14 (+Y) — 출력축 클램프 보어 관통(물림 14 = pivot_engage) +
//             슬릿 + 핀치 M3(에지) + 앵커 시트
//   [base]    t8 플랜지 — M5 ×4(턴테이블) + 플레이트 탭 슬롯 ×4
// 체결: 스택 M4 ×4 + **스페이서 튜브 ⌀8×31.4 ×4 (구매품 — 포크 내폭 결정)**
//       + 탭 핀 M4 ×2. 일체 보스 없음 (v0.13: 순수 플레이트 원칙)
// 하중 경로: 상완 모멘트 → [드라이브] plate_b 클램프 / [아이들] plate_a
//   608ZZ ×2 → 보스 4점(M4 예압) → 탭+핀 → 베이스 → 턴테이블
include <../config/parameters.scad>
use <../lib/utils.scad>

flange_x = shoulder_mount_px + 20;
flange_y = shoulder_mount_py + 16;
lug_r    = arm_lug_r + 2;
plate_t  = 14;                                    // = 608 ×2 = pivot_engage
gap      = tongue_w - 2 * plate_t;                // 보스 길이 31.4
plateA_y0 = -tongue_w / 2;                        // -29.7
plateB_y0 = tongue_w / 2 - plate_t;               // +15.7
flg_top  = -j2_axis_h + turntable_top_t;          // -82
// 스택 = 두꺼운 육각 스탠드오프 M6 AF13 ×3 + M6×12 볼트 양측 (v0.13 —
// 다수 스페이서 대신 소수 후육 스탠드오프). 러그 2점 + 기둥 1점
stack_bolts = [[-12, 20], [12, 20], [0, -40]];
tab_xs   = [-10, 10];

// 공통 2D 프로파일 (XZ): 러그 → 풋(26) 테이퍼 + 앵커 시트 + 탭 발
module sh_tongue2d(tabs = true) {
    union() {
        hull() {
            circle(r = lug_r);
            translate([-shoulder_tongue_x / 2, -51]) square([shoulder_tongue_x, 6]);
            translate([-13, flg_top - 0.1]) square([26, 6]);
        }
        translate([-10, 18]) square([20, 12]);     // 앵커 시트 (z 18..30)
        if (tabs)
            for (sx = tab_xs)
                translate([sx - 6, -j2_axis_h]) square([12, 10]); // 탭
    }
}

module sh_stack_holes2d() {
    for (p = stack_bolts) translate(p) circle(d = 6.6);   // M6 (스탠드오프 볼트)
}

// 경량 관통 슬롯 ×2 (양 플레이트 정렬) — 러그 후프·볼트 스파인·레일·풋 보존
module sh_lighten2d() {
    for (sx = [-10, 10])
        translate([sx, -46]) offset(r = 4) square([1, 36], center = true);
}

module lamY(y0, t) {
    translate([0, y0 + t, 0]) rotate([90, 0, 0]) linear_extrude(t) children();
}

// 탭 고정 핀 M4 ×2 (Y 관통, z=-86) — 차집합용
module sh_pin_holes() {
    for (x = tab_xs)
        translate([x, -flange_y / 2 - 1, -j2_axis_h + 4]) rotate([-90, 0, 0])
            bolt_hole(4, flange_y + 2);
}

// ── 플레이트 A (-Y): 608ZZ ×2 관통 시트 + M6 너트 포켓 ──
module shoulder_plate_a() {
    difference() {
        lamY(plateA_y0, plate_t) difference() {
            sh_tongue2d();
            circle(d = BRG_608ZZ[1] + bearing_press_fit);   // 608 ×2 관통 압입
            sh_stack_holes2d();
            sh_lighten2d();
        }
        sh_pin_holes();
        // 아이들 볼트 M6: 내면 너트 포켓 (개방 공간측 — 조립 접근 용이)
        translate([0, plateA_y0 + plate_t + 0.1, 0]) rotate([90, 0, 0])
            nut_pocket(m6_nut_af, 5.4);
        // J2 리미트 스위치 M2 ×2 (-X 에지 — 2차 드릴, 테이퍼 경사면 개구)
        translate([-30, plateA_y0 + plate_t / 2, -30]) rotate([0, 90, 0])
            ls_mount_holes(20);
    }
}

// ── 플레이트 B (+Y): 클램프 + 앵커 시트 — 순수 평판 (v0.13)
//    포크 내폭은 일체 보스가 아니라 **구매 스페이서 튜브 ⌀8×31.4 ×4**가
//    스택 볼트 위에서 결정 ──
module shoulder_plate_b() {
    difference() {
        lamY(plateB_y0, plate_t) difference() {
            sh_tongue2d();
            circle(d = gbx_out_shaft_d + clearance_fit / 2); // 클램프 관통
            translate([-1, 0]) square([2, lug_r + 2]);       // 상단 슬릿
            sh_stack_holes2d();
            sh_lighten2d();
        }
        sh_pin_holes();
        // 핀치 M3 (X 에지 — 2차 드릴)
        translate([-lug_r - 1, plateB_y0 + plate_t / 2, 13])
            rotate([0, 90, 0]) bolt_hole(3, 2 * lug_r + 2);
        // 앵커 체결 M3 ×2 (상단 에지 — 2차 드릴). pl_anchor와 정렬
        for (x = [-6, 6])
            translate([x, 23.4, 30 - 10]) cylinder(d = m3_tap_d, h = 10.1);
    }
}

// ── 베이스 플랜지: M5 ×4 + 플레이트 탭 슬롯 ×4 ──
module shoulder_base() {
    difference() {
        translate([0, 0, -j2_axis_h]) linear_extrude(turntable_top_t)
            offset(r = 6) square([flange_x - 12, flange_y - 12], center = true);
        for (x = [-1, 1], y = [-1, 1])
            translate([x * shoulder_mount_px / 2, y * shoulder_mount_py / 2,
                       -j2_axis_h - 0.1])
                bolt_hole(shoulder_mount_bolt_d, turntable_top_t + 0.2);
        // 탭 슬롯 (2 플레이트 × 2탭, 관통)
        for (py = [plateA_y0, plateB_y0], sx = tab_xs)
            translate([sx - 6 - 0.15, py - 0.15, -j2_axis_h - 0.1])
                cube([12.3, plate_t + 0.3, turntable_top_t + 0.2]);
        sh_pin_holes();
    }
}

// part: "full"(조립 표시) | "base" | "plate_a" | "plate_b"
module shoulder(part = "full") {
    if (part == "full") { shoulder_base(); shoulder_plate_a(); shoulder_plate_b(); }
    else if (part == "base") shoulder_base();
    else if (part == "plate_a") shoulder_plate_a();
    else if (part == "plate_b") shoulder_plate_b();
}

shoulder();
