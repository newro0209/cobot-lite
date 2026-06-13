use <common.scad>

// [bore, OD, width] (mm) — 부품이 베어링 치수 필요할 때 가져다 쓰는 노출 값.
function bearing_608zz_spec() = [8, 22, 7];

module bearing_608zz(col = [0.62, 0.62, 0.63]) {
    bearing(bearing_608zz_spec(), col);
}

bearing_608zz();
