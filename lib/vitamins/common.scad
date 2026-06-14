// 비타민(vitamin) 목업 공통 프리미티브입니다.
// 공개 비타민(vitamin)은 원점 중심이며, 출력축(output shaft)은 +Z 방향을 향합니다.
//
// 용어:
// 1. 비타민(vitamin)
// 2. 액추에이터(actuator)
// 3. 스테퍼 모터(stepper motor)
// 4. 감속기(gearbox)
// 5. 출력축(output shaft)
// 6. 파일럿 보스(pilot boss)
// 7. 카운터보어(counterbore)
// 8. 베어링(bearing)
// 9. 플랜지 커플러(flange coupler)
// 10. 숄더 볼트(shoulder bolt)
// 11. 캡스크류(cap screw)
// 12. 스탠드오프(standoff)
// 13. 로크 너트(lock nut)
// 14. 와셔(washer)
// 15. 스페이서(spacer)

$fa = 6;
$fs = 0.6;

// ── 액추에이터(actuator) ─────────────────────────────────────────────

// Sanyo Denki SF24xx-12B41 NEMA17 스테퍼 모터(stepper motor) 목업입니다.
// 원점은 금속 캔(metal can) 중심이며, 출력축(output shaft)은 +Z 방향입니다.
module motor_sf24(body_len, part_color = [0, 0.18, 0.89]) {
    assert(body_len > 0, "모터 본체 길이(body_len)는 양수여야 합니다");

    frame   = 42;     // 사각 프레임(square frame) 한 변, ±0.5
    chamfer = 5;      // 모서리 컷(cut corner), NEMA17 기준
    pitch   = 31;     // M3 체결 피치(mounting hole pattern), ±0.25
    hole_d  = 3;      // M3
    hole_depth = 4.5; // 탭 깊이(tap depth), 최소 4 mm
    counterbore_d = 5; // 전면 체결홀 카운터보어(counterbore)
    counterbore_h = 1.3;
    cap     = 4;      // 엔드벨 두께(endbell thickness)
    boss_d  = 22;     // 파일럿 보스 (pilot register, Ø22 -0.021)
    boss_h  = 1.5;    // 보스 높이 (±0.2)
    shaft_d = 5;      // 출력축 (output shaft, Ø5 -0.012)
    shaft_len = 24;   // 축 돌출(projection from front face), ±0.5
    flat_len = 15;    // D컷 길이(effective length), +1/0
    flat_depth = 0.5; // D컷 깊이(flat depth)
    groove_z = 2.4;   // 서클립 그루브(circlip groove) 위치

    front_z = body_len / 2;    // 전면(축) 면(front shaft face)
    rear_z = -body_len / 2;    // 후면(리드) 면(rear lead face)
    hole_pitch_radius  = pitch / 2;

    aluminum_color = [0.74, 0.75, 0.77]; // 알루미늄 엔드벨(machined aluminum)
    steel = [0.80, 0.80, 0.82];   // 축·강재(steel)
    core  = part_color * 0.85;           // 흑색 적층 코어(matte-black laminated core)

    // 모서리 컷(chamfered corner)이 있는 NEMA17 사각 단면이다.
    module chamfered_square(square_size, corner_cut) {
        half_size = square_size / 2;
        polygon([[half_size - corner_cut, half_size], [-half_size + corner_cut, half_size],
                 [-half_size, half_size - corner_cut], [-half_size, -half_size + corner_cut],
                 [-half_size + corner_cut, -half_size], [half_size - corner_cut, -half_size],
                 [half_size, -half_size + corner_cut], [half_size, half_size - corner_cut]]);
    }
    module band(h) linear_extrude(h) chamfered_square(square_size = frame, corner_cut = chamfer);

    // 전면 알루미늄 엔드벨(front aluminum endbell)은 카운터보어(counterbore) 체결홀을 가진다.
    color(aluminum_color) difference() {
        translate([0, 0, front_z - cap]) band(cap);
        for (x = [-hole_pitch_radius, hole_pitch_radius], y = [-hole_pitch_radius, hole_pitch_radius]) {
            translate([x, y, front_z - hole_depth]) cylinder(d = hole_d, h = hole_depth + 0.1, $fn = 24);
            translate([x, y, front_z - counterbore_h]) cylinder(d = counterbore_d, h = counterbore_h + 0.1, $fn = 24);
        }
    }
    // 흑색 적층 코어(laminated core)는 모터 본체 색상 대비를 준다.
    color(core) translate([0, 0, rear_z + cap]) band(body_len - 2 * cap);
    // 후면 엔드벨(rear endbell)은 리드선 측 기준면을 표현한다.
    color(core * 1.12) difference() {
        translate([0, 0, rear_z]) band(cap);
        for (x = [-hole_pitch_radius, hole_pitch_radius], y = [-hole_pitch_radius, hole_pitch_radius])
            translate([x, y, rear_z - 0.1]) cylinder(d = hole_d, h = hole_depth + 0.1, $fn = 24);
    }

