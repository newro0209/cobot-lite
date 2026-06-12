// 턴테이블 (turntable) — J1 회전체 (MEC-003)
// 허브 보스가 6810ZZ ×2 내경에 직접 안착 (CON-003), 스템이 J1 기어박스
// 출력축(⌀8×20)에 M4 무두 볼트 ×2로 결합 (베이스 칼럼 액세스 홀로 체결).
// 상판에 어깨 텅(shoulder) M5 ×4 체결. 출력 자세: 상판을 베드에 (뒤집어 출력).
include <../config/parameters.scad>
use <../lib/utils.scad>

/* ===== 파생 치수 (로컬 z=0 = 스템 하면) ===== */
stem_h      = col_open_h - 1;                          // 개방 존 높이 − 플로어 여유
boss_h      = 2 * BRG_6810ZZ[2] + turntable_bearing_gap; // 베어링 스팬 44
bore_depth  = gbx_out_shaft_len - arm_plate_t - 1;     // 출력축 물림 깊이
z_flg       = stem_h + boss_h;                         // 상판 하면
vane_r      = (turntable_top_d - 16) / 2;              // 리미트 베인 반경

module turntable() {
    difference() {
        union() {
            cylinder(d = j1_stem_d, h = stem_h + 0.1);            // 스템
            translate([0, 0, stem_h]) bearing_boss(BRG_6810ZZ, boss_h); // 허브 보스
            // 상판 — 상면 모서리 챔퍼 2mm (도립 출력 시 베드측 엘리펀트풋 완화)
            translate([0, 0, z_flg])
                cylinder(d = turntable_top_d, h = turntable_top_t - 2);
            translate([0, 0, z_flg + turntable_top_t - 2])
                cylinder(d1 = turntable_top_d, d2 = turntable_top_d - 4, h = 2);
            // J1 리미트 스위치 베인 (vane) — 하향 탭, 각도 0° 기준
            translate([vane_r - 4, -4, z_flg - 10])
                cube([8, 8, 10.1]);
        }

        // J1 출력축 보어 + 셋스크류 ×2 (90° 간격, 베이스 액세스 홀 ±45°와 정렬)
        translate([0, 0, -0.1])
            cylinder(d = gbx_out_shaft_d + clearance_fit / 2, h = bore_depth + 0.1);

        // 허브 중공 (클램프 존 위 → 상판 관통, ⌀30) — 경량 + 배선 통로 (v0.12).
        // 6810 보스 벽 잔존 10mm — 압입 후프 충분
        translate([0, 0, bore_depth + 3])
            cylinder(d = 30, h = z_flg + turntable_top_t);
        for (a = [45, 135])
            rotate([0, 0, a])
                translate([0, 0, 7])
                    rotate([0, 90, 0])
                        translate([0, 0, 2])
                            cylinder(d = set_screw_pilot_d, h = j1_stem_d / 2);

        // 상판 하면 릴리프: 상부 베어링 내륜에만 접촉 (외륜·칼럼 림과 비접촉)
        translate([0, 0, z_flg - 0.1])
            difference() {
                cylinder(d = turntable_top_d + 1, h = 0.9);
                cylinder(d = BRG_6810ZZ[1] + 2, h = 1.1);
            }

        // 어깨 텅 체결 M5 ×4 (MEC-001 어깨부 인터페이스, 볼트 방위각 ≈ ±32°/±148°)
        for (x = [-1, 1], y = [-1, 1])
            translate([x * shoulder_mount_px / 2, y * shoulder_mount_py / 2, z_flg - 0.1])
                bolt_hole(shoulder_mount_bolt_d, turntable_top_t + 0.2);

        // 경량화: 상판 하면 포켓 ×4 (깊이 4) — 0/90/180/270° (볼트 방위각 회피),
        // 외륜 비접촉 릴리프 존(r > 33) 내라 베어링 하중 경로 무영향
        for (a = [0 : 90 : 270])
            rotate([0, 0, a]) translate([40, 0, z_flg - 0.1])
                linear_extrude(4.1)
                    offset(r = 4) square([8, 10], center = true);
    }
}

turntable();
