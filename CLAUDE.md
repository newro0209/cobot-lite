# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

cobot-lite — 1kg 페이로드급 4축 절충형(palletizing-type) 협동 로봇 팔에서 출발, 대규모 디스코프(2026-06)로 현재는 **상완→하완 2링크 체인만 잔존** (베이스~어깨 접지부, 손목/공구, 수동 평행사변형 제거). 산출물: 기구 설계(OpenSCAD)와 BOM. 순수 모델링 프로젝트다.

**범위 외 (구현 금지)**: 역기구학(IK), 경로 계획, G-code 생성, 그리퍼 설계, 안전 기능(E-stop, 충돌 감지 등), 전장 설계(컨트롤러·드라이버·전원), 제어 펌웨어 (GEN-001, §7).

## 요구사항 문서가 최상위 권위

[REQUIREMENTS.md](REQUIREMENTS.md)가 모든 설계 결정의 기준. RFC 2119 마커(MUST/SHOULD/MAY) 사용. 작업 전 관련 요구사항 ID를 확인하고, 충돌 시 우선순위 스택 적용 (§0.2):

1. 부품 제약 (CON-*) — 최우선
2. 기능 (FUN-*/MEC-*)
3. 성능 (PER-*)
4. 제작/비용 (MFG-*, CST-*)
5. 프로젝트 관리 (PRJ-*, DOC-*)

SHOULD 예외를 둘 때는 사유를 `docs/`에 기록 (DOC-001). 값이 [TBD-n]으로 표시된 항목은 §11 TBD 목록 확인 후 임의 확정하지 말 것.

## 핵심 부품 제약 (모든 설계 판단에 선행)

- **피벗 샤프트**: 스트리퍼 볼트(숄더 볼트) + 와셔만. 숄더 5mm(625ZZ) / 8mm(608ZZ) 병용 가능. 환봉·전산볼트 금지 (CON-001)
- **베어링 4종만**: 608ZZ, 625ZZ, 6805ZZ, 6810ZZ. (CON-002/003)
- **모터**: 산요덴키 SF24 시리즈 3종만 (SF2424/SF2423/SF2422). 모터 + 기성품 유성 기어박스(planetary gearbox) 직결, 감속비 5:1/10:1/20:1만. 벨트/풀리 금지 (CON-004/005)
- **중력 보상 기구 금지** (스프링, 카운터웨이트 등). 단, 기존 부품(모터·전장) 배치를 균형에 유리하게 조정하는 것은 허용 (CON-009) — 구 J3 모터 후방 배치 근거(MEC-001c)는 v0.16 팔꿈치 직결로 유산화
- 구조 부품은 PETG-CF 출력 (CON-006). 구매 부품은 AliExpress/국내 유통 가능품만 (CON-008)

## 아키텍처

### 기구 (OpenSCAD)

- `config/parameters.scad`가 단일 치수 소스. 모든 출력 부품 치수는 전역 파라미터로 제어 — **매직 넘버 하드코딩 금지** (MEC-008). 베어링 압입 공차(-0.1~-0.2mm)도 단일 변수로 노출 (MFG-002)
- `parts/` — 1 파일 1 부품군 (다피스 부품은 파일 내 `piece` 셀렉터). `lib/utils.scad` — 공통 모듈(베어링 시트, 볼트 홀 등). `assembly/assembly.scad` — 전체 조립·간섭 확인용
- 구조 핵심 (v0.16): J3 = 팔꿈치 직결 — A3(SF2423+MG17-G20) 기어박스 플랜지를 상완 -Y 측판 팔꿈치 외면에 직결(⌀22 보어 = 파일럿, NEMA17 M3×4 — J2 인터페이스와 동일 홀 세트), 출력축 ⌀8 → 팔꿈치 허브(elbow_hub, 하완 볼트온 M4×3 r17) 클램프. +Y 아이들 피벗 = 상완 측판 608ZZ 인-플레이트 압입 + 숄더 ⌀8×25 + 갭 스페이서 ⌀12×8. 구 평행사변형(크랭크→구동 링크→혼)·후방 연장(rear_extension)·ua_adapter 폐지. J2 축 ⌀22 보어·NEMA17 홀은 장착 인터페이스로만 잔존(J2 액추에이터 제거). L1=225/L2=275는 구 토크 예산(PER-002)의 유산
- **동일 측판 원칙 (v0.15~)**: 상완·하완 측판은 _a/_b 구분 없는 1형상 ×2 (플립 장착). 한쪽 전용 기능은 볼트온 소부품으로 분리 — 팔꿈치 허브. 전제: 직선 빔(`ua_bend_deg = fa_bend_deg = 0` — 꺾임 복원 시 미러 쌍 필요) + z 대칭 홀 세트. 경량 관통창 금지
- 출력 제약: 서포트 없는 출력 우선, 불가피하면 부품 분할+볼트 체결 (MFG-003). 단일 부품 260×260×255mm 이내 (MFG-004, SparkX i7 — 측판 277은 베드 대각 배치). 3축 밀링 가공 가능 형상 유지 (GEN-002)

