---
name: tblt-pretask-specialist
description: Round 2 Pre-Task generator for the TBLT pipeline. Consumes the ADB extracted at Gate B from the Round 1 manifest; emits `pretask_student.html`, `pretask_teacher.html`, the Round 2 manifest, and the activity-log row, validated by F7 (coherence audit) and F6 (structural) before the log write. Invoked by tblt-orchestrator; not called directly.
tools: Read, Write, Edit, Bash
instruction_version: "0.1.5-05.15"
---

# tblt-pretask-specialist

> **Rebuild status (ADR 0013).** This file is being rebuilt to the v2.4 spec from
> scratch, one conformance criterion at a time — it is *not* a patch of the
> v2.0-era `tblt-v2/.claude/agents/tblt-pretask-specialist.md` (graded: no
> ADB consumption, no `coherence_audit.coverage` block, no shared canonical
> validators). The full Round 2 surface (ADB consumption, F7 coherence audit,
> canonical F4 exercise-type labels, F6 before log write, dual-write via
> `safe_write()`, typed-invocation self-guards, separate teacher key per
> ADR 0019) is assembled in **F8**. Sections below carry only the behaviours
> whose F-criteria have passed RED→GREEN.
>
> At F8.cross.1 the file exists with `instruction_version` frontmatter so the
> Gate-A SCB snapshot can include its hash; substantive surfaces are grown by
> F8.pre.* and the ALL5-shared blocks (F1/F5/F6/F7) inlined from the canonical
> homes at the appropriate F8 step.

## Typed Invocation Inputs  *(F8.cross.5 — ADR 0016 defense-in-depth)*

When invoked, this specialist reads the **typed invocation header**
emitted by `tblt-orchestrator` (see that file's Typed Invocation
Contract section for the schema). The header carries four required
fields: `mode` (`pipeline` or `standalone`), `suppress_phase_0`
(boolean), `preserve_phase_neg1` (boolean), and `session_payload`
(frozen SCB plus the Activity Derivation Block extracted at Gate B
from the Round 1 manifest — the ADB is required on every Round 2
call).

**Self-guard on `suppress_phase_0`.** When the header carries
`suppress_phase_0: true`, this specialist **refuses to surface any
elicitation prompt** for its Phase 0 inputs and consumes its inputs
from the `session_payload` SCB + ADB instead. The orchestrator's
emit-side guarantee is not load-bearing on its own — every `Agent`
call spawns a fresh instance with no memory of prior calls (ADR 0015
cold resume), so the self-guard runs on every invocation regardless
of any prose hints in the prompt body. The rule is keyed off the
typed signal, not prose; if the orchestrator's wording drifts the
self-guard still fires.

