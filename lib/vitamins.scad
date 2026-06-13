// 구매품 목업 (vitamins) — 조립 간섭 확인용 (출력 부품 아님)
// 모든 모듈은 % 배경 처리로 호출부에서 사용 시 STL export에서 제외된다.
// 좌표 규약: 액추에이터는 기어박스 플랜지면 z=0, 출력축 +Z, 몸체 −Z.
include <../config/parameters.scad>

// 리미트 스위치 내부 색상 구분 (모듈 자체 색 — 호출부 색 무관, use 스코프 자족)
C_SWITCH_BODY   = "#1f2933";   // 몸체 (흑청 플라스틱)
C_SWITCH_LEVER  = "#c4ccd4";   // 레버 스프링 (스테인리스)
C_SWITCH_ROLLER = "#e8e2d0";   // 롤러 (백색 나일론)
C_SWITCH_PIN    = "#c8a23c";   // 단자 핀 (황동)

// SF24 스테퍼 모터 (42각). len = 몸체 길이, 플랜지면 z=0, 몸체 −Z
module motor_sf24(len) {
    translate([0, 0, -len])
        linear_extrude(len)
            offset(r = 3) square(motor_frame - 6, center = true);
}

// MG17 유성 기어박스. len = 몸체 길이, 출력 플랜지면 z=0, 출력축 +Z, 몸체 −Z.
// col = 기준색 — 기어박스 하우징 = col, 출력축·파일럿 = col*1.6 (밝은 금속).
module gearbox_mg17(len, col = [0.16, 0.16, 0.16]) {
    color(col) translate([0, 0, -len]) cylinder(d = gbx_frame, h = len);
    color(col * 1.7) cylinder(d = gbx_out_shaft_d, h = gbx_out_shaft_len);  // 출력축
    color(col * 1.4) cylinder(d = nema17_pilot_d, h = 2);                   // 파일럿 보스
}

// 모터+기어박스 스택. 출력 플랜지면 z=0, 출력축 +Z. 모터 몸체 = col*0.8(더 어둡게).
module actuator(motor_len, gbx_len, col = [0.16, 0.16, 0.16]) {
    gearbox_mg17(gbx_len, col);
    color(col * 0.8) translate([0, 0, -gbx_len]) motor_sf24(motor_len);
}

// 관절별 액추에이터 프리셋 (MG17-G20)
module actuator_J2(col = [0.16, 0.16, 0.16]) { actuator(motor_len_SF2424, gbx_len_20to1, col); }
module actuator_J3(col = [0.16, 0.16, 0.16]) { actuator(motor_len_SF2423, gbx_len_20to1, col); }

// 기성 플랜지 커플러 (flange coupler) — set-screw 축 grip + 플랜지 볼트온.
// 치수 = config 파라미터 (이미지 실측 ID 8 flange coupling):
//   보어 ID 8(cpl_bore), 플랜지 OD 32, L 3, 몸체(허브) OD 16, L 10, 전고 13,
//   플랜지 볼트 M4 ×4(PCD 24 서클, r12), 무두 볼트 M3 ×2(90°).
// 사용처: J3 크랭크 외단 플랜지 / 팔꿈치 통축(하완 ±Y판).
// 좌표: z0 = 플랜지 결합면(구동 부품 밀착), 몸체·축은 -z 방향.
// col = 기준색(알루미늄). 톤온톤: 플랜지 = col, 몸체(무두 볼트부) = col*0.82(어둡게).
module flange_coupler(col = [0.72, 0.72, 0.74]) {
    // 플랜지
    color(col) difference() {
        translate([0, 0, -cpl_flange_t])
            cylinder(d = cpl_flange_od, h = cpl_flange_t);
        for (i = [0 : cpl_bolt_n - 1])                           // 플랜지 볼트 ×4
            rotate([0, 0, 45 + i * 360 / cpl_bolt_n])
                translate([cpl_bolt_r, 0, -cpl_flange_t - 0.1])
                    cylinder(d = cpl_bolt_d + 0.4, h = cpl_flange_t + 0.2);
        translate([0, 0, -cpl_h - 0.1]) cylinder(d = cpl_bore, h = cpl_h + 0.2);
    }
    // 몸체 (무두 볼트부, 어둡게)
    color(col * 0.82) difference() {
        translate([0, 0, -cpl_h]) cylinder(d = cpl_body_od, h = cpl_body_h);
        translate([0, 0, -cpl_h - 0.1]) cylinder(d = cpl_bore, h = cpl_h + 0.2);
        for (ang = [0, 90])                                      // 무두 볼트 ×2 (90°)
            rotate([0, 0, ang]) translate([0, 0, -cpl_h + cpl_body_h / 2])
                rotate([0, -90, 0]) cylinder(d = cpl_set_d, h = cpl_body_od);
    }
}

