// 용어
// 1. 리미트 스위치(limit switch)
// 2. 비타민 목업(vitamin mockup)
// 3. 장착홀 피치(mounting hole pitch)
// 4. 단자 피치(terminal pitch)
// 5. 레버 스트립(lever strip)
// 6. 롤러(roller)

// KW12 기계식 부품의 외형 검토용 모델입니다.
// 원점은 본체 바닥 면적 중심이고 Z는 본체 바닥에서 시작합니다.

$fa = 6;
$fs = 0.6;

// 치수 배열 순서: [길이, 높이, 두께] (mm).
function kw12_limit_switch_body_size() = [19.8, 10.8, 6.4];

module _kw12_body(size, hole_pitch, hole_d, part_color) {
    length = size[0];
    height = size[1];
    thickness = size[2];
    eps = 0.1;

    assert(length > 0, "KW12 본체 길이(length)는 양수여야 합니다");
    assert(height > 0, "KW12 본체 높이(height)는 양수여야 합니다");
    assert(thickness > 0, "KW12 본체 두께(thickness)는 양수여야 합니다");
    assert(hole_pitch > 0, "KW12 장착홀 피치(hole_pitch)는 양수여야 합니다");
    assert(hole_d > 0, "KW12 장착홀 지름(hole_d)은 양수여야 합니다");

    color(part_color)
        translate([-length / 2, -height / 2, 0])
            difference() {
                cube(size);
                for (x = [-hole_pitch / 2, hole_pitch / 2])
                    translate([length / 2 + x, height / 2, -eps])
                        cylinder(d = hole_d, h = thickness + 2 * eps, $fn = 16);
            }
}

module _kw12_terminals(size, terminal_pitch, terminal_d, terminal_len, part_color) {
    height = size[1];
    thickness = size[2];

    assert(terminal_pitch > 0, "KW12 단자 피치(terminal_pitch)는 양수여야 합니다");
    assert(terminal_d > 0, "KW12 단자 지름(terminal_d)은 양수여야 합니다");
    assert(terminal_len > 0, "KW12 단자 길이(terminal_len)는 양수여야 합니다");

    color(part_color)
        for (x = [-terminal_pitch / 2, 0, terminal_pitch / 2])
            translate([x, -height / 2, thickness / 2])
                rotate([90, 0, 0])
                    cylinder(d = terminal_d, h = terminal_len, $fn = 8);
}

module _kw12_lever(size, lever_len, lever_rise, strip_w, strip_h, roller_d, roller_w, part_color) {
    length = size[0];
    height = size[1];
    thickness = size[2];
    lever_anchor = [-length / 2, height / 2, thickness / 2];
    strip_corner = [0, -strip_w, -strip_h / 2];

    assert(lever_len > 0, "KW12 레버 길이(lever_len)는 양수여야 합니다");
    assert(strip_w > 0, "KW12 레버 스트립 폭(strip_w)은 양수여야 합니다");
    assert(strip_h > 0, "KW12 레버 스트립 높이(strip_h)는 양수여야 합니다");
    assert(roller_d > 0, "KW12 롤러 지름(roller_d)은 양수여야 합니다");
    assert(roller_w > 0, "KW12 롤러 폭(roller_w)은 양수여야 합니다");

    color(part_color)
        translate(lever_anchor)
            rotate([0, 0, lever_rise]) {
                translate(strip_corner)
                    cube([lever_len, strip_w, strip_h]);
                translate([lever_len, 0, 0])
                    cylinder(d = roller_d, h = roller_w, center = true, $fn = 24);
            }
}

module kw12_limit_switch(body_color = "#1f2933", lever_color = "#c4ccd4", pin_color = "#c8a23c") {
    body = kw12_limit_switch_body_size();

    mount_hole_pitch = 9.5;
    mount_hole_d = 2.6;

    terminal_pitch = 9.5;
    terminal_d = 0.9;
    terminal_len = 3.5;

    lever_len = 22;
    lever_rise = 8;
    strip_w = 0.6;
    strip_h = 4;
    roller_d = 5;
    roller_w = 4;

    _kw12_body(size = body,
               hole_pitch = mount_hole_pitch,
               hole_d = mount_hole_d,
               part_color = body_color);
    _kw12_terminals(size = body,
                    terminal_pitch = terminal_pitch,
                    terminal_d = terminal_d,
                    terminal_len = terminal_len,
                    part_color = pin_color);
    _kw12_lever(size = body,
                lever_len = lever_len,
                lever_rise = lever_rise,
                strip_w = strip_w,
                strip_h = strip_h,
                roller_d = roller_d,
                roller_w = roller_w,
                part_color = lever_color);
}

kw12_limit_switch();
