// 상완 (upper arm) — 순수 플레이트 아키텍처 (v0.13, MEC-001/004/006)
// =====================================================================
// 구성: 평판 측판 2장 (A/-Y, B/+Y, t7) + 표준 스페이서 튜브 ⌀10 ×6 (M4 관통)
//   — 일체 보스·웹·보·텅·리드 전부 폐기. 위에서 보면 막힘 없음(개방 프레임)
// 길이 365 > 빌드 대각 한계 → 각 측판을 x=ua_split_x에서 **맞대기 분할 +
//   스플라이스 더블러(평판, M4 ×4)** — 구 테논/소켓 tip 폐기
// 관절 (v0.13 반전): 팔꿈치 608ZZ는 **하완 플레이트에 압입** — 상완 측판은
//   ⌀8 숄더 볼트 클램프 홀만 (텅 삭제, MEC-004 분담 의도 유지)
// 제조: 전 피스 평판 — FDM 평면 출력 / CNC 2.5D (GEN-002)
// 인터페이스:
//   [B 외면] J2 액추에이터 NEMA17 (MEC-001b — 출력축은 어깨 plate_b 클램프로)
//   [A]      J2 아이들 ⌀8 홀 + 머리 카운터보어 / J3 NEMA17 (MEC-001c) /
//            J3 리미트 홀 / J2 베인(평면 외곽 범프)
//   [B]      J3 모터 몸체 통과 d44
// 프로파일: 러그 3점(후방/J2/팔꿈치) + 니(knee) 캡슐 체인 (꺾임 §3b),
//   x28~62 상단 트림 — 어깨 앵커 스윕(z<38, y30~37) 회피
include <../config/parameters.scad>
use <../lib/utils.scad>
use <../lib/vitamins.scad>

pa_in  = -arm_inner_w / 2;  pa_out = pa_in - arm_plate_t;
pb_in  =  arm_inner_w / 2;  pb_out = pb_in + arm_plate_t;
rear_lug_x = -rear_extension;
ua_knee_x = L1 * ua_bend_pos;
ua_knee_h = L1 * ua_bend_pos * (1 - ua_bend_pos) * tan(ua_bend_deg);
function ua_cz(x) = x < 0 ? 0
                  : x < ua_knee_x ? ua_knee_h * x / ua_knee_x
                  : ua_knee_h * (L1 - x) / (L1 - ua_knee_x);

// 두꺼운 육각 스탠드오프 M6 AF13 ×2 (v0.13 — 다수 튜브 대신 소수 후육).
// 나머지 구속: J2 관절(어깨 스택 클램프) + 팔꿈치 스택 + 스플라이스 더블러.
// 위치 제약: 후방 러그(r34) 내 + 전방은 x ≥ 90 (어깨 텅 스윕 반경 밖)·창 회피
ua_standoffs = [[-108, 0], [160, 9]];
rear_lug_R = arm_lug_r + 8;   // 후방 러그 r34 — J3 모터 사각 통과 홀(43.6²) 수용
// 스플라이스 더블러 볼트 [x, z] ×4 (분할선 ±16, 중심선 추종)
function ua_splice_pts() = [for (x = ua_splice, dz = [-10, 10])
                            [x, ua_cz(x) + dz]];

// 측판 외곽 2D: 러그-니 캡슐 체인 + 상단 트림 + (A측) 베인 범프
module ua_plate2d(vane = false) {
    difference() {
        union() {
            hull() {
                // 후방 러그 r34 — 하단: 평탄(-26) + 후방 45° 챔퍼.
                // J2 +45° 회전 시 45° 챔퍼는 수직이 되어 어깨 플랜지(z≤200)를
                // 기하학적으로 클리어 (t+h=-114 → z'=201.4, 그리드 검증 v0.14).
                // 사각 통과 홀 좌하 코너는 챔퍼에 개방 — 허용 (3변 구속 잔존)
                translate([rear_lug_x, 0]) intersection() {
                    circle(r = rear_lug_R);
                    polygon([[-8, -arm_lug_r], [40, -arm_lug_r], [40, 40],
                             [-40, 40], [-34, 0]]);
                }
                circle(r = arm_lug_r);
            }
            hull() {
                circle(r = arm_lug_r);
                translate([ua_knee_x, ua_knee_h]) circle(r = arm_lug_r - 4);
            }
            hull() {
                translate([ua_knee_x, ua_knee_h]) circle(r = arm_lug_r - 4);
                translate([L1, 0]) circle(r = arm_lug_r);
            }
            // J2 리미트 베인 (평면 외곽 범프, r 28~35 — 어깨 러그 r28 밖)
            if (vane) rotate(155) translate([31.5, 0]) square([7, 6], center = true);
        }
        // 상단 트림: x 20~62 z>15 — 어깨 앵커 암 스윕 존 회피.
        // (x 25~28의 러그→니 헐 에지도 J2 +40°에서 앵커 하면을 스침 — v0.14 확장)
        translate([20, 15]) square([42, 60]);
    }
}

