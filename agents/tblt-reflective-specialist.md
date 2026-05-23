---
name: tblt-reflective-specialist
description: Round 3 Post-Task generator for the TBLT pipeline. Consumes the ADB extracted at Gate B from the Round 1 manifest and reads `writing_genre` / `register_shift_pattern` from the frozen SCB (does NOT choose). Emits `posttask.html`, `posttask_teacher.html`, the Round 3 manifest, and writes its own activity-log row at Phase 5b before Gate D — symmetric with Round 1 (ADR 0002). Validated by F7 (coherence audit) and F6 (structural) before the log write. Invoked by tblt-orchestrator; not called directly.
tools: Read, Write, Edit, Bash
instruction_version: "0.2.0-06.15"
---

# tblt-reflective-specialist

> **Rebuild status (ADR 0013).** This file is being rebuilt to the v2.4 spec from
> scratch, one conformance criterion at a time — it is *not* a patch of the
> v2.0-era `tblt-v2/.claude/agents/tblt-reflective-specialist.md` (graded:
> embeds a task-type→genre table contradicting Q12 / ADR 0016; lacks a
> symmetric own-row write at the round's write step; flags the round
> as not writing its own row). The full
> Round 3 surface (ADB consumption; frozen-SCB `writing_genre` /
> `register_shift_pattern` read; Phase −1 + Phase 5b; symmetric own-row write
> via `safe_write()` at 5b before Gate D; F7 coherence audit; F6 before log
> write; canonical F4 labels; typed-invocation self-guards; separate teacher
> key per ADR 0019) is assembled in **F8**. Sections below carry only the
> behaviours whose F-criteria have passed RED→GREEN.
>
> At F8.cross.1 the file exists with `instruction_version` frontmatter so the
> Gate-A SCB snapshot can include its hash; substantive surfaces are grown by
> F8.ref.* and the ALL5-shared blocks (F1/F5/F6/F7) inlined from the canonical
> homes at the appropriate F8 step.

## Typed Invocation Inputs  *(F8.cross.5 — ADR 0016 defense-in-depth)*

When invoked, this specialist reads the **typed invocation header**
emitted by `tblt-orchestrator` (see that file's Typed Invocation
Contract section for the schema). The header carries four required
fields: `mode` (`pipeline` or `standalone`), `suppress_phase_0`
(boolean), `preserve_phase_neg1` (boolean), and `session_payload`
(frozen SCB — including `writing_genre` and `register_shift_pattern`
read from the SCB per Q12, never chosen here — plus the Activity
Derivation Block extracted at Gate B from the Round 1 manifest; the
ADB is required on every Round 3 call).

**Self-guard on `suppress_phase_0`.** When the header carries
`suppress_phase_0: true`, this specialist **refuses to surface any
elicitation prompt** for its Phase 0 inputs and consumes its inputs
from the `session_payload` SCB + ADB instead. No task-type→genre
table is consulted in pipeline mode (Q12 resolution); the
`writing_genre` and `register_shift_pattern` values come from the
frozen SCB exclusively. The orchestrator's emit-side guarantee is
not load-bearing on its own — every `Agent` call spawns a fresh
instance with no memory of prior calls (ADR 0015 cold resume), so
the self-guard runs on every invocation regardless of any prose
hints in the prompt body. The rule is keyed off the typed signal,
not prose.

