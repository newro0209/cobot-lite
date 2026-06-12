// 구동 혼 (drive horn) — 볼트온, 하완 측판 A' 외면 장착 (MEC-001a)
// =====================================================================
// 구 일체형 혼(브리지+플레이트)은 어떤 출력 자세에서도 캔틸레버 오버행
// 발생 → 별도 평면 출력 부품으로 분리 (v0.9 교차 검증).
// 좌표계: z0 = 장착면(측판 A' 외면, 조립 y=-21.3), +z = 외측(-Y),
//        +X = 혼 방향 (조립 시 하완 +90° 방향 = 크랭크와 평행사변형 쌍)
// 출력 자세: 장착면(플랜지) 베드 — 전 형상 수직 벽/상향 축소, 서포트 불요
// 체결: M4 FHCS ×3 (r17 볼트 서클) — 구동 링크 력 ≈ 108 N 전단을 M4 ×3이
//   분담(≈36 N/개). 레지스터 보스 폐지 (v0.15 — 동일 측판 양측 장착 호환)
// 핀: 5mm 숄더 볼트 (M4 파일럿, 상면에서) — 링크 평면(y≈-52)과 정렬
include <../config/parameters.scad>
use <../lib/utils.scad>

// 두께 = 링크 평면 혼 외면(47.5) − 측판 A' 외면(21.3)
horn_th = (arm_inner_w / 2 + arm_plate_t + 3.5 + crank_t)
        - (forearm_inner_w / 2 + arm_plate_t);

// 2단(two-tier) 구조 (v0.14 — 렌더/그리드 교차 검증):
//   [티어 1: 장착 칼라] t7 — 관절 측면 갭(8mm) 안에 수납. v0.13 관절 반전으로
//     상완 측판 A 러그(r26)가 같은 Y존에 있어, 전체 두께 칼라는 상시 간섭 → 박형화.
//     M4 ×3은 접시머리(FHCS)로 갭 내 플러시
//   [티어 2: 암] r ≥ 29.5 환형 밖에서만 전체 두께 — 상완 러그 스윕(r26)과
//     반경 분리(3.5mm). 핀 보스 ⌀16
module drive_horn() {
    difference() {
        union() {
            // 티어 1: 장착 칼라 (⌀44 + 암 루트 헐, t7)
            linear_extrude(arm_plate_t) hull() {
                circle(d = 44);
                translate([j3_crank_len, 0]) circle(d = 16);
            }
            // 티어 2: 암 (r 29.5 → 핀 보스, 전체 두께)
            linear_extrude(horn_th) hull() {
                translate([29.5, -8]) square([4, 16]);
                translate([j3_crank_len, 0]) circle(d = 16);
            }
        }
        // 팔꿈치 볼트 머리·와셔 도피 (관통)
        translate([0, 0, -0.1]) cylinder(d = 17, h = horn_th + 0.2);
        // M4 ×3 (r17): 접시머리(FHCS) — 칼라 t7 내 플러시
        for (a = [90, 210, 330]) rotate([0, 0, a]) {
            translate([horn_mount_r_local(), 0, -0.1])
                bolt_hole(4, arm_plate_t + 0.2);
            translate([horn_mount_r_local(), 0, arm_plate_t - 2.2])
                cylinder(d1 = 4.4, d2 = 9, h = 2.3);
        }
        // 구동 링크 핀: M4 파일럿 (상면에서, 5mm 숄더 볼트)
        translate([j3_crank_len, 0, horn_th - 12])
            cylinder(d = set_screw_pilot_d, h = 12.1);
    }
}

function horn_mount_r_local() = 17;   // forearm.scad horn_mount_r와 동기

drive_horn();
