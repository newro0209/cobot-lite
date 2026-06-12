// cobot-lite 전역 파라미터 (global parameters)
// 모든 부품 치수는 이 파일에서만 정의한다 — 매직 넘버 하드코딩 금지 (MEC-008)

/* ===== 출력/렌더링 ===== */
$fn = 64;

/* ===== 공통 가공 여유 (파생 치수에서 참조 — 선행 정의 필수) ===== */
clearance_fit = 0.3;      // 회전/슬라이드 끼움 여유
bolt_hole_oversize = 0.4; // 관통 볼트 홀 여유

/* ===== 베어링 (bearing) — CON-002: 이 4종만 사용 =====
   [내경, 외경, 폭] mm */
BRG_608ZZ  = [8,  22, 7];   // 관절 피벗 (8mm 숄더 볼트)
BRG_625ZZ  = [5,  16, 5];   // 평행 링크 피벗 (5mm 숄더 볼트)
BRG_6805ZZ = [25, 37, 7];   // 손목 롤 축, 중구경 허브
BRG_6810ZZ = [50, 65, 7];   // 베이스 턴테이블 메인 베어링

// 베어링 압입 공차 (press-fit tolerance) — MFG-002
// 외경 기준 -0.1 ~ -0.2mm. 프린터별 보정은 이 변수 하나로 조정한다.
bearing_press_fit = -0.15;

/* ===== 숄더 볼트 (stripper/shoulder bolt) — CON-001 ===== */
shoulder_d_small = 5;   // 625ZZ 결합
shoulder_d_large = 8;   // 608ZZ 결합

/* ===== 링크 길이 — MEC-006 [TBD-4] =====
   리치 500mm 잠정. 비대칭 분할 (J2 자중 부담 보상, MEC-001a 분담 구조) */
L1 = 225;   // 상완 (upper arm): J2 축 → J3 축
L2 = 275;   // 하완 (forearm): J3 축 → 공구 플랜지

/* ===== 링크 꺾임 (팔레타이저식 구조 오프셋) =====
   관절 축 좌표는 불변(직선 L1/L2 기준) — 꺾임은 빔 형상만 변경.
   목적: ① 신장/접힘 한계 자세에서 빔-빔 간섭 여유 확보
        ② 구조 외곽을 축선 위로 올려 저자세 작업 시 팔꿈치 하부 돌출 감소
   니(knee) 수직 오프셋 h = L·pos·(1-pos)·tan(deg) */
ua_bend_deg = 12;     // 상완 꺾임각 (0 = 직선)
ua_bend_pos = 0.68;   // 꺾임 위치 (0~1, J2 기준) — 분할 조인트(95~131) 뒤
fa_bend_deg = 12;     // 하완 꺾임각
fa_bend_pos = 0.5;    // 꺾임 위치 (팔꿈치 기준)

/* ===== 가동 엔벨로프 (소프트 리미트 권고값 — docs/design-notes.md) =====
   접힘각 = J3 - J2 (월드 피치 차).
   -90° = 평행사변형 구동 전동각(transmission angle) 특이점 (크랭크∥링크),
     0° = 완전 신장 특이점 (J2·J3·손목 일직선). 양쪽 모두 운용 금지 */
env_fold_min = -75;   // 접힘 한계 (전동각 sin25° ≈ 0.42 이상 확보)
env_fold_max = -3;    // 신장 한계 (리치 ≈ 499.5mm — 공칭 500 대비 -0.5)

// J3 모터 후방 배치 연장 길이 (MEC-001c)
// J2 액추에이터는 J2 축 동축 직결 (MEC-001b) — 후방 배치 대상은 J3 어셈블리만
// J1 회전 시 베이스·작업물 간섭 확인 필수
rear_extension = 80;    // J2 피벗 → J3 모터+기어박스 어셈블리 중심 [잠정]

/* ===== 턴테이블 (turntable) — MEC-003 ===== */
turntable_bearing_gap = 30;   // 6810ZZ 2개 축방향 이격, 30mm 이상 (SHOULD)

/* ===== 모터 (motor) — CON-004: 산요덴키 SF24 시리즈 =====
   NEMA 17 호환 42각 */
motor_frame = 42;             // 프레임 폭 (mm)
nema17_hole_pitch = 31;       // 고정 볼트 피치
nema17_pilot_d = 22;          // 센터 파일럿 직경
nema17_bolt_d = 3;            // M3

