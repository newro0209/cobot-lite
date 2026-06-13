// 뷰 컬러 팔레트 — 카테고리 기본색 + 조립 호출부 변형색
// 카테고리는 의미 묶음만 제공한다. 호출부는 어떤 부품에든 임의 색/변형색을 전달 가능.
// (시각화 전용 — 치수 아님)

function clamp01(x) = min(1, max(0, x));
function color_tone(c, gain = 1, bias = 0) =
    [clamp01(c[0] * gain + bias),
     clamp01(c[1] * gain + bias),
     clamp01(c[2] * gain + bias)];

/* 출력 부품 — 카테고리 기본색(rgb 벡터). */
C_UPPERARM     = [0.23, 0.44, 0.62];   // 상완 계열 (파랑)
C_FOREARM      = [0.18, 0.54, 0.54];   // 하완 계열 (청록)
C_LINKAGE      = [0.76, 0.64, 0.24];   // J3 링키지 계열 (골드)
C_CLIP         = [0.63, 0.54, 0.82];   // 케이블 클립 계열 (보라)

/* 조립 호출부 변형색 — 동일 부품 반복 사용 시 미세 구분. */
C_UPPERARM_POS = color_tone(C_UPPERARM, 1.12, 0.02);
C_UPPERARM_NEG = color_tone(C_UPPERARM, 0.88);

C_FOREARM_POS  = color_tone(C_FOREARM, 1.10, 0.02);
C_FOREARM_NEG  = color_tone(C_FOREARM, 0.86);

C_J3_CRANK     = color_tone(C_LINKAGE, 0.96);
C_DRIVE_LINK   = color_tone(C_LINKAGE, 1.14, 0.02);

C_CABLE_CLIP_A = color_tone(C_CLIP, 1.08, 0.02);
C_CABLE_CLIP_B = color_tone(C_CLIP, 0.86);

/* 구매품(vitamin) 기준색 — rgb 벡터 (모듈 내부 톤온톤 파생용: col*f).
   assembly가 이 기준색을 vitamin 모듈에 col 인자로 전달하면,
   모듈이 col*0.45(어둡게)·col*1.3(밝게)로 내부 디테일을 구분한다. */
C_VITAMIN   = [0.16, 0.16, 0.16];   // 모터+기어박스 (흑)
C_BOLT      = [0.42, 0.42, 0.42];   // 숄더 볼트·너트 (다크 스틸)
C_WASHER    = [0.50, 0.50, 0.50];   // 와셔
C_BEARING   = [0.62, 0.62, 0.63];   // 베어링 (스틸)
C_COUPLER   = [0.72, 0.72, 0.74];   // 플랜지 커플러 (알루미늄)
// 리미트 스위치 세부 색(몸체·레버·롤러·핀)은 lib/vitamins.scad 내부 정의 (use 스코프 자족).
