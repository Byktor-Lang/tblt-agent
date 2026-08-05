$base = 'C:/Users/azuaje.MSMC/Documents/spanish-tblt'
$sessionDir = $base + '/sessions/s16-2026-05-23-family'

Write-Output '=== Session s16 Artifacts ==='
$items = Get-ChildItem $sessionDir | Sort-Object Name
foreach ($item in $items) {
    $msg = $item.Name + ' (' + $item.Length + ' bytes)'
    Write-Output $msg
}

Write-Output ''
Write-Output '=== Log Files ==='
$logfiles = @(
    'sessions/s16-2026-05-23-family.json',
    'spanish_general_activity_log.md',
    'spanish_general_diagnostic_log.jsonl',
    'cross_course_telemetry.jsonl'
)
foreach ($lf in $logfiles) {
    $p = $base + '/' + $lf
    if (Test-Path $p) {
        $linecount = (Get-Content $p).Count
        Write-Output ('EXISTS: ' + $lf + ' (' + $linecount + ' lines)')
    } else {
        Write-Output ('MISSING: ' + $lf)
    }
}
