// cobot-lite 진입점 — Customizer로 뷰/자세/라벨 제어
//
// part:
//   assembly  — 전체 조립 (자세 = J1~J3)
//   exploded  — 분해 뷰 (explode 거리)
//   print     — 출력 부품 전체를 출력 자세로 배치
//   <부품명>  — 단일 부품 (호출부 지정 색)
// v0.17: J1~J3 모터 전부 하부 (J1 베이스 직결, J2/J3 타워 동축 — J3는
// 크랭크→링크→혼 평행사변형 원격 구동, 링크·혼 = 상완 포크 내부).
// 상완/하완 = 꺾임 빔 (15°/30°). 원점 = J1 축 ∩ 베이스판 상면.
include <config/parameters.scad>
include <lib/colors.scad>
use <lib/utils.scad>
use <assembly/assembly.scad>
use <parts/base_plate.scad>
use <parts/j1_ring.scad>
use <parts/turret_plate.scad>
use <parts/tower_plate.scad>
use <parts/foot_bracket.scad>
use <parts/drive_hub.scad>
use <parts/upper_arm.scad>
use <parts/forearm.scad>
use <parts/j3_crank.scad>
use <parts/drive_link.scad>
use <parts/cable_clip.scad>

/* [View] */
part = "assembly"; // [assembly, exploded, print, base_plate, j1_ring, turret_plate, tower_plate, foot_bracket, drive_hub_j2, upper_arm, upper_arm_plate, forearm, forearm_plate, j3_crank, drive_link, cable_clip]

/* [Pose] */
// J1 요 (deg)
J1 = 0;    // [-90:90]
// 상완 현 피치 (월드, 0 = 수평)
J2 = 30;   // [0:75]
// 하완 현 피치 (월드) — 접힘각 J3-J2 ∈ [-132, -15] 유지 (0° = 특이점)
J3 = -30;  // [-160:55]

/* [Labels] */
show_labels = true;       // leader + billboard labels on assembly/exploded
label_size  = 3.2;
// 세부 라벨: 얇은 지시선 + 순번만 표시. 부품/와셔/유틸 피처 매핑은 assembly/assembly.scad 주석 참조
label_detail = false;

/* [Hardware] */
// 베어링·볼트·너트·스페이서 목업 — assembly/exploded 공통
show_hardware = true;

/* [Exploded] */
// 분해 거리 단위 (mm)
explode = 60; // [10:150]

/* ===== 디스패치 ===== */
if (part == "assembly")
    robot(J1, J2, J3, 0, show_labels, label_size, show_hardware,
          label_detail);
else if (part == "exploded")
    robot(J1, J2, J3, explode, show_labels, label_size, show_hardware,
          label_detail);
else if (part == "print")            print_plate();
// 색상은 호출부에서 전달. parts 레이어는 색상 상수를 직접 참조하지 않음.
else if (part == "base_plate")       base_plate(col = C_BASE_CARRIER);
else if (part == "j1_ring")          j1_ring(col = C_BASE_RING);
else if (part == "turret_plate")     turret_plate(col = C_TURRET_PLATE);
else if (part == "tower_plate")      tower_plate(col = C_TOWER_POS);
else if (part == "foot_bracket")     foot_bracket(col = C_FOOT_A);
else if (part == "drive_hub_j2")     drive_hub("j2", col = C_HUB_J2);
else if (part == "upper_arm")        upper_arm(col = C_UPPERARM_POS, col2 = C_UPPERARM_NEG);
else if (part == "upper_arm_plate")  upper_arm("plate", col = C_UPPERARM_POS);
else if (part == "forearm")          forearm(col = C_FOREARM_POS, col2 = C_FOREARM_NEG);
else if (part == "forearm_plate")    forearm("plate", col = C_FOREARM_POS);
else if (part == "j3_crank")         j3_crank(col = C_J3_CRANK);
else if (part == "drive_link")       drive_link(col = C_DRIVE_LINK);
else if (part == "cable_clip")       cable_clip_part(col = C_CABLE_CLIP_A);

// 출력 플레이트: 전 출력 부품을 출력 자세로 배치
// 동일 측판/플레이트는 같은 형상 ×수량 — 한 종만 배치, 수량은 BOM이 관리
module print_plate() {
    // 출력 배치에서도 같은 부품 반복 사용 시 톤 차이 부여.
    // 베이스 플레이트 ×2 (동일 — 지면판 + 캐리어판)
    for (i = [0, 1])
        translate([0, i * (base_size + 15), 0])
            base_plate(col = (i == 0 ? C_BASE_CARRIER : C_BASE_GROUND));
    translate([-base_size / 2 - 60, 0, 0]) j1_ring(col = C_BASE_RING);
    translate([-base_size / 2 - 180, 0, 0]) turret_plate(col = C_TURRET_PLATE);
    // 타워 플레이트 ×2 (동일, 플립 쌍)
    for (i = [0, 1])
        translate([-base_size / 2 - 200, -base_size / 2 - 120 - 100 * i, 0])
            tower_plate(col = (i == 0 ? C_TOWER_POS : C_TOWER_NEG));
    // 풋 브래킷 ×4 (측면 눕힘)
    for (i = [0 : 3])
        translate([-base_size / 2 - 60 + 35 * i, -base_size / 2 - 100, 0])
            rotate([0, -90, 0]) foot_bracket(col = (i % 2 == 0 ? C_FOOT_A : C_FOOT_B));
    translate([-base_size / 2 - 60, 150, 0]) drive_hub("j2", col = C_HUB_J2);
    // 상완 측판 ×2 (동일, ~277 — 베드 대각 배치)
    for (i = [0, 1])
        translate([130, -170 - 75 * i, 0])
            upper_arm("plate", col = (i == 0 ? C_UPPERARM_POS : C_UPPERARM_NEG));
    // 하완 측판 ×2 (동일, ~277 — 베드 대각 배치)
    for (i = [0, 1])
        translate([130, -340 - 75 * i, 0])
            forearm("plate", col = (i == 0 ? C_FOREARM_POS : C_FOREARM_NEG));
    translate([460, -250, 0]) j3_crank(col = C_J3_CRANK);
    translate([130, -490, 0]) drive_link(col = C_DRIVE_LINK);
    // 케이블 클립 ×6
    for (i = [0 : 5])
        translate([500 + (i % 3) * 30, -120 - floor(i / 3) * 30, 0])
            cable_clip_part(col = (i % 2 == 0 ? C_CABLE_CLIP_A : C_CABLE_CLIP_B));
}
