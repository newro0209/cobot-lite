// 어깨 (shoulder) — v0.15 재설계: 동일 측판 ×2 + 볼트온 소부품
// =====================================================================
// 원칙: 측판 1형상 ×2 (좌우 구분 없음 — 플립 장착). 한쪽 전용 기능은 분리:
//   [sh_plate]  t14 동일 측판 ×2 — 중앙 ⌀22 보어 공용:
//                 -Y 포즈 = 608ZZ ×2 관통 압입 (J2 아이들)
//                 +Y 포즈 = 클램프 디스크 스피곳 압입 시트 (J2 구동)
//               풋 탭(M5 수직 관통 — 턴테이블까지 한 번에 클램프) + 스탠드오프
//               M6 ×4 (±32,±50) + LS 패드(2차측 전용) + 앵커 파일럿(구동측 전용)
//   [sh_clamp]  클램프 디스크 — ⌀34 디스크 + ⌀22 스피곳(보어 압입), ⌀8 클램프
//               + 슬릿 + 핀치 M3. 포크 내측에서 M4 FHCS ×4 체결 (토크 전달)
//   [sh_anchor] 평행사변형 정적 핀 앵커 t7 — 측판 외면에서 스페이서 ⌀8×10 ×2
//               + M4 ×2 입설. 핀 = 스트리퍼 5×10 + 튜브 ⌀8×4 + 와셔 (CON-001)
//   [sh_flange] 베이스 플랜지 t8 — 탭 슬롯 ×4 + M5 ×2 직결
// 키프아웃: 상완 베인 핀(M3, r=vane_pin_x) 스윕 환형 r51.5~60.5 — 측판 2D에서
//   섹터 차집합 (part θ -52..27 = -Y 포즈의 월드 θ -27..52)
// 좌표: 원점 = J2 축. 플랜지 하면 = -j2_axis_h
include <../config/parameters.scad>
use <../lib/utils.scad>

foot_top = -j2_axis_h + 24;        // 풋 밴드 상단 (-66)
tab_z    = -j2_axis_h;             // 탭 하단 (-90)

// 키프아웃 환형 섹터 2D (베인 핀 스윕 — part 좌표)
module sh_keepout2d() {
    intersection() {
        difference() { circle(r = vane_pin_x + 4.5); circle(r = vane_pin_x - 4.5); }
        polygon([[0, 0], for (a = [-52 : 10 : 27]) 200 * [cos(a), sin(a)],
                 200 * [cos(27), sin(27)]]);
    }
}

// 측판 2D — part 좌표 = +Y 포즈 월드 XZ (-Y 포즈는 z 미러로 나타남)
module sh_plate2d() {
    difference() {
        union() {
            hull() {
                circle(r = sh_lug_r);
                translate([0, -74]) square([94, 16], center = true);
            }
            // 풋 탭 ×2 (M5 수직 관통)
            for (s = [-1, 1])
                translate([s * 40, -86]) square([14, 8], center = true);
            // 상부 스탠드오프 패드 + 러그 연결 스트럿
            for (s = [-1, 1]) hull() {
                translate([s * 32, 50]) circle(8);
                translate([s * 12, 12]) circle(6);
            }
            // J2 리미트 스위치 스트립 + 패드 (part -z = -Y 포즈에서 전방 상부)
            hull() { translate([10, -16]) circle(6); translate([27, -56]) circle(6); }
            hull() {
                translate([27, -56]) circle(6);
                translate(64 * [cos(-46), sin(-46)]) circle(3.5);
                translate(64 * [cos(-57), sin(-57)]) circle(3.5);
            }
        }
        sh_keepout2d();
        circle(d = BRG_608ZZ[1] + bearing_press_fit);          // 공용 ⌀22 보어
        for (a = [45 : 90 : 359])                              // 클램프 M4 파일럿 ×4
            translate(13 * [cos(a), sin(a)]) circle(d = set_screw_pilot_d);
        // 앵커 M4 파일럿 ×2 (+Y 포즈 후방)
        for (p = [[-40, -5], [-33, 23]]) translate(p) circle(d = set_screw_pilot_d);
        // 스탠드오프 M6 ×4
        for (sx = [-1, 1], sz = [-1, 1])
            translate([sx * 32, sz * 50]) circle(d = 6.6);
        // LS M2 ×2 (피치 9.5 ≈ 8.5°@r64)
        for (a = [-47.5, -56])
            translate(64 * [cos(a), sin(a)]) circle(d = ls_hole_d);
    }
}

