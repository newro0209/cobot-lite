
use <common.scad>

// 용어
// 1. 플랜지 커플러(flange coupler)
// 2. 플랜지(flange)
// 3. 보디(body)
// 4. 볼트 원 반지름(bolt circle radius)

// 전체 높이는 기준 하단부 3 mm와 상단 원통부 10 mm의 합입니다.
function flange_coupler_8mm_h() = 13;

module flange_coupler_8mm(part_color = [0, 1, 0.35]) {
    flange_coupler(part_color = part_color,
                   bolt_radius = 12,
                   bolt_count = 4,
                   bolt_d = 4);
}

flange_coupler_8mm();
