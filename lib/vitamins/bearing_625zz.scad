
use <common.scad>

// 용어:
// 1. 내경(bore)
// 2. 외경(outer diameter)
// 3. 폭(width)
// 4. 베어링(bearing)
//
// [내경(bore), 외경(outer diameter), 폭(width)] mm — 부품이 베어링(bearing) 치수를 참조할 때 쓰는 공개 값이다.
function bearing_625zz_spec() = [5, 16, 5];

module bearing_625zz(part_color = [0, 0.6, 1]) {
    bearing(bearing_spec = bearing_625zz_spec(), part_color = part_color);
}

bearing_625zz();
