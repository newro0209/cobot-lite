// 상완 (upper arm) — 꺾임 빔 + J3 크랭크 저널
// =====================================================================
// 측판 1형상 ×2 — 전 홀 관통 → 평행이동 장착 (플립 불요, 꺾임과 양립).
// 프로파일: 러그 3원 hull (무릎 +z 볼록) — 현(chord) = x축 0~L1.
// 홀 세트 (양 측판 동일):
//   J2 (0):    6805ZZ 압입 ID 37 — +Y: 크랭크 보스 OD 25 저널
//   팔꿈치(L1): 608ZZ 압입 ID 22 (통축 볼트 내륜 press → 하완과 회전, 외륜 고정)
//   스탠드오프 M4 ×2: 현 아래 벨트
//   J3 리미트 스위치 M2 ×2: (L1-45, 0) — +Y 측판 내면 (forearm 베인 감지)
include <../config/parameters.scad>
use <../lib/utils.scad>

// 2D 관통 피처만 (베어링 포켓은 3D — bearing_pocket_cut)
module ua_plate2d() {
    difference() {
        bent_band2d([[0, 0], [ua_bend_pos * L1, knee_h(L1, ua_bend_pos, ua_bend_deg, ua_kink_off)], [L1, 0]], BRG_608ZZ[1] + 2, ua_body_hw);
        // 스탠드오프 M4 ×2 (현 아래 벨트, 굴절 따라 상승 — 밴드 내부 유지)
        for (x = ua_standoff_xa) translate([x, ua_standoff_pos(x)]) circle(d = m4_standoff_d);
        // J3 리미트 스위치 M2 ×2 (x 피치)
        for (s = [-1, 1])
            translate([L1 - elbow_ls_x + s * ls_hole_pitch / 2, 0])
                circle(d = ls_hole_d);
    }
}

module ua_plate(col = undef) {
    apply_part_color(col) difference() {
        linear_extrude(arm_plate_t) ua_plate2d();
        // J2 6805ZZ 포켓 (+Y 크랭크 저널)
        bearing_pocket_cut(BRG_6805ZZ, arm_plate_t);
        // 팔꿈치 608ZZ 포켓 (외륜 고정, 내륜 = 통축 볼트 press)
        translate([L1, 0, 0]) bearing_pocket_cut(BRG_608ZZ, arm_plate_t);
    }
}

// piece: "full"(측판 ×2 조립 배치) | "plate"(단품)
module upper_arm(piece = "full", col = undef, col2 = undef) {
    plate2_col = is_undef(col2) ? col : col2;
    if (piece == "full") {
        // 베어링 포켓을 양 측판 모두 외측 개방으로 통일 → -Y는 y-미러(플립) 장착.
        // 관통 피처는 중앙면 대칭이라 미러 불변, 포켓만 대칭 외측화 (608 시트 대칭).
        translate([0, ua_out_y, 0]) rotate([90, 0, 0]) ua_plate(col);                       // +Y
        mirror([0, 1, 0]) translate([0, ua_out_y, 0]) rotate([90, 0, 0]) ua_plate(plate2_col); // -Y 미러
    }
    else ua_plate(col);
}

upper_arm();
