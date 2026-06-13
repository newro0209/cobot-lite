use <common.scad>

// [bore, OD, width] (mm) — 부품이 베어링 치수 필요할 때 가져다 쓰는 노출 값.
function bearing_6805zz_spec() = [25, 37, 7];

module bearing_6805zz(col = [0.62, 0.62, 0.63]) {
    bearing(bearing_6805zz_spec(), col);
}

bearing_6805zz();
