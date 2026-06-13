// 구동 허브 (drive hub, J2) — 기성 플랜지 커플러 결합 → 상완 -Y 측판 볼트온
// =====================================================================
// ⌀56 — 상완 -Y 측판 외면 (M4 FHCS ×3 r24 — 측판 6805ZZ 보어 밖).
// +z 보스(⌀25)가 측판 6805ZZ 내륜에 안착 (CON-003) — 측판 지지 겸용.
// J2 리미트 베인 탭(r47) 일체.
// 좌표: z0 = 자유면(커플러 결합 + FHCS 접시), z7 = 장착면(플레이트 접촉), 보스 +z.
// 축 grip: z0 면에 기성 플랜지 커플러(set screw)가 셀프태핑 M5 ×4(r18.5) 볼트온,
//   커플러가 기어박스 ⌀8 축을 grip. (J1은 터릿 보스 일체로 별도 — piece 인자 잔존)
include <../config/parameters.scad>
use <../lib/utils.scad>

module drive_hub(piece = "j2", col = undef) {
    d  = hub_d_j2;
    br = hub_bolt_r_j2;
    apply_part_color(col) difference() {
        union() {
            cylinder(d = d, h = arm_plate_t);
            // 6805ZZ 내륜 보스 (측판 인-플레이트 베어링 속, 1판 두께)
            translate([0, 0, arm_plate_t])
                cylinder(d = BRG_6805ZZ[0] - bearing_press_fit,
                         h = arm_plate_t);
            // J2 리미트 베인 탭 (타워 내면 스위치 감지)
            rotate([0, 0, j2_vane_a])
                translate([0, -elbow_vane_w / 2, 0])
                    cube([j2_vane_r, elbow_vane_w, arm_plate_t]);
        }
        // 플랜지 커플러 장착 (z0 자유면): 축 팁 도피 + 리세스 + 셀프태핑 M4 ×4
        coupler_mount_cut(arm_plate_t);
        // 보스 내경 (축 선단 도피)
        translate([0, 0, arm_plate_t - 0.1])
            cylinder(d = crank_boss_id, h = arm_plate_t + 0.2);
        // 플레이트 장착 M4 FHCS ×3 — z0 면 접시 플러시
        for (a = [90, 210, 330]) rotate([0, 0, a]) {
            translate([br, 0, -0.1]) bolt_hole(4, arm_plate_t + 0.2);
            translate([br, 0, -0.05]) cylinder(d1 = 9, d2 = 4.4, h = 2.3);
        }
    }
}

drive_hub();
