// KW12 mechanical limit switch vitamin mockup.

module kw12_limit_switch() {
    hole_pitch = 9.5;
    hole_d = 2.6;
    roller_w = 4;

    body_col = "#1f2933";
    lever_col = "#c4ccd4";
    pin_col = "#c8a23c";

    body = [19.8, 10.8, 6.4];
    roller_d = 5;
    lever_pivot = [-body[0] / 2, body[1] / 2];
    lever_len = 22;
    lever_rise = 8;
    terminal_x = [-9.5 / 2, 0, 9.5 / 2];

    length = body[0]; height = body[1]; thickness = body[2];
    pivot_x = lever_pivot[0]; pivot_y = lever_pivot[1];

    terminal_d = 0.9;
    terminal_len = 3.5;
    strip_w = 0.6;
    strip_h = 4;
    lever_anchor = [pivot_x, pivot_y, thickness / 2];
    strip_corner = [0, -strip_w, strip_h / -2];

    color(body_col)
        translate([-length / 2, -height / 2, 0]) difference() {
            cube([length, height, thickness]);
            for (s = [-1, 1])
                translate([length / 2 + s * hole_pitch / 2, height / 2, -0.1])
                    cylinder(d = hole_d, h = thickness + 0.2, $fn = 16);
        }

    color(pin_col)
        for (x = terminal_x)
            translate([x, -height / 2, thickness / 2]) rotate([90, 0, 0])
                cylinder(d = terminal_d, h = terminal_len, $fn = 8);

    color(lever_col)
        translate(lever_anchor) rotate([0, 0, lever_rise]) {
            translate(strip_corner) cube([lever_len, strip_w, strip_h]);
            translate([lever_len, 0, 0])
                    cylinder(d = roller_d, h = roller_w, center = true, $fn = 24);
        }
}

kw12_limit_switch();
