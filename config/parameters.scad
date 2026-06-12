// cobot-lite 전역 파라미터 (global parameters)
// 모든 부품 치수는 이 파일에서만 정의한다 — 매직 넘버 하드코딩 금지 (MEC-008)

/* ===== 출력/렌더링 ===== */
$fn = 64;

/* ===== 공통 가공 여유 (파생 치수에서 참조 — 선행 정의 필수) ===== */
clearance_fit = 0.3;      // 회전/슬라이드 끼움 여유
bolt_hole_oversize = 0.4; // 관통 볼트 홀 여유

/* ===== 베어링 (bearing) — CON-002 허용 목록 중 사용분 =====
   [내경, 외경, 폭] mm */
BRG_608ZZ  = [8,  22, 7];   // 관절 피벗 (8mm 숄더 볼트)

// 베어링 압입 공차 (press-fit tolerance) — MFG-002
// 외경 기준 -0.1 ~ -0.2mm. 프린터별 보정은 이 변수 하나로 조정한다.
bearing_press_fit = -0.15;

/* ===== 숄더 볼트 (stripper/shoulder bolt) — CON-001 ===== */
shoulder_d_large = 8;   // 608ZZ 결합 (팔꿈치 아이들측 ⌀8×25)

/* ===== 링크 길이 — MEC-006 [TBD-4] =====
   리치 500mm 잠정. 비대칭 분할 (J2 자중 부담 보상, MEC-001a 분담 구조) */
L1 = 225;   // 상완 (upper arm): J2 축 → J3 축
L2 = 275;   // 하완 (forearm): J3 축 → 공구 플랜지

/* ===== 링크 꺾임 (팔레타이저식 구조 오프셋) =====
   v0.15: 0 고정 — 측판 A/B 동일 형상 1종(플립 장착) 원칙과 비호환.
   꺾임을 되살리려면 측판을 미러 쌍으로 되돌려야 한다 (docs/design-notes §4b) */
ua_bend_deg = 0;      // 상완 꺾임각 (0 = 직선 — 동일 측판 전제)
ua_bend_pos = 0.68;   // 꺾임 위치 (0~1, J2 기준)
fa_bend_deg = 0;      // 하완 꺾임각 (0 = 직선 — 동일 측판 전제)
fa_bend_pos = 0.5;    // 꺾임 위치 (팔꿈치 기준)

/* ===== 가동 엔벨로프 (소프트 리미트 권고값) =====
   접힘각 = J3 - J2 (월드 피치 차).
   직결 구동(평행사변형 폐지)으로 전동각·신장 특이점 소멸 — 한계는 물리 간섭만:
   하완 빔(반폭 26)·스탠드오프 AF13가 상완 스탠드오프(160,0)와 충돌하는
   |접힘각| ≈ 149° (asin(33.5/65))가 기하 한계 */
env_fold_min = -140;  // 접힘 한계 (간섭 -149°에 여유 9°)
env_fold_max = 20;    // 과신전 한계 [잠정 — 운용상 제한, 기하 한계는 +149°]

/* ===== 모터 (motor) — CON-004: 산요덴키 SF24 시리즈 =====
   NEMA 17 호환 42각 */
motor_frame = 42;             // 프레임 폭 (mm)
nema17_hole_pitch = 31;       // 고정 볼트 피치
nema17_pilot_d = 22;          // 센터 파일럿 직경
nema17_bolt_d = 3;            // M3

/* ===== 감속비 (gear ratio) — CON-005: 5/10/20만 허용 ===== */
// 주의: MG17-G10(10:1)은 허용 토크 5N·m로 급락 — 변경 시 토크 재검증 (docs/torque-budget.md)
ratio_J3 = 20;   // SF2423 + 20:1 확정 (TBD-3 해결)

/* ===== 기어박스 (gearbox) — MG17 데이터시트 (docs/tbd-research.md TBD-5) ===== */
gbx_frame = 42;            // NEMA 17 플랜지, 모터와 동일 42각
gbx_len_20to1 = 51;        // MG17-G20 길이 (J3)
gbx_out_shaft_d = 8;       // 출력축 직경
gbx_in_insert = 9.5;       // 입력 결합 깊이 — SF24 축 길이 호환 확인 항목
gbx_mass_20to1 = 400;      // g — 질량 예산 계산용

/* ===== 모터 몸체 치수 — SF24 카탈로그 일반값 [잠정: 구매 데이터시트로 확인] ===== */
motor_len_SF2423 = 39;    // J3
motor_shaft_d = 5;        // SF24 출력축 (MG17 입력 클램프 ⌀5)
gbx_out_shaft_len = 20;   // MG17 출력축 돌출 길이