// 베어링 (zz 실드) — col = 기준색 rgb 벡터(기본 스틸). 톤온톤:
//   내륜·외륜 = col, 레이스 사이 실드 밴드 = col*0.45 (더 어둡게 — 함몰면 식별).
//   brg = [ID(내경), OD(외경), L(폭)].
module bearing(brg, col = [0.62, 0.62, 0.63]) {
    bore = brg[0]; od = brg[1]; w = brg[2];
    span = (od - bore) / 2;             // 외경~내경 반경 차
    race = span * 0.30;                 // 각 레이스 링 반경 두께
    inner_od = bore + 2 * race;         // 내륜 외경
    outer_id = od   - 2 * race;         // 외륜 내경
    seal_h = w * 0.66;                  // 실드 밴드 높이 (함몰)
    seal_z = (w - seal_h) / 2;
    module ring(d_in, d_out, h) {
        difference() {
            cylinder(d = d_out, h = h);
            translate([0, 0, -0.1]) cylinder(d = d_in, h = h + 0.2);
        }
    }
    color(col) ring(bore, inner_od, w);                  // 내륜 (축측 활주면)
    color(col) ring(outer_id, od, w);                    // 외륜 (하우징 압입면)
    color(col * 0.45)                                    // 실드 밴드 (함몰 = 더 어둡게)
        translate([0, 0, seal_z]) ring(inner_od - 0.01, outer_id + 0.01, seal_h);
}

// 나사산 헬릭스 (single-start) — od = 호칭 외경, len = 길이. 코어 + 삼각 나사산 1줄.
//   pitch 기본 = od*0.18. linear_extrude twist 로 나선 리지 생성. z0 = 시작단.
module screw_thread(od, len, pitch = undef) {
    p     = is_undef(pitch) ? od * 0.18 : pitch;
    turns = len / p;
    core  = od * 0.80;
    linear_extrude(height = len, twist = -360 * turns, convexity = 4,
                   slices = max(10, ceil(turns * 10)), $fn = 24)
        union() {
            circle(d = core);
            polygon([[0, 0], [od / 2, p * 0.16], [od / 2, -p * 0.16]]);   // 나사산 1줄
        }
}

// 스트리퍼(숄더) 볼트 — **피벗 샤프트 역할** (CON-001):
// SHCS 캡 머리(육각 소켓·노출면 모따기) + 연삭 숄더(OD d, L l, 베어링 내경 활주면)
//   + 숄더→나사 언더컷 목 + 헬리컬 나사부(감경). z0 = 숄더 기단, 머리 −z, 나사 +z.
// 머리 OD = 1.5×d → 짝 베어링 내륜(inner race) 외경 안쪽에 안착(외륜 비접촉):
//   OD 8→12 < 608 내륜 12.2 / OD 5→7.5 < 625 내륜 8.3 (회전측만 grip).
module shoulder_bolt(d, l, col = [0.42, 0.42, 0.42]) {
    hd   = d * 1.5;          // 머리(SHCS 캡) 외경
    hh   = d;                // 머리 높이
    ch   = hd * 0.08;        // 머리 노출면 모따기
    th_d = d * 0.72;         // 나사부 외경 (호칭 ≈ d−2)
    neck = th_d * 0.82;      // 숄더→나사 언더컷 목 직경
    sock_af = d * 0.6;       // 육각 소켓 평면폭 (Allen)
    sock_h  = hh * 0.55;     // 소켓 깊이
    // 머리 (캡 + 노출면 −z 모따기 + 육각 소켓)
    color(col * 0.7) difference() {
        intersection() {
            translate([0, 0, -hh]) cylinder(d = hd, h = hh);
            union() {
                translate([0, 0, -hh]) cylinder(d1 = hd - 2 * ch, d2 = hd, h = ch, $fn = 48);
                translate([0, 0, -hh + ch]) cylinder(d = hd, h = hh - ch, $fn = 48);
            }
        }
        translate([0, 0, -hh - 0.1])                          // 육각 소켓 (노출면서 진입)
            cylinder(d = sock_af / cos(30), h = sock_h, $fn = 6);
    }
    // 숄더 (연삭 샤프트, 베어링 활주면)
    color(col) cylinder(d = d, h = l, $fn = 48);
    // 숄더 끝 언더컷 목 (나사 전이)
    color(col * 0.9) translate([0, 0, l]) cylinder(d = neck, h = neck * 0.3, $fn = 32);
    // 나사부 (헬리컬, 밝게)
    color(col * 1.2) translate([0, 0, l + neck * 0.3]) screw_thread(th_d, d - neck * 0.3);
}

