use <common.scad>

// [bore, OD, width] (mm) — 부품이 베어링 치수 필요할 때 가져다 쓰는 노출 값.
function bearing_625zz_spec() = [5, 16, 5];

module bearing_625zz(col = [0.62, 0.62, 0.63]) {
    bearing(bearing_625zz_spec(), col);
}

bearing_625zz();
