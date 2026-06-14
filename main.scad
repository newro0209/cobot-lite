// cobot-lite 진입점 — 커스터마이저(Customizer)로 뷰(view)와 자세(pose)를 제어합니다.
//
// 용어
// 1. 커스터마이저(Customizer)
// 2. 뷰(View)
// 3. 자세(Pose)
// 4. 조립체(Assembly)
// 5. 분해도(Exploded view)
// 6. 출력 플레이트(Print plate)
//
// part:
//   assembly  — 전체 조립체(assembly), 자세(pose) = J2/J3
//   exploded  — 분해도(exploded view), explode 거리 적용
//   print     — 출력 부품 전체를 출력 자세(print orientation)로 배치
//   <부품명>  — 단일 부품
//
// 원점(origin)은 J2 축(axis)입니다.
// 상완(upper arm)과 하완(forearm)은 꺾임 빔(bent beam)이며,
// J3는 크랭크(crank)→링크(link)→혼(horn) 평행사변형(parallelogram) 원격 구동(remote drive)으로 유지합니다.

use <assembly/assembly.scad>
use <parts/upper_arm.scad>
use <parts/forearm.scad>
use <parts/j3_crank.scad>
use <parts/drive_link.scad>
use <lib/vitamins/bearing_608zz.scad>
use <lib/vitamins/bearing_625zz.scad>
use <lib/vitamins/kw12_limit_switch.scad>

$fa = 6;
$fs = 0.8;

/* [View] */
part = "assembly"; // [assembly, exploded, print, upper_arm_plate, forearm_plate, j3_crank, drive_link, bearing_608zz, bearing_625zz, kw12_limit_switch]

/* [Pose] */
// 상완 현(chord) 피치(pitch)입니다. 월드(world) 기준 0도는 수평입니다.
J2 = 30;   // [0:75]
// 하완 현(chord) 피치(pitch)입니다. 접힘각(fold angle) J3-J2는 [-132, -15] 범위를 유지합니다.
// 0도는 현(chord)이 일직선이 되는 특이점(singularity)입니다.
J3 = -30;  // [-120:55]

/* [Hardware] */
// 베어링(bearing)·볼트(bolt)·너트(nut)·스페이서(spacer) 목업(mockup)은 조립체(assembly)와 분해도(exploded view)에 공통으로 사용합니다.
show_hardware = true;

/* [Exploded] */
// 분해 거리(explode distance)의 단위는 밀리미터(mm)입니다.
explode = 60; // [10:150]

/* ===== 디스패치 ===== */
module main_dispatch(view = "assembly", j2 = 30, j3 = -30, hardware = true, explode_mm = 60) {
    if (view == "assembly")
        robot(j2 = j2, j3 = j3, explode_distance = 0, hardware = hardware);
    else if (view == "exploded")
        robot(j2 = j2, j3 = j3, explode_distance = explode_mm, hardware = hardware);
    else if (view == "print")
        print_plate();
    else if (view == "upper_arm_plate")
        upper_arm_plate(col = [0, 0, 1]);
    else if (view == "forearm_plate")
        forearm_plate();
    else if (view == "j3_crank")
        j3_crank();
    else if (view == "drive_link")
        drive_link();
    else if (view == "bearing_608zz")
        bearing_608zz();
    else if (view == "bearing_625zz")
        bearing_625zz();
    else if (view == "kw12_limit_switch")
        kw12_limit_switch();
}

// 출력 플레이트(print plate): 전 출력 부품을 출력 자세(print orientation)로 배치합니다.
// 동일 측판(side plate)과 플레이트(plate)는 한 종만 배치하고, 수량은 자재 명세서(BOM)가 관리합니다.
module print_plate() {
    // 상완 측판 ×2 (동일)
    for (i = [0, 1])
        translate([-170, -130 - 75 * i, 0])
            upper_arm_plate(col = [0, 0, 1] * (i == 0 ? 1 : 0.75));

    // 하완 측판 ×2 (동일)
    for (i = [0, 1])
        translate([120, -130 - 75 * i, 0])
            forearm_plate();

    translate([390, -155, 0]) j3_crank();
    translate([-170, -305, 0]) drive_link();
}

main_dispatch(view = part, j2 = J2, j3 = J3, hardware = show_hardware, explode_mm = explode);
