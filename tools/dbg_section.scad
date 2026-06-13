// 디버그: J2 축 수평 단면 — y-스택 체결 검증용 (임시 도구)
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
