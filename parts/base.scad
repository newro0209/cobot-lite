// 베이스 (base) — J1 칼럼 일체 + 모터 마운트 디스크 (v0.15 재설계, MEC-003/005)
// =====================================================================
// 구성: 평판 + 원통 칼럼 + 베어링 포스트 — 일체 직립 출력 (내부 보어 하향 개방).
// J1 액추에이터: 마운트 디스크(j1_disc)에 M3 ×4 선조립 → 칼럼 하부로 삽입 →
//   디스크 상면이 내부 천장(z_seat)에 안착, M3 셀프태핑 ×2 상향 체결(회전 구속).
//   천장 링(r12~30.5)은 보어 위 브리지 출력 — 정렬은 보어 끼움이 담당.
// 6810ZZ ×2 (MEC-003, 30mm 이격): 내륜이 포스트 랜드에 안착 —
//   하부 랜드 압입 / 가운데 릴리프 ⌀48 / 상부 랜드 슬립.
//   (상부를 슬립으로 두어 하부 베어링이 통과 삽입 가능 — 외륜은 턴테이블 컵이
//   압입으로 잡으므로 축계 구속은 성립, docs/design-notes §1b)
// 리미트(ELE-004): 칼럼 외벽 M2 ×2 (세로 쌍, 몸체 상단이 칼럼 상면 위 돌출)
//   — 턴테이블 스커트 베인 하단이 트리거
include <../config/parameters.scad>
use <../lib/utils.scad>
use <../lib/vitamins.scad>

z_seat   = base_plate_t + j1_actuator_gap + motor_len_SF2424 + gbx_len_20to1
         + col_floor_t;                            // 디스크 상면 = 내부 천장 (116)
z_brg_lo = z_seat + col_core_h;                    // 하부 6810 하면 (146)
col_top  = z_brg_lo + 2 * BRG_6810ZZ[2] + turntable_bearing_gap;   // 190
col_od   = BRG_6810ZZ[1] + 2 * base_col_wall;      // 75

module base() {
    difference() {
        union() {
            linear_extrude(base_plate_t)
                offset(r = 8) square(base_plate_size - 16, center = true);
            cylinder(d = col_od, h = z_brg_lo);
            // 베어링 포스트: 릴리프 기둥 + 하부 압입 랜드 + 상부 슬립 랜드
            translate([0, 0, z_brg_lo])
                cylinder(d = BRG_6810ZZ[0] - 2, h = col_top - z_brg_lo);
            translate([0, 0, z_brg_lo])
                cylinder(d = BRG_6810ZZ[0] - bearing_press_fit, h = BRG_6810ZZ[2]);
            translate([0, 0, col_top - BRG_6810ZZ[2]])
                cylinder(d = BRG_6810ZZ[0] - clearance_fit, h = BRG_6810ZZ[2]);
        }
        // 작업대 고정 M5 ×4 (MEC-005)
        for (x = [-1, 1], y = [-1, 1])
            translate([x * base_bolt_pitch / 2, y * base_bolt_pitch / 2, -0.1])
                bolt_hole(base_bolt_d, base_plate_t + 0.2);
        // 액추에이터/디스크 보어 — 하향 개방, 천장 z_seat
        translate([0, 0, -0.1]) cylinder(d = col_bore, h = z_seat + 0.1);
        // 스템 통로 ⌀24 (천장 → 포스트 상단 관통)
        translate([0, 0, z_seat - 1])
            cylinder(d = tt_stem_d + 1, h = col_top - z_seat + 2);
        // 디스크 회전 구속 M3 셀프태핑 ×2 (하방 접근 — 기어박스 r21 밖 r26)
        for (a = [0, 180]) rotate(a)
            translate([26, 0, z_seat - 0.1]) cylinder(d = m3_tap_d, h = 8);
        // 스템 결합 무두 볼트 액세스 ⌀6 ×2 (90° 위상, 턴테이블 파일럿과 z 정렬)
        for (p = [[0, z_seat + 5], [90, z_seat + 10]])
            rotate(p[0]) translate([0, 0, p[1]])
                rotate([0, 90, 0]) cylinder(d = 6, h = col_od);
        // J1 리미트 스위치 M2 ×2 — 외벽 세로 쌍 (방위각 180)
        for (s = [-1, 1]) rotate(180)
            translate([0, 0, z_brg_lo - 12 + s * ls_hole_pitch / 2])
                rotate([0, 90, 180]) cylinder(d = ls_hole_d, h = col_od / 2 + 1);
        // 케이블 출구 ⌀10 (ELE-005)
        translate([0, 0, base_plate_t + 10])
            rotate([0, 90, 90]) cylinder(d = 10, h = col_od);
    }
}

// J1 모터 마운트 디스크 — 평판, 칼럼 하부 삽입 (NEMA17 + 파일럿 ⌀22)
module j1_disc() {
    difference() {
        cylinder(d = col_bore - 0.4, h = col_floor_t);
        translate([0, 0, -0.1]) nema17_mount(col_floor_t + 0.2);
        // 회전 구속 M3 관통 ×2 (베이스 천장 파일럿과 정렬)
        for (a = [0, 180]) rotate(a)
            translate([26, 0, -0.1]) bolt_hole(3, col_floor_t + 0.2);
    }
}

// 비주얼 참조 (STL 제외): 액추에이터 현수 위치
%translate([0, 0, z_seat - col_floor_t]) actuator_J1();

base();
translate([base_plate_size, 0, 0]) j1_disc();
