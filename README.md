# cobot-lite

1kg 페이로드급 2축 절충형(palletizing-type) 협동 로봇(collaborative robot) 팔.

공장 부분 자동화용: 필터 하우징 수직 픽업 → 압입기/융착기 지그에 수직 안착.

## 산출물 범위

- 기구 설계 (OpenSCAD) — 1단계 PETG-CF 출력, 2단계 CNC 전환 전제
- BOM

역기구학(IK), 경로 계획, G-code 생성, 그리퍼, 안전 기능, 전장 설계, 제어 펌웨어는 범위 외 — 상위/후속 프로젝트 책임.
베이스/레일/테이블 고정 구조와 하부 회전·지지 구조는 범위 외다.

## 저장소 구조

| 경로 | 내용 |
|---|---|
| [parts/](parts/) | 부품별 .scad (1 파일 1 부품, 단품 치수는 각 파일에 지역 정의) |
| [lib/utils.scad](lib/utils.scad) | 치수 독립 공통 모듈 (베어링 시트, 볼트 홀 등) |
| [lib/vitamins/](lib/vitamins/) | 구매품 목업 형상 라이브러리 |
| [assembly/assembly.scad](assembly/assembly.scad) | 전체 조립 모델 (간섭 확인용) |
| [export/stl/](export/stl/) | 출력용 STL |
| [docs/](docs/) | BOM, 질량/토크 예산, 설계 결정 기록 |
| [tools/](tools/) | 검증 스크립트 (간섭 검사, 질량 리포트) |

## 뷰어 (main.scad)

OpenSCAD에서 [main.scad](main.scad)를 열면 Customizer로 제어:

- `part`: `assembly`(조립) / `exploded`(분해) / `print`(출력 배치) / 단일 부품명
- `[Pose]` J2/J3 관절 각도 (가동 범위 주석 참조)
- `[Hardware]` `show_hardware` — 베어링·숄더 볼트·너트·와셔 목업 (assembly 전용)
- `[Exploded]` `explode` 분해 거리

컬러: 의미 카테고리별 기본 팔레트 + 조립 호출부 변형색([lib/colors.scad](lib/colors.scad)). parts 모듈은 `col` 파라미터만 받아 같은 부품도 배치별 톤 차이를 줄 수 있다. 구매품은 무채 톤온톤(모터 다크 → 볼트 → 와셔 → 베어링 라이트 스틸).

## STL 내보내기

```sh
openscad -o export/stl/<부품명>.stl parts/<부품명>.scad
openscad -o export/stl/<구매품명>.stl lib/vitamins/<구매품명>.scad
```

## 검증

```sh
pwsh tools/check_asm.ps1    # 자세 그리드 간섭 검사 (assembly check=2/3)
pwsh tools/mass_report.ps1  # STL 체적 → 질량·바운딩 박스 (MEC-007/MFG-004)
```
