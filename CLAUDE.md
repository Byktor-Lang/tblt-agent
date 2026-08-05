# tblt-agent — runtime instructions

This repo is the **working distribution** of the TBLT activity generator. It contains the six pipeline agents, three shared framework files, course/class profiles, and generated session output. There is no planning corpus here — see the companion `tblt-plan` repo for ADRs, conformance suites, and the build loop.

## Directory map

| Path | Role |
|------|------|
| `.claude/agents/tblt-orchestrator.md` | Entry point — invoke this agent to run a session |
| `.claude/agents/tblt-activity-specialist.md` | Round 1: generates the main task A/B representation and HTML |
| `.claude/agents/tblt-inspector.md` | Round 1 quality gate (post-generation, pre-Gate B) |
| `.claude/agents/tblt-pretask-specialist.md` | Round 2: generates the pre-task artifact |
| `.claude/agents/tblt-reflective-specialist.md` | Round 3: generates the post-task reflection artifact |
| `.claude/agents/tblt-retrospective-analyst.md` | Phase 8 (opt-in): cross-session retrospective HTML report |
| `frameworks/lee-schell-framework.md` | F2 — Lee-Schell communicative framework (read-only at runtime) |
| `frameworks/shared-taxonomy.md` | F4 — shared activity taxonomy (read-only at runtime) |
| `frameworks/html-structure-schema.md` | F6 — HTML artifact structure schema (read-only at runtime) |
| `profiles/courses/` | Course profiles — one per course (read-only at runtime) |
| `profiles/classes/` | Class profiles — one per class section (read-only at runtime) |
| `sessions/` | Generated lesson packages (write) |
| `logs/` | Activity log and telemetry (write) |
| `reports/` | Retrospective HTML reports (write) |
| `quarantine/` | Transient write-failure artifacts (write; normally empty) |

## How to run a session

Open a Claude Code session in this directory and invoke the orchestrator:

```
Run a full TBLT session for <course_slug>, class <class_id>, topic: <topic>.
```

For a standalone pre-task only:

```
Run a standalone pre-task for <course_slug>, class <class_id>, topic: <topic>.
```

The orchestrator manages all delegation; you do not invoke the specialist agents directly.

## Adding a course

1. Create `profiles/courses/<slug>_profile.md` — topic units, vocabulary scope, communicative functions, standards alignment.
2. Create `profiles/classes/<slug>_class_profile.md` — class size, level descriptors, pacing preferences.
3. Create `logs/<slug>_activity_log.md` — empty file with the course header (the orchestrator will append to it).

## Write rules (for Claude)

- Agent files in `.claude/agents/` and framework files in `frameworks/` are **read-only at runtime** — never modify them during a session run.
- Write only to `sessions/`, `logs/`, `reports/`, and `quarantine/`.
- Profile files are **read-only** during a run; edit them outside of a session.
- This repo does not contain `planning/`, `.conformance/`, or `.claude/skills/`. Do not attempt to read them — they live in the companion `tblt-plan` repo.
