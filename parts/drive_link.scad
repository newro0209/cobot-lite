// 구동 링크(drive link) — 크랭크 핀과 팔꿈치 혼 핀 사이의 결합봉이다.
// =====================================================================
// 용어:
// 1. 구동 링크(drive link)
// 2. 결합봉(coupler link)
// 3. 베어링 시트(bearing seat)
// 4. 압입(press fit)
// 5. 숄더 볼트(shoulder bolt)
// 6. 잼 너트(jam nut)
// 7. 환형 브리지(annular bridge)
// 8. 평행사변형 기구학(parallelogram kinematics)
//
// 평행사변형(parallelogram) 결합봉(coupler link)이며, 양단 625ZZ 베어링(bearing)을 압입한다.
// 하완(forearm) 중앙면 y=0 채널을 지나므로 핀 중심은 x0/xL1에 고정되어야 한다.
// 베어링 시트(bearing seat)는 핀 진입 방향의 반대면을 벽으로 남겨 축방향 이탈을 막는다.
// 크랭크측(crank side)은 +Y면 압입(press fit)과 M4 잼 너트(jam nut) 도피를 조합한다.
// 혼측(horn side)은 -Y면 압입(press fit)과 너트·와셔(nut and washer) 수납 도피를 조합한다.
// z0은 내면(-Y), 즉 상완 측판(upper-arm side plate) 쪽 기준면이다.
use <../lib/utils.scad>
use <../lib/vitamins/bearing_625zz.scad>

// ── 공개 스펙(spec): 어셈블리(assembly)와 링키지(linkage)가 참조한다. ──
function drive_link_length()  = 210;   // 핀 간 거리(pin spacing), 상완 현(upper-arm chord) L1과 동일
function drive_link_plate_t() = 9;     // 링크 두께

module drive_link(col = [1, 0, 0]) {
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
        color(col) difference() {
            // 이중 굴절 아치(double-kink arch)는 중앙 스탠드오프(standoff)를 피하려고 중앙 구간을 융기시킨다.
            // 핀 중심(pin center)은 x0/L1에 고정되어 평행사변형 기구학(parallelogram kinematics)을 보존한다.
            // 조립 회전(assembly rotation)이 상완(upper arm)과 반대라 2D 위쪽은 -y 방향이다.
            // 등두께 밴드(constant-width band)와 양단 베어링 허브(bearing hub)는 천이 필렛(transition fillet)으로 잇는다.
            linear_extrude(plate_t)
                bent_band2d(nodes = [[0, 0, (bearing_625[1] / 2) + (width / 2)],
                                     [arch_pos[0] * length, -arch_rise[0], width / 2],   // 크랭크측 (덜)
                                     [arch_pos[1] * length, -arch_rise[1], width / 2],   // 중앙
                                     [arch_pos[2] * length, -arch_rise[2], width / 2],   // 하완측 (훨씬 더)
                                     [length, 0, (bearing_625[1] / 2) + (width / 2)]],
                            fillet_r = fillet);
            // 크랭크측(crank side): +Y면 베어링 시트(bearing seat)와 하부 도피(relief)를 조합한다.
            translate([0, 0, plate_t - seat_w]) cylinder(d = bearing_625[1] + press_fit, h = seat_w + 0.1);
            translate([0, 0, -0.1]) cylinder(d = boss_id, h = plate_t - seat_w + 0.2);
            // 혼측(horn side): -Y면 베어링 시트(bearing seat)와 상부 도피(relief)를 조합한다.
            translate([length, 0, -0.1]) cylinder(d = bearing_625[1] + press_fit, h = seat_w + 0.1);
            translate([length, 0, seat_w - 0.1]) cylinder(d = boss_id, h = plate_t - seat_w + 0.2);
        }
    }
}

drive_link();
