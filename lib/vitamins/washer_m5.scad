
use <common.scad>

// 용어
// 1. 와셔(washer)
// 2. 내경(inner diameter)
// 3. 두께(thickness)
//
// M5 와셔(washer)는 M5 체결부의 내경(inner diameter) 기준으로 모델링합니다.
function washer_m5_t() = 1.2;   // 두께(thickness) (mm)

module washer_m5(part_color = [0.7, 0, 1]) {
    washer(id = 5,
           thickness = washer_m5_t(),
           part_color = part_color);
}

washer_m5();
