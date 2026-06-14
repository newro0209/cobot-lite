# cobot-lite

1kg 페이로드급 절충형(palletizing-type) 협동 로봇(collaborative robot) 팔의 J2/J3 링크 체인.

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
| [docs/](docs/) | BOM 기록 |

## 뷰어 (main.scad)

OpenSCAD에서 [main.scad](main.scad)를 열면 Customizer로 제어:

- `part`: `assembly`(조립) / `exploded`(분해) / `print`(출력 배치) / 단일 부품명
- `[Pose]` J2/J3 관절 각도 (가동 범위 주석 참조)
- `[Exploded]` `explode` 분해 거리
