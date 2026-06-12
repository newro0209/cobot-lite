// 베이스 (base) — 작업대 고정 플레이트 + 턴테이블 칼럼 (MEC-003, MEC-005)
// J1 액추에이터(SF2424 + MG17-G20)를 칼럼 내부에 수직 탑재, 출력축 위.
// 6810ZZ 2개는 칼럼 상부에서 압입, 사이에 turntable_spacer 링 삽입.
// 조립 순서: 액추에이터 측면 창 삽입 → 플로어에 M3 체결(상부 보어로 접근)
//            → 하부 베어링 → 스페이서 → 상부 베어링 → 턴테이블 압입.
include <../config/parameters.scad>
use <../lib/utils.scad>
use <../lib/vitamins.scad>

/* ===== 파생 치수 ===== */
col_od      = BRG_6810ZZ[1] + 2 * base_col_wall;      // 칼럼 외경
col_id      = BRG_6810ZZ[1];                          // 모터 캐비티 내경 (42각 대각 ≈59.4 수용)
z_flange    = base_plate_t + j1_actuator_gap
            + motor_len_SF2424 + gbx_len_20to1;       // 기어박스 출력 플랜지면
z_floor_top = z_flange + arm_plate_t;                 // 모터 마운트 플로어 상면
z_brg_lo    = z_floor_top + col_open_h;               // 하부 6810 하면
col_top     = z_brg_lo + 2 * BRG_6810ZZ[2]
            + turntable_bearing_gap;                  // 상부 6810 상면 = 칼럼 상면
shelf_id    = BRG_6810ZZ[0] + 4;                      // 베어링 외륜 받침 내경
window_h    = z_flange - base_plate_t - 8;            // 측면 창 높이
ls_pad_t    = 8;                                      // 리미트 스위치 패드 돌출

module base() {
    difference() {
        union() {
            // 플레이트 (모서리 R10 라운딩)
            linear_extrude(base_plate_t)
                offset(r = 10) square(base_plate_size - 20, center = true);
            // 칼럼 + 루트 필렛 링 (플레이트-칼럼 응력 집중 완화, 45° 콘)
            cylinder(d = col_od, h = col_top);
            translate([0, 0, base_plate_t])
                cylinder(d1 = col_od + 16, d2 = col_od, h = 8);
            // J1 리미트 스위치 패드 (+X 방향, 상단)
            // — 하부 헐 웻지(≈45°)로 직립 출력 서포트리스
            hull() {
                translate([col_od / 2 - 1, -ls_body[0] / 2 - 4,
                           col_top - ls_body[1] - 14])
                    cube([ls_pad_t + 1, ls_body[0] + 8, ls_body[1] + 10]);
                translate([col_od / 2 - 1, -ls_body[0] / 2 - 4,
                           col_top - ls_body[1] - 14 - ls_pad_t - 8])
                    cube([1, ls_body[0] + 8, 1]);
            }
        }

        // 작업대 고정 M5 ×4 (MEC-005)
        for (x = [-1, 1], y = [-1, 1])
            translate([x * base_bolt_pitch / 2, y * base_bolt_pitch / 2, -0.1])
                bolt_hole(base_bolt_d, base_plate_t + 0.2);

        // 경량화: 플레이트 상면 포켓 ×4 (깊이 4) — 칼럼 필렛 링과 고정
        // 볼트 보스 사이 대각 방향. 하면은 작업대 밀착면이라 보존
        for (a = [45 : 90 : 315])
            rotate([0, 0, a]) translate([52, 0, base_plate_t - 4])
                linear_extrude(4.1)
                    offset(r = 6) square([16, 24], center = true);

        // 모터 캐비티 (플레이트 상면 → 플랜지면)
        translate([0, 0, base_plate_t])
            cylinder(d = col_id, h = z_flange - base_plate_t);

        // 플로어: NEMA17 마운트 (기어박스 플랜지를 아래에서 밀착, M3는 위에서 체결)
        translate([0, 0, z_flange - 0.1])
            nema17_mount(arm_plate_t + 0.2);

        // 개방 존 보어 (스템·셋스크류 존)
        translate([0, 0, z_floor_top])
            cylinder(d = shelf_id, h = col_open_h + 0.1);

        // 베어링 포켓 존 (상부에서 일괄 압입: 하부 6810 → 스페이서 → 상부 6810)
        translate([0, 0, z_brg_lo])
            bearing_seat([BRG_6810ZZ[0], BRG_6810ZZ[1],
                          2 * BRG_6810ZZ[2] + turntable_bearing_gap + 0.1]);

        // 측면 창 ×2 (모터 삽입·배선, ELE-005 케이블 출구 겸용) — ±X
        // 상단 45° 박공(gable) 지붕 — 직립 출력 시 브리지/서포트 불요
        for (a = [0, 180])
            rotate([0, 0, a])
                translate([col_id / 2 - 6, 0, base_plate_t + 4])
                    rotate([90, 0, 90]) linear_extrude(base_col_wall + 12)
                        // 사각부 + 45° 박공 — 꼭짓점이 모터 플로어(z_flange) 아래
                        polygon([[-col_window_w / 2, 0], [col_window_w / 2, 0],
                                 [col_window_w / 2, window_h - col_window_w / 2],
                                 [0, window_h],
                                 [-col_window_w / 2, window_h - col_window_w / 2]]);

        // 셋스크류 액세스 홀 ×2 (개방 존, 90° 간격 — 창 리브 회피 위해 ±45°)
        for (a = [45, 135])
            rotate([0, 0, a])
                translate([0, 0, z_floor_top + 7])
                    rotate([0, 90, 0])
                        cylinder(d = 6, h = col_od / 2 + 1);

        // 리미트 스위치 장착 홀 (패드 면에 수평 체결)
        translate([col_od / 2 + ls_pad_t - 4, 0, col_top - ls_body[1] / 2 - 12])
            rotate([0, 0, 90]) rotate([90, 0, 0])
                translate([0, 0, -1]) ls_mount_holes(ls_pad_t + 6);
    }
}

// 비주얼 참조 (STL 제외): J1 액추에이터, 베어링
%translate([0, 0, z_flange]) actuator_J1();
%translate([0, 0, z_brg_lo]) bearing(BRG_6810ZZ);
%translate([0, 0, z_brg_lo + BRG_6810ZZ[2] + turntable_bearing_gap]) bearing(BRG_6810ZZ);

base();
