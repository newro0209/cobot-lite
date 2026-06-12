// cobot-lite 진입점 — Customizer로 뷰/자세/라벨 제어
//
// part:
//   assembly  — 전체 조립 (자세 = J1~J4)
//   exploded  — 분해 뷰 (explode 거리)
//   print     — 출력 부품 전체를 출력 자세로 배치 (docs/design-notes.md §5)
//   <부품명>  — 단일 부품 (카테고리 색)
// 컬러: 정적 = 무채색 톤온톤, 동적 = 카테고리 톤온톤 (lib/colors.scad). 라벨 동색.
include <config/parameters.scad>
include <lib/colors.scad>
use <lib/utils.scad>
use <assembly/assembly.scad>
use <parts/base.scad>
use <parts/turntable.scad>
use <parts/turntable_spacer.scad>
use <parts/shoulder.scad>
use <parts/pl_anchor.scad>
use <parts/upper_arm.scad>
use <parts/j3_crank.scad>
use <parts/forearm.scad>
use <parts/drive_horn.scad>
use <parts/rocker.scad>
use <parts/wrist.scad>
use <parts/tool_flange.scad>
use <parts/cable_clip.scad>

/* [View] */
part = "assembly"; // [assembly, exploded, print, base, turntable, turntable_spacer, shoulder, shoulder_base, shoulder_plate_a, shoulder_plate_b, pl_anchor, upper_arm, upper_arm_a_root, upper_arm_a_tip, upper_arm_b_root, upper_arm_b_tip, upper_arm_doubler, j3_crank, forearm, forearm_a, forearm_b, drive_horn, drive_link, pl_link1, pl_link2, rocker, wrist, wrist_side_a, wrist_side_b, wrist_top, wrist_bottom, tool_flange, cable_clip]

/* [Pose] */
// 베이스 요(yaw)
J1 = 0;    // [-180:180]
// 어깨 피치 (월드, 0 = 수평)
J2 = 20;   // [-20:45]
// 하완 피치 (월드) — 접힘각 J3-J2 ∈ [-95, +40] 유지 (design-notes §3)
J3 = -40;  // [-80:20]
// 손목 롤
J4 = 0;    // [-180:180]

/* [Labels] */
show_labels = true;       // leader + billboard labels on assembly/exploded
label_size  = 3.2;
// 세부 라벨: 서브 피처(측판·니·혼·플레이트) + 하드웨어(베어링·볼트·너트·와셔)
label_detail = false;

/* [Hardware] */
// 베어링·볼트·너트·와셔 목업 — assembly/exploded 공통 (분해 오프셋 추종)
show_hardware = true;

/* [Exploded] */
// 분해 거리 단위 (mm)
explode = 60; // [10:150]

/* ===== 디스패치 ===== */
if (part == "assembly")
    robot(J1, J2, J3, J4, 0, show_labels, label_size, show_hardware, label_detail);
else if (part == "exploded")
    robot(J1, J2, J3, J4, explode, show_labels, label_size, show_hardware,
          label_detail);
else if (part == "print")            print_plate();
else if (part == "base")             color(C_BASE) base();
else if (part == "turntable")        color(C_TURNTABLE) turntable();
else if (part == "turntable_spacer") color(C_SPACER) turntable_spacer();
else if (part == "shoulder")         color(C_SHOULDER) shoulder();
else if (part == "shoulder_base")    color(C_SHOULDER) shoulder("base");
else if (part == "shoulder_plate_a") color(C_SHOULDER) shoulder("plate_a");
else if (part == "shoulder_plate_b") color(C_SHOULDER) shoulder("plate_b");
else if (part == "pl_anchor")        color(C_ANCHOR) pl_anchor();
else if (part == "upper_arm")        color(C_UPPERARM) upper_arm();
else if (part == "upper_arm_a_root") color(C_UPPERARM) upper_arm("a_root");
else if (part == "upper_arm_a_tip")  color(C_UPPERARM_TIP) upper_arm("a_tip");
else if (part == "upper_arm_b_root") color(C_UPPERARM) upper_arm("b_root");
else if (part == "upper_arm_b_tip")  color(C_UPPERARM_TIP) upper_arm("b_tip");
else if (part == "upper_arm_doubler") color(C_UPPERARM_TIP) upper_arm("doubler");
else if (part == "j3_crank")         color(C_CRANK) j3_crank();
else if (part == "forearm")          color(C_FOREARM) forearm();
else if (part == "forearm_a")        color(C_FOREARM) forearm("plate_a");
else if (part == "forearm_b")        color(C_FOREARM) forearm("plate_b");
else if (part == "drive_horn")       color(C_FOREARM) drive_horn();
else if (part == "drive_link")       color(C_DRIVELINK) link_bar(rear_extension + L1);
else if (part == "pl_link1")         color(C_LINK1) link_bar(L1);
else if (part == "pl_link2")         color(C_LINK2) link_bar(forearm_len);
else if (part == "rocker")           color(C_ROCKER) rocker();
else if (part == "wrist")            color(C_WRIST) wrist();
else if (part == "wrist_side_a")     color(C_WRIST) wrist("side_a");
else if (part == "wrist_side_b")     color(C_WRIST) wrist("side_b");
else if (part == "wrist_top")        color(C_WRIST) wrist("top");
else if (part == "wrist_bottom")     color(C_WRIST) wrist("bottom");
else if (part == "tool_flange")      color(C_FLANGE) tool_flange();
else if (part == "cable_clip")       color(C_CLIP) cable_clip_part();