/* ===== 공통 셀프태핑 파일럿 ===== */
set_screw_pilot_d = 3.4;  // M4 셀프태핑 파일럿 (핀·무두 볼트)

/* ===== 암 단면/관절 (MEC-004) — v0.15 동일 측판 플레이트 아키텍처 =====
   원칙: ① 출력물은 평판(plate)만 — 간격은 표준 육각 스탠드오프/튜브가 결정
        ② _a/_b 측판 구분 폐지 — 동일 형상 1종 ×2 (플립 장착 호환).
          한쪽 전용 기능은 볼트온 소부품으로 분리:
          J2 클램프 디스크 / J2 아이들 부시 / J3 모터 어댑터 / 손목 혼 패들
        ③ 경량 관통창 전면 폐지 (v0.15) */
arm_plate_t = 7;          // 측판 두께 = 608ZZ 폭 (베어링 인-플레이트 압입)
fork_standoff_len = 30;   // 표준 육각 스탠드오프 길이 (= 하완 내폭)
hex_standoff_af = 13;     // 두꺼운 육각 스탠드오프 평면폭 (M6 암-암)
joint_spacer_od = 12;     // 관절 스택 스페이서 튜브 외경 (숄더 ⌀8 위)
// 상완 포크 내폭 = 표준 육각 스탠드오프 L60
arm_inner_w = 60;
forearm_inner_w = fork_standoff_len;  // 하완 측판 내폭 = 표준 스탠드오프 30
arm_lug_r = 26;           // 관절 러그(피벗 보스) 반경

/* ===== 팔꿈치 직결 (J3 direct drive) =====
   기어박스 플랜지 → 상완 -Y 측판 외면 직결 (⌀22 보어 = 파일럿, NEMA17 M3 ×4).
   출력축 ⌀8 → 팔꿈치 허브(elbow hub) 클램프 → 하완 측판 볼트온 (M4 ×3, r17).
   관절 측면 갭 = (arm_inner_w - forearm_inner_w)/2 - arm_plate_t = 8mm */
elbow_gap = (arm_inner_w - forearm_inner_w) / 2 - arm_plate_t;
elbow_hub_d = 44;         // 허브 디스크 외경 (M4 볼트 서클 + 벽)
elbow_hub_bolt_r = 17;    // 허브 M4 FHCS ×3 볼트 서클 반경 (하완 파일럿 동기)
elbow_hub_t = elbow_gap - 1;  // 허브 두께 = 갭 − 여유 1 (= 7)
elbow_vane_r = 48;        // J3 리미트 베인 반경 (허브 일체 탭 선단)
elbow_vane_w = 8;         // 베인 탭 폭
elbow_vane_a = 320;       // 베인 위상 (허브 로컬, 접힘 -140° 트리거) [잠정]
elbow_ls_x = 45;          // 리미트 스위치 위치: 팔꿈치에서 J2 방향 거리

/* ===== 너트 평면폭 (across flats) ===== */
m6_nut_af = 10;

/* ===== 하완 선단 ===== */
wrist_offset = 50;        // 구 손목 피치 피벗 → 공구 축 오프셋 (forearm_len 산정용 잔존)
forearm_len = L2 - wrist_offset; // 팔꿈치 축 → 하완 선단 (구 손목 피치 피벗)

/* ===== 리미트 스위치 (ELE-004) — KW12형 기계식 마이크로 기준품 ===== */
ls_body = [20, 10, 6.5];  // 몸체 [길이, 높이, 두께]
ls_hole_pitch = 9.5;      // 장착 홀 피치
ls_hole_d = 2.3;          // M2 셀프태핑/볼트

/* ===== 질량 산출 (MEC-007, docs/mass-budget.md) ===== */
petgcf_density = 1.30;    // g/cm³ (PETG-CF 카탈로그 일반값)
print_solidity = 0.6;     // 쉘+인필 유효 충전율 [잠정 — 슬라이서 추정으로 대체]
motor_mass_SF2423 = 380;  // g (산요 카탈로그 확정)

/* ===== 질량/성능 예산 ===== */
payload = 1.0;            // kg, 그리퍼 포함 정격 (PER-001)
moving_mass_budget = 0.8; // kg, 상완 이후 이동부 상한 (MEC-007)

/* ===== 출력 제약 — MFG-004 (Creality SparkX i7, TBD-8 해결) ===== */
build_volume = [260, 260, 255];
