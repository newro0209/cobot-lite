// Common vitamin mockup primitives.
// Shared generic modules used by item-specific vitamin files.
// Public vitamins are origin-centered; output shafts point +Z.

// ── Actuator ──────────────────────────────────────────────────────────

module motor_sf24(len) {
    frame = 42;
    translate([0, 0, -len / 2])
        linear_extrude(len)
            offset(r = 3) square(frame - 6, center = true);
}

module gearbox_mg17(len, col = [0.16, 0.16, 0.16]) {
    frame = 42;
    shaft_d = 8;
    shaft_len = 20;
    pilot_d = 22;
    output_z = (len - shaft_len) / 2;

    color(col) translate([0, 0, output_z - len]) cylinder(d = frame, h = len);
    color(col * 1.7) translate([0, 0, output_z]) cylinder(d = shaft_d, h = shaft_len);
    color(col * 1.4) translate([0, 0, output_z]) cylinder(d = pilot_d, h = 2);
}

module actuator(motor_len, gbx_len, col = [0.16, 0.16, 0.16]) {
    shaft_len = 20;
    translate([0, 0, motor_len / 2])
        gearbox_mg17(gbx_len, col);
    color(col * 0.8)
        translate([0, 0, -(gbx_len + shaft_len) / 2])
            motor_sf24(motor_len);
}

module actuator_J2(col = [0.16, 0.16, 0.16]) {
    motor_len = 47;
    gbx_len = 51;
    actuator(motor_len, gbx_len, col);
}

module actuator_J3(col = [0.16, 0.16, 0.16]) {
    motor_len = 39;
    gbx_len = 51;
    actuator(motor_len, gbx_len, col);
}

// ── Bearing ───────────────────────────────────────────────────────────

module bearing(brg, col = [0.62, 0.62, 0.63]) {
    bore = brg[0]; od = brg[1]; w = brg[2];
    span = (od - bore) / 2;
    race = span * 0.30;
    inner_od = bore + 2 * race;
    outer_id = od - 2 * race;
    seal_h = w * 0.66;
    base_z = -w / 2;
    seal_z = base_z + (w - seal_h) / 2;

    module ring(d_in, d_out, h) {
        difference() {
            cylinder(d = d_out, h = h);
            translate([0, 0, -0.1]) cylinder(d = d_in, h = h + 0.2);
        }
    }

    color(col) translate([0, 0, base_z]) ring(bore, inner_od, w);
    color(col) translate([0, 0, base_z]) ring(outer_id, od, w);
    color(col * 0.45)
        translate([0, 0, seal_z]) ring(inner_od - 0.01, outer_id + 0.01, seal_h);
}

// ── Coupler ───────────────────────────────────────────────────────────

module flange_coupler(col = [0.72, 0.72, 0.74],
                      bolt_r = 12, bolt_n = 4, bolt_d = 4) {
    bore = 8;
    flange_od = 32;
    flange_t = 3;
    body_od = 16;
    body_h = 10;
    total_h = flange_t + body_h;
    set_d = 3;
    top_z = total_h / 2;
    flange_z = top_z - flange_t;
    body_z = top_z - total_h;

    color(col) difference() {
        translate([0, 0, flange_z])
            cylinder(d = flange_od, h = flange_t);
        for (i = [0 : bolt_n - 1])
            rotate([0, 0, 45 + i * 360 / bolt_n])
                translate([bolt_r, 0, flange_z - 0.1])
                    cylinder(d = bolt_d + 0.4, h = flange_t + 0.2);
        translate([0, 0, body_z - 0.1]) cylinder(d = bore, h = total_h + 0.2);
    }

    color(col * 0.82) difference() {
        translate([0, 0, body_z]) cylinder(d = body_od, h = body_h);
        translate([0, 0, body_z - 0.1]) cylinder(d = bore, h = total_h + 0.2);
        for (ang = [0, 90])
            rotate([0, 0, ang]) translate([0, 0, body_z + body_h / 2])
                rotate([0, -90, 0]) cylinder(d = set_d, h = body_od);
    }
}

// ── Fasteners ─────────────────────────────────────────────────────────

module screw_thread(od, len, pitch = undef) {
    p = is_undef(pitch) ? od * 0.18 : pitch;
    turns = len / p;
    core = od * 0.80;
    linear_extrude(height = len, twist = -360 * turns, convexity = 4,
                   slices = max(10, ceil(turns * 10)), $fn = 24)
        union() {
            circle(d = core);
            polygon([[0, 0], [od / 2, p * 0.16], [od / 2, -p * 0.16]]);
        }
}

module shoulder_bolt(d, l, col = [0.42, 0.42, 0.42]) {
    head_d = d * 1.5;
    head_h = d;
    chamfer_h = head_d * 0.08;
    thread_d = d * 0.72;
    neck_d = thread_d * 0.82;
    socket_af = d * 0.6;
    socket_h = head_h * 0.55;
    shoulder_z = -l / 2;
    head_z = shoulder_z - head_h;
    neck_z = l / 2;
    thread_z = neck_z + neck_d * 0.3;

