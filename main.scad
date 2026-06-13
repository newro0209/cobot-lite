// cobot-lite 진입점 — Customizer로 뷰/자세 제어
//
// part:
//   assembly  — 전체 조립 (자세 = J2/J3)
//   exploded  — 분해 뷰 (explode 거리)
//   print     — 출력 부품 전체를 출력 자세로 배치
//   <부품명>  — 단일 부품 (호출부 지정 색)
//
// 원점은 J2 축이며 상완/하완은
// 꺾임 빔, J3는 크랭크→링크→혼 평행사변형 원격 구동으로 유지한다.
include <config/parameters.scad>
include <lib/colors.scad>
use <assembly/assembly.scad>
use <parts/upper_arm.scad>
use <parts/forearm.scad>
use <parts/j3_crank.scad>
use <parts/drive_link.scad>
use <parts/cable_clip.scad>

/* [View] */
part = "assembly"; // [assembly, exploded, print, upper_arm, upper_arm_plate, forearm, forearm_plate, j3_crank, drive_link, cable_clip]

/* [Pose] */
// 상완 현 피치 (월드, 0 = 수평)
J2 = 30;   // [0:75]
// 하완 현 피치 (월드) — 접힘각 J3-J2 ∈ [-132, -15] 유지 (0° = 특이점)
J3 = -30;  // [-120:55]

/* [Hardware] */
// 베어링·볼트·너트·스페이서 목업 — assembly/exploded 공통
show_hardware = true;

/* [Exploded] */
// 분해 거리 단위 (mm)
explode = 60; // [10:150]

/* ===== 디스패치 ===== */
if (part == "assembly")
    robot(J2, J3, 0, show_hardware);
else if (part == "exploded")
    robot(J2, J3, explode, show_hardware);
else if (part == "print")
    print_plate();
// 색상은 호출부에서 전달. parts 레이어는 색상 상수를 직접 참조하지 않음.
else if (part == "upper_arm")
    upper_arm(col = C_UPPERARM_POS, col2 = C_UPPERARM_NEG);
else if (part == "upper_arm_plate")
    upper_arm("plate", col = C_UPPERARM_POS);
else if (part == "forearm")
    forearm(col = C_FOREARM_POS, col2 = C_FOREARM_NEG);
else if (part == "forearm_plate")
    forearm("plate", col = C_FOREARM_POS);
else if (part == "j3_crank")
    j3_crank(col = C_J3_CRANK);
else if (part == "drive_link")
    drive_link(col = C_DRIVE_LINK);
else if (part == "cable_clip")
    cable_clip_part(col = C_CABLE_CLIP_A);

// 출력 플레이트: 전 출력 부품을 출력 자세로 배치
// 동일 측판/플레이트는 같은 형상 ×수량 — 한 종만 배치, 수량은 BOM이 관리
module print_plate() {
    // 상완 측판 ×2 (동일)
    for (i = [0, 1])
        translate([-170, -130 - 75 * i, 0])
            upper_arm("plate", col = (i == 0 ? C_UPPERARM_POS : C_UPPERARM_NEG));

    // 하완 측판 ×2 (동일)
    for (i = [0, 1])
        translate([120, -130 - 75 * i, 0])
            forearm("plate", col = (i == 0 ? C_FOREARM_POS : C_FOREARM_NEG));

    translate([390, -155, 0]) j3_crank(col = C_J3_CRANK);
    translate([-170, -305, 0]) drive_link(col = C_DRIVE_LINK);

    // 케이블 클립 ×6
    for (i = [0 : 5])
        translate([390 + (i % 3) * 30, -280 - floor(i / 3) * 30, 0])
            cable_clip_part(col = (i % 2 == 0 ? C_CABLE_CLIP_A : C_CABLE_CLIP_B));
}