    // 전면 파일럿 보스(pilot boss)는 모터 센터링 기준이다.
    color(aluminum_color) translate([0, 0, front_z]) cylinder(d = boss_d, h = boss_h, $fn = 64);

    // 출력축(output shaft)은 D컷(D-flat)과 서클립 그루브(circlip groove)를 포함한다.
    color(steel) translate([0, 0, front_z]) difference() {
        cylinder(d = shaft_d, h = shaft_len, $fn = 48);
        translate([shaft_d / 2 - flat_depth, -shaft_d, shaft_len - flat_len])
            cube([shaft_d, 2 * shaft_d, flat_len + 0.5]);
        rotate_extrude($fn = 48) translate([shaft_d / 2 - 0.35, groove_z]) square([0.6, 0.7]);
    }

    // 후면 온보드 JST PH 슈라우드 헤더(shrouded header)를 시각화한다.
    // B-PH-FK 상당, 11극 베이스에 짝수극 결번 → 6극(1·3·5·7·9·11), 유효 4.0mm 피치.
    connector_len = 24;    // 11극 PH 하우징 길이(X)
    connector_width = 5;   // 깊이(Y)
    connector_height = 6;  // 후면 위 높이(-Z)
    wall   = 0.9;      // 슈라우드 벽 두께 / shroud wall
    pin_count = 6;
    pin_pitch = 4.0;     // 유효 피치(effective pitch), 2.0×2
    connector_y = frame / 2 - 5;        // +Y 모서리 근처
    connector_z = rear_z - connector_height; // 슈라우드 바깥 면
    housing_color = [0.93, 0.93, 0.92]; // 백색 나일론 하우징

    // 슈라우드(shroud)는 -Z 방향 결합 개구(mating opening)를 가진다.
    color(housing_color) difference() {
        translate([-connector_len / 2, connector_y - connector_width / 2, connector_z])
            cube([connector_len, connector_width, connector_height]);
        translate([-connector_len / 2 + wall, connector_y - connector_width / 2 + wall, connector_z - 0.1])
            cube([connector_len - 2 * wall, connector_width - 2 * wall, connector_height - wall]);
    }
    // 프릭션 락 램프(friction-lock ramp)는 +Y 외벽에 둔다.
    color(housing_color) translate([-3, connector_y + connector_width / 2 - 0.1, connector_z + 1.5])
        rotate([90, 0, 90]) linear_extrude(6)
            polygon([[0, 0], [1.3, 0], [0, 2.6]]);
    // 6극 사각 포스트(square post)는 슈라우드(shroud) 내부 핀 배열을 나타낸다.
    color([0.85, 0.72, 0.30])
        for (i = [0 : pin_count - 1])
            translate([-(pin_count - 1) * pin_pitch / 2 + i * pin_pitch - 0.3,
                       connector_y - 0.3,
                       connector_z + wall])
                cube([0.6, 0.6, connector_height - wall + 1]);
}

// 감속기(gearbox) 본체 중심은 원점이고, 출력면(output face)은 +gearbox_body_len/2이다.
// 모터 전면(front face)이 감속기 입력면(input face)에 밀착 체결된다.
module actuator(motor_body_len, gearbox_body_len, part_color = [0, 0.18, 0.89]) {
    assert(motor_body_len > 0, "모터 본체 길이(motor_body_len)는 양수여야 합니다");
    assert(gearbox_body_len > 0, "감속기 본체 길이(gearbox_body_len)는 양수여야 합니다");

    gearbox_mg17(body_len = gearbox_body_len, part_color = part_color);
    translate([0, 0, -gearbox_body_len / 2 - motor_body_len / 2])
        motor_sf24(body_len = motor_body_len, part_color = part_color * 0.8);
}

// 액추에이터(actuator) 출력면, 즉 감속기 출력 플랜지(output flange) 면의 로컬 z는 조립 배치 기준이다.
function actuator_output_z(gearbox_body_len) = gearbox_body_len / 2;