// 캡 스크류 (cap screw, SHCS = socket head cap screw) — **고정 체결 전용** (샤프트 역할 아님).
//   d = 호칭경, l = 생크 길이. 캡 머리(육각 Allen 소켓·상단 모따기) + 헬리컬 전산 생크.
//   좌표: z0 = 머리↔생크 경계(체결면 밀착), 머리 −z, 생크 +z. 머리 어둡게 톤온톤.
module cap_screw(d, l, col = [0.42, 0.42, 0.42]) {
    hd      = d * 1.5;       // 캡 머리 OD (SHCS ≈ 1.5d)
    hh      = d;             // 머리 높이 (SHCS ≈ d)
    ch      = hd * 0.08;     // 머리 상단(노출 −z면) 모따기
    sock_af = d * 0.6;       // 육각 소켓 평면폭 (Allen)
    sock_h  = hh * 0.6;      // 소켓 깊이
    tip     = d * 0.5;       // 생크 끝단 모따기 높이
    // 머리 (캡 + 상면 −z 모따기 + 육각 소켓)
    color(col * 0.7) difference() {
        intersection() {
            translate([0, 0, -hh]) cylinder(d = hd, h = hh, $fn = 48);
            union() {
                translate([0, 0, -hh]) cylinder(d1 = hd - 2 * ch, d2 = hd, h = ch, $fn = 48);
                translate([0, 0, -hh + ch]) cylinder(d = hd, h = hh - ch, $fn = 48);
            }
        }
        translate([0, 0, -hh - 0.1])                          // 육각 소켓 (노출면서 진입)
            cylinder(d = sock_af / cos(30), h = sock_h, $fn = 6);
    }
    // 전산 생크 (헬리컬 나사) + 끝단 모따기
    color(col) intersection() {
        screw_thread(d, l);
        union() {
            cylinder(d = d + 1, h = l - tip);
            translate([0, 0, l - tip]) cylinder(d1 = d + 1, d2 = d * 0.7, h = tip, $fn = 32);
        }
    }
}

// 육각 스탠드오프 (hex standoff, 암-암) — 플레이트 간격 결정 구조재
module hex_standoff(af, l, col = [0.42, 0.42, 0.42]) {
    color(col) difference() {
        cylinder(d = af / cos(30), h = l, $fn = 6);
        translate([0, 0, -0.1]) cylinder(d = af * 0.45, h = l + 0.2);
    }
}

