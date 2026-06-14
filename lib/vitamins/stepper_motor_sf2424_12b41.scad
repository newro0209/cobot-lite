
use <common.scad>

// 용어
// 1. 스테퍼 모터(stepper motor)
// 2. 프레임(frame)
// 3. 본체 길이(body length)
// 4. 홀딩 토크(holding torque)
// 5. 로터 관성(rotor inertia)
// 6. 데이터시트(datasheet)
//
// Sanyo Denki SF2424-12B41은 NEMA17 2상 1.8도 스테퍼 모터(stepper motor)입니다.
// 정격 5.76 VDC / 1.2 A·phase, 홀딩 토크(holding torque) 0.8 N·m,
// 질량 0.51 kg, 로터 관성(rotor inertia) 0.094e-4 kg·m² 기준입니다.
// 데이터시트: part_references/SF2424-12B41(8kg)도면.pdf
// [프레임(frame), 본체 길이(body length)] (mm)
function stepper_motor_sf2424_12b41_spec() = [42, 59.5];
function stepper_motor_sf2424_12b41_mass() = 0.51;           // kg
function stepper_motor_sf2424_12b41_holding_torque() = 0.8;  // N·m

module stepper_motor_sf2424_12b41(part_color = [0, 0.18, 0.89]) {
    motor_sf24(body_len = stepper_motor_sf2424_12b41_spec()[1],
               part_color = part_color);
}

stepper_motor_sf2424_12b41();
