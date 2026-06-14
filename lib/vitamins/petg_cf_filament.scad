
use <common.scad>

// 용어:
// 1. 자재 명세서(bill of materials)
// 2. 탄소섬유 보강 PETG(PETG-CF)
// 3. 필라멘트 스풀(filament spool)
// 4. 외경(outer diameter)
// 5. 내경(inner diameter)

// 자재 명세서(bill of materials) 시각화를 위한 탄소섬유 보강 PETG(PETG-CF) 필라멘트 스풀(filament spool) 목업입니다.
module petg_cf_filament(part_color = [0, 0.7, 0]) {
    outer_d = 200;
    inner_d = 52;
    width = 65;
    assert(outer_d > inner_d, "스풀 외경(outer_d)은 내경보다 커야 합니다");
    assert(width > 0, "스풀 폭(width)은 양수여야 합니다");

    color(part_color) difference() {
        cylinder(d = outer_d, h = width, center = true);
        cylinder(d = inner_d, h = width + 0.2, center = true);
    }
}

petg_cf_filament();