// 나일론 락 너트 (nylock) — 원뿔 모따기 육각 몸체 + 보어 진입 모따기 + 라운드 나일론 인서트.
//   af = 평면폭(across flats), t = 금속 몸체 높이, bore = 호칭경. 칼라(나일론) = 밝게 톤온톤.
//   상·하면 원뿔 모따기(육각∩배럴) → 끝면 외곽이 원(실측 너트 형상), 중간 띠만 6평면 노출.
module lock_nut(af, t, bore, col = [0.42, 0.42, 0.42]) {
    cr   = af / cos(30);             // 대각폭 (across corners)
    ch   = (cr - af) / 2;            // 상·하 모서리 모따기 높이 (≈45° 원뿔)
    lead = min(0.8, bore * 0.12);    // 보어 진입 모따기 (양면)
    // 금속 육각 몸체 (원뿔 모따기 + 양면 보어 모따기)
    color(col) difference() {
        intersection() {
            cylinder(d = cr, h = t, $fn = 6);                  // 육각 (6평면)
            union() {                                          // 모따기 배럴 (원형)
                cylinder(d1 = af, d2 = cr, h = ch, $fn = 48);             // 하면 모따기
                translate([0, 0, ch]) cylinder(d = cr, h = t - 2 * ch, $fn = 6);
                translate([0, 0, t - ch])
                    cylinder(d1 = cr, d2 = af, h = ch, $fn = 48);         // 상면 모따기
            }
        }
        translate([0, 0, -0.1]) cylinder(d = bore, h = t + 0.2);          // 보어
        translate([0, 0, -0.01])                                          // 하면 진입 모따기
            cylinder(d1 = bore + 2 * lead, d2 = bore, h = lead);
        translate([0, 0, t - lead + 0.01])                                // 상면 진입 모따기
            cylinder(d1 = bore, d2 = bore + 2 * lead, h = lead);
    }
    // 나일론 인서트 칼라 (밝게) — 상면 위 라운드 스커트 (돔 모따기)
    skirt = af * 0.9;
    cap_h = t * 0.5;
    color(col * 1.35) difference() {
        union() {
            translate([0, 0, t - 0.1]) cylinder(d = skirt, h = cap_h * 0.6, $fn = 48);
            translate([0, 0, t - 0.1 + cap_h * 0.6])                       // 라운드 상단
                cylinder(d1 = skirt, d2 = skirt * 0.7, h = cap_h * 0.4, $fn = 48);
        }
        translate([0, 0, -0.1]) cylinder(d = bore, h = t + cap_h + 0.4);   // 나일론 관통
    }
}

// 평와셔 (washer) — CON-001: 피벗은 숄더 볼트 + 와셔. OD = 1.5×d_in.
module washer(d_in, t = 1.2, col = [0.50, 0.50, 0.50]) {
    color(col) difference() {
        cylinder(d = d_in * 1.5, h = t);
        translate([0, 0, -0.1]) cylinder(d = d_in + 0.3, h = t + 0.2);
    }
}

// 스페이서 튜브 (spacer) — 축 위 부품 간격 결정. 환형 실린더.
//   od = 외경, bore = 내경(축 통과), l = 길이. 좌표: z0 = 일단, +z로 뻗음.
module spacer(od, bore, l, col = [1.0, 1.0, 1.0]) {
    color(col) difference() {
        cylinder(d = od, h = l);
        translate([0, 0, -0.1]) cylinder(d = bore, h = l + 0.2);
    }
}

// 기계식 마이크로 리미트 스위치 (KW12형) — 몸체 + 버튼 + 롤러 레버 + 단자.
// 색상 구분: 몸체(흑청)/레버(스테인리스)/롤러(나일론)/핀(황동) — colors.scad.
// 좌표: z0 = 장착면(플레이트 접촉), 몸체 +z, 길이 x, 두께 y. 레버 피벗 = -x단,
//   자유단(롤러)은 +x로 뻗으며 lever_rise° 상향 (베인이 롤러를 눌러 버튼 작동).
module limit_switch() {
    L = ls_body[0]; H = ls_body[1]; T = ls_body[2];
    lever_len = L + 6;
    lever_rise = 12;            // 자유단 상향각 (작동 전 위치)
    color(C_SWITCH_BODY)       // 몸체 (흑청 플라스틱)
        translate([-L / 2, -T / 2, 0]) cube([L, T, H]);
    color(C_SWITCH_BODY)       // 액추에이터 버튼 (상면, 피벗측)
        translate([-L / 2 + 3.5, 0, H]) cylinder(d = 2.6, h = 1.4, $fn = 16);
    color(C_SWITCH_PIN)        // 단자 핀 ×3 (황동, 하부 후면 -y)
        for (i = [-1, 0, 1])
            translate([i * 5, -T / 2, 2]) rotate([90, 0, 0])
                cylinder(d = 1.2, h = 3, $fn = 8);
    color(C_SWITCH_LEVER)      // 롤러 레버 (스테인리스 스프링)
        translate([-L / 2 + 1, 0, H + 1.6]) rotate([0, -lever_rise, 0]) {
            translate([0, -1.3, -0.4]) cube([lever_len, 2.6, 0.8]);
            translate([lever_len, 0, 0]) rotate([90, 0, 0])  // 롤러 (나일론)
                color(C_SWITCH_ROLLER)
                    cylinder(d = 4, h = 4.2, center = true, $fn = 20);
        }
}