// 직결 관절 액추에이터(actuator) 프리셋(preset):
//   J1 베이스 요(base yaw) = SF2424(47) + MG17-G20(51)
//   J2 숄더 피치(shoulder pitch) = SF2424(47) + MG17-G20(51)
//   J3 엘보 피치(elbow pitch) = SF2422(39) + MG17-G10(40)
module actuator_j1(part_color = [0, 0.18, 0.89]) {
    actuator(motor_body_len = 47, gearbox_body_len = mg17_len(20), part_color = part_color);   // SF2424 + G20
}

module actuator_j2(part_color = [0, 0.18, 0.89]) {
    actuator(motor_body_len = 47, gearbox_body_len = mg17_len(20), part_color = part_color);   // SF2424 + G20
}

module actuator_j3(part_color = [0, 0.18, 0.89]) {
    actuator(motor_body_len = 39, gearbox_body_len = mg17_len(10), part_color = part_color);   // SF2422 + G10
}

// MG17 장착 인터페이스(mount interface)는 캐리어 파츠(carrier part)가 하드코딩 대신 참조한다.
// gearbox_mg17 모듈 형상의 정본 치수(canonical dimension)와 동일하게 미러링한다.
function mg17_body_d()          = 54;    // 원통 하우징 외경
function mg17_input_pitch()     = 31;    // NEMA17 모터측 볼트 패턴 (□31)
function mg17_input_pilot_d()   = 22;    // 입력 파일럿
function mg17_input_clear_d()   = 3.5;   // 입력 통과홀
function mg17_output_pilot_d()  = 25;    // 출력 파일럿 보스 (Ø25)
function mg17_output_pilot_h()  = 3;     // 보스 돌출
function mg17_output_bolt_circle() = 35; // 출력 볼트원 (Ø35)
function mg17_output_bc()       = mg17_output_bolt_circle(); // 기존 호출 호환용
function mg17_output_bolt_d()   = 4;     // 4x M4
function mg17_output_shaft_d()  = 10;    // 출력축 Ø10
function mg17_output_shaft_flat() = 8;   // D컷 across-flat (Ø8)
function mg17_output_shaft_len()  = 21.5;// 축 돌출
function mg17_len(ratio)        = ratio >= 20 ? 51 : 40;  // body_len by 감속비

// 감속기 출력 플랜지 장착 컷(output flange mount cut)은 캐리어 판(carrier plate)에 적용한다.
// 파일럿 보어(pilot bore), 4×M4 통과홀(clearance hole), 출력축(output shaft) 관통을 함께 만든다.
module mg17_output_mount(h, pilot_clearance = 0.3, bolt_clearance = 0.6) {
    assert(h > 0, "장착판 두께(h)는 양수여야 합니다");
    assert(pilot_clearance >= 0, "파일럿 클리어런스(pilot_clearance)는 음수일 수 없습니다");
    assert(bolt_clearance >= 0, "볼트 클리어런스(bolt_clearance)는 음수일 수 없습니다");

    translate([0, 0, -0.1]) cylinder(d = mg17_output_pilot_d() + pilot_clearance, h = h + 0.2);
    for (i = [0 : 3])
        rotate([0, 0, 45 + i * 90])
            translate([mg17_output_bolt_circle() / 2, 0, -0.1])
                cylinder(d = mg17_output_bolt_d() + bolt_clearance, h = h + 0.2, $fn = 24);
}

// STEPPERONLINE MG17 유성 감속기(planetary gearbox) 목업이며, 참조 도면은 part_references에 둔다.
// 원통 하우징(round housing) Ø54, 후면 NEMA17 모터 마운트(motor mount), 전면 출력 플랜지(output flange)를 표현한다.
// 31 mm 볼트 패턴(bolt pattern) 코너는 Ø54 원통 하우징(round housing) 안에 들어간다.
// G10/G20 차이는 본체 길이(body length)만으로 표현한다.
// 원점은 본체 중심이고, 출력축(output shaft)은 +Z 방향으로 돌출한다.
module gearbox_mg17(body_len, part_color = [0, 0.85, 0.85]) {
    assert(body_len > 0, "감속기 본체 길이(body_len)는 양수여야 합니다");

