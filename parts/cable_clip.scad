// 케이블 가이드 클립 (cable guide clip) — 관절 외부 배선 경로용 (ELE-005)
// 링크 외면에 M3 체결. 필요 수량은 BOM 참조 (상완·하완 각 2~3개).
use <../lib/utils.scad>

module cable_clip_part(cable_d = 8, col = undef) {
    $fn = 64;
    clip_t = 6;
    clip_center_x = (-cable_d / 2 - 7 + sqrt(pow(cable_d / 2 + 2.5, 2) - pow(cable_d * 0.35, 2))) / 2;

    translate([-clip_center_x, 0, -clip_t / 2]) {
        apply_part_color(col) difference() {
            union() {
                cable_clip(cable_d = cable_d, t = clip_t);
                // 체결 베이스
                translate([-cable_d / 2 - 7, -(cable_d / 2 + 2.5), 0])
                    cube([7, cable_d + 5, clip_t]);
            }
            translate([-cable_d / 2 - 3.5, 0, -0.1]) bolt_hole(3, clip_t + 0.2);
        }
    }
}

cable_clip_part();
