// 구동 링크 (drive link) — 크랭크 핀 ↔ 팔꿈치 혼 핀, 길이 = L1 (현)
// =====================================================================
// 평행사변형 결합봉: 양단 625ZZ 압입 (숄더 볼트 핀 M5 위 회전).
// forearm 중앙면(y=0) 채널 주행 (v0.18). 몸체는 상완 현과 동일 kink로 굴절
// (bent) — 굴절 무관 핀 중심은 x0/xL1 고정이라 평행사변형 기구학 불변.
// 베어링 시트 방향 (핀 진입 방향 반대면이 벽):
//   크랭크측(x0):  시트 z2~7 (+Y면에서 압입), z0~2 도피 ID 12 (M4 잼 너트 포켓)
//   혼측(x=L1):    시트 z0~5 (-Y면에서 압입), z5~7 도피 ID 12 (너트+와셔 수납)
// 좌표: z0 = 내면(-Y, 상완 측판측). 출력: 평면 — 도피→시트 환형 브리지 2mm
use <../lib/utils.scad>
use <../lib/vitamins/bearing_625zz.scad>

// ── 공개 스펙 (assembly·링키지가 참조) ──
function drive_link_length()  = 210;   // 핀 간 거리 = 상완 현 L1 (평행사변형)
function drive_link_plate_t() = 9;     // 링크 두께

module drive_link(col = undef) {
    $fn = 64;
    bearing_625 = bearing_625zz_spec();
    length = drive_link_length();
    plate_t = drive_link_plate_t();
    fillet = 16;
    press_fit = -0.15;
    boss_id = 12;
    width = bearing_625[1];
    arch_pos = [0.12, 0.5, 0.88];
    arch_rise = [24, 38, 24];
    seat_w = bearing_625[2];

    translate([-length / 2, 15, -plate_t / 2]) {
        apply_part_color(col) difference() {
            // 이중 굴절(아치) — 중앙 구간을 월드 '위'로 융기시켜 중앙 스탠드오프
            // 위로 브리지 (단일 킥은 스탠드오프와 같은 z라 간섭). 핀 중심은 x0/L1
            // 고정 → 평행사변형 기구학 불변. 장착 회전(assembly rotate[-90])이
            // 상완과 반대라 2D '위' = -y → 융기 부호 음수. link_arch_rise=0 → 직선.
            // 몸체 폭 16 등두께 밴드 + 양단 베어링 허브 OD 22, 천이 필렛.
            linear_extrude(plate_t)
                bent_band2d([[0, 0, (bearing_625[1] / 2) + (width / 2)],
                             [arch_pos[0] * length, -arch_rise[0], width / 2],   // 크랭크측 (덜)
                             [arch_pos[1] * length, -arch_rise[1], width / 2],   // 중앙
                             [arch_pos[2] * length, -arch_rise[2], width / 2],   // 하완측 (훨씬 더)
                             [length, 0, (bearing_625[1] / 2) + (width / 2)]],
                            fillet);
            // 크랭크측: 시트 상부(+Y면) / 도피 하부
            translate([0, 0, plate_t - seat_w]) cylinder(d = bearing_625[1] + press_fit, h = seat_w + 0.1);
            translate([0, 0, -0.1]) cylinder(d = boss_id, h = plate_t - seat_w + 0.2);
            // 혼측: 시트 하부(-Y면) / 도피 상부
            translate([length, 0, -0.1]) cylinder(d = bearing_625[1] + press_fit, h = seat_w + 0.1);
            translate([length, 0, seat_w - 0.1]) cylinder(d = boss_id, h = plate_t - seat_w + 0.2);
        }
    }
}

drive_link();
