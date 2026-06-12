// J3 크랭크 (crank) — J3 기어박스 출력축에 클램프, 구동 링크 입력단 (MEC-001a)
// 평행사변형 1:1: 크랭크 반경 = 하완 혼 반경 = j3_crank_len.
// 출력 자세: 평면 그대로 (서포트 불요).
// 좌표: 허브 축 = Z (조립 시 -Y 방향), 핀 = +X 방향 j3_crank_len.
include <../config/parameters.scad>
use <../lib/utils.scad>

// 하중: 구동 링크 핀 력 ≈ T_J3 / j3_crank_len ≈ 4.3 N·m / 0.04 m ≈ 108 N
//       핀 단 보스 ⌀16 (벽 6.3mm) — 전단은 숄더 볼트 생크가 부담,
//       암 굽힘은 허브 전폭(crank_hub_w) 루트에서 받음
module j3_crank() {
    difference() {
        union() {
            cylinder(d = crank_hub_d, h = crank_hub_w);            // 허브 (클램프)
            hull() {                                                // 암 — 허브 루트는 전폭
                cylinder(d = crank_hub_d, h = crank_hub_w);
                translate([j3_crank_len, 0, 0]) cylinder(d = 16, h = crank_t);
            }
            // J3 리미트 베인 (허브 반대측 반경 방향 탭, 각도 180° 기준)
            translate([-crank_hub_d / 2 - 5, -3, 0]) cube([6, 6, crank_t]);
        }
        // 출력축 클램프 (보어 + 슬릿 + M3 핀치) — 슬릿은 +Y측
        translate([0, 0, -0.1])
            shaft_clamp_cut(gbx_out_shaft_d, crank_hub_w + 0.2, crank_hub_d);
        // 구동 링크 핀: M4 파일럿 (5mm 숄더 볼트 체결, 나사 물림 = 보스 전체)
        translate([j3_crank_len, 0, -0.1])
            cylinder(d = set_screw_pilot_d, h = crank_hub_w + 0.2);
    }
}

j3_crank();
