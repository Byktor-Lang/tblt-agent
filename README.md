# TBLT Agent — Task-Based Language Teaching Activity Generator

A multi-agent pipeline that generates complete, standards-aligned TBLT lesson packages for 9th-grade Spanish. Built on Claude Code's sub-agent framework; each run produces student-ready HTML artifacts, teacher guides, and a cross-session activity log.

## What's in this repo

| Path | Contents |
|------|----------|
| `.claude/agents/` | The six pipeline agent instruction files (orchestrator, activity specialist, inspector, pre-task specialist, reflective specialist, retrospective analyst) |
| `frameworks/` | Three shared framework files the agents use at runtime: Lee-Schell (F2), shared taxonomy (F4), HTML structure schema (F6) |
| `profiles/courses/` | One Markdown profile per course (topic units, vocabulary scope, standards alignment) |
| `profiles/classes/` | One Markdown profile per class section (student level, size, pacing notes) |
| `sessions/` | Generated lesson packages — one subdirectory per session, each containing student HTML, teacher HTML, manifests, and YAML |
| `scripts/` | Teacher-run helper scripts — `inspect-harness.ps1` drives the inspector as a trusted subprocess and writes the Gate-B evidence marker (ADR 0029) |
| `logs/` | Per-course activity log (Markdown) and cross-course telemetry (JSONL) |
| `reports/` | Retrospective analyst HTML reports (one per retrospective run) |
| `quarantine/` | Transient write-failure artifacts; normally empty; created automatically by the orchestrator |

## Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/claude-code) installed and authenticated
- An Anthropic API key in your environment (`ANTHROPIC_API_KEY`)
- PowerShell 7+ (`pwsh`) — required to run the orchestrator's helper scripts

## Quick start

1. Clone this repo and open it in Claude Code (VS Code extension or CLI).
2. Open a Claude Code session in this directory.
3. Type a session prompt, for example:

   ```
   Run a full TBLT session for spanish_general, class 9A, topic: weekend plans.
   ```

4. The `tblt-orchestrator` agent takes over, delegates to the specialist agents, and writes all artifacts to `sessions/<session_id>/`.

## Course configuration

Each course needs two profile files:

- `profiles/courses/<slug>_profile.md` — topic units, vocabulary scope, communicative functions
- `profiles/classes/<slug>_class_profile.md` — class size, level descriptors, pacing

Copy an existing profile pair and edit to match your course. The orchestrator reads both at session start.

## Repository relationship

This repo is the **working distribution** — the files a user needs to run the pipeline.

The companion repo [`tblt-plan`](https://github.com/Byktor-Lang/tblt-plan) is the **development repo**: it contains everything here plus the full planning corpus (PRD, SSD, ISSUES, ADRs, grilling sessions, conformance suites, and the build loop). That material is for the maintainer building and extending the pipeline; end users do not need it.

Updates flow from `tblt-plan` → `tblt-agent` via `scripts/sync-agent-repo.ps1` (in `tblt-plan`).
