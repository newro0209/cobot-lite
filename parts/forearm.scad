// 하완(forearm) — v0.18: 꺾임 빔과 혼 핀 러그를 일체화한다.
// =====================================================================
// 용어:
// 1. 하완(forearm)
// 2. 측판(side plate)
// 3. 러그(lug)
// 4. 혼 핀(horn pin)
// 5. 숄더 핀(shoulder pin)
// 6. 평행사변형(parallelogram)
// 7. 플랜지 커플러(flange coupler)
// 8. 스탠드오프(standoff)
//
// 측판(side plate) 1형상 ×2 구조이며, 전 홀 관통 구조라 평행이동 장착만 필요하다.
// 프로파일(profile)은 러그(lug) 헐(hull)과 혼 핀 러그(horn pin lug)를 합친다.
// 두 측판(side plate) 사이의 M5 숄더 핀(shoulder pin)이 평행사변형(parallelogram)
// 구동력을 받아 별도 혼(horn) 없이 하완(forearm)을 구동한다.
// 팔꿈치(elbow)는 8 mm 관통축 클리어런스(clearance)와 M4×4 플랜지 커플러(flange coupler)를 공유한다.
// 혼 핀(horn pin)은 중앙 링크(center link)의 625ZZ 베어링(bearing)을 구동한다.
// 선단(tip)은 추후 공구 인터페이스(tool interface)를 위해 8 mm 피벗 홀(pivot hole)을 남긴다.
use <../lib/utils.scad>

// ── 공개 스펙(spec): 어셈블리(assembly)와 하드웨어 배치가 참조한다. ──
function forearm_length()       = 185;           // 현 길이(chord length)
function forearm_plate_t()      = 9;             // 측판 두께
function forearm_bend()         = [30, 0.25, 0]; // [굴절각, 위치비, 보조 오프셋]
function forearm_standoff_x()   = [0.38, 0.76];  // 스탠드오프 x (length 비율)
function forearm_crank_radius() = 36;            // 혼 핀 반경(horn pin radius), 크랭크 반경(crank radius)과 동일
function forearm_horn_angle()   = 155;           // 혼 핀 위상각(horn phase angle, deg)

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
            bent_band2d(nodes = [[0, 0, body_hw],
                                 [bend_pos * length,
                                  knee_h(length = length,
                                         bend_position = bend_pos,
                                         bend_angle = bend_angle,
                                         kink_offset = kink_offset),
                                  body_hw],
                                 [length, 0, large_shoulder_d]],
                        fillet_r = fillet);
            // 혼 핀 러그(horn pin lug)는 팔꿈치(elbow) 축과 핀 사이 하중 경로를 잇는다.
            hull() {
                circle(r = lug_r);
                translate(horn_pin) circle(r = 9);
            }

            // 선단(tip)은 공구 인터페이스(tool interface)를 나중에 받을 자리다.
            translate([length, 0]) circle(r = body_hw);

            // 리미트 베인(limit vane)은 스위치 롤러(switch roller) 접촉 기준 형상이다.
            rotate(320) translate([lug_r, -4]) square([20, 8]);
        }
        // 팔꿈치(elbow): 관통축 클리어런스(clearance)와 플랜지 커플러(flange coupler) 체결 패턴을 공유한다.
        circle(d = large_shoulder_d + clearance / 2);
        for (i = [0 : bolt_n - 1])
            rotate(45 + i * 360 / bolt_n)
                translate([bolt_r, 0]) circle(d = bolt_d - 0.5);
        // 혼 핀(horn pin)은 M5 숄더 핀(shoulder pin) 기준이다.
        translate(horn_pin) circle(d = small_shoulder_d + clearance / 2);
        // 선단(tip)은 공구 인터페이스(tool interface)용 피벗 홀(pivot hole)을 유보한다.
        translate([length, 0])
            circle(d = large_shoulder_d + clearance / 2);
        // M3 스탠드오프(standoff)는 굴절 중심선을 따라 밴드(band) 내부에 머문다.
        for (x = standoff_x)
            translate([x, arm_standoff_pos(length = length,
                                           bend_position = bend_pos,
                                           bend_angle = bend_angle,
                                           kink_offset = kink_offset,
                                           x = x)])
                circle(d = standoff_d);
    }
}

// 출력/BOM 모듈은 단일 측판(side plate)만 만들고, 조립 배치와 색상은 호출부(assembly)가 담당한다.
module forearm_plate(col = [0, 1, 0]) {
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
        color(col) {
            linear_extrude(plate_t) fa_plate2d();
        }
}

forearm_plate();
