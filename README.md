# TBLT Agent Runtime

Agent instruction files and shared framework modules for the **Task-Based Language Teaching (TBLT) activity generator**. This five-agent pipeline produces standards-aligned, gap-pair-based Spanish activities for 9th-grade learners.

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

profiles/
└── courses/
    ├── spanish_general_profile.md
    └── spanish_health_profile.md

sessions/
├── s16-2026-05-23-family.json
└── s16-2026-05-23-family/
    ├── student_a.html
    ├── student_b.html
    ├── teacher_key.html
    ├── pretask_student.html
    ├── pretask_teacher.html
    ├── posttask.html
    ├── posttask_teacher.html
    └── ab_representation.yaml
```

Each folder under `sessions/` is one complete lesson package. The `.json` file is the session state (gate results, vocabulary list, grammar targets, task design). The HTML files are ready-to-use student and teacher materials; download the folder for a lesson and open the files in any browser.

## Pipeline overview

tblt-agent is an AI-powered multi-agent system for generating complete Task-Based Language Teaching (TBLT) lesson packages for Spanish language classrooms.

The project combines large language models with a structured pedagogical workflow to create communicative, standards-aligned materials focused on meaningful interaction and real-world language use. Instead of isolated exercises, the system generates cohesive lesson sequences that include tasks, vocabulary support, student activities, reflections, and pedagogical evaluation.

Each agent in the pipeline performs a specific instructional role, such as lesson planning, task generation, language scaffolding, quality review, or formatting.

Rounds generate:
- **Round 1 (Main Task):** HTML student/teacher files
- **Round 2 (Pre-Task):** `pretask_student.html` + `pretask_teacher.html`
- **Round 3 (Post-Task):** `posttask.html` + `posttask_teacher.html`

## Usage

These files are Claude agent instruction files (`.md` prompts). Load `tblt-orchestrator.md` as the entry-point agent in a Claude Code or Claude.ai multi-agent setup. The orchestrator delegates to the four specialist agents at the appropriate gates.
