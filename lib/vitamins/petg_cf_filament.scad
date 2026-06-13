// PETG-CF filament spool placeholder for BOM visualization.

module petg_cf_filament(col = [0.08, 0.08, 0.08]) {
    outer_d = 200;
    inner_d = 52;
    width = 65;
    color(col) difference() {
        cylinder(d = outer_d, h = width, center = true);
        cylinder(d = inner_d, h = width + 0.2, center = true);
    }
}

petg_cf_filament();
