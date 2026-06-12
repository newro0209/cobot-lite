// 턴테이블 (turntable) — 디스크 + 외륜 컵 + 출력축 스템 일체 (v0.15 재설계)
// =====================================================================
// 좌표: z0 = 디스크 상면(어깨 장착면), 본체 -z. 도립 출력(상면 베드 — 서포트리스)
// 컵 스커트: 6810ZZ 외륜을 잡는다 — 상부 압입 존 + 내부 숄더(상부 외륜 상면
//   접촉), 하부는 슬립 존(베이스 포스트 하부 베어링 외륜의 반경 가이드).
//   구 turntable_spacer(별도 링) 폐지 — 이격 30mm는 베이스 포스트 랜드가 결정
// 스템: 포스트 보어 ⌀24 통과, 선단 ⌀8 보어 + M4 무두 파일럿 ×2 (90° 위상,
//   베이스 칼럼 액세스 홀과 z 정렬)
// 어깨 장착: M5 — 풋 탭 관통 ×4 (±40, ±25) + 플랜지 직결 ×2 (0, ±25), 너트 하면
include <../config/parameters.scad>
use <../lib/utils.scad>

skirt_od = BRG_6810ZZ[1] + 0.55 + 8;      // 73.4 — 슬립 보어 + 벽 4
stem_len = 75;                            // 디스크 하면 → 스템 선단 (z -83)

module turntable() {
    difference() {
        union() {
            translate([0, 0, -turntable_top_t])
                cylinder(d = turntable_top_d, h = turntable_top_t);
            translate([0, 0, -53]) cylinder(d = skirt_od, h = 45);   // 컵 스커트
            translate([0, 0, -8 - stem_len])
                cylinder(d = tt_stem_d, h = stem_len);
            // J1 리미트 베인 — 스커트 외측 반경 탭 (방위각 180), 하단이 레버 타격
            rotate(180) translate([38, -3, -55.5]) cube([4, 6, 14]);
        }
        // 컵 보어: 슬립 존(-53..-18) / 압입 존(-18..-10) / 숄더 링(ID56, -10..-8)
        translate([0, 0, -53.1]) cylinder(d = BRG_6810ZZ[1] + 0.55, h = 35.1);
        translate([0, 0, -18])
            cylinder(d = BRG_6810ZZ[1] + bearing_press_fit, h = 8);
        translate([0, 0, -10]) cylinder(d = 56, h = 2);
        // 스템 선단 ⌀8 보어 (기어박스 출력축, 물림 14) + M4 무두 파일럿 ×2
        translate([0, 0, -8 - stem_len - 0.1])
            cylinder(d = gbx_out_shaft_d + clearance_fit, h = 14.1);
        for (p = [[0, -79], [90, -74]])
            rotate(p[0]) translate([0, 0, p[1]])
                rotate([0, 90, 0]) cylinder(d = set_screw_pilot_d, h = tt_stem_d);
        // 어깨 장착 M5 ×6
        for (pt = [[40, 25], [40, -25], [-40, 25], [-40, -25], [0, 25], [0, -25]])
            translate([pt[0], pt[1], -turntable_top_t - 0.1])
                bolt_hole(shoulder_mount_bolt_d, turntable_top_t + 0.2);
    }
}

turntable();
