// J3 크랭크 (crank) — 중앙 디스크 + 보스 OD 25(+Y 6805 저널) + 외단 플랜지
// =====================================================================
// 평행사변형 평면 = forearm 중앙(y=0). 크랭크 = J2축 회전 a = j3 + horn_phase.
//   디스크 OD 52(world y4.7~11.7) — 핀(R36.5, z0=-Y면)이 중앙 링크 625ZZ에 결합.
//   보스 OD 25 — +Y 측판 6805ZZ 내륜 안착.
//   외단 플랜지 — 기성 플랜지 커플러 M4 ×4 볼트온.
// 좌표: 부품 z0 = 디스크 -Y면(핀측, world y4.7). 출력: 보스 직립, 디스크 바닥 — 서포트 불요.
use <../lib/utils.scad>

// ── 공개 스펙 (assembly·링키지가 참조) ──
function j3_crank_radius() = 36;   // 핀 피치 반경 (= forearm 혼 R)
function j3_crank_disk_d() = 52;   // 중앙 디스크 외경

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

module j3_crank(col = undef) {
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
        apply_part_color(col) difference() {
            union() {
                linear_extrude(plate_t) crank2d();
            }
            // 중앙 경량 보어 (관통)
            translate([0, 0, -0.1]) cylinder(d = boss_id, h = plate_t + 0.2);
            // 핀 숄더 보어 (관통)
            translate([crank_radius, 0, -0.1])
                cylinder(d = small_shoulder_d + clearance / 2, h = plate_t + 0.2);
        }
    }
}

j3_crank();
