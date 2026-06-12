// cobot-lite 진입점 — Customizer로 뷰/자세/라벨 제어
//
// part:
//   assembly  — 전체 조립 (자세 = J1~J4)
//   exploded  — 분해 뷰 (explode 거리)
//   print     — 출력 부품 전체를 출력 자세로 배치 (docs/design-notes.md §5)
//   <부품명>  — 단일 부품 (카테고리 색)
// v0.15: _a/_b 측판 폐지 — 동일 형상 1종 ×2. 한쪽 전용 기능은 볼트온 소부품
// (shoulder_clamp / shoulder_anchor / ua_adapter / ua_bush / wrist_horn)
include <config/parameters.scad>
include <lib/colors.scad>
use <lib/utils.scad>
use <assembly/assembly.scad>
use <parts/base.scad>
use <parts/turntable.scad>
use <parts/shoulder.scad>
use <parts/upper_arm.scad>
use <parts/j3_crank.scad>
use <parts/forearm.scad>
use <parts/drive_horn.scad>
use <parts/rocker.scad>
use <parts/wrist.scad>
use <parts/tool_flange.scad>
use <parts/cable_clip.scad>

/* [View] */
part = "assembly"; // [assembly, exploded, print, base, j1_disc, turntable, shoulder, shoulder_plate, shoulder_clamp, shoulder_anchor, shoulder_flange, upper_arm, upper_arm_plate, ua_adapter, ua_bush, j3_crank, forearm, forearm_plate, drive_horn, drive_link, pl_link1, pl_link2, rocker, wrist, wrist_side, wrist_bottom, wrist_horn, tool_flange, cable_clip]

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
// 세부 라벨: 서브 피처(측판·혼·디스크) + 하드웨어(베어링·볼트·너트·와셔)
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
else if (part == "j1_disc")          color(C_BASE) j1_disc();
else if (part == "turntable")        color(C_TURNTABLE) turntable();
else if (part == "shoulder")         color(C_SHOULDER) shoulder();
else if (part == "shoulder_plate")   color(C_SHOULDER) shoulder("plate");
else if (part == "shoulder_clamp")   color(C_SHOULDER) shoulder("clamp");
else if (part == "shoulder_anchor")  color(C_SHOULDER) shoulder("anchor");
else if (part == "shoulder_flange")  color(C_SHOULDER) shoulder("flange");
else if (part == "upper_arm")        color(C_UPPERARM) upper_arm();
else if (part == "upper_arm_plate")  color(C_UPPERARM) upper_arm("plate");
else if (part == "ua_adapter")       color(C_UPPERARM) upper_arm("adapter");
else if (part == "ua_bush")          color(C_UPPERARM) upper_arm("bush");
else if (part == "j3_crank")         color(C_CRANK) j3_crank();
else if (part == "forearm")          color(C_FOREARM) forearm();
else if (part == "forearm_plate")    color(C_FOREARM) forearm("plate");
else if (part == "drive_horn")       color(C_FOREARM) drive_horn();
else if (part == "drive_link")       color(C_DRIVELINK) link_bar(rear_extension + L1);
else if (part == "pl_link1")         color(C_LINK1) link_bar(L1);
else if (part == "pl_link2")         color(C_LINK2) link_bar(forearm_len);
else if (part == "rocker")           color(C_ROCKER) rocker();
else if (part == "wrist")            color(C_WRIST) wrist();
else if (part == "wrist_side")       color(C_WRIST) wrist("side");
else if (part == "wrist_bottom")     color(C_WRIST) wrist("bottom");
else if (part == "wrist_horn")       color(C_WRIST) wrist("horn");
else if (part == "tool_flange")      color(C_FLANGE) tool_flange();
else if (part == "cable_clip")       color(C_CLIP) cable_clip_part();

// 출력 플레이트: 전 출력 부품을 출력 자세로 배치 (자세 근거: design-notes §5)
// 동일 측판은 같은 형상 ×수량 — 한 종만 배치하고 수량은 BOM이 관리
module print_plate() {
    color(C_BASE) base();                                          // 직립 일체
    color(C_BASE) translate([110, -90, 0]) j1_disc();
    color(C_TURNTABLE) translate([170, 0, 83]) turntable();        // 도립 (상판 베드)
    // 어깨: 측판 ×2 (동일) + 클램프 디스크 + 앵커 + 플랜지
    color(C_SHOULDER) for (i = [0, 1])
        translate([260 + i * 105, 80, 0]) shoulder("plate");
    color(C_SHOULDER) translate([250, -40, 0]) shoulder("clamp");
    color(C_SHOULDER) translate([330, -40, 0]) shoulder("anchor");
    color(C_SHOULDER) translate([300, -120, 0]) shoulder("flange");
    color(C_FLANGE) translate([420, -40, 0]) tool_flange();

    // 상완 측판 ×2 (동일, 단일 피스 365 — FDM 베드 대각 배치) + 어댑터 + 부시
    color(C_UPPERARM) for (i = [0, 1])
        translate([130, -170 - 70 * i, 0]) upper_arm("plate");
    color(C_UPPERARM) translate([460, -120, 0]) upper_arm("adapter");
    color(C_UPPERARM) translate([460, -50, 0]) upper_arm("bush");

    // 하완 측판 ×2 (동일, 277 — 베드 대각 배치)
    color(C_FOREARM) for (i = [0, 1])
        translate([130, -320 - 60 * i, 0]) forearm("plate");
    color(C_FOREARM) translate([460, -190, 0]) drive_horn();

    // 링크류 — 평면 그대로
    color(C_DRIVELINK) translate([10, -450, 0]) link_bar(rear_extension + L1);
    color(C_LINK1)     translate([10, -485, 0]) link_bar(L1);
    color(C_LINK2)     translate([10, -520, 0]) link_bar(forearm_len);
    color(C_CRANK)     translate([380, -450, 0]) j3_crank();
    color(C_ROCKER)    translate([380, -495, 0]) rocker();

    // 손목: 측판 ×2 (동일) + 바텀 + 혼 패들
    color(C_WRIST) for (i = [0, 1])
        translate([500 + i * 130, 60, 0]) wrist("side");
    color(C_WRIST) translate([500, -40, 0]) translate([-wb_x0, 35, 0]) wrist("bottom");
    color(C_WRIST) translate([590, -60, 0]) wrist("horn");

    // 케이블 클립 ×6
    color(C_CLIP) for (i = [0 : 5])
        translate([500 + (i % 3) * 30, -120 - floor(i / 3) * 30, 0])
            cable_clip_part();
}