    body_d = 54;         // 원통 하우징 외경(round housing OD), Ø54
    bolt_pitch = 31;     // M3 체결 피치(NEMA17 mounting pattern), □31
    mount_hole_d = 3.5;  // 입력 통과홀(input clearance holes), 4x Ø3.5
    input_pilot_d = 22;  // 입력 파일럿 리세스(input register recess), Ø22 +0.03/+0.005
    input_pilot_h = 3;
    set_d      = 3;      // 커플러 클램프 셋스크류 측면 / coupling clamp set-screw access (M3, T8)
    output_pilot_d = 25; // 출력 파일럿 보스(output register boss), Ø25 0/-0.025
    output_pilot_h = 3;
    output_bolt_circle = 35; // 출력 볼트원(output bolt circle), Ø35
    output_bolt_d = 4;  // 4x M4
    output_bolt_depth = 8; // 탭 깊이(tap depth), 8 mm
    shaft_d    = 10;     // 출력축 / output shaft (Ø10)
    flat_depth = 2;      // D컷 깊이(D-flat depth), across-flat Ø8 0/-0.012
    flat_len = 18;       // D컷 길이(flat length)
    shaft_len = 21.5;    // 축 돌출(projection from output face)
    cap        = 3.5;    // 플랜지 음영 밴드(flange shading band), 시각화 전용

    steel = [0.80, 0.80, 0.82];   // 축·강재 / steel
    input_face_z = -body_len / 2;  // 입력 면(input motor-mount face)
    output_face_z = body_len / 2;  // 출력 면(output face)
    hole_pitch_radius = bolt_pitch / 2;

    // 원통 본체 밴드(round body band)는 감속기 외곽의 기준 실루엣이다.
    module band(h) cylinder(d = body_d, h = h, $fn = 96);

    // 본체는 입력 플랜지(input flange), 코어(core), 출력 플랜지(output flange)를 음영으로 구분한다.
    difference() {
        union() {
            color(part_color * 1.12) translate([0, 0, input_face_z])       band(cap);
            color(part_color)        translate([0, 0, input_face_z + cap]) band(body_len - 2 * cap);
            color(part_color * 1.12) translate([0, 0, output_face_z - cap]) band(cap);
        }
        // 입력 파일럿 리세스(input pilot recess)는 모터 보스(motor boss)를 수용한다.
        translate([0, 0, input_face_z - 0.1]) cylinder(d = input_pilot_d, h = input_pilot_h + 0.1, $fn = 64);
        // NEMA17 통과홀(input clearance hole)은 모터 체결 볼트가 지나는 자리다.
        for (x = [-hole_pitch_radius, hole_pitch_radius], y = [-hole_pitch_radius, hole_pitch_radius])
            translate([x, y, input_face_z - 0.1]) cylinder(d = mount_hole_d, h = 6, $fn = 24);
        // 커플러 클램프 셋스크류(set screw)는 입력부 측면에서 접근한다.
        translate([0, 0, input_face_z + 8]) rotate([0, 90, 0])
            cylinder(d = set_d, h = body_d + 2, center = true, $fn = 24);
        // 출력 M4 탭홀(tapped hole)은 Ø35 볼트원(bolt circle) 위의 블라인드 홀(blind hole)이다.
        for (i = [0 : 3])
            rotate([0, 0, 45 + i * 90])
                translate([output_bolt_circle / 2, 0, output_face_z - output_bolt_depth])
                    cylinder(d = output_bolt_d, h = output_bolt_depth + 0.1, $fn = 24);
    }

    // 출력 파일럿 보스(output register boss)는 출력 플랜지(output flange)의 센터링 기준이다.
    color(part_color * 1.18) translate([0, 0, output_face_z]) cylinder(d = output_pilot_d, h = output_pilot_h, $fn = 64);

    // 출력축(output shaft)은 D컷(D-flat)으로 회전 고정을 표현한다.
    color(steel) translate([0, 0, output_face_z + output_pilot_h]) difference() {
        cylinder(d = shaft_d, h = shaft_len, $fn = 48);
        translate([shaft_d / 2 - flat_depth, -shaft_d, 2])
            cube([shaft_d, 2 * shaft_d, flat_len]);
    }
}

// ── 베어링(bearing) ─────────────────────────────────────────────────

module bearing(bearing_spec, part_color = [0, 0.6, 1]) {
    bore = bearing_spec[0];
    od = bearing_spec[1];
    w = bearing_spec[2];
    assert(bore > 0, "베어링 내경(bore)은 양수여야 합니다");
    assert(od > bore, "베어링 외경(od)은 내경보다 커야 합니다");
    assert(w > 0, "베어링 폭(w)은 양수여야 합니다");

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

