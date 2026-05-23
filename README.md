# TBLT Agent Runtime

Agent instruction files and shared framework modules for the **Task-Based Language Teaching (TBLT) activity generator** — a five-agent pipeline that produces standards-aligned, gap-pair-based Spanish activities for 9th-grade learners.

## What's here

```
agents/
├── tblt-orchestrator.md          # Pipeline conductor: gates, session state, Phase −1→8
├── tblt-activity-specialist.md   # Round 1 — Main Task (gap-pair, A/B representation)
├── tblt-inspector.md             # Lee-Schell quality evaluation between Round 1 and Gate B
├── tblt-pretask-specialist.md    # Round 2 — Pre-Task (bridge exercise tied to gap structure)
└── tblt-reflective-specialist.md # Round 3 — Post-Task (writing task with register shift)

frameworks/
├── lee-schell-framework.md       # Externalized quality rubric (kill criteria + Layer A/B)
├── shared-taxonomy.md            # Canonical labels for paso structure, exercise types, genres
└── html-structure-schema.md      # Structural validation schema for all generated HTML
```

## Pipeline overview

The orchestrator drives a three-round generation sequence through Gates A→D, delegating each round to a specialist agent via a typed invocation contract. The inspector evaluates Round 1 output against the Lee-Schell framework before Gate B opens. All rounds write to per-course activity logs and a cross-course telemetry feed via a retry/quarantine recovery stack.

Rounds generate:
- **Round 1 (Main Task):** `ab_representation.yaml` + gap-type-conditional HTML student/teacher files
- **Round 2 (Pre-Task):** `pretask_student.html` + `pretask_teacher.html`
- **Round 3 (Post-Task):** `posttask.html` + `posttask_teacher.html`

## Usage

These files are Claude agent instruction files (`.md` prompts). Load `tblt-orchestrator.md` as the entry-point agent in a Claude Code or Claude.ai multi-agent setup. The orchestrator delegates to the four specialist agents at the appropriate gates.

Runtime configuration (course profiles, class profiles, session state) lives outside this repo per the system design.
