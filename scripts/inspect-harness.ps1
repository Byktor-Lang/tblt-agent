#Requires -Version 7
# scripts/inspect-harness.ps1
# Inspector Evidence-Anchoring Harness — ADR 0029 — SSD §22
#
# Trusted-executor harness: drives tblt-inspector as a Read-only claude -p subprocess,
# verifies evidence anchors in code, writes the Gate-B marker with written_by:"harness".
# Gate B opens only on a harness-written marker (§22.2).
#
# Distribution-repo product — synced downstream via sync-agent-repo.ps1.
# The sync script itself is dev-repo-only and NOT synced.
#
# Usage (teacher-run):
#   pwsh -File scripts/inspect-harness.ps1 -SessionId <session_id>
# Dot-source for conformance testing (no subprocess launched):
#   . scripts/inspect-harness.ps1
#
# Build note (ADR 0013): rebuilt one criterion at a time — criteria 12.1–12.10.
# Current state: tracer bullet 12.2 (Normalize-AnchorText + Test-AnchorSubstring).

param(
    [string]$SessionId  = '',
    [string]$ConfigRoot = '',          # optional; defaults to SPANISH_TBLT_LOG_DIR or ~/Documents/spanish-tblt
    [switch]$LoadFunctionsOnly         # dot-source-safe: define functions without invoking the harness
)

$ErrorActionPreference = 'Stop'

# ════════════════════════════════════════════════════════════════════════════
# Anchor normalization + substring verification (§22.4 Guard 1 — criterion 12.2)
# ════════════════════════════════════════════════════════════════════════════

function Normalize-AnchorText {
    <#
    .SYNOPSIS
    Normalize text for anchor substring verification (ADR 0029 §3 Guard 1).
    Steps: decode HTML entities, strip tags, collapse whitespace, trim, lowercase.
    Accent-preserving: .ToLower() keeps accented characters (e.g. 'É' stays 'É'→'é').
    #>
    param([Parameter(Mandatory)][string]$Text)
    # Decode HTML entities (&amp; → &, &lt; → <, &oacute; → ó, &#233; → é, etc.)
    $t = [System.Net.WebUtility]::HtmlDecode($Text)
    # Strip HTML tags
    $t = $t -replace '<[^>]+>', ''
    # Collapse whitespace (space, tab, CR, LF → single space)
    $t = $t -replace '[ \t\r\n]+', ' '
    $t = $t.Trim()
    # Case-insensitive; accent-preserving (.ToLower preserves accented characters)
    $t.ToLower()
}

function Test-AnchorSubstring {
    <#
    .SYNOPSIS
    Verify that a normalized evidence quote is a substring of the normalized source
    file content. Returns $true if found, $false if not (§22.4, §22.2).
    Both sides normalized before comparison.
    #>
    param(
        [Parameter(Mandatory)][string]$Quote,
        [Parameter(Mandatory)][string]$SourceContent
    )
    $normQuote  = Normalize-AnchorText -Text $Quote
    $normSource = Normalize-AnchorText -Text $SourceContent
    $normSource.Contains($normQuote)
}

function Test-AnchorMinLength {
    <#
    .SYNOPSIS
    Guard 2 (§22.4): each normalized quote must be ≥ 40 characters.
    Returns $true if the quote meets the minimum length; $false otherwise.
    #>
    param([Parameter(Mandatory)][string]$Quote)
    $norm = Normalize-AnchorText -Text $Quote
    $norm.Length -ge 40
}

function Test-AnchorDistinctness {
    <#
    .SYNOPSIS
    Guard 3 (§22.4): no two criteria may cite the identical normalized quote.
    Accepts a list of quote strings; returns $true if all are distinct, $false
    if any two normalize to the same string.
    #>
    param([Parameter(Mandatory)][string[]]$Quotes)
    $normalized = @($Quotes | ForEach-Object { Normalize-AnchorText -Text $_ })
    $uniqueCount = ($normalized | Sort-Object -Unique).Count
    $uniqueCount -eq $normalized.Count
}

