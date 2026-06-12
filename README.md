# cobot-lite

1kg 페이로드급 4축 절충형(palletizing-type) 협동 로봇(collaborative robot) 팔.

공장 부분 자동화용: 필터 하우징 수직 픽업 → 압입기/융착기 지그에 수직 안착. 공구 자세는 수동 평행사변형 링크(passive parallelogram linkage)로 항상 연직(tool-down) 유지.

## 산출물 범위

- 기구 설계 (OpenSCAD) — 1단계 PETG-CF 출력, 2단계 CNC 전환 전제
- 전장 설계 (DRV8825 ×4, 24V 단일 전원)
- 관절 제어 펌웨어 (UART 명령 수신 / 개루프 스테퍼 구동 / 호밍)
- BOM

역기구학(IK), 경로 계획, G-code 생성, 그리퍼, 안전 기능은 범위 외 — 상위 프로젝트 책임.

## 저장소 구조

| 경로 | 내용 |
|---|---|
| [REQUIREMENTS.md](REQUIREMENTS.md) | 요구사항 명세 — 모든 설계 결정의 기준 |
| [config/parameters.scad](config/parameters.scad) | 전역 파라미터 (치수, 공차, 감속비) — 단일 치수 소스 |
| [parts/](parts/) | 부품별 .scad (1 파일 1 부품) |
| [lib/utils.scad](lib/utils.scad) | 공통 모듈 (베어링 시트, 볼트 홀 등) |
| [assembly/assembly.scad](assembly/assembly.scad) | 전체 조립 모델 (간섭 확인용) |
| [export/stl/](export/stl/) | 출력용 STL |
| [firmware/](firmware/) | 관절 제어 펌웨어 |
| [docs/](docs/) | BOM, 질량/토크 예산, 호밍, 설계 결정 기록 |

## STL 내보내기

```
openscad -o export/stl/<부품명>.stl parts/<부품명>.scad
```
