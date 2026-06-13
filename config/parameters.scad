// cobot-lite 전역 파라미터 (global parameters)
// 하부 회전·지지 구조를 제외한 2축 팔 체인 기준.
// 모든 부품 치수는 이 파일에서만 정의한다 — 매직 넘버 하드코딩 금지.

/* ===== 출력/렌더링 ===== */
$fn = 64;

/* ===== 공통 가공 여유 ===== */
clearance_fit = 0.3;      // 회전/슬라이드 끼움 여유
bolt_hole_oversize = 0.4; // 관통 볼트 홀 여유
washer_t = 1.2;           // 평와셔 표준 두께

/* ===== 베어링 (bearing)
   [ID, OD, L] mm */
BRG_608ZZ  = [8,  22, 7]; // 팔꿈치 피벗 ×2
BRG_625ZZ  = [5,  16, 5]; // 구동 링크 양단 ×2
BRG_6805ZZ = [25, 37, 7]; // J3 크랭크 저널 ×1

// 베어링 압입 공차 (press-fit tolerance)
bearing_press_fit = -0.15;

/* ===== 숄더 볼트 (stripper/shoulder bolt) ===== */
shoulder_d_large = 8; // 608ZZ 결합 — 팔꿈치 단일 통축
shoulder_d_small = 5; // 625ZZ 결합 — 크랭크/혼 핀

/* ===== 링크 길이 =====
   L1/L2는 관절축 사이 '현(chord)' 거리 — 빔 꺾임과 무관하게 기구학 기준 */
L1 = 210;                 // 상완 현: J2 축 → 팔꿈치 축
L2 = 235;                 // 하완 현: 팔꿈치 축 → 공구 기준점
wrist_offset = 50;        // 공구 기준점 오프셋
forearm_len = L2 - wrist_offset;

/* ===== 링크 꺾임 (팔레타이저식 기구학 오프셋) ===== */
ua_bend_deg = 8;
ua_bend_pos = 0.55;
fa_bend_deg = 30;
fa_bend_pos = 0.25;

ua_kink_off = 0;
fa_kink_off = 0;

/* ===== 가동 엔벨로프 ===== */
env_fold_min = -132;
env_fold_max = -15;
env_j2_min = 0;
env_j2_max = 75;

/* ===== 모터/기어박스 목업용 치수 ===== */
motor_frame = 42;
nema17_hole_pitch = 31;
nema17_pilot_d = 22;
nema17_bolt_d = 3;

gbx_frame = 42;
gbx_len_20to1 = 51;
gbx_out_shaft_d = 8;
gbx_out_shaft_len = 20;

motor_len_SF2423 = 39; // J3
motor_len_SF2424 = 47; // J2

/* ===== 기성 플랜지 커플러 (flange coupler) =====
   OD 8 축을 무두 볼트(set screw)로 grip, 플랜지를 구동 부품에 볼트온. */
cpl_bore = gbx_out_shaft_d;
cpl_flange_od = 32;
cpl_flange_t = 3;
cpl_body_od = 16;
cpl_body_h = 10;
cpl_h = cpl_flange_t + cpl_body_h;
cpl_bolt_r = 12;
cpl_bolt_n = 4;
cpl_bolt_d = 4;
cpl_set_d = 3;

/* ===== 암 단면/관절 ===== */
arm_plate_t = 9;
m4_standoff_d  = 4.5;
m4_standoff_af = 7;
m3_standoff_d  = 3.4;
m3_standoff_af = 5.5;
joint_spacer_od = 12;
arm_lug_r = 26;
ua_body_hw = 22;
fa_body_hw = 16;
fillet_r = 6;

arm_inner_w = 60;
ua_in_y  = arm_inner_w / 2;
ua_out_y = ua_in_y + arm_plate_t;
forearm_inner_w = 30;
arm_standoff_z = 0;

ua_standoff_x = [0.3, 0.70];
ua_standoff_xa = [for (p = ua_standoff_x) p * L1];
fa_standoff_x = [0.38, 0.76];
fa_standoff_xa = [for (p = fa_standoff_x) p * forearm_len];

/* ===== J3 크랭크/링키지 =====
   크랭크는 J2 축에서 회전하고, +Y 상완 측판의 6805ZZ에 저널된다. */
crank_R = 36;
horn_phase = 155;
crank_disk_d = 52;
crank_boss_od = BRG_6805ZZ[0] - bearing_press_fit;
crank_boss_id = 12;
crank_flange_d = cpl_flange_od + 4;
link_w = BRG_625ZZ[1];
link_end_d = 22;
link_arch_pos = [0.12, 0.5, 0.88];
link_arch_rise = [24, 38, 24];
crank_clear = 0.5;

link_y0 = -arm_plate_t / 2;
link_y1 =  arm_plate_t / 2;
crank_disk_y0 = link_y1 + washer_t;
crank_flange_y0 = ua_out_y + crank_clear;
crank_flange_y1 = crank_flange_y0 + arm_plate_t;

/* ===== 팔꿈치 + 혼 핀 ===== */
elbow_gap = (arm_inner_w - forearm_inner_w) / 2 - arm_plate_t;
elbow_pin_len = 80;
horn_pin_len  = 50;
elbow_ls_x = 45;
elbow_vane_r = 48;
elbow_vane_w = 8;
elbow_vane_a = 320;

print_layout_span = 200;

/* ===== 너트 평면폭 (across flats) ===== */
m6_nut_af = 10;
m4_nut_af = 7;

/* ===== 리미트 스위치 (ELE-004) ===== */
ls_body = [20, 10, 6.5];
ls_hole_pitch = 9.5;
ls_hole_d = 2.3;