function Test-AnchorsByType {
    <#
    .SYNOPSIS
    Per-criterion-type anchor rules (§22.4, criterion 12.5).
    Validates a single anchor record against its criterion type.
    Returns a hashtable: @{ ok=$bool; reason=$string }.

    Criterion classes and required anchor shape:
      Layer A (criterion_id starts 'A'): always required; {criterion_id, score, source_file,
          evidence_quote}; evidence_quote verified as substring of source_file content.
      Layer B B1–B4 (criterion_id in 'B1'..'B4'): same as Layer A.
      Layer B B5 (criterion_id 'B5'): manifest locator — anchor must carry a
          'manifest_locator' key matching 'paso_structure.count_in_last_5_sessions';
          suppressed (no anchor required) in bootstrap state (denominator=24).
      Kill criteria (criterion_id starts 'K'): anchor required ONLY when score='triggered';
          if score='passed', no anchor needed (returns ok=$true).

    Parameters:
      $Anchor       - hashtable: the single anchor record from the inspector output.
      $SourceFiles  - hashtable: { filename => content } for substring verification.
      $Denominator  - int: 24=bootstrap, 27=full (for B5 suppression logic).
      $Triggered    - bool: for kill criteria, whether this criterion fired.
    #>
    param(
        [Parameter(Mandatory)][hashtable]$Anchor,
        [Parameter(Mandatory)][hashtable]$SourceFiles,
        [int]$Denominator = 27,
        [bool]$Triggered  = $false
    )

    $id = $Anchor['criterion_id']
    if (-not $id) { return @{ ok=$false; reason='missing criterion_id' } }

    # ── Kill criteria (K1–K5): anchor only when triggered ──
    if ($id -match '^K') {
        $score = $Anchor['score']
        if ($score -eq 'passed' -or -not $Triggered) { return @{ ok=$true; reason='kill_not_triggered' } }
        # triggered: requires evidence_quote
        if (-not $Anchor['evidence_quote']) { return @{ ok=$false; reason='kill_triggered_missing_quote' } }
        $src = $Anchor['source_file']
        if (-not $SourceFiles.ContainsKey($src)) { return @{ ok=$false; reason="source_file_not_found: $src" } }
        if (-not (Test-AnchorSubstring -Quote $Anchor['evidence_quote'] -SourceContent $SourceFiles[$src])) {
            return @{ ok=$false; reason='kill_quote_not_substring' }
        }
        if (-not (Test-AnchorMinLength -Quote $Anchor['evidence_quote'])) {
            return @{ ok=$false; reason='kill_quote_too_short' }
        }
        return @{ ok=$true; reason='kill_triggered_verified' }
    }

    # ── B5 (Structural freshness): manifest locator; suppressed in bootstrap ──
    if ($id -eq 'B5') {
        if ($Denominator -eq 24) { return @{ ok=$true; reason='B5_bootstrap_suppressed' } }
        # full state: requires manifest_locator field
        $loc = $Anchor['manifest_locator']
        if (-not $loc) { return @{ ok=$false; reason='B5_missing_manifest_locator' } }
        if ($loc -ne 'paso_structure.count_in_last_5_sessions') {
            return @{ ok=$false; reason="B5_wrong_locator: $loc" }
        }
        return @{ ok=$true; reason='B5_locator_verified' }
    }

    # ── Layer A (A1–A4) and Layer B B1–B4: always require evidence_quote ──
    if ($id -match '^[AB][1-4]?$' -or $id -match '^A') {
        $quote = $Anchor['evidence_quote']
        if (-not $quote) { return @{ ok=$false; reason='missing_evidence_quote' } }
        $src = $Anchor['source_file']
        if (-not $src)                           { return @{ ok=$false; reason='missing_source_file' } }
        if (-not $SourceFiles.ContainsKey($src)) { return @{ ok=$false; reason="source_file_not_found: $src" } }
        if (-not (Test-AnchorSubstring -Quote $quote -SourceContent $SourceFiles[$src])) {
            return @{ ok=$false; reason='quote_not_substring' }
        }
        if (-not (Test-AnchorMinLength -Quote $quote)) {
            return @{ ok=$false; reason='quote_too_short' }
        }
        return @{ ok=$true; reason='verified' }
    }

    return @{ ok=$false; reason="unrecognized_criterion_id: $id" }
}