/* ===== 감속비 (gear ratio) — CON-005: 5/10/20만 허용 ===== */
// 주의: MG17-G10(10:1)은 허용 토크 5N·m로 급락 — 변경 시 토크 재검증 (docs/torque-budget.md)
ratio_J1 = 20;
ratio_J2 = 20;
ratio_J3 = 20;   // SF2423 + 20:1 확정 (TBD-3 해결)
ratio_J4 = 5;

/* ===== 기어박스 (gearbox) — MG17 데이터시트 (docs/tbd-research.md TBD-5) ===== */
gbx_frame = 42;            // NEMA 17 플랜지, 모터와 동일 42각
gbx_len_20to1 = 51;        // MG17-G20 길이 (J1~J3)
gbx_len_5to1  = 40;        // MG17-G5 길이 (J4)
gbx_out_shaft_d = 8;       // 출력축 직경
gbx_in_insert = 9.5;       // 입력 결합 깊이 — SF24 축 길이 호환 확인 항목
gbx_mass_20to1 = 400;      // g — 질량 예산 계산용
gbx_mass_5to1  = 350;      // g

/* ===== 모터 몸체 치수 — SF24 카탈로그 일반값 [잠정: 구매 데이터시트로 확인] ===== */
motor_len_SF2424 = 47;    // J1, J2
motor_len_SF2423 = 39;    // J3
motor_len_SF2422 = 33;    // J4
motor_shaft_d = 5;        // SF24 출력축 (MG17 입력 클램프 ⌀5)
gbx_out_shaft_len = 20;   // MG17 출력축 돌출 길이

/* ===== 베이스/J1 (MEC-003, MEC-005) ===== */
base_plate_size = 140;    // 정사각 베이스 플레이트 한 변
base_plate_t = 8;
base_bolt_d = 5;          // M5 ×4 작업대 고정 (MEC-005)
base_bolt_pitch = 120;    // 고정 볼트 피치
base_col_wall = 5;        // 턴테이블 칼럼 벽 두께
col_window_w = 50;        // 칼럼 측면 배선/조립 창 폭
turntable_top_d = 100;    // 턴테이블 상판 직경
turntable_top_t = 8;
j1_actuator_gap = 4;      // 베이스 플레이트 상면 → 모터 하면 여유
col_open_h = 24;          // 모터 플로어 상면 → 하부 베어링 (스템 결합·셋스크류 존)
j1_stem_d = 20;           // 턴테이블 허브 스템(출력축 결합부) 외경
set_screw_pilot_d = 3.4;  // M4 무두 볼트(set screw) 셀프태핑 파일럿
m3_tap_d = 2.8;           // M3 셀프태핑 파일럿 (앵커 등 소형 체결)
shoulder_mount_px = 80;   // 어깨 텅 ↔ 턴테이블 볼트 피치 X
shoulder_mount_py = 50;   // 어깨 텅 ↔ 턴테이블 볼트 피치 Y
shoulder_mount_bolt_d = 5;// M5 ×4
shoulder_tongue_x = 40;   // 어깨 텅 깊이(X) — 포크 내 스윕 간섭 한계 결정 (J2 ≈ ±55°)

/* ===== 암 단면/관절 (MEC-004) — v0.13 플레이트 아키텍처 =====
   원칙: 출력물은 평판(plate)만. 간격은 표준 스페이서 튜브 + 관통 볼트가
   결정 (일체 보스·웹·박스 금지). 관절 베어링은 플레이트에 직접 압입 —
   플레이트 두께 = 608ZZ 폭(7) */