// 공통 홀 2D: 스탠드오프 M6 + 스플라이스 M4 + 경량창
module ua_holes2d() {
    for (p = ua_standoffs) translate(p) circle(d = 6.6);
    for (p = ua_splice_pts()) translate(p) circle(d = 4.4);
    for (p = [[-40, 0, 16], [38, -6, 14]])              // 루트 존 경량창
        translate([p[0], p[1]]) circle(d = p[2]);
    for (x = [75, 160, 188])                            // 빔 존 경량창 (중심선 추종)
        translate([x, ua_cz(x)]) circle(d = 20);
}

// ── 측판 A (-Y): J2 아이들 + J3 NEMA ──
module ua_plate_a() {
    difference() {
        translate([0, pa_in, 0]) rotate([90, 0, 0]) linear_extrude(arm_plate_t)
            difference() {
                ua_plate2d(vane = true);
                ua_holes2d();
                circle(d = shoulder_d_large + clearance_fit);       // J2 아이들 ⌀8
                translate([L1, 0]) circle(d = shoulder_d_large + clearance_fit); // 팔꿈치 ⌀8
            }
        // J2 아이들 머리 카운터보어 (외면 플러시 — 구동 링크 평면 간섭 회피)
        translate([0, pa_out - 0.1, 0]) rotate([-90, 0, 0]) cylinder(d = 15, h = 4.1);
        // 팔꿈치 머리 카운터보어
        translate([L1, pa_out - 0.1, 0]) rotate([-90, 0, 0]) cylinder(d = 15, h = 4.1);
        // J3 NEMA17 (플랜지 내면 밀착, -Y측 M3 체결)
        translate([rear_lug_x, pa_out - 0.1, 0]) rotate([-90, 0, 0])
            nema17_mount(arm_plate_t + 0.2);
        // J3 리미트 스위치 홀 (크랭크 베인 감지)
        translate([rear_lug_x + 32, pa_out - 0.1, -14]) rotate([-90, 0, 0])
            ls_mount_holes(arm_plate_t + 0.2);
    }
}

// ── 측판 B (+Y): J2 NEMA + J3 통과 ──
module ua_plate_b() {
    difference() {
        translate([0, pb_out, 0]) rotate([90, 0, 0]) linear_extrude(arm_plate_t)
            difference() {
                ua_plate2d();
                ua_holes2d();
                // J3 모터 몸체 통과 — 42각 + 1.6 여유 **사각** 홀
                // (원형 d44는 모터 코너 대각 59.4가 침범 — 렌더 교차 검증 v0.14)
                translate([rear_lug_x, 0])
                    square(motor_frame + 1.6, center = true);
                translate([L1, 0]) circle(d = shoulder_d_large + clearance_fit);
            }
        // J2 NEMA17 (기어박스 플랜지 외면 안착)
        translate([0, pb_out + 0.1, 0]) rotate([90, 0, 0])
            nema17_mount(arm_plate_t + 0.2);
    }
}

// ── 스플라이스 더블러 (평판 52×40 t6, 내면측 — 양 측판 공용 ×2) ──
module ua_doubler() {
    linear_extrude(6) difference() {
        translate([ua_split_x, ua_cz(ua_split_x)])
            offset(r = 8) square([36, 24], center = true);
        for (p = ua_splice_pts()) translate(p) circle(d = 4.4);
    }
}

// section: "full" | "a_root"/"a_tip"/"b_root"/"b_tip" (분할 측판) | "doubler"
module upper_arm(section = "full") {
    if (section == "full") {
        ua_plate_a(); ua_plate_b();
        translate([0, pa_in + 6, 0]) rotate([90, 0, 0]) ua_doubler();
        translate([0, pb_in, 0]) rotate([90, 0, 0]) ua_doubler();
    }
    else if (section == "doubler") ua_doubler();
    else if (section == "a_root") ua_half(true) ua_plate_a();
    else if (section == "a_tip")  ua_half(false) ua_plate_a();
    else if (section == "b_root") ua_half(true) ua_plate_b();
    else if (section == "b_tip")  ua_half(false) ua_plate_b();
}

// 맞대기 분할 헬퍼: root = x ≤ ua_split_x (더블러가 이음)
module ua_half(root) {
    intersection() {
        children();
        translate([root ? ua_split_x - 500 : ua_split_x, -200, -200])
            cube([500, 400, 400]);
    }
}

// 비주얼 참조 (STL 제외)
%translate([0, pb_out, 0]) rotate([90, 0, 0]) actuator_J2();
%translate([rear_lug_x, pa_in, 0]) rotate([90, 0, 0]) actuator_J3();

upper_arm();
