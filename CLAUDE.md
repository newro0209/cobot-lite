# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

cobot-lite — 1kg 페이로드급 4축 절충형(palletizing-type) 협동 로봇 팔. 산출물: 기구 설계(OpenSCAD)와 BOM. 순수 모델링 프로젝트다.

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
- **중력 보상 기구 금지** (스프링, 카운터웨이트 등). 단, 기존 부품(모터·전장) 배치를 균형에 유리하게 조정하는 것은 허용 (CON-009) — J3 모터를 J2 축 후방 배치하는 근거 (MEC-001c)
- 구조 부품은 PETG-CF 출력 (CON-006). 구매 부품은 AliExpress/국내 유통 가능품만 (CON-008)

## 아키텍처

### 기구 (OpenSCAD)

- `config/parameters.scad`가 단일 치수 소스. 모든 출력 부품 치수는 전역 파라미터로 제어 — **매직 넘버 하드코딩 금지** (MEC-008). 베어링 압입 공차(-0.1~-0.2mm)도 단일 변수로 노출 (MFG-002)
- `parts/` — 1 파일 1 부품군 (다피스 부품은 파일 내 `piece` 셀렉터). `lib/utils.scad` — 공통 모듈(베어링 시트, 볼트 홀 등). `assembly/assembly.scad` — 전체 조립·간섭 확인용
- 구조 핵심: J2 모터는 J2 축 동축 직결(스테이터 상완 측, MEC-001b). J3 모터는 상완 후방 연장 탑재 + 평행사변형 구동 링크로 하완 구동 (MEC-001a/001c). 공구 연직 유지는 수동 평행사변형 링크 (MEC-002). 이 분담 구조가 토크 예산(PER-002)의 전제 — L1=225/L2=275 비대칭 분할 근거
- **동일 측판 원칙 (v0.15)**: 상완·하완·손목·어깨 측판은 _a/_b 구분 없는 1형상 ×2 (플립 장착). 한쪽 전용 기능은 볼트온 소부품으로 분리 — J2 클램프 디스크 / J2 아이들 부시 / J3 모터 어댑터 / 손목 혼 패들. 전제: 직선 빔(`ua_bend_deg = fa_bend_deg = 0` — 꺾임 복원 시 미러 쌍 필요, design-notes §4c) + z 대칭 홀 세트. 경량 관통창 금지
- 출력 제약: 서포트 없는 출력 우선, 불가피하면 부품 분할+볼트 체결 (MFG-003). 단일 부품 260×260×255mm 이내 (MFG-004, SparkX i7 — 상완 단일 피스 365는 베드 대각 배치, 사용자 지시로 분할 폐지·재검토 항목). 3축 밀링 가공 가능 형상 유지 (GEN-002)

### 전장 인터페이스 (장착부만 제공)

전장(드라이버, 전원, 컨트롤러, 배선)은 범위 외. 단, 기구 모델은 다음 장착부를 제공해야 한다: NEMA 17 모터 마운트, 관절당 리미트 스위치(limit switch) 장착부 1개소, 케이블 가이드(SHOULD).

## 명령어

OpenSCAD STL 내보내기 (다피스 부품은 `piece` 파일 변수로 선택):
```
openscad -o export/stl/<부품명>.stl parts/<부품명>.scad
openscad -o export/stl/shoulder_plate.stl -D "piece=\"plate\"" parts/shoulder.scad
```

`main.scad` = Customizer 뷰어 진입점: `part`(assembly/exploded/print/단일 부품), `[Pose]` J1~J4, `[Labels]` show_labels/label_size/label_detail(하드웨어·서브피처 전수 라벨), `[Hardware]` show_hardware(베어링·볼트·너트·와셔 목업), `[Exploded]` explode. 컬러 팔레트는 `lib/colors.scad`(정적 무채색 / 동적 카테고리 톤온톤, 라벨 동색, 구매품 무채 톤온톤). `assembly/assembly.scad`의 `robot(j1,j2,j3,j4,e,labels,lsize,hardware)` 모듈이 본체 — CLI 간섭 검사(check=1~5)는 `-D J2a=...` 파일 변수로 동작하며 hw 기본 false라 체결류 면접촉 노이즈 없음.

## 문서화 규칙

- 공학 용어는 '한국어(영어)' 병기 (DOC-002). 예: 유성 기어(planetary gear)
- 유지 의무 문서: `docs/bom.md` (부품명·규격·수량·단가·구매처 링크), `docs/mass-budget.md` (이동부 0.8kg 이하, MEC-007), `docs/torque-budget.md` (PER-002 분담 정역학 검증)
- 설계 변경 시 질량·토크 예산 문서를 함께 갱신할 것 — 토크 예산은 리치 500mm 성립 여부를 결정 (PER-002: 기어박스 정격 미달 시 L2 → L1 순 축소)

## 검증 도구

- `tools/check_asm.ps1` — 간섭 검사 그리드 (assembly check=1: 체인∩고정부, check=2: 하완∩상완). 빈 STL = 통과
- `tools/mass_report.ps1` — STL 체적 → 질량(g)·바운딩 박스 리포트 (MEC-007/MFG-004 검증)
- 형상 변경 시 두 스크립트 재실행 + `docs/mass-budget.md`·`docs/torque-budget.md` 갱신

## 현재 상태

v0.15 — 동일 측판 통합 + J1/J2/J4 단순 재설계 (design-notes §4c): 출력 부품 22종.
J1 = 베이스(평판+칼럼+포스트 일체) + 마운트 디스크 + 턴테이블(컵+스템 일체, 스페이서 부품 폐지).
J2 = 동일 측판 t14 ×2 + 플랜지 + 클램프 디스크 + 앵커(구 pl_anchor 흡수).
J4 = 동일 측판 ×2 + 바텀(NEMA·6805 동심) + 혼 패들 + 플랜지(스템 보스).
상완 단일 피스(분할·더블러 폐지), 직선 빔(꺾임 0°), 경량창 전부 제거.
운용 엔벨로프 [-75°, -3°](§3a), 체결류 역할 구분(§4a) 유지.
전 파일 .csg 컴파일 통과 — **간섭 그리드·STL 질량 재계측은 v0.15 기준 미실행 (요청 시 일괄)**.
잔여: BOM 단가·링크, 질량/토크 예산 v0.15 갱신, 8mm 숄더 볼트 L68 수급 확인, MFG-004(상완 365) 재검토.
