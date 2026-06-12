// 구매품 목업 (vitamins) — 조립 간섭 확인용 (출력 부품 아님)
// 모든 모듈은 % 배경 처리로 호출부에서 사용 시 STL export에서 제외된다.
// 좌표 규약: 액추에이터는 기어박스 플랜지면 z=0, 출력축 +Z, 몸체 −Z.
include <../config/parameters.scad>

// SF24 스테퍼 모터 (42각). len = 몸체 길이, 플랜지면 z=0, 몸체 −Z
module motor_sf24(len) {
    translate([0, 0, -len])
        linear_extrude(len)
            offset(r = 3) square(motor_frame - 6, center = true);
}

// MG17 유성 기어박스. len = 몸체 길이, 출력 플랜지면 z=0, 출력축 +Z, 몸체 −Z
module gearbox_mg17(len) {
    union() {
        translate([0, 0, -len]) cylinder(d = gbx_frame, h = len);
        cylinder(d = gbx_out_shaft_d, h = gbx_out_shaft_len);
        cylinder(d = nema17_pilot_d, h = 2); // 출력측 파일럿 보스
    }
}

// 모터+기어박스 스택. 출력 플랜지면 z=0, 출력축 +Z
module actuator(motor_len, gbx_len) {
    union() {
        gearbox_mg17(gbx_len);
        translate([0, 0, -gbx_len]) motor_sf24(motor_len);
    }
}

// 관절별 액추에이터 프리셋
module actuator_J1() { actuator(motor_len_SF2424, gbx_len_20to1); }
module actuator_J2() { actuator(motor_len_SF2424, gbx_len_20to1); }
module actuator_J3() { actuator(motor_len_SF2423, gbx_len_20to1); }
module actuator_J4() { actuator(motor_len_SF2422, gbx_len_5to1); }

// 베어링 (zz 실드 단순 링)
module bearing(brg) {
    difference() {
        cylinder(d = brg[1], h = brg[2]);
        translate([0, 0, -0.1]) cylinder(d = brg[0], h = brg[2] + 0.2);
    }
}

// 스트리퍼(숄더) 볼트 — **피벗 샤프트 역할** (CON-001):
// SHCS형 머리 + 연삭 숄더(⌀d × l, 베어링 내경 활주면) + 감경 나사부
module shoulder_bolt(d, l) {
    union() {
        cylinder(d = d, h = l);                              // 숄더 (샤프트면)
        translate([0, 0, -d]) cylinder(d = d * 1.6, h = d);  // 머리
        translate([0, 0, l]) cylinder(d = d * 0.72, h = d);  // 나사부 (M(d-2)급)
    }
}

// 머신 볼트 (SHCS) — **고정 체결 전용** (샤프트 역할 아님)
module machine_bolt(d, l) {
    union() {
        translate([0, 0, -d]) cylinder(d = d * 1.7, h = d);  // 캡 머리
        cylinder(d = d, h = l);                              // 전산 생크
    }
}

// 육각 스탠드오프 (hex standoff, 암-암) — 플레이트 간격 결정 구조재
module hex_standoff(af, l) {
    difference() {
        cylinder(d = af / cos(30), h = l, $fn = 6);
        translate([0, 0, -0.1]) cylinder(d = af * 0.45, h = l + 0.2);
    }
}

// 나일론 락 너트 (nylock) — 회전 관절 축단 풀림 방지 (일반 너트와 구분)
module lock_nut(af, t, bore) {
    difference() {
        union() {
            cylinder(d = af / cos(30), h = t, $fn = 6);
            translate([0, 0, t - 0.1]) cylinder(d = af * 0.92, h = t * 0.5);
        }
        translate([0, 0, -0.1]) cylinder(d = bore, h = 2 * t);
    }
}

// 평와셔 (washer) — CON-001: 피벗은 숄더 볼트 + 와셔
module washer(d_in, t = 1.2) {
    difference() {
        cylinder(d = d_in * 2.2, h = t);
        translate([0, 0, -0.1]) cylinder(d = d_in + 0.3, h = t + 0.2);
    }
}

// 육각 너트 — af = 평면폭(across flats), 보어 = 호칭경
module hex_nut(af, t, bore) {
    difference() {
        cylinder(d = af / cos(30), h = t, $fn = 6);
        translate([0, 0, -0.1]) cylinder(d = bore, h = t + 0.2);
    }
}

// 기계식 마이크로 리미트 스위치 (KW12형) — 몸체만, 레버 생략
module limit_switch() {
    translate([-ls_body[0] / 2, -ls_body[2] / 2, 0])
        cube([ls_body[0], ls_body[2], ls_body[1]]);
}