    color(col * 0.7) difference() {
        intersection() {
            translate([0, 0, head_z]) cylinder(d = head_d, h = head_h);
            union() {
                translate([0, 0, head_z]) cylinder(d1 = head_d - 2 * chamfer_h, d2 = head_d, h = chamfer_h, $fn = 48);
                translate([0, 0, head_z + chamfer_h]) cylinder(d = head_d, h = head_h - chamfer_h, $fn = 48);
            }
        }
        translate([0, 0, head_z - 0.1])
            cylinder(d = socket_af / cos(30), h = socket_h, $fn = 6);
    }

    color(col) translate([0, 0, shoulder_z]) cylinder(d = d, h = l, $fn = 48);
    color(col * 0.9) translate([0, 0, neck_z]) cylinder(d = neck_d, h = neck_d * 0.3, $fn = 32);
    color(col * 1.2) translate([0, 0, thread_z]) screw_thread(thread_d, d - neck_d * 0.3);
}

module cap_screw(d, l, col = [0.42, 0.42, 0.42]) {
    head_d = d * 1.5;
    head_h = d;
    chamfer_h = head_d * 0.08;
    socket_af = d * 0.6;
    socket_h = head_h * 0.6;
    tip_h = d * 0.5;
    thread_z = (d - l) / 2;
    head_z = thread_z - head_h;

    color(col * 0.7) difference() {
        intersection() {
            translate([0, 0, head_z]) cylinder(d = head_d, h = head_h, $fn = 48);
            union() {
                translate([0, 0, head_z]) cylinder(d1 = head_d - 2 * chamfer_h, d2 = head_d, h = chamfer_h, $fn = 48);
                translate([0, 0, head_z + chamfer_h]) cylinder(d = head_d, h = head_h - chamfer_h, $fn = 48);
            }
        }
        translate([0, 0, head_z - 0.1])
            cylinder(d = socket_af / cos(30), h = socket_h, $fn = 6);
    }

    color(col) translate([0, 0, thread_z]) intersection() {
        screw_thread(d, l);
        union() {
            cylinder(d = d + 1, h = l - tip_h);
            translate([0, 0, l - tip_h]) cylinder(d1 = d + 1, d2 = d * 0.7, h = tip_h, $fn = 32);
        }
    }
}

module hex_standoff(af, l, col = [0.42, 0.42, 0.42]) {
    base_z = -l / 2;

    color(col) difference() {
        translate([0, 0, base_z]) cylinder(d = af / cos(30), h = l, $fn = 6);
        translate([0, 0, base_z - 0.1]) cylinder(d = af * 0.45, h = l + 0.2);
    }
}

module lock_nut(af, t, bore, col = [0.42, 0.42, 0.42]) {
    corner_d = af / cos(30);
    chamfer_h = (corner_d - af) / 2;
    lead_h = min(0.8, bore * 0.12);
    base_z = -t * 0.75;

    color(col) difference() {
        intersection() {
            translate([0, 0, base_z]) cylinder(d = corner_d, h = t, $fn = 6);
            union() {
                translate([0, 0, base_z]) cylinder(d1 = af, d2 = corner_d, h = chamfer_h, $fn = 48);
                translate([0, 0, base_z + chamfer_h]) cylinder(d = corner_d, h = t - 2 * chamfer_h, $fn = 6);
                translate([0, 0, base_z + t - chamfer_h])
                    cylinder(d1 = corner_d, d2 = af, h = chamfer_h, $fn = 48);
            }
        }
        translate([0, 0, base_z - 0.1]) cylinder(d = bore, h = t + 0.2);
        translate([0, 0, base_z - 0.01])
            cylinder(d1 = bore + 2 * lead_h, d2 = bore, h = lead_h);
        translate([0, 0, base_z + t - lead_h + 0.01])
            cylinder(d1 = bore, d2 = bore + 2 * lead_h, h = lead_h);
    }

    skirt_d = af * 0.9;
    cap_h = t * 0.5;
    color(col * 1.35) difference() {
        union() {
            translate([0, 0, base_z + t - 0.1]) cylinder(d = skirt_d, h = cap_h * 0.6, $fn = 48);
            translate([0, 0, base_z + t - 0.1 + cap_h * 0.6])
                cylinder(d1 = skirt_d, d2 = skirt_d * 0.7, h = cap_h * 0.4, $fn = 48);
        }
        translate([0, 0, base_z - 0.1]) cylinder(d = bore, h = t + cap_h + 0.4);
    }
}

module washer(d_in, t = 1.2, col = [0.50, 0.50, 0.50]) {
    base_z = -t / 2;

    color(col) difference() {
        translate([0, 0, base_z]) cylinder(d = d_in * 1.5, h = t);
        translate([0, 0, base_z - 0.1]) cylinder(d = d_in + 0.3, h = t + 0.2);
    }
}

module spacer(od, bore, l, col = [1.0, 1.0, 1.0]) {
    base_z = -l / 2;

    color(col) difference() {
        translate([0, 0, base_z]) cylinder(d = od, h = l);
        translate([0, 0, base_z - 0.1]) cylinder(d = bore, h = l + 0.2);
    }
}
