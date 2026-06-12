// J3 구동 링크 (drive link) — 크랭크 핀 ↔ 하완 구동 혼 핀 (MEC-001a)
// 길이 = J3 모터 축 ↔ 팔꿈치 축 거리 (평행사변형 1:1).
// 출력: 길이 305mm → 베드 대각 배치 (MFG-004)
include <../config/parameters.scad>
use <../lib/utils.scad>

drive_link_len = rear_extension + L1;

link_bar(drive_link_len);
