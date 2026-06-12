// cobot-lite 진입점 — Customizer로 뷰/자세/라벨 제어
//
// part:
//   assembly  — 전체 조립 (자세 = J2~J3)
//   exploded  — 분해 뷰 (explode 거리)
//   print     — 출력 부품 전체를 출력 자세로 배치
//   <부품명>  — 단일 부품 (카테고리 색)
// 베이스~어깨·손목 이후 제거 — 체인 = 상완→하완 (원점 = J2 축).
// J3 직결 (v0.16): 평행사변형(크랭크·링크·혼)·후방 연장·어댑터 폐지.
// 동일 측판 1형상 ×2 원칙 유지. 한쪽 전용 기능은 볼트온 소부품 (elbow_hub)
include <config/parameters.scad>
include <lib/colors.scad>
use <lib/utils.scad>
use <assembly/assembly.scad>
use <parts/upper_arm.scad>
use <parts/forearm.scad>
use <parts/elbow_hub.scad>
use <parts/cable_clip.scad>

/* [View] */
part = "assembly"; // [assembly, exploded, print, upper_arm, upper_arm_plate, forearm, forearm_plate, elbow_hub, cable_clip]

/* [Pose] */
// 어깨 피치 (월드, 0 = 수평)
J2 = 20;   // [-20:45]
// 하완 피치 (월드) — 접힘각 J3-J2 ∈ [-140, +20] 유지 (직결 — 간섭 한계)
J3 = -40;  // [-160:65]

/* [Labels] */
show_labels = true;       // leader + billboard labels on assembly/exploded
label_size  = 3.2;
// 세부 라벨: 서브 피처(측판·허브 베인) + 하드웨어(베어링·볼트·너트·와셔)
label_detail = false;

/* [Hardware] */
// 베어링·볼트·너트·와셔 목업 — assembly/exploded 공통 (분해 오프셋 추종)
show_hardware = true;

/* [Exploded] */
// 분해 거리 단위 (mm)
explode = 60; // [10:150]

/* ===== 디스패치 ===== */
if (part == "assembly")
    robot(J2, J3, 0, show_labels, label_size, show_hardware, label_detail);
else if (part == "exploded")
    robot(J2, J3, explode, show_labels, label_size, show_hardware,
          label_detail);
else if (part == "print")            print_plate();
else if (part == "upper_arm")        color(C_UPPERARM) upper_arm();
else if (part == "upper_arm_plate")  color(C_UPPERARM) upper_arm("plate");
else if (part == "forearm")          color(C_FOREARM) forearm();
else if (part == "forearm_plate")    color(C_FOREARM) forearm("plate");
else if (part == "elbow_hub")        color(C_FOREARM) elbow_hub();
else if (part == "cable_clip")       color(C_CLIP) cable_clip_part();

// 출력 플레이트: 전 출력 부품을 출력 자세로 배치
// 동일 측판은 같은 형상 ×수량 — 한 종만 배치하고 수량은 BOM이 관리
module print_plate() {
    // 상완 측판 ×2 (동일, 단일 피스 277 — FDM 베드 대각 배치)
    color(C_UPPERARM) for (i = [0, 1])
        translate([130, -170 - 70 * i, 0]) upper_arm("plate");

    // 하완 측판 ×2 (동일, 277 — 베드 대각 배치)
    color(C_FOREARM) for (i = [0, 1])
        translate([130, -320 - 60 * i, 0]) forearm("plate");

    // 팔꿈치 허브 — 평면 그대로 (장착면 베드, 서포트 불요)
    color(C_FOREARM) translate([460, -190, 0]) elbow_hub();

    // 케이블 클립 ×6
    color(C_CLIP) for (i = [0 : 5])
        translate([500 + (i % 3) * 30, -120 - floor(i / 3) * 30, 0])
            cable_clip_part();
}