function Invoke-AnchorVerification {
    <#
    .SYNOPSIS
    Run the full anchor verification pipeline for a set of anchors (§22.5 / criterion 12.6).
    Applies all three guards (12.2 substring, 12.3 min-length, 12.4 distinctness) and
    per-criterion-type rules (12.5) to every anchor. Returns a hashtable:
      @{ ok=$bool; failures=[string[]]; verifiedAnchors=[hashtable[]] }
    Marker is written by the caller ONLY when ok=$true (anchor verification before verdict).
    #>
    param(
        [Parameter(Mandatory)][hashtable[]]$Anchors,
        [Parameter(Mandatory)][hashtable]$SourceFiles,
        [int]$Denominator = 27,
        [hashtable]$TriggeredKills = @{}   # { criterion_id => $true/$false }
    )
    $failures = [System.Collections.Generic.List[string]]::new()

    # Per-criterion-type check (covers 12.2 substring + per-type rules 12.5)
    foreach ($anchor in $Anchors) {
        $triggered = $false
        $cid = $anchor['criterion_id']
        if ($cid -and $TriggeredKills.ContainsKey($cid)) { $triggered = $TriggeredKills[$cid] }
        $result = Test-AnchorsByType -Anchor $anchor -SourceFiles $SourceFiles `
                                     -Denominator $Denominator -Triggered $triggered
        if (-not $result.ok) { $failures.Add("$($cid): $($result.reason)") }
    }

    # Min-length guard (12.3) — applied to every evidence_quote present
    foreach ($anchor in $Anchors) {
        $q = $anchor['evidence_quote']
        if ($q -and -not (Test-AnchorMinLength -Quote $q)) {
            $failures.Add("$($anchor['criterion_id']): quote_too_short")
        }
    }

    # Distinctness guard (12.4) — across all evidence_quotes in this verification run
    $quotes = @($Anchors | Where-Object { $_['evidence_quote'] } | ForEach-Object { $_['evidence_quote'] })
    if ($quotes.Count -gt 0 -and -not (Test-AnchorDistinctness -Quotes $quotes)) {
        $failures.Add('distinctness_violation')
    }

    if ($failures.Count -gt 0) {
        return @{ ok=$false; failures=@($failures); verifiedAnchors=@() }
    }
    return @{ ok=$true; failures=@(); verifiedAnchors=$Anchors }
}

function Invoke-SafeWriteInfraError {
    <#
    .SYNOPSIS
    ADR 0007 + F5 infra-failure path for subprocess errors (§22.5 / criterion 12.10).
    Subprocess/infra failure (claude -p auth/network/crash/unparseable JSON) is NOT
    inspection_unverified — it is routed through the ADR 0007 + F5 safe_write stack:
    transient-retry-then-quarantine, raw error to quarantine/, no marker written.
    This function writes the raw error to the quarantine path (the F5 Layer 2 path).
    Returns: @{ status='infra_failure'; quarantinePath=$path }
    #>
    param(
        [Parameter(Mandatory)][string]$ConfigRoot,
        [Parameter(Mandatory)][string]$CourseId,
        [Parameter(Mandatory)][string]$ErrorDetail
    )
    $quarantinePath = "$ConfigRoot\quarantine\${CourseId}_pending_log_writes.jsonl"
    $entry = [ordered]@{
        event_type = 'inspect_harness_infra_failure'
        detail     = $ErrorDetail
        written_at = (Get-Date -Format 'o')
    }
    # F5 Layer 2 behavior: append raw error to quarantine file
    # (safe_write() retry/quarantine stack is declared on tblt-orchestrator.md)
    $json = $entry | ConvertTo-Json -Compress
    Add-Content -Path $quarantinePath -Value $json -Encoding utf8
    return @{ status='infra_failure'; quarantinePath=$quarantinePath }
}

function Invoke-InspectorWithRetry {
    <#
    .SYNOPSIS
    One-retry anchor-verification state machine (§22.5 / criteria 12.8–12.9).
    Simulates two inspector invocations (attempt 1 + one retry on anchor failure).
    Returns: @{ status='verified'|'inspection_unverified'|'infra_failure';
                marker=$marker_or_null; subprocessRunCount=$n; failureReason=$str }

    Status values:
      'verified'             — all anchors passed; marker written; OK to trust verdict.
      'inspection_unverified'— anchor failure on both attempts; no marker; distinct from
                               pedagogical ESCALATE (§22.5 / criterion 12.9).
      'infra_failure'        — subprocess/infra error; routed to ADR 0007 + F5; NOT
                               inspection_unverified (criterion 12.10).

    Parameters:
      $GetAnchorsAttempt1 / $GetAnchorsAttempt2  — scriptblocks that simulate the inspector
         subprocess returning an anchors list. Return $null to simulate infra failure.
      $SourceFiles, $Denominator   — forwarded to Invoke-AnchorVerification.
      $Verdict, $SessionId         — forwarded to New-InspectionMarker on success.
    #>
    param(
        [Parameter(Mandatory)][scriptblock]$GetAnchorsAttempt1,
        [Parameter(Mandatory)][scriptblock]$GetAnchorsAttempt2,
        [Parameter(Mandatory)][hashtable]$SourceFiles,
        [string]$SessionId   = 'sess-retry',
        [string]$Verdict     = 'CONVERGED',
        [int]$Denominator    = 27
    )
    $runCount = 0

    # ── Attempt 1 ──
    $runCount++
    $anchors1 = & $GetAnchorsAttempt1
    if ($null -eq $anchors1) {
        # Infra failure on attempt 1 — reuse ADR 0007 path (12.10)
        return @{ status='infra_failure'; marker=$null; subprocessRunCount=$runCount; failureReason='infra_attempt_1' }
    }
    $ver1 = Invoke-AnchorVerification -Anchors @($anchors1) -SourceFiles $SourceFiles -Denominator $Denominator
    if ($ver1.ok) {
        $marker = New-InspectionMarker -SessionId $SessionId -Verdict $Verdict `
                                       -VerifiedAnchors @($anchors1) -Denominator $Denominator
        return @{ status='verified'; marker=$marker; subprocessRunCount=$runCount; failureReason=$null }
    }

    # ── Attempt 2 (one retry on anchor failure; artifact unchanged — not re-routed to activity-specialist) ──
    $runCount++
    $anchors2 = & $GetAnchorsAttempt2
    if ($null -eq $anchors2) {
        # Infra failure on retry — still ADR 0007 path (12.10)
        return @{ status='infra_failure'; marker=$null; subprocessRunCount=$runCount; failureReason='infra_attempt_2' }
    }
    $ver2 = Invoke-AnchorVerification -Anchors @($anchors2) -SourceFiles $SourceFiles -Denominator $Denominator
    if ($ver2.ok) {
        $marker = New-InspectionMarker -SessionId $SessionId -Verdict $Verdict `
                                       -VerifiedAnchors @($anchors2) -Denominator $Denominator
        return @{ status='verified'; marker=$marker; subprocessRunCount=$runCount; failureReason=$null }
    }

    # ── Both attempts failed — inspection_unverified (Error); no marker written ──
    # Bound: ≤ 4 subprocess runs per session (2 anchor-verify attempts × 2 pedagogical rounds).
    # This function covers the per-round anchor retry (2 runs); the caller enforces the session bound.
    return @{ status='inspection_unverified'; marker=$null; subprocessRunCount=$runCount;
              failureReason="anchor_failure_both_attempts: $($ver2.failures -join '; ')" }
}

function New-InspectionMarker {
    <#
    .SYNOPSIS
    Build the Gate-B marker object (§22.2 / criterion 12.7).
    The harness writes this after all anchors verify — never the subprocess.
    written_by is hardcoded 'harness' (proof of trusted-executor provenance).
    #>
    param(
        [Parameter(Mandatory)][string]$SessionId,
        [Parameter(Mandatory)][string]$Verdict,
        [Parameter(Mandatory)][hashtable[]]$VerifiedAnchors,
        [hashtable]$ArtifactHashes = @{},
        [string]$FrameworkHash     = '',
        [int]$Denominator          = 27
    )
    [ordered]@{
        session_id         = $SessionId
        written_by         = 'harness'                   # §22.2 provenance field
        evaluation_round   = 1
        evaluated_at       = (Get-Date -Format 'o')
        verdict            = $Verdict
        denominator        = $Denominator
        artifacts_hashes   = $ArtifactHashes
        framework_hash     = $FrameworkHash
        verified_anchors   = @($VerifiedAnchors | ForEach-Object {
            [ordered]@{
                criterion_id    = $_['criterion_id']
                source_file     = $_['source_file']
                anchor_type     = if ($_['evidence_quote']) { 'quote' } else { 'locator' }
            }
        })
    }
}

# ════════════════════════════════════════════════════════════════════════════
# Subprocess invocation contract (SS22.3 / criterion 12.1)
#
# When the main harness runs (SessionId supplied), it drives the inspector as:
#   claude -p --allowedTools Read --system-prompt <tblt-inspector.md> <artifact-paths...>
#
# Key properties enforced by construction:
#   - --allowedTools Read : Write NOT granted; inspector cannot write the marker even if
#                           it tried — self-attestation closed at capability level (SS22.3).
#   - System prompt = tblt-inspector.md : single source of truth; typed invocation header
#                                         built by the harness on this path (ADR 0016).
#   - Artifact paths passed, NOT inlined content : inspector reads files itself; quotes
#                                                  come from files actually opened (SS22.3).
#
# The live claude -p call is out of RED->GREEN (SS22.7 / criterion 12.17) — validated by a
# teacher-run golden smoke run, then covered by adversarial injection.
# ════════════════════════════════════════════════════════════════════════════

function Invoke-HarnessWithRetry {
    <#
    .SYNOPSIS
    Live harness retry machine (§22.5 / criteria 12.1–12.10).
    Drives the inspector as a claude -p subprocess (--allowedTools Read), verifies anchors
    in code, and — only on success — builds the Gate-B marker.
    Returns: @{ status='verified'|'inspection_unverified'|'infra_failure';
                marker=$null_or_marker; verdict=$null_or_str;
                subprocessRunCount=$n; failureReason=$null_or_str }

    Distinct failure modes (ADR 0029 §6):
      'infra_failure'       — subprocess crash / auth / network / unparseable JSON;
                              route to ADR 0007 + F5 quarantine; NOT inspection_unverified.
      'inspection_unverified'— anchors failed on both attempts; distinct from pedagogical ESCALATE.

    --system-prompt passes tblt-inspector.md as the subprocess system prompt (ADR 0016 typed
    header is built into $InvocationPrompt by the caller). --allowedTools Read closes
    self-attestation at the capability level (§22.3 / criterion 12.1, 12.7).
    #>
    param(
        [Parameter(Mandatory)][string]$InvocationPrompt,
        [Parameter(Mandatory)][string]$InspectorSystemPromptContent,
        [Parameter(Mandatory)][hashtable]$SourceFiles,
        [string]$SessionId   = '',
        [int]$Denominator    = 27,
        [int]$MaxAttempts    = 2   # ≤4 subprocess runs per session (2 anchor retries × 2 ped. rounds)
    )

    $runCount = 0

    for ($a = 1; $a -le $MaxAttempts; $a++) {
        $runCount++

        # ── Subprocess call ────────────────────────────────────────────────
        $response  = $null
        $infraErr  = $null
        try {
            # Read-only: subprocess cannot write the marker even if it tried (§22.3 / 12.7)
            $raw = $InvocationPrompt |
                   & claude -p --allowedTools 'Read' --system-prompt $InspectorSystemPromptContent 2>&1 |
                   Out-String
            if ($LASTEXITCODE -ne 0) { throw "claude -p exited $LASTEXITCODE" }
            # Extract outermost JSON object from response text
            $startJ = $raw.IndexOf('{')
            $endJ   = $raw.LastIndexOf('}')
            if ($startJ -lt 0 -or $endJ -le $startJ) { throw 'no JSON object in response' }
            $obj = $raw.Substring($startJ, $endJ - $startJ + 1) | ConvertFrom-Json -AsHashtable -ErrorAction Stop
            if ($null -eq $obj.anchors) { throw 'anchors field missing in response' }
            $response = $obj
        } catch { $infraErr = $_ }

        # Infra failure → immediate return (no retry); route to ADR 0007 + F5 (criterion 12.10)
        if ($infraErr) {
            return @{ status='infra_failure'; marker=$null; verdict=$null;
                      subprocessRunCount=$runCount; failureReason=$infraErr.Exception.Message }
        }

        # ── Anchor verification before trusting verdict (criterion 12.6) ──
        $ver = Invoke-AnchorVerification -Anchors @($response.anchors) `
                                         -SourceFiles $SourceFiles `
                                         -Denominator $Denominator
        if ($ver.ok) {
            $verdict = if ($response.verdict) { [string]$response.verdict } else { 'CONVERGED' }
            $marker  = New-InspectionMarker -SessionId $SessionId -Verdict $verdict `
                           -VerifiedAnchors @($response.anchors) -Denominator $Denominator
            return @{ status='verified'; marker=$marker; verdict=$verdict;
                      subprocessRunCount=$runCount; failureReason=$null }
        }

        # Anchor failure on final attempt → inspection_unverified (distinct from infra; criterion 12.9)
        if ($a -eq $MaxAttempts) {
            return @{ status='inspection_unverified'; marker=$null; verdict=$null;
                      subprocessRunCount=$runCount;
                      failureReason="anchor_failure_both_attempts: $($ver.failures -join '; ')" }
        }
        # Otherwise: loop to attempt 2 (artifact unchanged; not re-routed to activity-specialist)
    }
}

