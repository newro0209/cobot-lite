// 팔꿈치 허브 (elbow hub) — J3 직결: 기어박스 출력축 ⌀8 클램프 → 하완 볼트온
// =====================================================================
// 구 크랭크→구동 링크→혼 평행사변형(v0.15 이전)을 대체 — 직결 1부품.
// 좌표계: z0 = 장착면(하완 -Y 측판 외면, 조립 y=-22), +z = 외측(-Y),
//        디스크 ⌀44 × t7 — 관절 측면 갭 8mm 안에 수납 (외면 여유 1mm)
// 체결: M4 FHCS ×3 (r17, 위상 60/180/300 — 하완 측판 파일럿과 1:1,
//   동일 측판 플립 장착 호환) — z7 면에서 접시 플러시.
//   조립 순서: 허브를 측판에 선체결 → 포크 삽입 → 출력축 삽입 → 핀치 조임
// 클램프: 보어 ⌀8 + 슬릿 + M3 핀치 (슬릿 위상 120° — FHCS·베인과 분리).
//   핀치 접근은 갭 반경 방향 (볼엔드 키) [잠정 — 조립성 확인 항목]
// 베인: J3 리미트 감지 탭 (r48, 위상 elbow_vane_a) — 허브 일체, 평면 출력
include <../config/parameters.scad>
use <../lib/utils.scad>

module elbow_hub() {
    difference() {
        union() {
            cylinder(d = elbow_hub_d, h = elbow_hub_t);
            // 리미트 베인 탭 (상완 측판 내면의 스위치를 접힘 한계에서 트리거)
            rotate([0, 0, elbow_vane_a])
                translate([0, -elbow_vane_w / 2, 0])
                    cube([elbow_vane_r, elbow_vane_w, elbow_hub_t]);
        }
        // 출력축 클램프 (보어 + 슬릿 + M3 핀치) — 슬릿 위상 120°
        rotate([0, 0, 30]) translate([0, 0, -0.1])
            shaft_clamp_cut(gbx_out_shaft_d, elbow_hub_t + 0.2, elbow_hub_d);
        // M4 ×3 (r17): 접시머리(FHCS) — z7 면 플러시, 하완 파일럿과 동위상
        for (a = [60, 180, 300]) rotate([0, 0, a]) {
            translate([elbow_hub_bolt_r, 0, -0.1])
                bolt_hole(4, elbow_hub_t + 0.2);
            translate([elbow_hub_bolt_r, 0, elbow_hub_t - 2.2])
                cylinder(d1 = 4.4, d2 = 9, h = 2.3);
        }
    }
}

elbow_hub();
