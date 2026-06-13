// 구동 링크 (drive link) — 크랭크 핀 ↔ 팔꿈치 혼 핀, 길이 = L1 (현)
// =====================================================================
// 평행사변형 결합봉: 양단 625ZZ 압입 (⌀5 숄더 볼트 핀 위 회전).
// 상완 +Y 측판 밖 평면(y 39.3~46.3)을 상완 현과 평행하게 주행 —
// 핀 상대각 [15°,140°] (horn_phase)로 코리도는 항상 현 위쪽 한측.
// 베어링 시트 방향 (핀 진입 방향 반대면이 벽):
//   크랭크측(x0):  시트 z2~7 (+Y면에서 압입), z0~2 도피 ⌀12 (M4 잼 너트 포켓)
//   혼측(x=L1):    시트 z0~5 (-Y면에서 압입), z5~7 도피 ⌀12 (너트+와셔 수납)
// 좌표: z0 = 내면(-Y, 상완 측판측). 출력: 평면 — 도피→시트 환형 브리지 2mm
include <../config/parameters.scad>
use <../lib/utils.scad>

module drive_link(col = undef) {
    seat_w = BRG_625ZZ[2];
    apply_part_color(col) difference() {
        linear_extrude(arm_plate_t) union() {
            hull() {
                circle(d = link_w);
                translate([L1, 0]) circle(d = link_w);
            }
            circle(d = link_end_d);
            translate([L1, 0]) circle(d = link_end_d);
        }
        // 크랭크측: 시트 상부(+Y면) / 도피 하부
        translate([0, 0, arm_plate_t - seat_w])
            cylinder(d = BRG_625ZZ[1] + bearing_press_fit, h = seat_w + 0.1);
        translate([0, 0, -0.1])
            cylinder(d = crank_boss_id, h = arm_plate_t - seat_w + 0.2);
        // 혼측: 시트 하부(-Y면) / 도피 상부
        translate([L1, 0, -0.1])
            cylinder(d = BRG_625ZZ[1] + bearing_press_fit, h = seat_w + 0.1);
        translate([L1, 0, seat_w - 0.1])
            cylinder(d = crank_boss_id, h = arm_plate_t - seat_w + 0.2);
    }
}

drive_link();