function Get-InspectorSystemPromptPath {
    <#
    .SYNOPSIS
    Returns the path to tblt-inspector.md used as the claude -p system prompt (12.1 / SS22.3).
    The instruction file itself is the system prompt — single source of truth (ADR 0016).
    #>
    param([string]$RepoRoot = $PSScriptRoot)
    $root = if ($RepoRoot -match 'scripts$') { Split-Path $RepoRoot -Parent } else { $RepoRoot }
    Join-Path $root '.claude\agents\tblt-inspector.md'
}

# ════════════════════════════════════════════════════════════════════════════
# Main harness entrypoint — teacher-run: pwsh -File scripts/inspect-harness.ps1 -SessionId <id>
# Not when dot-sourced for testing; not when -LoadFunctionsOnly is set (§22.3 / criterion 12.1).
# Live claude -p call validated by teacher golden smoke run, then adversarial injection (12.17).
# ════════════════════════════════════════════════════════════════════════════
if ($SessionId -and -not $LoadFunctionsOnly) {

    # ── 1. Resolve config root (SSD §3.1) ────────────────────────────────
    $root = if ($ConfigRoot)                  { $ConfigRoot }
            elseif ($env:SPANISH_TBLT_LOG_DIR) { $env:SPANISH_TBLT_LOG_DIR }
            else                               { Join-Path $HOME 'Documents\spanish-tblt' }

    $sessionStateFile = Join-Path $root "sessions\$SessionId.json"
    $sessionDir       = Join-Path $root "sessions\$SessionId"
    $markerPath       = Join-Path $sessionDir 'inspector_run_marker.json'

    if (-not (Test-Path $sessionDir)) {
        Write-Error "Session directory not found: $sessionDir"; exit 1
    }

    # ── 2. Load session state ─────────────────────────────────────────────
    $gapType  = $null     # determined below
    $courseId = 'unknown'
    if (Test-Path $sessionStateFile) {
        try {
            $ss = Get-Content $sessionStateFile -Raw | ConvertFrom-Json
            # gap_type may be top-level, or task_type inside scb (older session format)
            if ($ss.gap_type)                            { $gapType  = [string]$ss.gap_type }
            elseif ($ss.scb -and $ss.scb.task_type) {
                $gapType = if ([string]$ss.scb.task_type -match 'resource') { 'resource' } else { 'oral' }
            }
            if ($ss.course_id) { $courseId = [string]$ss.course_id }
        } catch { Write-Warning "Could not parse session state; will auto-detect gap_type from files." }
    }

    # ── 3. Locate Round 1 artifacts ───────────────────────────────────────
    $abYaml     = Join-Path $sessionDir 'ab_representation.yaml'
    $teacherKey = Join-Path $sessionDir 'teacher_key.html'

    # Auto-detect gap_type from files on disk when session state doesn't carry it
    if (-not $gapType) {
        $gapType = if (Test-Path "$sessionDir\student_a.html") { 'resource' } else { 'oral' }
    }

    # Use @() explicit array construction to prevent PowerShell scalar-unboxing on single-element arrays
    $students = if ($gapType -eq 'resource') {
                    @("$sessionDir\student_a.html", "$sessionDir\student_b.html")
                } else {
                    @("$sessionDir\student.html")
                }

    # Auto-discover Round 1 manifest (YAML or JSON; try common filenames)
    $manifestPath = @('round_1_manifest.json', 'round1_manifest.yaml', 'round1_manifest.json',
                      'r1_manifest.json', 'manifest.json', 'manifest.yaml') |
        ForEach-Object { Join-Path $sessionDir $_ } |
        Where-Object   { Test-Path $_ } |
        Select-Object  -First 1

    # Validate required artifacts present (force array with @() before + to prevent string concat)
    $required = @($students) + @($abYaml, $teacherKey)
    $missing  = @($required | Where-Object { -not (Test-Path $_) })
    if ($missing.Count -gt 0) {
        Write-Error "Missing artifacts:`n$($missing -join [Environment]::NewLine)"; exit 1
    }

    # ── 4. Load source file contents for anchor substring verification ────
    $srcFiles = @{}
    foreach ($f in @($required)) { $srcFiles[(Split-Path $f -Leaf)] = Get-Content $f -Raw }
    if ($manifestPath) { $srcFiles[(Split-Path $manifestPath -Leaf)] = Get-Content $manifestPath -Raw }

    # ── 5. Determine denominator (/24 bootstrap vs /27 full; ADR 0009/0024) ─
    $denominator = 27
    if ($manifestPath) {
        try {
            $mf = Get-Content $manifestPath -Raw | ConvertFrom-Json -ErrorAction Stop
            if ($null -eq $mf.novelty_signature) { $denominator = 24 }
        } catch {}
    }

    # ── 6. Build typed invocation prompt (ADR 0016 header + artifact paths) ─
    $artifactList = ($required + @($manifestPath | Where-Object { $_ })) -join "`n"
    $invocationPrompt = @"
mode: pipeline
suppress_phase_0: true
preserve_phase_neg1: true
session_payload:
  session_id: $SessionId
  gap_type: $gapType
  invocation_context: harness

You are invoked by scripts/inspect-harness.ps1 (trusted executor — ADR 0029).
Use your Read tool on each artifact path. Do NOT assume content — read the files.

$artifactList

Per your Evidence-Anchored Output Contract, return a JSON object (nothing after it):
{
  "anchors": [
    { "criterion_id": "A1", "score": <0-3>, "source_file": "<filename.html>", "evidence_quote": "<verbatim ≥40 chars>" },
    { "criterion_id": "B5", "manifest_locator": "paso_structure.count_in_last_5_sessions" }
  ],
  "verdict": "CONVERGED|FEEDBACK|ESCALATE",
  "feedback": "<revision instructions if FEEDBACK or ESCALATE, else null>"
}
Kill criteria: include anchor record only when triggered (score: "triggered"). Passed kills omitted.
B5 omitted in bootstrap state (/24 denominator — fewer than 5 sessions in course log).
"@

    # ── 7. Load inspector as system prompt ───────────────────────────────
    $inspectorFile    = Get-InspectorSystemPromptPath -RepoRoot (Split-Path $PSScriptRoot -Parent)
    $inspectorContent = Get-Content $inspectorFile -Raw

    # ── 8. Run with retry machine (Invoke-HarnessWithRetry) ──────────────
    $result = Invoke-HarnessWithRetry `
        -InvocationPrompt              $invocationPrompt `
        -InspectorSystemPromptContent  $inspectorContent `
        -SourceFiles                   $srcFiles `
        -SessionId                     $SessionId `
        -Denominator                   $denominator

    # ── 9. Handle result ─────────────────────────────────────────────────
    switch ($result.status) {
        'verified' {
            $result.marker | ConvertTo-Json -Depth 10 | Set-Content $markerPath -Encoding utf8
            Write-Host "Inspection verified. Marker written to:"
            Write-Host "  $markerPath"
            Write-Host "  written_by: harness  |  verdict: $($result.verdict)  |  subprocess runs: $($result.subprocessRunCount)"
            exit 0
        }
        'inspection_unverified' {
            Write-Host "INSPECTION UNVERIFIED -- anchor verification failed on both attempts."
            Write-Host "Gate B remains closed. Reason: $($result.failureReason)"
            Write-Host "Re-run the harness, or fall back to the ADR 0027 path."
            exit 2
        }
        'infra_failure' {
            $null = Invoke-SafeWriteInfraError -ConfigRoot $root -CourseId $courseId `
                        -ErrorDetail "harness_infra_failure: $($result.failureReason)"
            Write-Host "Infrastructure failure -- claude -p subprocess failed."
            Write-Host "Error logged to quarantine ($root\quarantine\). Gate B remains closed."
            Write-Host "Reason: $($result.failureReason)"
            exit 3
        }
    }
}