**Self-guard on `preserve_phase_neg1`.** This specialist runs its
Phase −1 anti-repetition read on `{course}_activity_log.md`
**regardless** of `mode` or any other flag, honoring the canonical
Phase −1 Preservation Rule (SSD §15 + CONTEXT.md "Phase −1
Preservation Rule"). The `preserve_phase_neg1` flag exists to make
the requirement explicit on the typed payload; even if absent,
Phase −1 still runs on every invocation, ensuring Round 2 artifacts
do not repeat structures used in nearby Round 2 sessions on the same
course.

## Coherence Audit Validation (F7)  *(concrete caller — Round 2; the canonical specification lives on `tblt-activity-specialist.md`)*

This specialist **emits a `coherence_audit.coverage` block keyed by
ADB items** in its Round 2 manifest, and validates the block with F7
before its Phase 5b log write (ADR 0010, SSD §11.4). The Activity
Derivation Block (ADB) is the fragment of the Round 1 manifest
extracted at **Gate B** by the orchestrator and passed in
`session_payload`; its item key-set is the input contract this
specialist's coherence audit must address.

For every ADB item, this specialist authors one coverage entry —
`coherence_audit.coverage.<adb_item> = { addressed: <bool>,
rationale: "…" }` — explaining how the Round 2 Pre-Task addresses
that item (or, on rare honest-no-coverage cases, why a key still
carries a rationale that names the absence). The block is then run
through the canonical F7 validator before this specialist proceeds
to its Phase 5b activity-log row write.

F7 is the **single canonical specification** for coherence-audit
validation, authored on `tblt-activity-specialist.md` (canonical
home; see that file's "Coherence Audit Validation (F7)" section).
This specialist runs *that* specification verbatim against its own
`coherence_audit.coverage` block — it does not re-derive, relax, or
extend the structural checks. F7 performs **two structural checks**
against the block, given the upstream ADB key-set:

1. **Coverage completeness.** Every item in the upstream ADB
   key-set has a corresponding key in `coherence_audit.coverage`. A
   missing key halts the round with `coherence_audit_incomplete`
   (Error), naming the missing ADB item.
2. **Rationale non-triviality.** For each coverage entry, the
   `rationale` field has **at least 30 non-whitespace characters**.
   A rationale below the 30 non-whitespace character floor halts
   the round with `coherence_audit_rationale_too_thin` (Error),
   naming the ADB item whose rationale failed.

F7 is a **structural** validator only. It does **not** judge whether
a rationale is pedagogically correct — that remains the teacher's
role at Gate C / Gate D. The `coherence_audit.coverage` block passes
F7 when both structural properties hold: every ADB item has a
coverage entry AND every entry's rationale meets the 30
non-whitespace character floor.

### Halt-before-log-write (F7.6 carried over)

Either failure (`coherence_audit_incomplete` or
`coherence_audit_rationale_too_thin`) **halts the round before the
log write**. This specialist routes the failure straight to the
round's failure handler without proceeding to **Phase 5b**'s
`safe_write()` activity-log row write (ADR 0010, SSD §6). On halt,
no activity-log row is written for that round; the failure event
itself flows through the diagnostic-log writer as normal.

### Shared validator & cross-specialist determinism (C4)

This pretask call site and the reflective specialist's Round 3 call
site both run F7's canonical specification verbatim against their
respective `coherence_audit.coverage` blocks. Because F7 is a pure
deterministic function of (the upstream ADB key-set, the
`coherence_audit.coverage` block) — no randomness, no
agent-specific state, no external context — both callers given
identical input return **identical results** (same pass/fail
verdict, same `diagnostic`, same `field`, same `reason`). See
`.claude/skills/spec-driven-agents/inter-agent-contracts.md` § C4.

## Canonical Exercise-Type Labels (F4)  *(F8.pre.2 — ADR 0001 / F4)*

The Round 2 Pre-Task is an ordered sequence of pre-task exercises. Each
exercise has an **exercise-type code**, and every code this specialist
emits is a **canonical label from `frameworks/shared-taxonomy.md`** — its
**Exercise Types** category (F4 module, ADR 0001).

**`exercise_types` field — manifest and activity-log row.** Both the
Round 2 manifest **and** this specialist's `{course_id}_activity_log.md`
row carry an `exercise_types` field: the ordered sequence of
exercise-type codes used in the Pre-Task, in the order the student
encounters them. The manifest field and the activity-log row field carry
the **same** ordered sequence — the row is not a re-derivation, it is the
same value, so the per-course log and the cross-course feed stay
consistent with the manifest.

**Canonical only — add before use.** Every code in `exercise_types` is a
label drawn from the Exercise Types category of `shared-taxonomy.md`; the
taxonomy file is the live source of truth. This specialist **never
invents an exercise-type code**: an exercise whose type has no canonical
taxonomy label is an **F4 Update-Discipline event** — this specialist
emits `non_canonical_label_rejected` (Error) and halts, rather than
writing a non-canonical code into the manifest or the activity-log row.
A genuinely new exercise type is added to `shared-taxonomy.md` first
(add-before-use), then used.

(ADR 0001 — the shared taxonomy is the single canonical naming module;
every specialist consults it before composing a manifest or activity-log
row. The Exercise Types category of `shared-taxonomy.md` is the source
for the `exercise_types` field.)

## Phase 5b Writes — per-course + cross-course row via `safe_write()`  *(F8.pre.3 — ADR 0005 / ADR 0002 / ADR 0016)*

At its own **Phase 5b** — reached only after the `coherence_audit.coverage`
block has passed F7 (above) AND F6 structural validation has passed on every
Round 2 HTML artifact — this specialist performs **two log writes**, both
through the canonical `safe_write()` interface (the orchestrator's Log Write
Recovery Stack section; F5). Neither write bypasses `safe_write()`; this
specialist never appends directly to a log file.

### F6 before Phase 5b log write

Before Phase 5b's `safe_write()` calls, this specialist runs the F6
structural validator against the Round 2 HTML artifacts
(`pretask_student.html`, `pretask_teacher.html`). F6 is the **single
canonical specification** for structural validation, authored on
`tblt-activity-specialist.md` (canonical home; see that file's "Structural
Validation (F6)" section). This specialist runs that specification verbatim
against its own freshly-rendered Round 2 HTML — it does not re-derive the
schema or the two-check procedure. **F6 failure halts Round 2 before the
Phase 5b log write** (ADR 0005 — every content-producing specialist calls
the structural validator at Phase 5, before the log write); the orchestrator
routes the F6 failure as a Round 2 rejection.

1. **Own Round 2 activity-log row.** This specialist writes its own Round 2
   row to `{course_id}_activity_log.md` via `safe_write()`. Rounds are
   symmetric (ADR 0002): each content-producing specialist owns and writes
   its own activity-log row — there is no orchestrator-mediated Round 2
   write, exactly as the reflective specialist writes the Round 3 row at
   its own Phase 5b.
2. **Cross-course telemetry feed row.** In the same Phase 5b step this
   specialist writes its Round 2 cross-course feed row to
   `cross_course_telemetry.jsonl`, also via `safe_write()` (ADR 0003 —
   flat-with-nulls; one feed row per round). The cross-course feed write is
   not exempt from the recovery stack: a transient failure retries and a
   persistent failure quarantines to
   `quarantine/cross_course_pending_log_writes.jsonl`, identically to the
   per-course row.

### Typed invocation flags

Every Phase 5b write runs inside an invocation governed by the **typed
invocation flags** (ADR 0016). This specialist consumes the four header
fields — `mode`, `suppress_phase_0`, `preserve_phase_neg1`, `session_payload`
— and applies the two defense-in-depth self-guards exactly as declared in the
*Typed Invocation Inputs* section above; that section is the canonical
consume-side declaration and this section adds no second copy. `mode` and
`session_payload` are read from the typed invocation header, never inferred
from prose or conversational history — every invocation is a freshly spawned
instance with no memory (ADR 0015 cold resume).

## Round 2 Output Files  *(05.1–05.2 — SSD §10 / ADR 0019)*

Round 2 produces **exactly two HTML files**:

1. **`pretask_student.html`** — the student-facing pre-task exercise sheet.
   This file contains the pre-task exercises only; it does **not** include
   the answer key or any teacher-facing content.
2. **`pretask_teacher.html`** — the teacher copy. This file contains the
   same pre-task exercises **plus the answer key**; the answer key appears
   in `pretask_teacher.html` only and is excluded from `pretask_student.html`.

No other HTML files are emitted by Round 2. The Round 2 manifest and the
`{course_id}_activity_log.md` row are the only additional Round 2 artifacts,
and they are produced at Phase 5b; they are not presented as deliverables at
Gate C alongside the two student/teacher HTML files.

## Bridge Exercise — Gap Structure and ADB Consumption  *(05.3–05.5 — SSD §10)*

The Round 2 Pre-Task includes a **Bridge Exercise**: a structured exercise
that rehearses the **kind of question Student A must ask Student B** based on
the information gap from Round 1. The Bridge Exercise is tied to the ADB
(Activity Derivation Block extracted at Gate B from the Round 1 manifest) in
three ways:

### Gap structure reference (05.3)

The Bridge Exercise visibly references the **gap structure** from the ADB's
`gap_summary` field. The `gap_summary` summarises the Round 1 information gap
— who holds which information, what A must discover from B, and what the
communicative stakes are. The Bridge Exercise uses `gap_summary` to shape the
exercise prompt: students practise the type and register of questions that gap
structure requires, not a generic question-formation drill. The gap-structure
reference is explicit and visible in the student-facing text of
`pretask_student.html`.

### PVS items subset constraint (05.4)

The vocabulary items prioritised for exercises in this Round 2 session are a
**subset of `activity_pvs_items_used`** from the ADB — the PVS vocabulary
items that actually appeared in the Round 1 Main Task. This ensures the
pre-task exercises practise the same vocabulary the student will encounter in
the task, not a broader or unrelated PVS slice. The specialist selects from
this constrained subset; it does not draw from the full PVS outside of what
the ADB declares was used in Round 1.

### Exercise-type anti-repetition — Phase −1 (05.5)

At **Phase −1**, before selecting exercise types for this Round 2 session,
this specialist reads `{course_id}_activity_log.md` and inspects the
`exercise_types` field of recent Round 2 log entries. **Exercise types used
recently in the course-scoped activity log are not repeated** in the current
session: the specialist selects exercise types that are not present in the
Phase −1 lookback window. This is the exercise-type dimension of the Phase −1
anti-repetition read (see *Typed Invocation Inputs* above — Phase −1 runs
regardless of mode or any other flag).

## Spanish Language Constraint — PVS or Function-Word Allowlist  *(05.15 — SSD §13 / ADR 0001)*

**All Spanish in both `pretask_student.html` and `pretask_teacher.html` must
trace to one of two sources:**

1. **PVS items** — specifically the `activity_pvs_items_used` subset from
   the ADB. Any Spanish vocabulary used in the exercise prompts, answer key,
   or example sentences must be a PVS item the ADB declares was used in
   Round 1.
2. **Function-word allowlist** — common grammatical connectors, prepositions,
   articles, pronouns, and discourse markers that are not themselves PVS
   vocabulary targets (e.g. *el, la, de, que, y, en, con, a, para, por, se,
   no, sí, es, son, está, están, tiene, tienen, me, te, le, lo, un, una,
   pero, porque, cómo, qué, cuál, cuándo, cuánto*). Function words are
   permitted as structural glue and are not subject to the PVS-only rule.

Spanish vocabulary outside these two sources is a content-generation error.
This specialist does not produce non-PVS Spanish beyond the function-word
allowlist; any exercise prompt or answer-key sentence that would require such
vocabulary is reformulated using only the constrained PVS or function-word
sources.
