// 평행사변형 정적 핀 앵커 (parallelogram static-pin anchor) — MEC-002
// =====================================================================
// 어깨 텅 상단 시트(z=30 면)에 M3 ×2 체결. 링크 1의 접지(ground) 핀 제공.
// 좌표계: 어깨와 동일 (원점 = J2 축) — 조립 변환 불요.
// 분할 사유: 일체형 타워의 수평 암(+Y 돌출)이 직립 출력 시 하부 지지 불가
//   (하부는 상완 플레이트 B 스윕 존이라 웻지 금지) → 별도 부품을 측면(-X면)
//   눕혀 출력 = 전 형상 평면 내, 서포트 불요 (MFG-003)
// 형상 제약 (간섭 검사 근거, docs/design-notes.md §3):
//   · 수직부·베이스: y ≤ 29.7 (텅 폭 안)
//   · 수평 암: z ≥ pl_offset-7 (플레이트 B 상단 모서리 스윕 z_max ≈ 38 위)
// 하중: 링크 1 력 ≈ 13 N (손목 수평 유지 모멘트) — M3 ×2 전단으로 충분
include <../config/parameters.scad>
use <../lib/utils.scad>

anchor_face = arm_inner_w / 2 + arm_plate_t + dl_offset - 5; // 핀 면 (+Y) = 39

module pl_anchor() {
    difference() {
        union() {
            // 베이스 플레이트 (어깨 시트 z=30 위)
            translate([-10, 17, 30]) cube([20, tongue_w / 2 - 17, 6]);
            // 수직부 (텅 폭 안)
            translate([-7, 17, 30]) cube([14, tongue_w / 2 - 17, pl_offset + 7 - 30]);
            // 수평 암: 링크 평면까지 +Y 돌출 (z ≥ pl_offset-7)
            translate([-7, 17, pl_offset - 7]) cube([14, anchor_face - 17, 14]);
        }
        // 정적 핀: M4 파일럿 (+Y면, 5mm 숄더 볼트 체결)
        translate([0, anchor_face + 0.1, pl_offset]) rotate([90, 0, 0])
            cylinder(d = set_screw_pilot_d, h = 14);
        // 어깨 체결 M3 ×2 (관통 + 머리 카운터보어)
        for (x = [-6, 6]) {
            translate([x, 23.4, 29.9]) bolt_hole(3, 6.3);
            translate([x, 23.4, 34]) cylinder(d = 6.5, h = 2.2);
        }
    }
}

pl_anchor();
