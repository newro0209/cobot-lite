// 전체 조립 모델 (full assembly) — 간섭 확인용
// 관절 각도를 바꿔가며 간섭(특히 MEC-001c 후방 연장 ↔ 베이스/작업물)을 확인한다.
include <../config/parameters.scad>
use <../lib/utils.scad>

// 부품 추가 시 여기에 use <../parts/...> 로 포함

/* ===== 조립 자세 파라미터 ===== */
J1 = 0;   // 베이스 요(yaw), deg
J2 = 0;   // 어깨 피치(pitch), deg (0 = 수평)
J3 = 0;   // 팔꿈치 피치, deg
J4 = 0;   // 손목 롤(roll), deg

module assembly() {
    // TODO: parts/ 부품 작성 후 조립 트리 구성
    // 스켈레톤: 링크 중심선만 표시
    rotate([0, 0, J1]) {
        // 상완 (L1)
        rotate([0, -J2, 0]) {
            %cylinder(d = 10, h = L1);          // 상완 중심선
            // 후방 연장 (MEC-001c)
            %rotate([0, 180, 0]) cylinder(d = 10, h = rear_extension);
            translate([0, 0, L1])
                rotate([0, -J3, 0])
                    %cylinder(d = 8, h = L2);   // 하완 중심선
        }
    }
}

assembly();