// 출력 플레이트: 전 출력 부품을 출력 자세로 배치 (자세 근거: design-notes §5)
module print_plate() {
    color(C_BASE) base();                                          // 직립 일체
    // 어깨 2-플레이트 — 평면 출력 (v0.12: FDM/CNC 2.5D 겸용)
    color(C_SHOULDER) translate([160, 40, j2_axis_h]) shoulder("base");
    color(C_SHOULDER) translate([255, 60, tongue_w / 2]) rotate([90, 0, 0])
        shoulder("plate_a");                     // 외면 베드
    color(C_SHOULDER) translate([255, -80, tongue_w / 2]) rotate([-90, 0, 0])
        shoulder("plate_b");                     // 외면 베드, 보스 상향
    color(C_TURNTABLE) translate([290, 0, 75])
        rotate([180, 0, 0]) turntable();                           // 도립 (상판 베드)
    color(C_SPACER) translate([385, 0, 0]) turntable_spacer();
    color(C_FLANGE) translate([460, 0, 0]) tool_flange();          // 디스크 하면 z0
    // 정적 핀 앵커 — -X면 눕혀 출력 (전 형상 평면 내)
    color(C_ANCHOR) translate([395, -90, 10]) rotate([0, 90, 0]) pl_anchor();

    // 상완 측판 4피스 + 더블러 ×2 — 전부 평판 (병렬 출력 단위, v0.13)
    color(C_UPPERARM) translate([130, -150, arm_inner_w / 2 + arm_plate_t])
        rotate([-90, 0, 0]) upper_arm("a_root");
    color(C_UPPERARM_TIP) translate([-90, -150, arm_inner_w / 2 + arm_plate_t])
        rotate([-90, 0, 0]) upper_arm("a_tip");
    color(C_UPPERARM) translate([130, -215, arm_inner_w / 2 + arm_plate_t])
        rotate([90, 0, 0]) upper_arm("b_root");
    color(C_UPPERARM_TIP) translate([-90, -215, arm_inner_w / 2 + arm_plate_t])
        rotate([90, 0, 0]) upper_arm("b_tip");
    color(C_UPPERARM_TIP) for (i = [0, 1])
        translate([240 - 115, -260 - 50 * i, 0]) upper_arm("doubler");

    // 하완 측판 ×2 — 평판 (277mm — 베드 대각 배치)
    color(C_FOREARM) translate([30, -320, forearm_inner_w / 2 + arm_plate_t])
        rotate([-90, 0, 0]) forearm("plate_a");
    color(C_FOREARM) translate([30, -380, forearm_inner_w / 2 + arm_plate_t])
        rotate([90, 0, 0]) forearm("plate_b");
    // 구동 혼 — 장착면 베드
    color(C_FOREARM) translate([420, -300, 0]) drive_horn();

    // 링크류 — 평면 그대로
    color(C_DRIVELINK) translate([10, -400, 0]) link_bar(rear_extension + L1);
    color(C_LINK1)     translate([10, -435, 0]) link_bar(L1);
    color(C_LINK2)     translate([10, -470, 0]) link_bar(forearm_len);
    color(C_CRANK)     translate([360, -400, 0]) j3_crank();
    color(C_ROCKER)    translate([360, -445, 0]) rocker();

    // 손목 4피스 — 전부 평판 (v0.13)
    color(C_WRIST) translate([330, -120, arm_inner_w / 2 + arm_plate_t])
        rotate([-90, 0, 0]) wrist("side_a");
    color(C_WRIST) translate([330, -190, arm_inner_w / 2 + arm_plate_t])
        rotate([90, 0, 0]) wrist("side_b");
    color(C_WRIST) translate([330, -260, (arm_lug_r + 4) + arm_plate_t])
        wrist("top");
    color(C_WRIST) translate([330, -330,
        (arm_lug_r + 4) + arm_plate_t + (gbx_out_shaft_len + 5) + arm_plate_t])
        wrist("bottom");

    // 케이블 클립 ×6
    color(C_CLIP) for (i = [0 : 5])
        translate([440 + (i % 3) * 30, -400 - floor(i / 3) * 30, 0])
            cable_clip_part();
}
