# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

cobot-lite — 1kg 페이로드급 2축 절충형(palletizing-type) 협동 로봇 팔. 현재 모델은 **J2/J3 피치 축의 팔 체인**만 다룬다. 베이스/레일/테이블 고정 구조, 하부 회전·지지 구조, 손목/공구, 그리퍼, 전장, 제어 펌웨어는 범위 외다.

산출물은 OpenSCAD 기반 기구 설계와 BOM이다.

## 범위 외

역기구학(IK), 경로 계획, G-code 생성, 그리퍼 설계, 안전 기능(E-stop, 충돌 감지 등), 전장 설계(컨트롤러·드라이버·전원), 제어 펌웨어는 구현하지 않는다.

## 아키텍처

- `config/parameters.scad`가 단일 치수 소스다. 출력 부품 치수와 공차는 이 파일에서 제어한다.
- `parts/`는 1 파일 1 부품군 구조를 유지한다.
- `assembly/assembly.scad`는 전체 조립과 간섭 검사용 모델이다.
- `main.scad`는 OpenSCAD Customizer 진입점이다.

현재 출력 부품:

- `upper_arm.scad`
- `forearm.scad`
- `j3_crank.scad`
- `drive_link.scad`
- `cable_clip.scad`

## 기구 규약

- 좌표 원점은 J2 축이다.
- `J2`/`J3`는 각각 상완/하완 현(chord)의 월드 피치다.
- 접힘각은 `J3 - J2`이며, 권고 범위는 `env_fold_min..env_fold_max`다.
- 상완/하완은 꺾임 빔이며, 기구학 기준은 항상 관절축을 잇는 현이다.
- J3는 크랭크 → 구동 링크 → 하완 혼 핀의 평행사변형 전달 구조를 유지한다.

## 명령어

OpenSCAD STL 내보내기:

```sh
openscad -o export/stl/<부품명>.stl parts/<부품명>.scad
openscad -o export/stl/upper_arm_plate.stl -D "piece=\"plate\"" parts/upper_arm.scad
```

검증:

```sh
pwsh tools/check_asm.ps1
pwsh tools/mass_report.ps1
```

`assembly/assembly.scad`의 간섭 검사:

- `check=2`: 하완 그룹 ∩ 상완 그룹
- `check=3`: 링키지 ∩ 팔 구조

## 문서화 규칙

- 공학 용어는 가능한 경우 한국어(English)를 병기한다.
- BOM은 [docs/bom.md](docs/bom.md)를 기준으로 유지한다.
