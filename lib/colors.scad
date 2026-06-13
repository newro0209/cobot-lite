// 뷰 컬러 팔레트 — 카테고리 기본색 + 조립 호출부 변형색
// 카테고리는 의미 묶음만 제공한다. 호출부는 어떤 부품에든 임의 색/변형색을 전달 가능.
// (시각화 전용 — 치수 아님)

function clamp01(x) = min(1, max(0, x));
function color_tone(c, gain = 1, bias = 0) =
    [clamp01(c[0] * gain + bias),
     clamp01(c[1] * gain + bias),
     clamp01(c[2] * gain + bias)];

function upper_arm_base_color() = [0.23, 0.44, 0.62];
function forearm_base_color() = [0.18, 0.54, 0.54];
function linkage_base_color() = [0.76, 0.64, 0.24];
function clip_base_color() = [0.63, 0.54, 0.82];

function upper_arm_pos_color() = color_tone(upper_arm_base_color(), 1.12, 0.02);
function upper_arm_neg_color() = color_tone(upper_arm_base_color(), 0.88);
function forearm_pos_color() = color_tone(forearm_base_color(), 1.10, 0.02);
function forearm_neg_color() = color_tone(forearm_base_color(), 0.86);
function j3_crank_color() = color_tone(linkage_base_color(), 0.96);
function drive_link_color() = color_tone(linkage_base_color(), 1.14, 0.02);
function cable_clip_a_color() = color_tone(clip_base_color(), 1.08, 0.02);
function cable_clip_b_color() = color_tone(clip_base_color(), 0.86);

function vitamin_color() = [0.16, 0.16, 0.16];
function bolt_color() = [0.42, 0.42, 0.42];
function washer_color() = [0.50, 0.50, 0.50];
function bearing_color() = [0.62, 0.62, 0.63];
function coupler_color() = [0.72, 0.72, 0.74];
// 리미트 스위치 세부 색은 lib/vitamins/kw12_limit_switch.scad 내부 정의이다.
