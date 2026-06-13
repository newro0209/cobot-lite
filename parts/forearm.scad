// 하완 (forearm) — v0.18: 꺾임 빔 + 혼 핀 러그 일체 (별도 혼 부품 폐지)
// =====================================================================
// 측판 1형상 ×2 — 전 홀 관통 → 평행이동 장착 (플립 불요).
// 프로파일: 러그 hull (무릎 +z 볼록) + 혼 핀 러그(R36.5, horn_phase) — 측판이
//   곧 혼: 두 측판 사이 숄더 핀 M5가 평행사변형 힘을 받아 forearm 구동(대칭).
// 팔꿈치(0): 통축 클리어 ID 8 + 플랜지 커플러 M5×4 (하완이 커플러로 통축 볼트 grip → 함께 회전)
// 혼 핀(R36.5@horn_phase): 숄더 핀 M5 — 중앙 링크 625ZZ 구동
// 선단(225): 피벗 홀 ID 8 (공구 인터페이스 유보)
use <../lib/utils.scad>

// ── 공개 스펙 (assembly·하드웨어 배치가 참조) ──
function forearm_length()       = 185;           // 현(chord) 길이
function forearm_plate_t()      = 9;             // 측판 두께
function forearm_bend()         = [30, 0.25, 0]; // [굴절각, 위치비, 보조 오프셋]
function forearm_standoff_x()   = [0.38, 0.76];  // 스탠드오프 x (length 비율)
function forearm_crank_radius() = 36;            // 혼 핀 반경 (= 크랭크 R, 평행사변형)
function forearm_horn_angle()   = 155;           // 혼 핀 위상각 (deg)

module fa_plate2d() {
    clearance = 0.3;
    length = forearm_length();
    fillet = 16;
    bend_angle = forearm_bend()[0];
    bend_pos = forearm_bend()[1];
    kink_offset = forearm_bend()[2];
    standoff_x = [for (f = forearm_standoff_x()) f * length];
    crank_radius = forearm_crank_radius();
    horn_angle = forearm_horn_angle();
    small_shoulder_d = 5;
    large_shoulder_d = 8;
    body_hw = 16;
    lug_r = 26;
    standoff_d = 3.4;
    bolt_r = 12;
    bolt_n = 4;
    bolt_d = 4;
    horn_pin = crank_radius * [cos(horn_angle), sin(horn_angle)];

    difference() {
        fillet_concave2d()
        union() {
            bent_band2d([[0, 0, body_hw],
                         [bend_pos * length, knee_h(length, bend_pos, bend_angle, kink_offset), body_hw],
                         [length, 0, large_shoulder_d]], fillet);
            // 혼 핀 러그 (팔꿈치 → 핀)
            hull() {
                circle(r = lug_r);
                translate(horn_pin) circle(r = 9);
            }

            // 선단
            translate([length, 0]) circle(r = body_hw);

            // 리미트 베인
            rotate(320) translate([lug_r, -4]) square([20, 8]);
        }
        // 팔꿈치: 통축 클리어 ID 8 + 플랜지 커플러 M4×4 셀프태핑 (+Y판이 커플러로 볼트 grip)
        circle(d = large_shoulder_d + clearance / 2);
        for (i = [0 : bolt_n - 1])
            rotate(45 + i * 360 / bolt_n)
                translate([bolt_r, 0]) circle(d = bolt_d - 0.5);
        // 혼 핀 ID 5
        translate(horn_pin) circle(d = small_shoulder_d + clearance / 2);
        // 선단 ID 8 (공구 유보)
        translate([length, 0])
            circle(d = large_shoulder_d + clearance / 2);
        // 스탠드오프 M3 ×2 (중심선 굴절 추종 — 밴드 내부 유지)
        for (x = standoff_x)
            translate([x, arm_standoff_pos(length, bend_pos, bend_angle, kink_offset, x)])
                circle(d = standoff_d);
    }
}

// 출력/BOM 모듈 — 단일 측판. 조립 배치·색은 호출부(assembly)가 담당한다.
module forearm_plate(col = undef) {
    $fn = 64;
    base_length = 210;
    inner_w = 30;
    plate_t = forearm_plate_t();
    roller_w = 3.2;
    roller_local = [13.89, 6.96, 4.8];
    vane_angle = 320;
    switch_roller = [base_length + 40 * cos(vane_angle - 130),
                     30 - roller_local[2],
                     40 * sin(vane_angle - 130)];
    plate_mid_y = inner_w / 2 + plate_t / 2;
    vane_t = 2 * (switch_roller[1] + roller_w / 2 + 1.0 - plate_mid_y);
    plate_center = [75.686, 1.054, plate_t / 2];

    translate(-plate_center)
        apply_part_color(col) {
            linear_extrude(plate_t) fa_plate2d();
        }
}

forearm_plate();
