
use <common.scad>

// 용어
// 1. 스페이서(spacer)
// 2. 외경(outer diameter)
// 3. 보어(bore)
// 4. 길이(length)

module spacer_od12_id8_4_l6(part_color = [1, 0, 0.8]) {
    spacer(od = 12,
           bore = 8.4,
           spacer_len = 6,
           part_color = part_color);
}

spacer_od12_id8_4_l6();
