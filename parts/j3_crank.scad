// J3 크랭크(crank) — 중앙 디스크와 보스, 외단 플랜지를 단일 출력 부품으로 만든다.
// =====================================================================
// 용어:
// 1. 크랭크(crank)
// 2. 디스크(disk)
// 3. 보스(boss)
// 4. 저널(journal)
// 5. 플랜지(flange)
// 6. 평행사변형(parallelogram)
// 7. 중앙 링크(center link)
// 8. 숄더 보어(shoulder bore)
//
// 평행사변형(parallelogram) 평면은 하완(forearm) 중앙 y=0에 맞춘다.
// 크랭크(crank) 각도는 J3 각도와 혼 위상(horn phase)을 더한 값으로 조립부에서 정한다.
// 핀(pin)은 중앙 링크(center link)의 625ZZ 베어링(bearing)에 결합한다.
// 보스(boss)는 +Y 측판(side plate)의 6805ZZ 내륜(inner race)에 안착한다.
// 외단 플랜지(outer flange)는 기성 플랜지 커플러(flange coupler)의 M4×4 체결을 따른다.
// 부품 z0은 디스크(disk)의 -Y면, 즉 핀(pin) 측 기준면이다.
use <../lib/utils.scad>

// ── 공개 스펙(spec): 어셈블리(assembly)와 링키지(linkage)가 참조한다. ──
function j3_crank_radius() = 36;   // 핀 피치 반경(pin pitch radius), 하완 혼 반경(forearm horn radius)과 동일
function j3_crank_disk_d() = 52;   // 중앙 디스크 외경(center disk OD)

module crank2d() {
    disk_d = j3_crank_disk_d();
    crank_radius = j3_crank_radius();
    pin_lug_r = 8;

    fillet_concave2d()
    union() {
        circle(d = disk_d);
        hull() {
            circle(d = disk_d * 0.7);
            translate([crank_radius, 0]) circle(r = pin_lug_r);
        }
    }
}

module j3_crank(col = [1, 0.5, 0]) {
    $fn = 64;
    clearance = 0.3;
    plate_t = 9;
    disk_d = j3_crank_disk_d();
    crank_radius = j3_crank_radius();
    pin_lug_r = 8;
    boss_id = 12;
    small_shoulder_d = 5;
    center_x = (max(disk_d / 2, crank_radius + pin_lug_r) - disk_d / 2) / 2;

    translate([-center_x, 0, -plate_t / 2]) {
        color(col) difference() {
            union() {
                linear_extrude(plate_t) crank2d();
            }
            // 중앙 보어(center bore)는 질량을 줄이면서 관통 기준축을 남긴다.
            translate([0, 0, -0.1]) cylinder(d = boss_id, h = plate_t + 0.2);
            // 핀 숄더 보어(pin shoulder bore)는 M5 숄더 핀(shoulder pin) 기준 관통홀이다.
            translate([crank_radius, 0, -0.1])
                cylinder(d = small_shoulder_d + clearance / 2, h = plate_t + 0.2);
        }
    }
}

j3_crank();