    color(part_color) translate([0, 0, base_z]) ring(bore, inner_od, w);
    color(part_color) translate([0, 0, base_z]) ring(outer_id, od, w);
    color(part_color * 0.45)
        translate([0, 0, seal_z]) ring(inner_od - 0.01, outer_id + 0.01, seal_h);
}

// ── 커플러(coupler) ─────────────────────────────────────────────────

module flange_coupler(part_color = [0, 1, 0.35],
                      bolt_radius = 12,
                      bolt_count = 4,
                      bolt_d = 4) {
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

    assert(bore > 0, "커플러 보어(bore)는 양수여야 합니다");
    assert(bolt_radius > 0, "볼트 반경(bolt_radius)은 양수여야 합니다");
    assert(bolt_count > 0, "볼트 개수(bolt_count)는 양수여야 합니다");
    assert(bolt_d > 0, "볼트 지름(bolt_d)은 양수여야 합니다");

    color(part_color) difference() {
        translate([0, 0, flange_z])
            cylinder(d = flange_od, h = flange_t);
        for (i = [0 : bolt_count - 1])
            rotate([0, 0, 45 + i * 360 / bolt_count])
                translate([bolt_radius, 0, flange_z - 0.1])
                    cylinder(d = bolt_d + 0.4, h = flange_t + 0.2);
        translate([0, 0, body_z - 0.1]) cylinder(d = bore, h = total_h + 0.2);
    }

    color(part_color * 0.82) difference() {
        translate([0, 0, body_z]) cylinder(d = body_od, h = body_h);
        translate([0, 0, body_z - 0.1]) cylinder(d = bore, h = total_h + 0.2);
        for (ang = [0, 90])
            rotate([0, 0, ang]) translate([0, 0, body_z + body_h / 2])
                rotate([0, -90, 0]) cylinder(d = set_d, h = body_od);
    }
}

// ── 체결품(fastener) ────────────────────────────────────────────────

module screw_thread(od, thread_len, pitch = undef) {
    assert(od > 0, "나사 외경(od)은 양수여야 합니다");
    assert(thread_len > 0, "나사 길이(thread_len)는 양수여야 합니다");

    thread_pitch = is_undef(pitch) ? od * 0.18 : pitch;
    turns = thread_len / thread_pitch;
    core = od * 0.80;
    linear_extrude(height = thread_len, twist = -360 * turns, convexity = 4,
                   slices = max(10, ceil(turns * 10)), $fn = 24)
        union() {
            circle(d = core);
            polygon([[0, 0], [od / 2, thread_pitch * 0.16], [od / 2, -thread_pitch * 0.16]]);
        }
}

module shoulder_bolt(d, shoulder_len, part_color = [0.74, 0.41, 0]) {
    assert(d > 0, "숄더 볼트 지름(d)은 양수여야 합니다");
    assert(shoulder_len > 0, "숄더 길이(shoulder_len)는 양수여야 합니다");

    head_d = d * 1.5;
    head_h = d;
    chamfer_h = head_d * 0.08;
    thread_d = d * 0.72;
    neck_d = thread_d * 0.82;
    socket_af = d * 0.6;
    socket_h = head_h * 0.55;
    shoulder_z = -shoulder_len / 2;
    head_z = shoulder_z - head_h;
    neck_z = shoulder_len / 2;
    thread_z = neck_z + neck_d * 0.3;

    color(part_color * 0.7) difference() {
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

    color(part_color) translate([0, 0, shoulder_z]) cylinder(d = d, h = shoulder_len, $fn = 48);
    color(part_color * 0.9) translate([0, 0, neck_z]) cylinder(d = neck_d, h = neck_d * 0.3, $fn = 32);
    color(part_color * 1.2) translate([0, 0, thread_z]) screw_thread(od = thread_d, thread_len = d - neck_d * 0.3);
}

module cap_screw(d, screw_len, part_color = [0.74, 0.41, 0]) {
    assert(d > 0, "캡스크류 지름(d)은 양수여야 합니다");
    assert(screw_len > 0, "캡스크류 길이(screw_len)는 양수여야 합니다");

    head_d = d * 1.5;
    head_h = d;
    chamfer_h = head_d * 0.08;
    socket_af = d * 0.6;
    socket_h = head_h * 0.6;
    tip_h = d * 0.5;
    thread_z = (d - screw_len) / 2;
    head_z = thread_z - head_h;