// 측판 (extrude z 0..14, z0 면 = 장착 포즈에서 외면 — 스탠드오프 머리 카운터보어)
module sh_plate() {
    difference() {
        linear_extrude(sh_plate_t) sh_plate2d();
        for (sx = [-1, 1], sz = [-1, 1])
            translate([sx * 32, sz * 50, -0.1]) cylinder(d = 11.5, h = 6.3);
        // 풋 탭 M5 수직 관통 (에지 홀 — CNC 2차 드릴)
        for (s = [-1, 1])
            translate([s * 40, -92, sh_plate_t / 2])
                rotate([-90, 0, 0]) cylinder(d = 5.4, h = 30);
    }
}

// 클램프 디스크 — z0 = 디스크 외면(포크 내측), 스피곳 +z (보어 삽입 방향)
module sh_clamp() {
    difference() {
        union() {
            cylinder(d = 34, h = 6);
            cylinder(d = BRG_608ZZ[1] + bearing_press_fit, h = 6 + sh_plate_t);
        }
        // ⌀8 클램프 보어 + 슬릿 + 핀치 M3 (디스크 존)
        translate([0, 0, -0.1])
            cylinder(d = gbx_out_shaft_d + clearance_fit / 2,
                     h = 6 + sh_plate_t + 0.2);
        translate([-1, 0, -0.1]) cube([2, 18, 6 + sh_plate_t + 0.2]);
        translate([-18, 11, 3]) rotate([0, 90, 0]) bolt_hole(3, 36);
        // M4 FHCS ×4 (r13, 접시 카운터싱크 — 외면 플러시)
        for (a = [45 : 90 : 359]) translate(13 * [cos(a), sin(a)]) {
            translate([0, 0, -0.1]) bolt_hole(4, 6 + sh_plate_t + 0.2);
            translate([0, 0, -0.1]) cylinder(d1 = 8.8, d2 = 4.4, h = 2.3);
        }
    }
}

// 정적 핀 앵커 t7 (월드 XZ 그대로 — +Y 측판 외면에서 y39..46)
module sh_anchor() {
    linear_extrude(7) difference() {
        union() {
            hull() { translate([-40, -5]) circle(6); translate([-33, 23]) circle(6); }
            hull() { translate([-33, 23]) circle(6); translate([0, pl_offset]) circle(8); }
        }
        for (p = [[-40, -5], [-33, 23]]) translate(p) circle(d = 4.4);
        translate([0, pl_offset]) circle(d = set_screw_pilot_d);   // 핀 M4 파일럿
    }
}

// 베이스 플랜지 t8 — 탭 슬롯 ×4 + M5 ×2
module sh_flange() {
    linear_extrude(8) difference() {
        offset(r = 8) square([110 - 16, 72 - 16], center = true);
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * 40, sy * 22]) square(14.4, center = true);
        for (sy = [-1, 1]) translate([0, sy * 25]) circle(d = 5.4);
    }
}

// piece: "full" | "plate" | "clamp" | "anchor" | "flange"
module shoulder(piece = "full") {
    if (piece == "full") {
        translate([0, tongue_w / 2, 0]) rotate([90, 0, 0]) sh_plate();    // +Y
        translate([0, -tongue_w / 2, 0]) rotate([-90, 0, 0]) sh_plate();  // -Y (z 미러)
        translate([0, tongue_w / 2 - sh_plate_t - 6, 0])
            rotate([-90, 0, 0]) sh_clamp();
        translate([0, tongue_w / 2 + 10 + 7, 0]) rotate([90, 0, 0]) sh_anchor();
        translate([0, 0, -j2_axis_h]) sh_flange();
    }
    else if (piece == "plate")  sh_plate();
    else if (piece == "clamp")  sh_clamp();
    else if (piece == "anchor") sh_anchor();
    else if (piece == "flange") sh_flange();
}

shoulder();