arm_plate_t = 7;          // 측판 두께 = 608ZZ 폭 (베어링 인-플레이트 압입)
fork_standoff_len = 30;   // 표준 육각 스탠드오프 길이 (어깨 포크 갭 = 하완 내폭)
hex_standoff_af = 13;     // 두꺼운 육각 스탠드오프 평면폭 (M6 암-암)
joint_spacer_od = 12;     // 관절 스택 스페이서 튜브 외경 (숄더 ⌀8 위)
ua_split_x = 115;         // 상완 플레이트 분할선 (365 > 빌드 대각 한계)
ua_splice = [99, 131];    // 스플라이스 더블러 볼트 X 위치 (분할선 ±16)
// 어깨 텅(플레이트 스택) 폭 = 플레이트 14 ×2 + 표준 스탠드오프 30 (v0.13)
tongue_w = 28 + fork_standoff_len;          // 58
// 상완 포크 내폭 = 표준 육각 스탠드오프 L60 (전 스탠드오프 표준화 — v0.14).
// 텅 58과의 편차 1mm/측은 J2 스택 M8 와셔가 흡수 (CON-001 와셔 기존 품목)
arm_inner_w = 60;
arm_h = 50;               // 암 단면 높이
j2_axis_h = 90;           // 턴테이블 상면 → J2 축 높이
                          // — J2 +45° 시 후방 러그 하단 ↔ 어깨 플랜지 간섭 회피 (간섭 검사 확인)
j3_crank_len = 40;        // J3 크랭크 = 하완 혼 반경 (평행사변형 1:1)
pl_offset = 45;           // 수동 평행사변형(MEC-002) 피벗 오프셋
                          // — J2 모터 42각 코너 스윕 반경(≈30) + 여유
forearm_inner_w = fork_standoff_len;  // 하완 측판 내폭 = 표준 스탠드오프 30 (v0.13)
beam_w = 40;              // 상완/하완 중앙 보(beam) 폭
arm_lug_r = 26;           // 관절 러그(피벗 보스) 반경 — NEMA17 볼트 코너(r≈21.9) + 벽
beam_wall = 4;            // 보 쉘 벽 두께 (경량화)
pivot_engage = 14;        // 축 클램프/베어링 물림 깊이
crank_t = 8;              // J3 크랭크 암 두께
crank_hub_d = 20;         // 크랭크 허브 외경
crank_hub_w = 12;         // 크랭크 허브 폭
dl_offset = 8;            // 구동 링크 평면: 플레이트 A 외면 → 링크 중심 거리
ua_joint_x = 95;          // 상완 분할 조인트 위치 (MFG-004: 365mm > 빌드 대각 한계)
ua_lap = 36;              // 랩 조인트(소켓-테논) 물림 길이

/* ===== 너트 평면폭 (across flats) ===== */
m3_nut_af = 5.5;
m4_nut_af = 7;
m6_nut_af = 10;
link_bar_w = 12;          // 링크 바 단면 폭
link_bar_t = 6;           // 링크 바 단면 두께
link_boss_d = 24;         // 링크 단부 625ZZ 보스 외경 (625 외경 16 + 벽 4×2)

/* ===== 손목/공구 플랜지 (GEN-004) ===== */
wrist_offset = 50;        // 손목 피치 피벗 → J4(플랜지) 축 수평 오프셋
                          // — J4 모터 몸체 ↔ 하완 러그 스윕 간섭 회피 (≥ lug_r + 모터 반폭)
forearm_len = L2 - wrist_offset; // 팔꿈치 축 → 손목 피치 피벗
wrist_wall = 5;           // 손목 하우징 벽 두께
flange_d = 45;            // 공구 플랜지 직경
flange_t = 8;
flange_bc = 32;           // 그리퍼 볼트 서클
flange_bolt_d = 4;        // M4 ×4

/* ===== 리미트 스위치 (ELE-004) — KW12형 기계식 마이크로 기준품 ===== */
ls_body = [20, 10, 6.5];  // 몸체 [길이, 높이, 두께]
ls_hole_pitch = 9.5;      // 장착 홀 피치
ls_hole_d = 2.3;          // M2 셀프태핑/볼트

/* ===== 질량 산출 (MEC-007, docs/mass-budget.md) ===== */
petgcf_density = 1.30;    // g/cm³ (PETG-CF 카탈로그 일반값)
print_solidity = 0.6;     // 쉘+인필 유효 충전율 [잠정 — 슬라이서 추정으로 대체]
motor_mass_SF2424 = 510;  // g (산요 카탈로그 확정)
motor_mass_SF2423 = 380;
motor_mass_SF2422 = 300;

/* ===== 질량/성능 예산 ===== */
payload = 1.0;            // kg, 그리퍼 포함 정격 (PER-001)
moving_mass_budget = 0.8; // kg, 상완 이후 이동부 상한 (MEC-007)

/* ===== 출력 제약 — MFG-004 (Creality SparkX i7, TBD-8 해결) ===== */
build_volume = [260, 260, 255];
