// 디버그(debug): J2 축(axis) 수평 단면(horizontal section)으로 y-스택(y-stack) 체결을 검증하는 임시 도구입니다.
//
// 용어
// 1. 디버그(Debug)
// 2. 축(Axis)
// 3. 수평 단면(Horizontal section)
// 4. 수직 단면(Vertical section)
// 5. 체결 스택(Fastener stack)
//
// openscad -o sec.png --camera=... -D J2s=0 -D J3s=-45 tools/dbg_section.scad
use <../assembly/assembly.scad>

module debug_section(j2 = 0, j3 = -45, section_z = 0, vertical = false) {
    $fn = 64;
    intersection() {
        robot(j2, j3, 0, false);
        if (vertical)
            translate([-600, -1, -200]) cube([1200, 2, 600]);
        else
            translate([-600, -600, section_z - 1])
                cube([1200, 1200, 2]);
    }
}

debug_section(j2 = is_undef(J2s) ? 0 : J2s,
              j3 = is_undef(J3s) ? -45 : J3s,
              section_z = is_undef(sec_z) ? 0 : sec_z,
              vertical = is_undef(vsec) ? false : vsec);