### 전장 인터페이스 (장착부만 제공)

전장(드라이버, 전원, 컨트롤러, 배선)은 범위 외. 단, 기구 모델은 잔존 관절(J3)에 NEMA 17 모터 마운트·리미트 스위치(limit switch) 장착부·케이블 가이드(SHOULD)를 제공한다.

## 명령어

OpenSCAD STL 내보내기 (다피스 부품은 `piece` 파일 변수로 선택):
```
openscad -o export/stl/<부품명>.stl parts/<부품명>.scad
openscad -o export/stl/upper_arm_plate.stl -D "piece=\"plate\"" parts/upper_arm.scad
```

`main.scad` = Customizer 뷰어 진입점: `part`(assembly/exploded/print/단일 부품), `[Pose]` J2~J3, `[Labels]` show_labels/label_size/label_detail(하드웨어·서브피처 전수 라벨), `[Hardware]` show_hardware(베어링·볼트·너트·와셔 목업), `[Exploded]` explode. 컬러 팔레트는 `lib/colors.scad`(동적 카테고리 톤온톤, 라벨 동색, 구매품 무채 톤온톤). `assembly/assembly.scad`의 `robot(j2,j3,e,labels,lsize,hardware,label_detail)` 모듈이 본체 — CLI 간섭 검사(check=2)는 `-D J2a=...` 파일 변수로 동작하며 hw 기본 false라 체결류 면접촉 노이즈 없음.

## 문서화 규칙

- 공학 용어는 '한국어(영어)' 병기 (DOC-002). 예: 유성 기어(planetary gear)
- 유지 의무 문서: `docs/bom.md` (부품명·규격·수량·단가·구매처 링크)

## 검증 도구

- `tools/check_asm.ps1` — 간섭 검사 그리드 (assembly check=2: 하완∩상완 — check=1은 접지부 제거로 폐지). 빈 STL = 통과
- `tools/mass_report.ps1` — STL 체적 → 질량(g)·바운딩 박스 리포트 (MEC-007/MFG-004 검증)
- 형상 변경 시 두 스크립트 재실행

## 현재 상태

J3 팔꿈치 직결 (2026-06-13, v0.16) — 상완→하완 2링크 체인. 출력 부품 4종:
upper_arm_plate ×2 (277, 후방 연장 폐지), forearm_plate ×2 (277), elbow_hub (⌀44 + 리미트 베인 일체), cable_clip ×6.
제거됨 (v0.16): j3_crank·drive_link·drive_horn·ua_adapter, rear_extension, 625ZZ·⌀5 숄더 볼트,
구동 평행사변형 기구학(psi)·전동각/신장 특이점 (엔벨로프 = 간섭 한계 j3-j2 ∈ [-140, +20], 기하 한계 ±149°).
(v0.15 이전 제거분: 베이스/J1, 어깨/J2 접지부, 손목/J4·공구 플랜지, 수동 평행사변형, J1/J2/J4 액추에이터.)
좌표 원점 = J2 축. 사용 베어링 608ZZ ×3만, 사용 모터 SF2423(J3)만 — CON 허용 목록은 불변.
팔꿈치 숄더 볼트 = ⌀8×25 확정 (구 L68 재산정 완료 — 스택 22 + 와셔 조정).
전 파일 .csg 컴파일 통과. 잔여: 허브 핀치 볼트 갭 내 접근성 확인, 베인 위상(elbow_vane_a) 검증,
BOM 단가·링크, 간섭 그리드(check=2)·질량 재계측.
참고: REQUIREMENTS.md·docs(design-notes 등)는 삭제됨 — 요구사항 ID 참조는 유산 표기.
