// 디버그: 수평 단면 (J2 축 평면) — y-스택 체결 검증용 (임시 도구)
// openscad -o sec.png --camera=... -D J2s=0 -D J3s=-45 tools/dbg_section.scad
include <../config/parameters.scad>
use <../assembly/assembly.scad>

J2s = 0;    // 단면은 z = J2 축 높이 — j2=0이면 팔 전장이 단면에 들어온다
J3s = -45;
sec_z = 0;  // 단면 z 오프셋 (J2 축 기준)

// vsec=true → J1 수직 단면 (x-z 평면, y=0), 아니면 J2 축 수평 단면
vsec = false;
intersection() {
    robot(0, J2s, J3s, 0, false, 3.2, true, false);
    if (vsec)
        translate([-600, -1, -200]) cube([1200, 2, 600]);
    else
        translate([-600, -600, j1_ring_h + tower_j2_h + sec_z - 1])
            cube([1200, 1200, 2]);
}
