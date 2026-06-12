// cobot-lite 전역 파라미터 (global parameters)
// 모든 부품 치수는 이 파일에서만 정의한다 — 매직 넘버 하드코딩 금지 (MEC-008)

/* ===== 출력/렌더링 ===== */
$fn = 64;

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

// J2/J3 모터 후방 배치 연장 길이 (MEC-001c)
// J1 회전 시 베이스·작업물 간섭 확인 필수
rear_extension = 80;    // J2 피벗 → 모터 어셈블리 중심 [잠정]

/* ===== 턴테이블 (turntable) — MEC-003 ===== */
turntable_bearing_gap = 30;   // 6810ZZ 2개 축방향 이격, 30mm 이상 (SHOULD)

/* ===== 모터 (motor) — CON-004: 산요덴키 SF24 시리즈 =====
   NEMA 17 호환 42각 */
motor_frame = 42;             // 프레임 폭 (mm)
nema17_hole_pitch = 31;       // 고정 볼트 피치
nema17_pilot_d = 22;          // 센터 파일럿 직경
nema17_bolt_d = 3;            // M3

/* ===== 감속비 (gear ratio) — CON-005: 5/10/20만 허용 ===== */
ratio_J1 = 20;
ratio_J2 = 20;
ratio_J3 = 20;   // [TBD-3] SF2423 vs SF2424
ratio_J4 = 5;

/* ===== 질량/성능 예산 ===== */
payload = 1.0;            // kg, 그리퍼 포함 정격 (PER-001)
moving_mass_budget = 0.8; // kg, 상완 이후 이동부 상한 (MEC-007)

/* ===== 출력 제약 — MFG-004 [TBD-8] ===== */
build_volume = [220, 220, 250];

/* ===== 공통 가공 여유 ===== */
clearance_fit = 0.3;      // 회전/슬라이드 끼움 여유
bolt_hole_oversize = 0.4; // 관통 볼트 홀 여유
