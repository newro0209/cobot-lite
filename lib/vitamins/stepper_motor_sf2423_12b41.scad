
use <common.scad>

// 용어
// 1. 스테퍼 모터(stepper motor)
// 2. 정격 전압(rated voltage)
// 3. 상 전류(phase current)
// 4. 홀딩 토크(holding torque)
// 5. 로터 관성(rotor inertia)
// 6. 프레임(frame)
// 7. 본체 길이(body length)
//
// Sanyo Denki SF2423-12B41 (BP5.6kg) — NEMA17 2상(two-phase) 1.8도 스테퍼 모터(stepper motor).
// 정격 전압(rated voltage) 4.44 VDC / 상 전류(phase current) 1.2 A, 홀딩 토크(holding torque) 0.56 N·m.
// 질량(mass) 0.38 kg, 로터 관성(rotor inertia) 0.063e-4 kg·m².
// 데이터시트(datasheet): part_references/SF2423-12B41(BP5.6kg)도면.pdf
// 사양(specification) 배열: [프레임(frame), 본체 길이(body length)] (mm)
function stepper_motor_sf2423_12b41_spec() = [42, 48];
function stepper_motor_sf2423_12b41_mass() = 0.38;            // 질량(mass), kg
function stepper_motor_sf2423_12b41_holding_torque() = 0.56;  // 홀딩 토크(holding torque), N·m

module stepper_motor_sf2423_12b41(part_color = [0, 0.18, 0.89]) {
    motor_sf24(body_len = stepper_motor_sf2423_12b41_spec()[1],
               part_color = part_color);
}

stepper_motor_sf2423_12b41();