    color(part_color * 0.7) difference() {
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

    color(part_color) translate([0, 0, thread_z]) intersection() {
        screw_thread(od = d, thread_len = screw_len);
        union() {
            cylinder(d = d + 1, h = screw_len - tip_h);
            translate([0, 0, screw_len - tip_h]) cylinder(d1 = d + 1, d2 = d * 0.7, h = tip_h, $fn = 32);
        }
    }
}

module hex_standoff(across_flat, standoff_len, part_color = [0.74, 0.41, 0]) {
    assert(across_flat > 0, "스탠드오프 대변거리(across_flat)는 양수여야 합니다");
    assert(standoff_len > 0, "스탠드오프 길이(standoff_len)는 양수여야 합니다");

    base_z = -standoff_len / 2;

    color(part_color) difference() {
        translate([0, 0, base_z]) cylinder(d = across_flat / cos(30), h = standoff_len, $fn = 6);
        translate([0, 0, base_z - 0.1]) cylinder(d = across_flat * 0.45, h = standoff_len + 0.2);
    }
}

module lock_nut(across_flat, thickness, bore, part_color = [0.74, 0.41, 0]) {
    assert(across_flat > 0, "너트 대변거리(across_flat)는 양수여야 합니다");
    assert(thickness > 0, "너트 두께(thickness)는 양수여야 합니다");
    assert(bore > 0, "너트 보어(bore)는 양수여야 합니다");

    corner_d = across_flat / cos(30);
    chamfer_h = (corner_d - across_flat) / 2;
    lead_h = min(0.8, bore * 0.12);
    base_z = -thickness * 0.75;

    color(part_color) difference() {
        intersection() {
            translate([0, 0, base_z]) cylinder(d = corner_d, h = thickness, $fn = 6);
            union() {
                translate([0, 0, base_z]) cylinder(d1 = across_flat, d2 = corner_d, h = chamfer_h, $fn = 48);
                translate([0, 0, base_z + chamfer_h]) cylinder(d = corner_d, h = thickness - 2 * chamfer_h, $fn = 6);
                translate([0, 0, base_z + thickness - chamfer_h])
                    cylinder(d1 = corner_d, d2 = across_flat, h = chamfer_h, $fn = 48);
            }
        }
        translate([0, 0, base_z - 0.1]) cylinder(d = bore, h = thickness + 0.2);
        translate([0, 0, base_z - 0.01])
            cylinder(d1 = bore + 2 * lead_h, d2 = bore, h = lead_h);
        translate([0, 0, base_z + thickness - lead_h + 0.01])
            cylinder(d1 = bore, d2 = bore + 2 * lead_h, h = lead_h);
    }

    skirt_d = across_flat * 0.9;
    cap_h = thickness * 0.5;
    color(part_color * 1.35) difference() {
        union() {
            translate([0, 0, base_z + thickness - 0.1]) cylinder(d = skirt_d, h = cap_h * 0.6, $fn = 48);
            translate([0, 0, base_z + thickness - 0.1 + cap_h * 0.6])
                cylinder(d1 = skirt_d, d2 = skirt_d * 0.7, h = cap_h * 0.4, $fn = 48);
        }
        translate([0, 0, base_z - 0.1]) cylinder(d = bore, h = thickness + cap_h + 0.4);
    }
}

module washer(id, thickness = 1.2, part_color = [0.7, 0, 1]) {
    assert(id > 0, "와셔 내경(id)은 양수여야 합니다");
    assert(thickness > 0, "와셔 두께(thickness)는 양수여야 합니다");

    base_z = -thickness / 2;

    color(part_color) difference() {
        translate([0, 0, base_z]) cylinder(d = id * 1.5, h = thickness);
        translate([0, 0, base_z - 0.1]) cylinder(d = id + 0.3, h = thickness + 0.2);
    }
}

module spacer(od, bore, spacer_len, part_color = [1, 0, 0.8]) {
    assert(od > 0, "스페이서 외경(od)은 양수여야 합니다");
    assert(bore > 0, "스페이서 보어(bore)는 양수여야 합니다");
    assert(spacer_len > 0, "스페이서 길이(spacer_len)는 양수여야 합니다");
    assert(od > bore, "스페이서 외경(od)은 보어보다 커야 합니다");

    base_z = -spacer_len / 2;

    color(part_color) difference() {
        translate([0, 0, base_z]) cylinder(d = od, h = spacer_len);
        translate([0, 0, base_z - 0.1]) cylinder(d = bore, h = spacer_len + 0.2);
    }
}
