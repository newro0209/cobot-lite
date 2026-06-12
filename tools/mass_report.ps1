# 부품 체적/질량/바운딩 박스 리포트 (MEC-007, MFG-004)
# ASCII STL에서 부호 있는 사면체 합으로 체적 계산.
# 질량 = 체적 × PETG-CF 밀도(1.30 g/cm³) × 유효 충전율(print_solidity)
param([double]$Density = 1.30, [double]$Solidity = 0.6)
$dir = Join-Path $PSScriptRoot "..\export\stl"
foreach ($f in Get-ChildItem $dir -Filter *.stl | Sort-Object Name) {
    $vol = 0.0
    $min = [double[]]@(1e9, 1e9, 1e9); $max = [double[]]@(-1e9, -1e9, -1e9)
    $tri = New-Object 'System.Collections.Generic.List[double[]]'
    foreach ($line in [IO.File]::ReadLines($f.FullName)) {
        $t = $line.Trim()
        if ($t.StartsWith("vertex")) {
            $p = $t.Split(" ", [StringSplitOptions]::RemoveEmptyEntries)
            $v = [double[]]@([double]$p[1], [double]$p[2], [double]$p[3])
            $tri.Add($v)
            for ($c = 0; $c -lt 3; $c++) {
                if ($v[$c] -lt $min[$c]) { $min[$c] = $v[$c] }
                if ($v[$c] -gt $max[$c]) { $max[$c] = $v[$c] }
            }
            if ($tri.Count -eq 3) {
                $a = $tri[0]; $b = $tri[1]; $c2 = $tri[2]
                $vol += ($a[0]*($b[1]*$c2[2]-$b[2]*$c2[1]) - $a[1]*($b[0]*$c2[2]-$b[2]*$c2[0]) + $a[2]*($b[0]*$c2[1]-$b[1]*$c2[0])) / 6.0
                $tri.Clear()
            }
        }
    }
    $cm3 = [math]::Abs($vol) / 1000.0
    $bb = "{0:f0}x{1:f0}x{2:f0}" -f ($max[0]-$min[0]), ($max[1]-$min[1]), ($max[2]-$min[2])
    "{0,-20} vol={1,8:f1} cm3  mass_solid={2,6:f0} g  mass_eff={3,6:f0} g  bbox={4}" -f $f.BaseName, $cm3, ($cm3*$Density), ($cm3*$Density*$Solidity), $bb
}
