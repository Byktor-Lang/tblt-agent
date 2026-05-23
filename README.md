# TBLT Agent Runtime

Agent instruction files and shared framework modules for the **Task-Based Language Teaching (TBLT) activity generator** — a five-agent pipeline that produces standards-aligned, gap-pair-based Spanish activities for 9th-grade learners.

## What's here

```
agents/
├── tblt-orchestrator.md
├── tblt-activity-specialist.md
├── tblt-inspector.md
├── tblt-pretask-specialist.md
└── tblt-reflective-specialist.md

frameworks/
├── lee-schell-framework.md
├── shared-taxonomy.md
└── html-structure-schema.md
```

## Pipeline overview

The orchestrator drives a three-round generation sequence through Gates A→D, delegating each round to a specialist agent via a typed invocation contract. The inspector evaluates Round 1 output against the Lee-Schell framework before Gate B opens. All rounds write to per-course activity logs and a cross-course telemetry feed via a retry/quarantine recovery stack.

Rounds generate:
- **Round 1 (Main Task):** HTML student/teacher files
- **Round 2 (Pre-Task):** `pretask_student.html` + `pretask_teacher.html`
- **Round 3 (Post-Task):** `posttask.html` + `posttask_teacher.html`

## Usage

These files are Claude agent instruction files (`.md` prompts). Load `tblt-orchestrator.md` as the entry-point agent in a Claude Code or Claude.ai multi-agent setup. The orchestrator delegates to the four specialist agents at the appropriate gates.

Runtime configuration (course profiles, class profiles, session state) lives outside this repo per the system design.
