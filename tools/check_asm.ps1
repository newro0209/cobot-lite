# 간섭 검사 그리드 실행기 — 충돌 시 교집합 바운딩 박스 출력
# 사용: pwsh tools/check_asm.ps1
# check=1(체인∩고정부)은 베이스~어깨 제거로 폐지 — check=2(하완∩상완)만 기본 실행
param(
    [int[]]$Checks = @(2),
    [int[]]$J2 = @(-20, 0, 20, 40, 45),
    [int[]]$J3 = @(-80, -45, 0, 20)
)
$scad = "C:\Program Files\OpenSCAD\openscad.com"
$asm = Join-Path $PSScriptRoot "..\assembly\assembly.scad"
$tmp = Join-Path $env:TEMP "chk.stl"
$fail = 0

function Get-Bbox($path) {
    $min = [double[]]@([double]::MaxValue, [double]::MaxValue, [double]::MaxValue)
    $max = [double[]]@([double]::MinValue, [double]::MinValue, [double]::MinValue)
    foreach ($line in [IO.File]::ReadLines($path)) {
        if ($line -match 'vertex\s+(\S+)\s+(\S+)\s+(\S+)') {
            $p = @([double]$Matches[1], [double]$Matches[2], [double]$Matches[3])
            for ($c = 0; $c -lt 3; $c++) {
                if ($p[$c] -lt $min[$c]) { $min[$c] = $p[$c] }
                if ($p[$c] -gt $max[$c]) { $max[$c] = $p[$c] }
            }
        }
    }
    $dims = @($max[0]-$min[0], $max[1]-$min[1], $max[2]-$min[2])
    $degen = ($dims | Where-Object { $_ -lt 0.05 }).Count -gt 0
    return @{
        txt = ("X {0:f1}..{1:f1} Y {2:f1}..{3:f1} Z {4:f1}..{5:f1}" -f $min[0],$max[0],$min[1],$max[1],$min[2],$max[2])
        degen = $degen
    }
}

foreach ($chk in $Checks) {
    foreach ($a in $J2) {
        foreach ($b in $J3) {
            Remove-Item $tmp -ErrorAction SilentlyContinue
            $out = & $scad -D "check=$chk" -D "J2a=$a" -D "J3a=$b" -o $tmp $asm 2>&1 | Out-String
            $sz = (Get-Item $tmp -ErrorAction SilentlyContinue).Length
            if (($out -match 'empty') -or (-not $sz) -or ($sz -lt 200)) { continue }
            $bb = Get-Bbox $tmp
            $tag = if ($bb.degen) { "TOUCH(면접촉)" } else { "COLLIDE"; $script:fail++ }
            Write-Output "chk=$chk J2=$a J3=$b $tag $($bb.txt)"
        }
    }
}
Write-Output "done. real collisions: $fail"
