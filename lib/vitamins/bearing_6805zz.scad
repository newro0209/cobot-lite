
use <common.scad>

// 용어
// 1. 베어링(bearing)
// 2. 보어(bore)
// 3. 외경(outer diameter)
// 4. 폭(width)

// 치수 배열 순서: [2번, 3번, 4번] (mm). 조립부가 6805ZZ 기준 치수를 공유할 때 사용합니다.
function bearing_6805zz_spec() = [25, 37, 7];

module bearing_6805zz(part_color = [0, 0.6, 1]) {
    bearing(bearing_spec = bearing_6805zz_spec(), part_color = part_color);
}

bearing_6805zz();
