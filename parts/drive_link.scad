// 구동 링크 (drive link) — 크랭크 핀 ↔ 팔꿈치 혼 핀, 길이 = L1 (현)
// =====================================================================
// 평행사변형 결합봉: 양단 625ZZ 압입 (숄더 볼트 핀 M5 위 회전).
// forearm 중앙면(y=0) 채널 주행 (v0.18). 몸체는 상완 현과 동일 kink로 굴절
// (bent) — 굴절 무관 핀 중심은 x0/xL1 고정이라 평행사변형 기구학 불변.
// 베어링 시트 방향 (핀 진입 방향 반대면이 벽):
//   크랭크측(x0):  시트 z2~7 (+Y면에서 압입), z0~2 도피 ID 12 (M4 잼 너트 포켓)
//   혼측(x=L1):    시트 z0~5 (-Y면에서 압입), z5~7 도피 ID 12 (너트+와셔 수납)
// 좌표: z0 = 내면(-Y, 상완 측판측). 출력: 평면 — 도피→시트 환형 브리지 2mm
include <../config/parameters.scad>
use <../lib/utils.scad>

module drive_link(col = undef) {
    seat_w = BRG_625ZZ[2];
    apply_part_color(col) difference() {
        // 이중 굴절(아치) — 중앙 구간을 월드 '위'로 융기시켜 중앙 스탠드오프
        // 위로 브리지 (단일 킥은 스탠드오프와 같은 z라 간섭). 핀 중심은 x0/L1
        // 고정 → 평행사변형 기구학 불변. 장착 회전(assembly rotate[-90])이
        // 상완과 반대라 2D '위' = -y → 융기 부호 음수. link_arch_rise=0 → 직선.
        // 몸체 폭 16 등두께 밴드 + 양단 베어링 허브 OD 22, 천이 필렛.
        linear_extrude(arm_plate_t)
            bent_band2d([[0, 0],
                         [link_arch_pos[0] * L1, -link_arch_rise[0]],   // 크랭크측 (덜)
                         [link_arch_pos[1] * L1, -link_arch_rise[1]],   // 하완측 (훨씬 더)
                         [link_arch_pos[2] * L1, -link_arch_rise[2]],   // 하완측 (훨씬 더)
                         [L1, 0]],
                        link_end_d / 2, link_w / 2);
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