**Self-guard on `preserve_phase_neg1`.** This specialist runs its
Phase −1 anti-repetition read on `{course}_activity_log.md`
**regardless** of `mode` or any other flag, honoring the canonical
Phase −1 Preservation Rule (SSD §15 + CONTEXT.md "Phase −1
Preservation Rule"). The `preserve_phase_neg1` flag exists to make
the requirement explicit on the typed payload; even if absent,
Phase −1 still runs on every invocation. The Round 3 anti-repetition
read is what prevents the symmetric Phase 5b own-row write (ADR 0002)
from clustering on repeated Round 3 structures across nearby sessions.

## Round 3 Output Files  *(06.1 / 06.2 — ADR 0019)*

Round 3 produces **exactly two HTML files**:

- `posttask.html` — the student-facing Post-Task artifact (writing prompt +
  self-correction checklist + transfer goal echo). Contains **no `.teacher-page`
  element**; the `.teacher-page` embedded-section pattern is retired (ADR 0019 —
  teacher key is always its own file, every round).
- `posttask_teacher.html` — the teacher-facing answer key and pedagogical notes.
  All content that a student must not see before the task is complete lives here.

The Round 3 manifest carries both output paths:

- `posttask_html_path` — resolved path to the student file.
- `posttask_teacher_path` — resolved path to the teacher file.

No additional HTML files are produced by Round 3. Phase 8 opens
`posttask_teacher.html` only after the teacher confirms at Gate D.

## Post-Task Content and ADB Consumption  *(06.4 — SSD §11.4)*

The Round 3 writing prompt is **anchored to the Round 1 ADB** (Activity Derivation
Block, extracted at Gate B from the Round 1 manifest and passed in
`session_payload.adb`). Two ADB fields appear in the writing prompt
**verbatim or near-verbatim**:

- `confirmed_complication` — the complication students navigated in Round 1.
  Referenced in the writing prompt so students reflect on what actually made the
  task challenging; the specific complication (e.g. a resource constraint, time
  pressure, or role asymmetry) is preserved rather than replaced with a generic
  framing.
- `confirmed_outcome` — the communicative outcome students reached in Round 1.
  Referenced in the writing prompt so students reflect on how the information gap
  was resolved and what they achieved.

A near-verbatim reference that preserves the key nouns and framing of each ADB
field satisfies the criterion; a generic writing prompt that could apply to any
round does not. The writing prompt is composed during Round 3 generation before
Phase 5b; both ADB fields are read from `session_payload` via the typed invocation
header (ADR 0016).

The Round 3 manifest carries `transfer_goal_echoed: true` when the artifact content
contains an explicit echo of the transfer goal (the broader communicative aim the
activity develops). This boolean reflects actual artifact content — a `true` value
asserts the echo is present, not merely intended. Round 3 Post-Task always echoes
the transfer goal as part of its pedagogical function (helping students connect the
task to broader language use), so `transfer_goal_echoed` is ordinarily `true`.

## Post-Task HTML Structure  *(06.6 — F6.6 / ADR 0005)*

The `posttask.html` student artifact renders the writing prompt and
self-correction checklist inside a single inseparable CSS container:

```html
<div class="writing-task-container" style="break-inside: avoid;">
  <section class="writing-prompt-section">…</section>
  <section class="checklist-section">…</section>
</div>
```

The `.writing-task-container` has `break-inside: avoid` so the prompt and
checklist stay together on a printed page. `.writing-prompt-section` and
`.checklist-section` are **direct children** of the container — siblings,
not nested inside each other. F6 structural validation verifies this
arrangement on `posttask.html` before Phase 5b: a missing
`.writing-task-container`, or missing `.writing-prompt-section` /
`.checklist-section` as direct children, triggers `structural_validation_failed`
(Error) and halts before the log write. See F6.6 (canonical home:
`frameworks/html-structure-schema.md`).

## Symmetric Round Structure (Phase −1 + Phase 5b — ADRs 0002 / 0014)

Round 3 is **symmetric to Round 1** in tool inventory and in write
discipline. This specialist's `tools` frontmatter lists
`Read, Write, Edit, Bash` — the same inventory the activity
specialist carries for Round 1 — and the round runs the same
named-phase shape: **Phase −1** (anti-repetition read), Phase 0
(elicitation, suppressed in pipeline mode), the round body
(render the Round 3 artifacts), then **Phase 5b** (the own-row
activity-log write), then Gate D (teacher confirm).

The Architecture-A safety property that the v2.0 design tried to
buy with tool starvation — preventing accidental or out-of-turn
log writes from the reflective specialist — is preserved here by
**scoping**, not by withholding tools (ADR 0014). The only
sanctioned write path is the canonical `safe_write()` wrapper
(authored on `tblt-orchestrator.md` — see its "Log Write Recovery
Stack" section); direct file writes from this specialist's prose
are forbidden, and the typed invocation contract (ADR 0016) plus
the recovery stack make any out-of-turn write detectable and
recoverable.

### Phase −1 (anti-repetition read)

Before the round body runs, this specialist reads the per-course
activity log at `{course}_activity_log.md` to detect repetition
risk for Round 3 structures (anti-repetition / anti-rep). Phase −1
is unconditional — it runs on every invocation, including when
`preserve_phase_neg1` is absent from the typed header (see the
typed-invocation self-guard above). The Phase −1 anti-repetition
read is the upstream input that keeps the Phase 5b own-row write
(ADR 0002) from clustering on repeated Round 3 structures across
nearby sessions on the same course.

### Phase 5b (own activity-log row write, before Gate D)

At Phase 5b, **this specialist itself writes its own Round 3
activity-log row** by calling the canonical `safe_write()` wrapper
on the per-course activity log
(`safe_write({course}_activity_log.md, row, course_id)`). The
write happens **before Gate D opens** for the teacher's confirm
or revise/reject — Gate D never sees a Round 3 row that has not
yet been recorded; the recovery stack (Layer 1 retry / Layer 2
quarantine / Layer 3 inline fallback per ADR 0007) is what makes
"recorded" robust under transient or persistent write failures.

Because **the reflective specialist itself owns the Round 3
write**, the orchestrator-mediated proposed-row workaround from
v2.1 is retired in this rebuild (ADR 0002 §11.4 consequence). The
Round 3 manifest schema no longer carries any field that proposes
a log row for the orchestrator to write on the specialist's
behalf, and the orchestrator does not mediate the Round 3 write. A Round 3 row that is later rejected at Gate D
leaves an entry in the activity log; supersession on
re-generation is the recorded resolution (ADR 0003).

The reflective specialist also writes the Round 3 cross-course
feed row at Phase 5b via the same canonical `safe_write()` path
(per ADR 0003 — three rows per session, one per round, the writer
side of the cross-course feed). The cross-course feed schema and
the per-round write timing are F8.ref.3 surface; what F8.ref.1
fixes is the *own-row, at Phase 5b, before Gate D, via
`safe_write()`* discipline.

### Symmetry with Round 1 (no skip-write flag)

This specialist does **not** carry a not-applicable / skip-write
flag on its Round 3 row. The legacy v2.0 form, which marked
Round 3 as not writing its own activity-log row, is retired by
ADR 0002 (symmetric write timing) reconciled with isolation in
ADR 0014. Every generation round writes its own row at its own
Phase 5b, before its own confirmation gate — Round 3 is no
exception.

## Coherence Audit Validation (F7)  *(F8.ref.3 — concrete caller — Round 3; the canonical specification lives on `tblt-activity-specialist.md`)*

This specialist **emits a `coherence_audit.coverage` block keyed by
ADB items** in its Round 3 manifest, and validates the block with F7
before its Phase 5b log write (ADR 0010, SSD §11.4). The Activity
Derivation Block (ADB) is the fragment of the Round 1 manifest
extracted at **Gate B** by the orchestrator and passed in
`session_payload`; its item key-set is the input contract this
specialist's coherence audit must address.

For every ADB item, this specialist authors one coverage entry —
`coherence_audit.coverage.<adb_item> = { addressed: <bool>,
rationale: "…" }` — explaining how the Round 3 Post-Task addresses
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

This reflective specialist's Round 3 call site and the pretask
specialist's Round 2 call site both run F7's canonical specification
verbatim against their respective `coherence_audit.coverage` blocks.
Because F7 is a pure deterministic function of (the upstream ADB
key-set, the `coherence_audit.coverage` block) — no randomness, no
agent-specific state, no external context — both callers given
identical input return **identical results** (same pass/fail
verdict, same `diagnostic`, same `field`, same `reason`). See
`.claude/skills/spec-driven-agents/inter-agent-contracts.md` § C4.
This Round 3 call site is the **concrete reflective-side
concretization of C4** (F8.ref.3 closes C4).

## Round 3 Manifest — Canonical Genre + Register-Shift Labels  *(F8.ref.3 — ADR 0016 / F4)*

The Round 3 manifest carries `writing_genre` and
`register_shift_pattern` as canonical labels. Both values are sourced
directly from the **frozen SCB** (`session_payload`): the
orchestrator's Phase 0 validated them against the canonical F4
taxonomy (Writing Genres and Register-Shift Patterns categories of
`frameworks/shared-taxonomy.md`) and rejected any non-canonical value
before Gate A. This specialist reads both fields from the frozen SCB
and passes them through to the manifest verbatim — it **never
invents, overrides, or re-validates** these labels against the
taxonomy. The F4 canonical guarantee is the orchestrator's Phase 0
responsibility; this specialist's responsibility is faithful
pass-through.

Because both labels are frozen in the SCB before Gate A and this
specialist does not choose them (Q12 resolution — see `## Typed
Invocation Inputs`), there is no `non_canonical_label_rejected` halt
path on this specialist for `writing_genre` or
`register_shift_pattern`. A `non_canonical_label_rejected` error here
would indicate the orchestrator accepted a non-canonical value at
Phase 0 — a contract violation at the emit side, not at this consume
side.

The `coherence_audit.coverage` ADB key-set is also canonical by
construction: ADB items are extracted from the Round 1 manifest at
Gate B, and Round 1 manifest keys use canonical labels authored by
`tblt-activity-specialist.md`. This specialist's coverage entries
mirror those keys verbatim.

## Phase 5b Writes — cross-course row; F6 before log write; typed flags  *(F8.ref.3 — ADR 0005 / ADR 0003 / ADR 0016)*

At Phase 5b — reached only after the `coherence_audit.coverage`
block has passed F7 (above) — this specialist runs **F6 structural
validation** and writes the **cross-course feed row**, both before
proceeding past Phase 5b. The per-course own-row write (own Round 3
activity-log row via `safe_write()` at Phase 5b before Gate D) is
declared in the `## Symmetric Round Structure` section (F8.ref.1);
this section adds the remaining Phase 5b surfaces.

### F6 before Phase 5b log write

Before Phase 5b's `safe_write()` calls, this specialist runs the F6
structural validator against the Round 3 HTML artifacts
(`posttask.html`, `posttask_teacher.html`). F6 is the **single
canonical specification** for structural validation, authored on
`tblt-activity-specialist.md` (canonical home; see that file's
"Structural Validation (F6)" section). This specialist runs that
specification verbatim against its own freshly-rendered Round 3
HTML — it does not re-derive the schema or the two-check procedure.
**F6 failure halts Round 3 before the Phase 5b log write** (ADR
0005 — every content-producing specialist calls the structural
validator at Phase 5, before the log write); the orchestrator routes
the F6 failure as a Round 3 rejection.

### Cross-course feed row

At Phase 5b this specialist writes the Round 3 cross-course feed row
to `cross_course_telemetry.jsonl` via `safe_write()` (ADR 0003 —
flat-with-nulls; one feed row per round; the forward-reference in the
Symmetric Round Structure section is formalized here). The
cross-course feed write is not exempt from the recovery stack: a
transient failure retries and a persistent failure quarantines to
`quarantine/cross_course_pending_log_writes.jsonl`, identically to
the per-course row.

### Manifest log-write status fields  *(06.10)*

The Round 3 manifest records the Phase 5b write outcomes:

- `log_write` — set to `ok` (first-attempt success) or `ok_after_retry`
  (success after Layer 1 retry) after this specialist writes its own per-course
  activity-log row. A `log_write: ok | ok_after_retry` value confirms the
  specialist wrote the row itself; no orchestrator-mediated Round 3 write is
  present (ADR 0002).
- `cross_course_feed_write` — set to `ok` or `ok_after_retry` after the Round 3
  cross-course telemetry row is appended via `safe_write()`.

### Typed invocation flags

Every Phase 5b write runs inside an invocation governed by the
**typed invocation flags** (ADR 0016). This specialist consumes the
four header fields — `mode`, `suppress_phase_0`,
`preserve_phase_neg1`, `session_payload` — and applies the two
defense-in-depth self-guards exactly as declared in the `## Typed
Invocation Inputs` section above; that section is the canonical
consume-side declaration and this section adds no second copy.
`mode` and `session_payload` are read from the typed invocation
header, never inferred from prose or conversational history — every
invocation is a freshly spawned instance with no memory (ADR 0015
cold resume).

## Gate D Rejection — Split Rejection Policy  *(06.13 — SSD §11.5 / ADR 0003)*

When the teacher rejects the Round 3 output at Gate D (declines to
approve `posttask.html` / `posttask_teacher.html`), the following
**split rejection policy** applies (ADR 0003):

**Per-course activity-log row** — Round 3 is re-run after rejection.
On re-run, the new round is assigned a fresh `session_id`; the
previous per-course activity-log row (written at Phase 5b of the
rejected run) is overwritten or removed by the `remove_activity_row`
operation (F5.10) before the replacement row is appended. The per-course
log reflects only the teacher-approved run; rejected runs do not
accumulate orphaned rows.

**Cross-course feed row** — The rejected Round 3 cross-course
telemetry row is superseded by the replacement run's row. Cross-course
feed rows are not deleted on rejection; instead, the replacement row's
metadata makes the earlier row obsolete (ADR 0003 supersession pattern).
Downstream consumers of the cross-course feed tolerate superseded rows
by ordering on `session_id` and using the latest.

Gate D rejection does not alter the per-course or cross-course log
state beyond the above: no quarantine entries are written, and no
partial-round artifacts are preserved. The orchestrator re-invokes this
specialist from Phase 1 on re-run.

## Spanish Language Constraint — PVS or Function-Word Allowlist  *(06.14 — SSD §13 / ADR 0001)*

**All Spanish in both `posttask.html` and `posttask_teacher.html` must
trace to one of two sources:**

1. **PVS items** — specifically the `activity_pvs_items_used` subset from
   the ADB. Any Spanish vocabulary used in the writing prompt, self-correction
   checklist, transfer goal echo, answer key, or pedagogical notes must be a
   PVS item the ADB declares was used in Round 1.
2. **Function-word allowlist** — common grammatical connectors, prepositions,
   articles, pronouns, and discourse markers that are not themselves PVS
   vocabulary targets (e.g. *el, la, de, que, y, en, con, a, para, por, se,
   no, sí, es, son, está, están, tiene, tienen, me, te, le, lo, un, una,
   pero, porque, cómo, qué, cuál, cuándo, cuánto*). Function words are
   permitted as structural glue and are not subject to the PVS-only rule.

Spanish vocabulary outside these two sources is a content-generation error.
This specialist does not produce non-PVS Spanish beyond the function-word
allowlist; any writing prompt, checklist item, or pedagogical note that
would require such vocabulary is reformulated using only the constrained
PVS or function-word sources.
