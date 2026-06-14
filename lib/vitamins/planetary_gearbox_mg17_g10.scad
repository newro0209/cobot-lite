
use <common.scad>

// 용어:
// 1. 유성 감속기(planetary gearbox)
// 2. 입력 플랜지(input flange)
// 3. 본체 길이(body length)
// 4. 출력축 지름(output shaft diameter)
// 5. 감속비(reduction ratio)

// STEPPERONLINE MG17-G10 유성 감속기(planetary gearbox)는 NEMA17 입력 플랜지(input flange)와 감속비(reduction ratio) 10:1 기준입니다.
// 사양 배열: [입력 플랜지(input flange), 본체 길이(body length), 출력축 지름(output shaft diameter), 감속비(reduction ratio)], mm
function planetary_gearbox_mg17_g10_spec() = [42, 40, 10, 10];

module planetary_gearbox_mg17_g10(part_color = [0, 0.85, 0.85]) {
    body_len = planetary_gearbox_mg17_g10_spec()[1];
    gearbox_mg17(body_len = body_len, part_color = part_color);
}

planetary_gearbox_mg17_g10();
