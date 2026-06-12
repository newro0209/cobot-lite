// 하완 (forearm) — 순수 플레이트 아키텍처 (v0.13, MEC-001/004/006)
// =====================================================================
// 구성: 평판 측판 2장 (A/-Y, B/+Y, t7 = 608ZZ 폭) + 스페이서 튜브 ⌀10 ×4
//   (M4 관통) — 웹·분할 보스 폐기. 개방 프레임
// 관절 (v0.13 반전): 팔꿈치·손목 608ZZ를 **측판에 직접 압입** (관통 d21.85)
//   — 숄더 볼트 위 내측 스페이서 튜브 ⌀12×30.6이 내륜 간격 유지,
//   상완/손목 측판과는 측면 스페이서 ⌀12×7.2로 이격 (조립 스택은 BOM ①②)
// 구동 혼: 볼트온 부품(drive_horn) — 측판 A 외면 M4 ×3 + 레지스터 보스 ⌀5
// 꺾임: fa_bend_deg/_pos (§design-notes 3b). 길이 277 — 베드 대각 배치 (분할 불요)
// 제조: 평판 — FDM 평면 / CNC 2.5D (GEN-002)
include <../config/parameters.scad>
use <../lib/utils.scad>

fi = forearm_inner_w / 2;
fo = fi + arm_plate_t;
flen = forearm_len;
horn_mount_r = 17;
fa_knee_x = forearm_len * fa_bend_pos;
fa_knee_h = forearm_len * fa_bend_pos * (1 - fa_bend_pos) * tan(fa_bend_deg);
function fa_cz(x) = x < fa_knee_x ? fa_knee_h * x / fa_knee_x
                                  : fa_knee_h * (flen - x) / (flen - fa_knee_x);

// 두꺼운 육각 스탠드오프 M6 AF13 ×2, L=fork_standoff_len (v0.13).
// 중심선 위 배치 — 창(55/97/139/181, r14) 사이 솔리드 띠에 홀
fa_standoffs = [76, 160];

// 측판 외곽 2D: 러그-니 캡슐 체인
module fa_plate2d() {
    union() {
        hull() {
            circle(r = arm_lug_r);
            translate([fa_knee_x, fa_knee_h]) circle(r = arm_lug_r - 3);
        }
        hull() {
            translate([fa_knee_x, fa_knee_h]) circle(r = arm_lug_r - 3);
            translate([flen, 0]) circle(r = arm_lug_r);
        }
    }
}

// 공통 홀 2D: 양단 608ZZ 관통 압입 + 스페이서 + 경량창
module fa_holes2d() {
    for (x = [0, flen])
        translate([x, 0]) circle(d = BRG_608ZZ[1] + bearing_press_fit);
    for (x = fa_standoffs) translate([x, fa_cz(x)]) circle(d = 6.6); // M6
    for (x = [55 : 42 : flen - 50])
        translate([x, fa_cz(x)])
            circle(d = 2 * (arm_lug_r - 3) - 2 * beam_wall - 10);
}

// half: "full"(조립 표시) | "plate_a"(-Y, 혼 마운트측) | "plate_b"(+Y)
module forearm(half = "full") {
    if (half == "full") { fa_plate_a(); fa_plate_b(); }
    else if (half == "plate_a") fa_plate_a();
    else fa_plate_b();
}

// ── 측판 A (-Y): 구동 혼 마운트 ──
module fa_plate_a() {
    difference() {
        union() {
            translate([0, -fi, 0]) rotate([90, 0, 0]) linear_extrude(arm_plate_t)
                difference() { fa_plate2d(); fa_holes2d(); }
            // 구동 혼 레지스터 보스 (외면 ⌀5×3 — 108N 전단 전달.
            // 각도: 혼 로컬각 + 90° = 하완각 120°)
            rotate([0, -120, 0]) translate([horn_mount_r, -fo, 0])
                rotate([90, 0, 0]) cylinder(d = 5, h = 3);
        }
        // 구동 혼 체결 M4 ×3 (하완각 180/300/60 = 혼 로컬 90/210/330 + 90)
        for (a = [180, 300, 60])
            rotate([0, -a, 0]) translate([horn_mount_r, -fo - 0.1, 0])
                rotate([-90, 0, 0]) cylinder(d = set_screw_pilot_d,
                                             h = arm_plate_t + 0.2);
    }
}

// ── 측판 B (+Y) ──
module fa_plate_b() {
    translate([0, fo, 0]) rotate([90, 0, 0]) linear_extrude(arm_plate_t)
        difference() { fa_plate2d(); fa_holes2d(); }
}

forearm();
