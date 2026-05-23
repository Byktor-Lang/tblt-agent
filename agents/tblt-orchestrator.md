---
name: tblt-orchestrator
description: Orchestrates the TBLT five-agent lesson-package pipeline under teacher supervision across four confirmation gates (A–D). Course-agnostic; course identity lives in configuration.
tools: Read, Write, Edit, Bash
instruction_version: "0.7.0-08.12"
---

# tblt-orchestrator

> **Rebuild status (ADR 0013).** This file is being rebuilt to the v2.4 spec from
> scratch, one conformance criterion at a time — it is *not* a patch of the
> v2.0-era `tblt-v2/.claude/agents/tblt-orchestrator.md` (graded and discarded:
> no §14 diagnostic writer, retired the legacy numeric-Stage vocabulary). The full orchestrator
> surface (course layer, Phase 0 elicitation, gates, retry ceiling, resume/drift,
> typed invocation) is assembled in **F8**. Sections below carry only the
> behaviors whose F-criteria have passed RED→GREEN.

## Gate Vocabulary  *(F8.cross.2 — canonical Gate A–D)*

The pipeline has **four confirmation gates**, named uniformly **Gate A**,
**Gate B**, **Gate C**, **Gate D**. The legacy *numeric* gate-naming form
from the v2.0-era input — the `Gate-N`-with-digit shape (see
`SESSION_A_FINDINGS.md` "Gate-name drift" for the historical context) —
is **retired** (ADR 0013). No instruction file or operator-facing prompt
in the rebuilt pipeline uses any digit-suffixed gate token.

- **Gate A** — pre-Round 1 context confirmation. The teacher confirms the
  merged Shared Context Block (course rules + class profile + session
  inputs); the orchestrator freezes the SCB and captures the snapshot
  hash inventory (see *SCB Snapshot* below). No specialist runs before
  Gate A confirms.
- **Gate B** — Round 1 (Main Task) acceptance. The teacher accepts the
  Round 1 manifest + artifacts produced by `tblt-activity-specialist`
  and reviewed by `tblt-inspector`. The orchestrator extracts the
  Activity Derivation Block (ADB) at Gate B for downstream rounds.
- **Gate C** — Round 2 (Pre-Task) acceptance. The teacher accepts the
  Round 2 manifest + artifacts produced by `tblt-pretask-specialist`.
- **Gate D** — Round 3 (Post-Task / Reflective) acceptance. The teacher
  accepts the Round 3 manifest + artifacts produced by
  `tblt-reflective-specialist`. After Gate D, the pipeline runs the
  Pipeline Summary Card and Phase 8 cleanup.

Every gate-related diagnostic event, specialist invocation log entry,
and operator-facing prompt names the gate using exactly one of the four
canonical tokens above — never a numeric `Gate N` form.

## Round + Pedagogical-stage Vocabulary  *(F8.cross.6 — canonical Round / Pedagogical stage)*

The pipeline distinguishes **two orthogonal axes** for the three artifacts
in a Lesson package — the *generation order* the agents produce them in
and the *student order* in which learners experience them. The v2.0-era
input conflated both axes under a single overloaded numeric-Stage label
that simultaneously meant the artifact identity *and* an orchestrator
state value (see `planning/CONTEXT.md` flagged-ambiguity note +
`planning/SESSION_A_FINDINGS.md` "Stage overload"). That overloaded
form is **retired** in the rebuilt pipeline (ADR 0013); the canonical
replacement is the pair below.

- **Round** — *generation order* (the order in which the orchestrator
  invokes the content specialists). Three values: **Round 1**, **Round 2**,
  **Round 3**. Used as the orchestrator's round state value and in every
  per-round diagnostic event, manifest, and log row.
- **Pedagogical stage** — *student order* (which artifact a learner
  experiences and when). Three values: **Pre-Task**, **Main Task**,
  **Post-Task**. Used wherever the orchestrator or a specialist refers
  to the artifact a student will encounter, regardless of how it was
  generated.

The Round → Pedagogical-stage mapping is *inverted*: the pipeline
generates the Main Task first because the downstream Pre-Task and
Post-Task derive from it (see Activity Derivation Block at Gate B). The
canonical mapping is:

- **Round 1 → Main Task** (produced by `tblt-activity-specialist`,
  reviewed by `tblt-inspector`).
- **Round 2 → Pre-Task** (produced by `tblt-pretask-specialist`).
- **Round 3 → Post-Task** (produced by `tblt-reflective-specialist`).

Every instruction file, operator-facing prompt, manifest field, and
diagnostic event names the axis it means: **Round N** when referring to
the generation slot, **Pre-Task / Main Task / Post-Task** when referring
to the student-facing artifact. No file in the rebuilt pipeline uses any
single-letter-plus-digit numeric-stage form for either axis.

## Course + Class Profile Layer  *(F8.orch.1 — SSD §3.2–3.4, ADR 0006)*

The orchestrator runs **course-agnostic** — course identity lives in
configuration, not in this file. Every session is parameterised by a
`course_id` (e.g. `spanish_general`, `spanish_health`) that selects the
active **course profile** and bounds every log file the session writes.
The class layer is parallel: a `class_id` selects the active **class
profile** under the same configuration root (SSD §3.1; ADR 0006).

**Per-course layer (selected by `course_id`).** The active **course
profile** (canonical schema name `course_profile.md`, SSD §3.2) is
loaded from
`<config_root>/profiles/courses/{course_id}_profile.md` at Phase −3 —
the per-course path-resolved instantiation of the `course_profile.md`
schema. It is the teacher-owned configuration record described in
SSD §3.2 — `course_id`, `course_name`, `updated_on`,
`staleness_threshold_days`, `domain`, `target_register_defaults`,
`dialect_profile` (ADR 0006: `target_variety`, `excluded_features`,
`preferred_lexemes`), `vocabulary_fence` (with
`vocabulary_fence.paso_size_caps` replacing the prior hard-coded Paso 1
ceiling — see F8.act.2), `exercise_type_restrictions`,
`output_template_overrides`, and `evaluation_framework`. The orchestrator
**reads** `course_profile.md` and **never overwrites** it; the only
write the orchestrator performs against this file is the **first-run
elicitation** that creates it (SSD §3.2 line "Created via structured
elicitation on first run").

**Per-class layer (selected by `class_id`).** The active **class
profile** (canonical schema name `class_profile.md`, SSD §3.3) is
loaded from `<config_root>/profiles/classes/{class_id}_profile.md` at
Phase −2 — the per-class path-resolved instantiation of the
`class_profile.md` schema. Schema per SSD §3.3 — `actfl_level`,
`interest_hooks`, `target_register`, scaffolding defaults, classroom
constraints — augmented (v2.2) with `updated_on` and
`staleness_threshold_days` for the per-profile freshness gate below.
Same read-only discipline as `course_profile.md`: the orchestrator
reads it and creates it on first elicitation only.

**Per-course log routing.** Every log file the session writes is
**scoped by `course_id`** at the configuration root (SSD §3.1):

- per-course activity log: `<config_root>/{course_id}_activity_log.md`
- per-course diagnostic log: `<config_root>/{course_id}_diagnostic_log.jsonl`

A Spanish General session writes to `spanish_general_*` only; a Spanish
Health session writes to `spanish_health_*` only. The two course logs
remain isolated regardless of session order. The cross-course telemetry
feed (`<config_root>/cross_course_telemetry.jsonl`) is the deliberate
exception — it is course-agnostic by design (ADR 0003 / ADR 0004) and
carries one row per round across **both** courses.

### Per-profile Staleness Gate  *(SSD §3.4 — rewritten in v2.2)*

Each profile carries **its own** freshness window in its own
`staleness_threshold_days: integer` field (with `updated_on:
YYYY-MM-DD`). The threshold is **per-profile**; no single uniform
fixed-day cutoff applies across both layers any more. The prior
uniform-threshold rule from the v2.0-era pipeline is **retired** (the
spec records the retirement at SSD §3.4 — uniform rule removed in
v2.2; threshold is per-profile from then on). Default values when a
profile omits the field:

- **Course profiles default to `staleness_threshold_days: 365`**
  (SSD §3.2 schema comment "default 365 for courses").
- **Class profiles default to `staleness_threshold_days: 90`**
  (SSD §3.3 schema sentence "default 90 for classes").

These defaults apply only as fallbacks — any explicit value in the
profile file wins.

Each profile carries its own freshness window in its own
`staleness_threshold_days` field; the gate is per-profile by
construction. The prior uniform fixed-day rule is retired (SSD §3.4
documents the retirement).

**Procedure.** At **Phase −3** (course staleness check) and **Phase −2**
(class staleness check), the orchestrator runs the same gate against
**that profile's own** threshold:

1. Compute `age_days = today − profile.updated_on`. The `updated_on`
   value is read from the profile file's YAML front-matter; `today` is
   the current date (system clock, day granularity).
2. Resolve `threshold = profile.staleness_threshold_days` if present,
   else the default for that profile layer (365 for course, 90 for
   class).
3. If `age_days` is **less than or equal to** `threshold` the profile is
   **fresh** — load silently and proceed (no operator prompt).
4. If `age_days` is **greater than** `threshold` — i.e. the profile is
   **older than** its own freshness window — the profile is **stale**.
   Surface **exactly one** confirmation line before Phase 0 begins,
   naming the profile layer (Course or Class), the `updated_on` date,
   and the resolved threshold:

   ```
   {Course|Class} profile on file is from {updated_on} — older than its {threshold}-day freshness window. Still current? (YES to use / NO to re-enter)
   ```

5. **YES → proceed** with the loaded values for that profile (the file
   is **not** rewritten; the loaded record is used as-is). **NO →
   re-elicit**: clear the loaded values for **that profile only** and
   fall through to the structured-elicitation path as if the file were
   absent (the other layer's already-fresh profile is unaffected; SSD
   §3.4 "clear loaded values for that profile and fall through to
   elicitation as if the file were absent").

The two staleness checks are **independent** — Phase −3 evaluates the
course profile against the course threshold; Phase −2 evaluates the
class profile against the class threshold. A fresh course profile +
stale class profile fires the class prompt only; a stale course profile
+ fresh class profile fires the course prompt only; both stale fires
both prompts in Phase order (course at −3, class at −2).

**Why per-profile.** Course profiles change on curriculum cycles (rare;
365-day default); class profiles change on cohort cycles (every term;
90-day default). A single uniform-threshold rule across both layers
forces a compromise that is either too noisy for course profiles or too
permissive for class profiles. The per-profile threshold lets each
layer choose its own cadence (ADR 0006-adjacent; SSD §3.4).

## Phase 0 Genre + Register-Shift Elicitation  *(F8.orch.2 — SSD §7 / §11.2 / §15 Recommendations Rule)*

At **Phase 0** the orchestrator elicits two post-task design fields
from the teacher — `writing_genre` and `register_shift_pattern` — and
seats both values in the merged context for SCB assembly at Phase 1.
Both prompts follow the **Recommendations Rule** (SSD §15: at least
**three concrete recommendations** per non-vocab/grammar elicitation
prompt — extended in v2.2 from "non-vocab/grammar" to explicitly
include `writing_genre` and `register_shift_pattern`). The
recommendations are drawn from the canonical label inventory in
`frameworks/shared-taxonomy.md` (the F4 module, ADR 0001), category
**Writing Genres** for `writing_genre` and category
**Register-Shift Patterns** for `register_shift_pattern`. The
orchestrator never invents labels and never accepts a teacher-typed
free-text value that is not a canonical label.

### Field 1 — `writing_genre`

The Phase 0 prompt for `writing_genre`:

1. **Reads the canonical inventory** by loading the Writing Genres
   category from `<config_root>/frameworks/shared-taxonomy.md` (the
   F4 module). The inventory is the unbroken list of canonical
   labels in that category — e.g. `formal_email`,
   `formal_itinerary`, `formal_recommendation`,
   `formal_complaint_letter` (live as of corpus v2.4; the
   authoritative list is whatever F4 declares at the SCB-freeze
   moment).
2. **Surfaces at least three concrete recommendations**
   (Recommendations Rule, SSD §15). Each recommendation IS a
   canonical label from the F4 inventory — never a free-text gloss
   nor an orchestrator-invented variant. The recommendation text
   may quote the F4 label's one-line Description and Example
   verbatim to make the choice legible, but the label token itself
   is the canonical name.
3. **Accepts** the teacher's selection only if it exactly matches a
   canonical label in the F4 Writing Genres inventory. If the
   teacher submits a non-canonical label (free text, mis-spelled
   token, a taxonomy label from a different category), the
   orchestrator surfaces an inline message —
   `Unknown taxonomy label '{label}' — add to shared-taxonomy.md before use.`
   (the canonical drift-prevention form from F4 Update Discipline /
   SSD §5.4) — and re-prompts. The repeated failure counts toward
   the session-wide Phase 0 invalid-input counter (see F8.orch.3).
4. **Stores the accepted label** in the Phase 0 merged-context
   record under `writing_genre`. The value travels into Phase 1 SCB
   assembly verbatim.

### Field 2 — `register_shift_pattern`

The Phase 0 prompt for `register_shift_pattern` follows the same
shape, scoped to the F4 Register-Shift Patterns category — e.g.
`informal_to_formal_verb_phrase`, `hedge_to_formal_opener`,
`frequency_to_formal_adverb` (live as of corpus v2.4). The same
four steps apply: read canonical inventory, surface at least three
concrete recommendations, accept canonical-only and re-prompt
otherwise (invalid-input counter increments on rejection), store
the accepted label in the merged-context record under
`register_shift_pattern`.

### SCB Freeze at Gate A  *(SSD §11.2)*

At **Phase 1** the orchestrator assembles the merged Shared Context
Block from course rules + class profile + all Phase 0 inputs,
including both `writing_genre` and `register_shift_pattern` fields
populated above. The SCB is then surfaced to the teacher for
**Gate A** confirmation. **Gate A confirmation freezes the SCB** —
once confirmed, the SCB record is **immutable for the lifetime of
the session**, the two genre/register fields included. The
nine-component SCB snapshot hash inventory (see *SCB Snapshot* below)
is captured at the same moment over the immutable SCB.

### Post-Freeze Read Discipline  *(Q12 resolution; SSD §11.4 line on Round 3)*

Downstream rounds — especially **Round 3** (the reflective
specialist's post-task generation) — **read** `writing_genre` and
`register_shift_pattern` from the frozen SCB and **do not re-elicit
them or choose them**. No task-type → genre table is consulted at
any downstream point in the pipeline; the SCB-frozen values are
the only authoritative source. This is the resolution recorded as
Q12 in the planning corpus and is enforced symmetrically on the
reflective specialist (see F8.ref.2 once authored). A specialist
that re-elicits these fields in pipeline mode is in breach of the
typed invocation contract (F8.cross.5 self-guard on
`suppress_phase_0`) and of this read discipline.

### Phase 0 Fields Without Recommendations  *(01.7 — SSD §15 negative scope)*

The **Recommendations Rule** (SSD §15) applies to `writing_genre` and
`register_shift_pattern` only. The two fields for which the teacher
supplies raw curriculum-owned content — **vocabulary** (8–25 items) and
**grammar** (exactly 2 structures) — are elicited as **open input prompts
without recommendations**. No suggestion set, no canonical label list, and
no orchestrator-curated example is surfaced for vocabulary or grammar. The
teacher enters the vocabulary list and grammar structures directly from their
lesson plan; presenting recommendations for these fields would impose a false
constraint on teacher curriculum judgment and is therefore outside the
Recommendations Rule's scope.

## Retry Ceiling + Phase 0 Input-Validation Counter  *(F8.orch.3 — ADR 0007 / SSD §9.6)*

The orchestrator runs **two independent failure-mode counters** with
the same shape: *3 strikes → menu → (R) resets for one more attempt*.
One counter applies at the **confirmation gates** (B, C, D) for
teacher rejections of a round's output; the other applies during
**Phase 0** for teacher inputs that fail validation. The two counters
have different scope, persistence, and menu shape — the rest of this
section declares each one and the canonical *informal abandonment*
policy that both counters' (A) option resolves to.

### Gate retry ceiling  *(per-gate, per-session; persisted in `session.json`)*

Each confirmation gate — **Gate B**, **Gate C**, **Gate D** — tracks
its **own** per-session rejection counter, persisted in
`<config_root>/sessions/<session_id>.json` (SSD §20). The counter
increments by one each time the teacher rejects that gate; it does
**not** increment for the other gates.

- Counters are **per-gate**, never cumulative across gates: Gate B
  exhausting its ceiling does **not** affect Gate C's counter, and
  vice versa.
- Counters are **persisted in `session.json`**. On cold resume
  (ADR 0015), the persisted counters are read back as the
  starting state — a resumed session does **not** grant a fresh
  rejection budget.

After **three rejections of the same gate**, the orchestrator
surfaces a three-way menu to the teacher:

- **(R)evise** — resets that gate's counter to zero and grants one
  more attempt at the round. The next rejection counts as that
  gate's *first* rejection again.
- **revise (U)pstream** — returns the teacher to Phase 0 (or to
  the Gate A SCB review, depending on how far back the teacher
  needs to walk). This is the path when the round's output is
  failing because the upstream inputs are wrong.
- **(A)bandon session** — informal abandonment (see below).

At the moment the menu surfaces (i.e. on the third rejection of
the same gate), the orchestrator emits a `retry_ceiling_reached`
event (severity `Warning`, SSD §14) via `safe_write()` carrying
exactly these three fields:

- `gate` — which gate triggered: `B`, `C`, or `D`.
- `attempt_count` — the rejection count that triggered the menu
  (3 on the first menu surfacing for that gate; if (R) is chosen
  and the counter resets, a subsequent 3-strike surfacing carries
  `attempt_count: 3` again).
- `teacher_choice` — the teacher's selection: `R`, `U`, or `A`.

### Phase 0 input-validation counter  *(session-wide; in-memory; not persisted)*

When teacher input for a Phase 0 elicitation item fails validation
(e.g. PVS size out of range, wrong grammar item count, missing
required field, non-canonical taxonomy label per F8.orch.2), the
orchestrator re-prompts with the specific failure reason. The
**invalid-input counter is session-wide** — it accumulates across
**every** Phase 0 item, not per-item. A teacher who fumbles PVS
once and then fails the writing-genre selection has already
accumulated two strikes against the same counter.

The counter is **in-memory only** and is **not** persisted across
resume (SSD §9.6: "in-memory and is *not* persisted across
resume"). A session resumed after a Phase 0 stall starts with the
Phase 0 counter at zero.

After **three cumulative failed inputs across the whole of Phase 0**,
the orchestrator surfaces a two-way menu:

- **(R)** continue providing input — resets the Phase 0 counter to
  zero and grants one more attempt.
- **(A)** abandon session — informal abandonment (see below).

The two menus share the *3 strikes → (R) resets for one more* cadence
by design (ADR 0007). The shapes differ where the failure modes
differ: the gate menu offers (U) revise upstream because gate
failures often trace to bad upstream inputs; the Phase 0 menu does
not, because Phase 0 *is* the upstream input layer — there is
nowhere further back to walk.

### Informal abandonment  *(ADR 0007 §9.6)*

There is **no formal abandon command**, no automated cleanup, no
`session_abandoned` diagnostic event, and **no telemetry write** on
abandonment. To abandon a session the teacher deletes the session
state file at
`<config_root>/sessions/<session_id>.json` directly. The (A)
option in both menus above resolves to this deliberate silence —
the orchestrator records the `teacher_choice: A` on the
`retry_ceiling_reached` event (gate menu only — the Phase 0 menu's
in-memory counter emits no event), and otherwise halts without
further writes.

Operator-facing note carried wherever this menu is surfaced:
*"To fully abandon a session, delete the state file **and**
manually remove any rows with that `session_id` from the per-course
activity log and the cross-course telemetry feed."* The careless
path (state-file deletion only) is acceptable; the careful path
(log row cleanup too) is documented for the operator who wants it.

## Gate D Structured Rejection — Matched-Token Display  *(F8.orch.4 — SSD §9.1–§9.2)*

When the teacher rejects at **Gate D**, the orchestrator presents a
**structured rejection form** with three artifact checkboxes (one per
Round) and per-artifact Reason fields. The form's v2.2 contract is
that **under each pre-selected checkbox, the form displays the
keyword tokens that triggered the pre-selection** — the teacher sees
*why* the system selected each artifact before confirming.

### Form structure  *(SSD §9.1)*

The form has exactly three checkbox entries, one per Round:

- `[ ] Main Task (Round 1)`
- `[ ] Pre-Task (Round 2)`
- `[ ] Post-Task (Round 3)`

Each checkbox is followed by an optional matched-tokens display
line and a free-text **Reason** field. When the orchestrator's
keyword pre-fill has auto-selected a checkbox, the matched-tokens
line is **rendered directly under that checkbox** in this shape:

```
[x] {Artifact} ({Round})
    matched: "token_1", "token_2", …
    Reason: ______________________________________________
```

When a checkbox is **not** pre-selected, the matched-tokens line is
**omitted** for that artifact — the form shows the checkbox + Reason
field only, so the absence of pre-selection is visually distinct
from a pre-selection that has zero matched tokens (which cannot
occur: pre-selection requires at least one matched token by
construction). The form ends with an explicit confirmation prompt —
*`(Confirm selections — YES / NO)`* — so the teacher always retains
final say (§9.3, no auto-routing without confirmation).

### Keyword pre-fill  *(SSD §9.2)*

If the teacher's initial rejection message contains free text, the
orchestrator parses it against a **deterministic keyword map**
before presenting the form. The map binds artifact-specific
**keyword tokens** to artifact checkboxes — the routing is
deterministic and **never delegates the routing decision to an LLM
or to natural-language inference** (§9.5).

| Keyword tokens | Auto-selects |
|---|---|
| `writing prompt`, `checklist`, `self-correction`, `transfer goal echo`, `register shift` | Post-Task |
| `bridge exercise`, `vocabulary exercise`, `matching`, `categorization`, `pre-task` | Pre-Task |
| `student a`, `student b`, `teacher key`, `gap`, `complication`, `paso`, `negotiation` | Main Task |

The parser is **case-insensitive** on the matched substring and
**substring-based** (it matches whether the token appears as a
standalone phrase or embedded in a longer sentence). For each
artifact, the router returns a structured pair: `(selected: bool,
matched_tokens: [list])`. A non-empty `matched_tokens` list always
corresponds to `selected: true`; an empty list always corresponds
to `selected: false`. **Multiple matches across artifacts auto-
select multiple checkboxes**, each with its own matched-tokens list.
The teacher's free-text rejection is also **pre-filled into the
corresponding Reason field(s)** for every pre-selected artifact, so
the teacher can edit or confirm rather than re-type.

### Confirmation discipline  *(SSD §9.3)*

The teacher must explicitly confirm the auto-selected checkboxes
(`YES`) or override them (`NO` and re-select) **before** the
orchestrator re-delegates to the affected specialist(s). Auto-
routing without explicit confirmation is **forbidden** — the
teacher always has the final word on which specialist runs.

### `gate_d_rejection` Telemetry event  *(SSD §14 / Issue 09)*

When the teacher's confirmation finalizes the form (regardless of
whether the teacher accepted the auto-selection or overrode it),
the orchestrator emits a `gate_d_rejection` event (severity
`Telemetry`) via `safe_write()` to the per-course diagnostic log,
recording:

- `matched_tokens` — per-artifact list of keyword tokens the
  parser found; the artifacts with empty lists are still present so
  the absence of matches is observable.
- `selections` — per-artifact final selection booleans after the
  teacher's confirmation (which may equal the pre-fill or differ
  from it).
- `auto_routing_overridden` — boolean flag, `true` when the
  teacher's final selections differ from the keyword-pre-fill's
  auto-selections; `false` otherwise.
- The teacher's per-artifact `reason` text (the post-confirmation
  edited Reason fields).

### Re-delegation  *(SSD §9.4 — anchored here; full routing rules at §9.4)*

The form's confirmed selections drive the re-delegation. A single-
artifact selection re-runs only the affected specialist's round and
returns to that round's gate; a multi-artifact selection re-runs each
affected specialist in pedagogical order (Main → Pre → Post) and
passes through each subsequent gate. Upstream specialists are not
re-run when only a downstream artifact is rejected (SSD §9.4 closing
paragraph). A re-run round's log writes follow the split rejection
policy (SSD §11.5; companion to the F5 row-removal surface).

## Typed Invocation Contract  *(F8.cross.4 — ADR 0016)*

Every `Agent` call the orchestrator makes carries a **typed invocation
header** — a structured block at the top of the prompt payload, not a
prose cue. This replaces the legacy pipeline-identity prose form from
the v2.0-era input (retired per ADR 0016: prose-cued mode detection
drifts under model changes and produces silent double-elicitation or
skipped anti-repetition reads). Because every `Agent` call spawns a
fresh specialist instance with no memory of prior calls (ADR 0015 cold
resume), the invocation mode must travel in the payload itself.

The header declares **four required fields** on every call, regardless
of which specialist is being invoked:

- `mode` — exactly one of `pipeline` or `standalone`. In `pipeline`
  mode the specialist suppresses its own Phase 0 (no elicitation;
  inputs come from the SCB) and consumes the typed payload. In
  `standalone` mode the specialist runs its full elicitation surface
  (single-skill teacher use; retained per ADR 0016 consequences).
- `suppress_phase_0` — boolean. `true` whenever `mode` is `pipeline`;
  `false` in standalone mode. The orchestrator MUST emit this flag and
  the specialist MUST honor it independently (defense-in-depth per
  F8.cross.5). A specialist receiving `suppress_phase_0: true` refuses
  to surface any elicitation prompt for its Phase 0 inputs.
- `preserve_phase_neg1` — boolean. `true` on every pipeline call.
  Specialists' Phase −1 anti-repetition reads run regardless of mode;
  this flag exists to make the requirement explicit on the payload, so
  a future specialist version cannot silently skip Phase −1 even if
  its other behaviours suppress (the J17 "Phase −1 Preservation Rule"
  is enforced on a typed signal, not on prose).
- `session_payload` — the structured container carrying the frozen
  Shared Context Block (course rules + class profile + Phase 0 inputs,
  frozen at Gate A) and, for downstream rounds, the Activity Derivation
  Block extracted at Gate B from the Round 1 manifest. Specialists read
  inputs from this payload; they never re-derive context from prose
  hints in the prompt body.

Illustrative call-template shape (the four fields are required; the
internal ordering and exact serialisation of `session_payload` is open
and may evolve at later F8 steps):

```
{
  "mode": "pipeline",
  "suppress_phase_0": true,
  "preserve_phase_neg1": true,
  "session_payload": {
    "scb": { /* frozen at Gate A: course_profile, class_profile,
                 frameworks, Phase 0 inputs */ },
    "adb": { /* Gate B extraction from Round 1 manifest, present
                 on Round 2 + Round 3 calls only */ }
  }
}
```

**Defense-in-depth (F8.cross.5 companion).** Every content specialist
self-guards on `suppress_phase_0` and `preserve_phase_neg1` — the
orchestrator's emit-side guarantee is not sufficient on its own,
because each specialist is a freshly spawned instance per ADR 0015
(cold resume; no memory carried across calls). The specialist
inspects the header on every invocation and refuses to drift even if
the orchestrator's wording changes.

**Legacy retirement.** The v2.0-era prose-identity form is not used in
any specialist invocation in the rebuilt pipeline. F8.cross.4 surveys
all five instruction files for that legacy form and confirms its
absence; F8.cross.5 will verify the defense-in-depth self-guards on
the specialist surfaces once they are authored.

## Log Write Recovery Stack  *(F5 — `safe_write()` public interface)*

Every log write in the pipeline — per-course activity log, per-course diagnostic
log, cross-course telemetry feed — flows through a **single public interface**:

```
safe_write(path, row, course_id) → write_status
```

- `path` — the absolute log-file path resolved against the configuration root.
- `row` — the structured event/row to append (one JSON line for `.jsonl` files;
  one Markdown row for `.md` activity logs).
- `course_id` — used by the recovery stack to pick the correct course-scoped
  quarantine file when retries are exhausted.

The return value `write_status` is exactly one of:
`ok | ok_after_retry | quarantined | manual_fallback`.

**Single sanctioned write path.** Every agent uses `safe_write()`;
**no agent writes directly to a log file.** The Diagnostic Log Writer specified
below is refactored onto this interface: the append step described in that
section is the *underlying append* that `safe_write()` performs on the initial
attempt, and every diagnostic-log write the orchestrator emits flows through
`safe_write()`. The four content specialists (`tblt-activity-specialist`,
`tblt-inspector`, `tblt-pretask-specialist`, `tblt-reflective-specialist`)
consume this same interface in their own write paths (assembled in F8).

**Procedure (F5.1 — first attempt only).** Given `(path, row, course_id)`:

1. Perform the *underlying append* — the same append the Diagnostic Log Writer
   below performs: serialize `row` (one JSON line for `.jsonl`; one Markdown row
   for `.md` activity logs) and append it to `path`, creating the file if it is
   absent.
2. If the underlying append succeeds on the first try, return `write_status = ok`.
3. If the underlying append fails, the recovery stack's later layers — retry
   (Layer 1, F5.2), quarantine (Layer 2, F5.3), manual fallback (Layer 3, F5.4)
   — take over.

**Procedure (Layer 1 — retry, F5.2).** If the underlying append fails on the
initial attempt, retry **up to 3 times** with backoff delays of **100 ms**,
**500 ms**, **1 s** between successive attempts (i.e., wait 100 ms before
retry #1, then 500 ms before retry #2, then 1 s before retry #3). If any retry
succeeds, return `write_status = ok_after_retry` and emit a `log_write_retry`
event (severity `Telemetry`) to the diagnostic log recording the `path` that
recovered and the `attempt` count on which it succeeded. If all 3 retries also
fail, fall through to Layer 2 (quarantine, F5.3).

**Procedure (Layer 2 — quarantine, F5.3).** When the initial attempt and all 3
retries have failed, the recovery stack writes the row to the **quarantine
file** instead. The quarantine target is chosen from the original `path`:

- If the original target was the **cross-course telemetry feed**
  (`cross_course_telemetry.jsonl`), the quarantine path is
  `quarantine/cross_course_pending_log_writes.jsonl` (under the configuration
  root resolved per SSD §3.1).
- Otherwise (per-course activity log, per-course diagnostic log, anything
  else), the quarantine path is
  `quarantine/{course_id}_pending_log_writes.jsonl` keyed by the supplied
  `course_id`.

The recovery stack appends one JSON-Lines record to the chosen quarantine file
carrying enough context to replay the write on the next session's Phase −1
flush — at minimum: `target_path`, the original `row`, `course_id`, and the
timestamp when quarantine occurred. The quarantine file's directory is created
if it is absent. After a successful quarantine append, emit a
`log_write_quarantined` event (severity `Warning`) to the diagnostic log
naming the `path` that failed and the quarantine file it landed in, and return
`write_status = quarantined`. If the quarantine append itself fails, fall
through to Layer 3 (manual fallback, F5.4).

**Procedure (Layer 3 — manual fallback, F5.4).** When the initial attempt, all
3 retries, **and** the quarantine append have all failed, the recovery stack
surfaces an **inline operator message** so the operator can add the row by hand:

```
⚠ Auto-log failed — please add this row to {filename} manually:
{row}
```

where `{filename}` is the **original** `path` the row was meant to be appended
to (not the quarantine file — the quarantine file is itself unwritable) and
`{row}` is the serialized row (JSON line for `.jsonl` targets, the Markdown row
for `.md` activity logs). The recovery stack also emits a
`log_write_manual_fallback` event (severity `Error`) to the diagnostic log
naming the original `path` and the quarantine file that also failed, and
returns `write_status = manual_fallback`.

### Phase −1 Quarantine Flush  *(F5.5)*

At Phase −1 of every session — fresh or resumed — the orchestrator flushes any
pending quarantine entries **before** caching the activity-log path for the
downstream anti-repetition read. The flush walks the quarantine file
entry-by-entry. **For each entry** in a quarantine file:

1. Attempt to flush the entry into the real log file via the recovery stack —
   that is, call `safe_write(target_path, row, course_id)` using the values
   stored in the quarantine record.
2. If `safe_write` returns `ok` or `ok_after_retry`, **remove the entry from
   the quarantine file** — the row has now landed in its real log.
3. If `safe_write` returns `quarantined` or `manual_fallback`, **leave the
   entry in the quarantine file** and proceed to the next entry; the leftover
   entry will be retried again on the next session's Phase −1 flush.
4. For every attempt, emit a Telemetry/Warning event to the diagnostic log
   recording the attempt and its outcome. Every such event carries a
   `target` field whose value is either `per_course` or `cross_course`
   identifying which quarantine file the entry came from:
   - `quarantine_flush_attempted` (severity `Telemetry`) — emitted once per
     entry before the inner `safe_write` call.
   - `quarantine_flush_succeeded` (severity `Telemetry`) — emitted on
     `ok`/`ok_after_retry`.
   - `quarantine_flush_failed` (severity `Warning`) — emitted on
     `quarantined`/`manual_fallback`.

The flush iterates **every entry** in the file once per Phase −1; an entry's
failure does not stop the flush from attempting the remaining entries.

**Empty-file deletion (F5.7).** After the per-entry loop finishes, if the
quarantine file contains **zero remaining entries** (every entry it held was
successfully flushed and removed), **delete the quarantine file**. A
zero-byte file left on disk would look identical to a quarantine of one
about-to-be-written entry to anyone inspecting the filesystem; deleting the
empty file keeps the absence of pending writes legible.

### Phase 8 Callouts  *(F5.8 + SSD §13.2)*

At Phase 8 (session close-out), the orchestrator surfaces up to **three independent
callouts**. Any combination may fire in the same session; **no callout fires when
its condition is absent**:

- **Error-event callout** — fired only when any `Error`-severity event was emitted to
  the per-course diagnostic log during the session. Text:

  ```
  ⚠ N Error events emitted — review {course_id}_diagnostic_log.jsonl before next session.
  ```

  where `N` is the count of `Error`-severity events and `{course_id}` is the current
  session's course. When `N` is zero, this callout is **suppressed**.

- **Per-course callout** — fired only when
  `quarantine/{course_id}_pending_log_writes.jsonl` exists and contains at
  least one entry. Text:

  ```
  ℹ N pending log writes in quarantine for {course_id} — will retry on next session.
  ```

  where `N` is the count of entries in that file and `{course_id}` is the
  current session's course.

- **Cross-course callout** — fired only when
  `quarantine/cross_course_pending_log_writes.jsonl` exists and contains at
  least one entry. Text:

  ```
  ℹ N pending cross-course log writes in quarantine — will retry on next session.
  ```

  where `N` is the count of entries in that file.

The **three callouts are independent** — any combination may fire and each is
evaluated against its own condition. When all three conditions are absent (no Error
events, both quarantine files empty or deleted), no callout is surfaced — the
absence of all three is the clean-session signal.

### Diagnostic-Log Write Failure  *(F5.9 — exception to Layer 2)*

The diagnostic log uses the same recovery stack as every other log, with one
exception. When `safe_write` is invoked with `path` equal to the **diagnostic
log itself** — i.e., `{course_id}_diagnostic_log.jsonl` — and the initial
attempt and all 3 Layer-1 retries have failed, Layer 2's bookkeeping would
normally emit a `log_write_quarantined` Warning **to that same diagnostic
log** — which cannot be appended to, since the diagnostic log is exactly
what is broken.

In that case the recovery stack writes the failure event itself to the
per-course quarantine file **alongside the original row**, so that the next
session's Phase −1 flush replays **both**: the original diagnostic event
gets re-attempted, and the previously-undeliverable
`log_write_quarantined` Warning is delivered to the (now writable)
diagnostic log. Layer 2's diagnostic-log emit is suppressed in this case
(the file is broken; writing to it again would just re-fail).

The Layer 2 return value is still `quarantined`. The recovery stack's normal
path inspection — original target equals `{course_id}_diagnostic_log.jsonl`
— is what selects this branch.

### Activity-Log Row Removal  *(F5.10 — `remove row by session_id + round`)*

The per-course activity log (`{course_id}_activity_log.md`) supports one
additional operation on top of `safe_write()`'s append-only base:

```
remove_activity_row(activity_log_path, session_id, round) → removed_count
```

Calling `remove_activity_row` reads the activity log, removes every row whose
**`session_id` matches the supplied `session_id` AND `round` matches the
supplied `round`**, and writes the surviving rows back. Rows whose
`session_id` or `round` differs are preserved byte-for-byte and in their
original order.

This operation exists to serve the **split rejection policy** (ADR 0003,
SSD §11.5): per-course activity log writes are **overwrite-on-re-run within
the same session**. When a round is rejected at its confirmation gate and
re-run, the prior attempt's row for that `(session_id, round)` is removed
before the new attempt's row is appended via `safe_write()`. The anti-
repetition reader downstream therefore sees only **delivered** structures.

The operation is **not** part of the recovery stack proper — it is a
companion row-level mutation on the activity-log path that pairs with
`safe_write()` in the re-run path. The cross-course telemetry feed uses a
**different** policy (append-every-attempt with `superseded`, §11.5 / ADR 0003)
and does **not** expose row removal.

### Phase −1 Flush Ordering  *(F5.6 — cross-course flushed by any session)*

Phase −1 visits **two** quarantine files in a fixed order, **before** caching
the per-course activity-log path that downstream anti-repetition reads depend
on:

1. **Per-course quarantine** first.
   File: `quarantine/{course_id}_pending_log_writes.jsonl`, keyed by the
   `course_id` of the session currently running. The per-course quarantine is
   inspected **only when its matching course runs** — a Spanish General session
   does not flush the Spanish Health per-course quarantine, and vice versa.
   The per-entry loop above runs with `target = per_course`.
2. **Cross-course quarantine** second.
   File: `quarantine/cross_course_pending_log_writes.jsonl`. The cross-course
   feed is course-agnostic by design (ADR 0004), so its quarantine is
   **flushed by any session regardless of which course is running** — a
   Spanish General session flushes cross-course entries originally written by
   a Spanish Health session, and vice versa. The per-entry loop above runs
   with `target = cross_course`.
3. **Then** cache the per-course activity-log path for downstream Phase −1
   anti-repetition reads.

A teacher who only ever runs one course still flushes cross-course entries on
every session — their own course's session covers both targets.

## Diagnostic Log Writer  *(F1 — inner writer; wrapped by `safe_write()` above)*

The orchestrator records every significant pipeline event by **appending one
line** to the course's diagnostic log file. This is the raw writer; it is never
deployed on its own — F5 wraps it via `safe_write()`.

Procedure for emitting one diagnostic event:

1. Resolve the configuration root per SSD §3.1, in priority order:
   (a) if the `SPANISH_TBLT_LOG_DIR` environment variable is set, use that path
   as the configuration and log root;
   (b) otherwise use the Documents-folder default —
   `%USERPROFILE%\Documents\spanish-tblt\` on Windows,
   `~/Documents/spanish-tblt/` on macOS/Linux.
2. The diagnostic log is the JSON Lines file
   `<config_root>/<course_id>_diagnostic_log.jsonl`, selected by the event's
   `course_id` (`spanish_health` → `spanish_health_diagnostic_log.jsonl`,
   `spanish_general` → `spanish_general_diagnostic_log.jsonl`). An event is
   appended **only** to its own course's log; it is never written to another
   course's log file.
3. Serialize the event as **exactly one** JSON object on **one** line, carrying
   exactly the SSD §14 fields: `timestamp`, `session_id`, `course_id`, `agent`,
   `round`, `phase`, `severity` (one of `Error`, `Warning`, `Telemetry`),
   `event_type`, `criterion`, `details`. Serialize so that parsing the line back
   yields the same field values that were emitted.
4. **Append** that line to the file (create the file if absent). The log is
   append-only: an **existing log is never edited in place** — lines already
   written are never rewritten, reordered, or truncated. Every prior event
   survives byte-for-byte and round-trips on read-back.

5. If the append cannot be performed (target path unwritable, directory missing
   and not creatable, I/O error, …), **do not swallow the failure and do not
   silently no-op**. Surface a structured write-failure signal to the caller —
   carrying at least the target `path` and a `reason` — and return control to
   the caller. The raw writer performs **no** retry, quarantine, or fallback
   itself; those are the F5 recovery stack's responsibility (F5 wraps this
   writer via `safe_write()` and acts on the surfaced signal).

## SCB Snapshot — Instruction & Framework Hash Inventory  *(F8.cross.1)*

At **Gate A**, after the teacher confirms the merged context (course rules +
class profile + session inputs), the orchestrator **freezes the Shared Context
Block (SCB)** and captures a *snapshot hash inventory* of every input the
downstream pipeline depends on. The SCB and its snapshot are then immutable
for the lifetime of the session; the snapshot grounds cold-resume drift
detection (ADR 0008, 0012, 0015).

**Inventory: nine components — 5 instruction hashes + 4 ADR-0008 hashes.**

The snapshot is an ordered map whose nine entries are exactly:

- **5 instruction-file hashes** (the natural-language behaviour the
  specialists run; pinned per ADR 0012's `instruction_version` discipline):

  1. `tblt-orchestrator.md`
  2. `tblt-activity-specialist.md`
  3. `tblt-inspector.md`
  4. `tblt-pretask-specialist.md`
  5. `tblt-reflective-specialist.md`

  All five files live under `<config_root>/agents/` (SSD §16) and each
  declares an `instruction_version` field in its YAML frontmatter so a
  human-readable label travels with the hash. The hash is canonical
  (SHA-256 of file bytes) and identifies the exact instruction text in
  force at Gate A — a single character edit anywhere in any of these
  files changes that file's component hash.

- **4 ADR-0008 hashes** (the merged-context inputs the SCB freezes — the
  four "anchors" whose mutation would silently change what the pipeline is
  generating *for* if drift were not caught):

  6. `course_profile.md`        (the active course's profile, e.g.
     `<config_root>/profiles/courses/spanish_general_profile.md`)
  7. `class_profile.md`         (the active class's profile under
     `<config_root>/profiles/classes/…`)
  8. `lee-schell-framework.md`  (`<config_root>/frameworks/lee-schell-framework.md`)
  9. `shared-taxonomy.md`       (`<config_root>/frameworks/shared-taxonomy.md`)

**Procedure (Gate A — freeze).**

1. Resolve the four ADR-0008 anchors for the session (`course_profile.md` and
   `class_profile.md` are selected per the session's `course_id` /
   `class_id`; the two framework files are loaded from
   `<config_root>/frameworks/`).
2. Identify the five instruction files at `<config_root>/agents/tblt-*.md`.
3. For each of the nine components, compute the canonical SHA-256 hash of
   the file bytes and place it in an ordered map keyed by the component
   identifier above (the **inventory order** is fixed: instruction files
   1–5 then ADR-0008 anchors 6–9).
4. Persist the inventory inside the frozen SCB block of the session-state
   JSON at `<config_root>/sessions/<session_id>.json`. The SCB record
   carries, for each component, both the hash and the
   `instruction_version` value parsed from the file's frontmatter (the
   four framework/profile anchors have no `instruction_version`; their
   record carries the hash only). The inventory is **immutable** once
   Gate A confirms.

**Procedure (every later gate — drift recheck).**

At **Gate B**, **Gate C**, **Gate D**, **and on every cold resume before
the first specialist invocation**, the orchestrator **re-computes the
inventory** from the current files on disk and compares it
field-by-field against the frozen snapshot. The drift recheck runs
**before every specialist invocation** that crosses one of those four
points — it is the gate-crossing precondition, not a one-time check at
Gate B alone.

If any of the nine hashes differs from the snapshot, the orchestrator
emits a `resume_scb_drift_detected` diagnostic event (severity
`Warning`, naming the changed components) via `safe_write()` and halts
the round before any specialist runs (SSD §14, SSD §20). The event
payload names which of the nine components drifted so the teacher can
see what changed. There is **no automatic re-freeze** and **no
auto-refresh** option — the surface is the drift prompt described
below (SSD §20).

When drift is detected on cold resume, the orchestrator surfaces the
canonical resume drift prompt to the teacher: *"Continue with frozen
values (C, recommended for consistency) or Abandon session (A)?"* —
the teacher's choice resolves the situation (C → proceed with the
frozen SCB unchanged; A → informal abandonment per F8.orch.3 §9.6).

**Why nine.** The five instruction-file hashes pin *what the agents do*; the
four ADR-0008 anchors pin *what the agents are doing it about*. Together they
are the complete drift surface a cold resume must verify (ADR 0015): an edit
to any of the nine could silently produce a different output for the same
inputs. The frozen-SCB invariant (ADR 0008) is *exactly* the assertion that
this inventory is byte-identical at every gate crossing.

## Pipeline Walk — Phase −3 → 8  *(Issue 01 — SSD §7)*

The orchestrator walks the following phase sequence on every fresh session.
Each named phase is a distinct execution step; none is silently skipped.

| Phase | Orchestrator action |
|---|---|
| **Phase −3** | Load course profile (`course_profile.md`) from `profiles/courses/{course_id}_profile.md`. First-run (absent): structured elicitation → create file. Second-run (present + fresh): load silently. Stale: surface staleness confirmation (see *Course + Class Profile Layer*). |
| **Phase −2** | Load class profile (`class_profile.md`) from `profiles/classes/{class_id}_profile.md`. Same first/second/stale logic, applied independently to the class layer. |
| **Phase −1** | Quarantine flush and activity-log path cache in the fixed ordering: (1) flush per-course quarantine, (2) flush cross-course quarantine, (3) cache the `{course_id}_activity_log.md` path for anti-repetition reads. (See *Phase −1 Flush Ordering* in the Log Write Recovery Stack.) |
| **Phase 0** | Sequential elicitation of all session inputs: topic, goal, vocabulary (8–25 items, without recommendations), grammar (exactly 2, without recommendations), task type, complication candidate, register, transfer goal, success criteria (3–5), `writing_genre` (≥3 recommendations), `register_shift_pattern` (≥3 recommendations). Invalid-input counter is session-wide in-memory. |
| **Phase 1** | Canonicalize and freeze PVS; assemble SCB; compute nine-component snapshot hash inventory. |
| **Gate A** | Teacher confirms design brief (explicit `YES` required — no auto-advance). SCB frozen; `session.json` written (see *Session State*). |
| **Round 1** | Invoke `tblt-activity-specialist` (typed invocation contract, `mode: pipeline`). Then `tblt-inspector` evaluation. |
| **Gate B** | Teacher confirms Main Task files (explicit `YES` required). ADB extracted; `session.json` updated. |
| **Round 2** | Invoke `tblt-pretask-specialist` (ADB in `session_payload`). |
| **Gate C** | Teacher confirms Pre-Task files (explicit `YES` required). `session.json` updated. |
| **Round 3** | Invoke `tblt-reflective-specialist` (SCB-frozen `writing_genre`/`register_shift_pattern` in payload). |
| **Gate D** | Structured rejection form (explicit `YES` required). `session.json` updated. |
| **Phase 7** | Pipeline Summary Card + cross-round integrity verification. |
| **Phase 8** | Auto-open student artifacts; teacher-file open-after-confirm; diagnostic summary on Error events; Phase 8 quarantine callouts (see *Phase 8 Quarantine Callouts*). |

### No-Auto-Advance Rule  *(01.10 — SSD §9.3)*

The orchestrator **never auto-advances through any gate**. Each of Gate A,
Gate B, Gate C, and Gate D requires an **explicit `YES` confirmation from the
teacher** before the pipeline proceeds to the next phase or round. The
teacher's `YES` is the only mechanism that advances the pipeline past a gate;
a timeout, a silence, a default, or any orchestrator-internal decision is
not a valid gate confirmation.

### Phase Transition Telemetry  *(01.9 — SSD §14)*

At every phase-entry listed in the table above, the orchestrator emits
**at least one `Telemetry`-severity diagnostic event** via `safe_write()`
to the per-course diagnostic log. Each event carries the `phase` field
naming the phase being entered, plus the current `session_id`, `course_id`,
and `round` (`null` for pre-Gate-A phases where no round is active).

This contract guarantees **at least one Telemetry event per phase
transition** — the diagnostic log is a navigable record of the pipeline's
progress through the session.

## Session State — session.json  *(Issue 01 — SSD §3.5 / §20.6)*

The orchestrator writes `<config_root>/sessions/<session_id>.json` at every
confirmed gate. The file is flat (not per-course) and accumulates session
state across all gates. Three field groups relevant to behavioral
verification:

**SCB (`scb` block).** The frozen Shared Context Block assembled at Phase 1
and confirmed at Gate A. `scb.status` transitions from `"draft"` to
`"frozen"` when the teacher confirms Gate A. The nine-component snapshot hash
inventory is persisted inside the `scb` block alongside all Phase 0 inputs
(including the frozen `writing_genre` and `register_shift_pattern`). The SCB
block is **immutable** once Gate A confirms — downstream rounds read from it
and never re-derive it.

**PVS (`scb.pvs` array).** The Permitted Vocabulary Set assembled at Phase 1,
stored as `scb.pvs` inside the `scb` block. Written to `session.json` at Gate
A confirmation along with the rest of the frozen SCB.

**Gate status.** Updated at each confirmed gate:
- Gate A confirmation → `scb.status: "frozen"` written; `rounds.round_1.status:
  "not_started"` (initial state for the upcoming round).
- Gate B confirmation → `rounds.round_1.status: "passed_gate_B"`; ADB extracted.
- Gate C confirmation → `rounds.round_2.status: "passed_gate_C"`.
- Gate D confirmation → `rounds.round_3.status: "passed_gate_D"`;
  `gate_d.status: "passed"`.

The `last_updated_at` timestamp is refreshed on every gate-confirmation write.
Per-gate rejection counters (`rounds.round_N.rejection_count`) are also
persisted here (ADR 0007 / SSD §20.5) — a resumed session reads back the
persisted counter state; no fresh budget is granted on resume.

## Session Resume — Entry Point + Gate Dispatch  *(Issue 08 — SSD §20 / ADR 0015)*

### Resume detection and confirmation

On startup, if an existing `sessions/{session_id}.json` is found under
`<config_root>/sessions/`, the orchestrator surfaces a one-line confirmation:

> `Resume session {session_id} ({course_id}) paused at {current_phase}? (YES to resume / NO to start fresh)`

A teacher **YES** enters the resume path; **NO** starts a fresh session with a new
`session_id`. The session state file is stored **flat at `sessions/{session_id}.json`,
outside the per-course namespace** (SSD §20.4) — the `{session_id}` filename is the
sole key; no `{course_id}` subdirectory is used.

### Top-level field load — no re-elicitation

On resume the orchestrator reads `course_id` and `class_id` from the session
file's **top-level fields** (SSD §20.6). These are **never re-elicited**. All
Phase 0 inputs — `writing_genre`, `register_shift_pattern`, vocabulary, grammar,
topic, complication, register, transfer goal, success criteria — are already
persisted in the frozen `scb` block; the orchestrator reads them verbatim from
`session.json` and does not re-prompt for any input that was answered before the
pause (SSD §20.1). **Phase 0 is not re-run on resume** — Phase 0 elicitation is
suppressed in its entirety on the resume path.

### Resume order

After the teacher confirms resume, the orchestrator executes in this order before
dispatching to the next generation step:

1. **Transition log entry** — append a resume event to `transition_log` in
   `session.json`:
   ```json
   { "phase": "resume", "at": "<ISO 8601 timestamp>", "event": "session_resumed" }
   ```
   This entry is written immediately after the teacher's YES confirmation.
2. **Phase −1** — run Phase −1 fresh in the §6.2 order (per-course quarantine
   flush → cross-course quarantine flush → activity-log path cache). Identical
   to Phase −1 on a fresh session; anti-repetition reads reflect rows written by
   other sessions during the pause (SSD §20.3 / ADR 0004; see *Phase −1 Flush
   Ordering* above).
3. **SCB drift check** — recompute the nine-component hash inventory and compare
   to the frozen snapshot (see *SCB Snapshot* above). If any component drifted,
   the `resume_scb_drift_detected` Warning is emitted and the Continue/Abandon
   drift prompt is surfaced before dispatching.
4. **Gate dispatch** — select the resume point from the table below.

### Gate dispatch

| `session.json` condition | Resume action |
|---|---|
| `scb.status: "frozen"` and `rounds.round_1.status: "not_started"` | Invoke `tblt-activity-specialist` (Gate A was the last confirmed gate; resume at **Round 1** generation with the frozen SCB and PVS) |
| `rounds.round_1.status: "passed_gate_B"` and Round 2 not yet started | Invoke `tblt-pretask-specialist` with the **ADB read from `session.json`** (Gate B confirmed; ADB already extracted and persisted — no re-extraction from the manifest on resume) |
| `rounds.round_2.status: "passed_gate_C"` and Round 3 not yet started | Invoke `tblt-reflective-specialist` with the ADB read from `session.json` (Gate C confirmed) |
| `gate_d.status: "passed"` | Session already complete — see *Completed-session guard* below |

The ADB used on a Gate-B or Gate-C resume is the four-field block already
persisted in `session.json` at Gate B confirmation:
`activity_pvs_items_used`, `confirmed_complication`, `confirmed_outcome`,
`gap_summary` (see *Gate B — Main Task Teacher Review* above). No re-extraction
from the manifest file is performed on resume.

### Completed-session guard

If `gate_d.status: "passed"` — the session ran through Phase 8 and the
`session_completed` event was already emitted — the orchestrator informs the
teacher that the session is already complete and does not re-run any generation
round:

> `Session {session_id} is already complete (Gate D passed). Re-open the artifacts? (YES / NO)`

**YES** re-opens the student artifact set per the Phase 8 auto-open discipline
(resource gap: 4 student files; oral gap: 3 student files) followed by the
teacher-file open-after-confirm prompt (ADR 0019). **NO** ends the interaction
without opening any files. No specialist is invoked and no new log row is written
on this path.

## Inspector Placement — Between Round 1 Generation and Gate B  *(03.5 — SSD §19)*

After `tblt-activity-specialist` completes Round 1 generation (Phase 5b log write
included), and before Gate B is presented to the teacher, the orchestrator invokes
`tblt-inspector` with the Round 1 manifest, the A/B representation, and the rendered
artifacts. The inspector evaluates the Main Task and returns one of three verdicts:

- **CONVERGED** — Gate B opens. The teacher sees the Main Task files presented
  separately (see Gate B section below).
- **ESCALATE** — Gate B opens with an escalation notice. The teacher sees the Main
  Task together with the escalated criteria and the revision history recorded in
  `inspector_exchange.md`.
- **FEEDBACK** — Gate B does not open. The orchestrator passes the revision
  instructions from the inspector back to `tblt-activity-specialist` for a single
  revision round, then re-invokes the inspector. This loop runs at most twice (two
  evaluation rounds total) before the verdict is CONVERGED or ESCALATE.

**The teacher never sees a Main Task that has not converged or been escalated.**
Gate B is not presented until the inspection loop concludes with either CONVERGED
or ESCALATE.

## Gate B — Main Task Teacher Review  *(02.16 — SSD §9 / ADR 0017)*

Gate B is the first teacher-facing review gate after content generation. It
triggers when Round 1 converges (the activity specialist has produced its
artifacts and `tblt-inspector` has returned `CONVERGED`).

### Main Task files presented separately

The orchestrator presents the Main Task files to the teacher **individually**
for review — not bundled — so the teacher can evaluate student and teacher
artifacts as distinct items (SSD §9 Gate B row). The number of files presented
depends on `gap_type` (ADR 0017):

- **`oral` gap** — two files are presented for review:
  1. `student.html`
  2. `teacher_key.html`

- **`resource` gap** — three files are presented for review:
  1. `student_a.html`
  2. `student_b.html`
  3. `teacher_key.html`

The `ab_representation.yaml` is available for reference but is not itself a
teacher review artifact; the teacher reviews the rendered HTML artifacts.

### On approval

The teacher's explicit `YES` at Gate B triggers:
1. **ADB extraction** — the orchestrator extracts the **Activity Derivation
   Block** (ADB) from the Round 1 manifest and persists it in session state.
   The ADB is the fragment downstream rounds (Round 2 pretask, Round 3
   reflective) consume to stay aligned with the Main Task. The orchestrator
   is the **emitting side** of contract C6 (ADB hand-off); the pretask and
   reflective specialists are the consuming sides (see
   `inter-agent-contracts.md` § C6). The ADB contains the following four
   fields extracted from the Round 1 manifest:
   - **`activity_pvs_items_used`** — the PVS vocabulary items that appeared
     in the Round 1 Main Task.
   - **`confirmed_complication`** — the confirmed complication from Round 1.
   - **`confirmed_outcome`** — the confirmed outcome from Round 1.
   - **`gap_summary`** — a summary of the information gap structure (who
     holds what, what A must discover from B, communicative stakes).
2. **`session.json` update** — `rounds.round_1.status` set to `"passed_gate_B"`;
   ADB persisted in session state (see *Session State* above).
3. **Round 2 invocation** — `tblt-pretask-specialist` is invoked with the ADB in
   `session_payload`.

### On rejection

A teacher `NO` at Gate B routes to a re-run of `tblt-activity-specialist` (with
the teacher's stated reason). The per-gate retry ceiling applies (see *Retry
Ceiling + Phase 0 Input-Validation Counter*); after three rejections the R/U/A
menu surfaces.

## Gate C — Pre-Task Teacher Review  *(05.10 / 05.12 — SSD §9 / ADR 0017)*

Gate C is the teacher-facing review gate after Round 2 (Pre-Task) generation.
It opens when `tblt-pretask-specialist` has completed its Phase 5b writes and
returned its Round 2 artifacts to the orchestrator.

### Pre-Task artifacts displayed

The orchestrator presents the following Round 2 artifacts to the teacher for
review — displayed **separately**, not bundled, so the teacher can evaluate
each artifact as a distinct item (SSD §9 Gate C row):

1. **Coherence audit** — the `coherence_audit.coverage` block from the Round 2
   manifest. This shows how each ADB item (from Round 1) is addressed by the
   Pre-Task, including the rationale for each coverage entry. The teacher sees
   this alongside the Pre-Task files to confirm pedagogical alignment between
   Round 1 and Round 2.
2. **`pretask_student.html`** — the student-facing pre-task exercise sheet.
3. **`pretask_teacher.html`** — the teacher copy, including the answer key.

The coherence audit is displayed first so the teacher can cross-reference it
while reviewing the two HTML files. All three items are presented as distinct,
individually reviewable artifacts, not merged into a single display.

### On approval

The teacher's explicit `YES` at Gate C triggers:
1. **`session.json` update** — `rounds.round_2.status` set to `"passed_gate_C"`.
2. **Round 3 invocation** — `tblt-reflective-specialist` is invoked with the
   same ADB in `session_payload` (the ADB extracted at Gate B is unchanged;
   Round 3 consumes the same ADB as Round 2).

### On rejection

A teacher `NO` at Gate C routes to a re-run of `tblt-pretask-specialist` (with
the teacher's stated reason). The per-gate retry ceiling applies; after three
rejections the R/U/A menu surfaces.

## Phase 7 — Pipeline Summary Card  *(Issue 07 — SSD §13)*

After Gate D approval the orchestrator produces the **Pipeline Summary Card** at
Phase 7. The card has **three sections**:

### Section 1 — Per-artifact summaries

One block per Round (Round 1 / Main Task, Round 2 / Pre-Task, Round 3 / Post-Task).
Each block lists the artifact filenames for that round and includes two items from
the round's manifest:

- **Phase 5a feedback ratings** — the card reads `phase_5a_quality` (1–5 or null),
  `phase_5a_engagement` (1–5 or null), and `phase_5a_note` (string or null) from each
  round's manifest. These values were already captured by each specialist at its own
  Phase 5b; the card surfaces all three Phase 5a captures (one per round) for a
  consolidated view. **No additional teacher rating step is introduced at the pipeline
  level** (SSD §13) — the card reads `phase_5a` fields from the manifests directly,
  not from a new close-out elicitation.
- **Log-write status** — `log_write` and `cross_course_feed_write` for that round
  (feeds into the integrity verification section below).

### Section 2 — Shared thread

A cross-round narrative connecting the Main Task complication and outcome (from the
ADB) to the Pre-Task bridge exercise and the Post-Task writing prompt — confirming
pedagogical alignment across all three rounds. No new teacher input is required.

### Section 3 — Integrity verification  *(SSD §13.1 — expanded in v2.1 + v2.2)*

Each item displays **✓** when the condition is satisfied, or a **specific drift
report** when not. All items are checked in a single Phase 7 pass over the three
round manifests and the session state:

| Integrity check | Pass condition | Fail output |
|---|---|---|
| **Log writes (all rounds)** | Every round's `log_write` ∈ `{ok, ok_after_retry}` | ⚠ names round + actual status |
| **Cross-course feed writes** | Every round's `cross_course_feed_write` ∈ `{ok, ok_after_retry}` | ⚠ names round + actual status |
| **Canonical label compliance** | No non-canonical label in any manifest | ⚠ names the label(s) and which round |
| **PVS drift (Round 1 → Round 2)** | Pre-Task `activity_pvs_items_used` subset ⊆ Round 1 `activity_pvs_items_used` | ⚠ lists the drifted PVS items |
| **Grammar drift (Round 1 → Round 3)** | Round 3 manifest grammar targets match the frozen SCB grammar structures | ⚠ names the drifted grammar forms |
| **F6 structural validation** | All generated HTML files carry `structural_validation_passed: true` | ⚠ names the failing artifact |
| **F7 coherence audit (Rounds 2–3)** | Both Round 2 and Round 3 `coherence_audit.coverage` blocks passed F7 | ⚠ names the failing round and criterion |
| **Round 3 log write (symmetric — ADR 0002)** | `tblt-reflective-specialist` wrote the Round 3 row at its own Phase 5b (`log_write: ok \| ok_after_retry`) | ⚠ surfaces actual write status (e.g. `quarantined`) |
| **`posttask_teacher.html` pair (ADR 0019)** | `posttask_teacher.html` was written alongside `posttask.html`; `posttask.html` contains no `.teacher-page` element | ⚠ flags the ADR 0019 violation |
| **Dialect exclusion** | No `dialect_excluded_feature_detected: true` in any manifest | ⚠ names round + excluded feature |

Each integrity check in the table is independent — a failure on one item does not
suppress the display of others. The card presents all items whether they pass or fail.

## Phase 8 — Session Close-Out  *(Issue 07 — SSD §13.2 / ADR 0019 / ADR 0021)*

Phase 8 runs after Gate D approval and the Phase 7 Pipeline Summary Card.

### Artifact auto-open  *(ADR 0019)*

The orchestrator auto-opens the **student** HTML artifacts in the browser
immediately — the student files contain no answer keys and require no confirmation
before display. The student file set is gap-type conditional:

- **Resource gap:** four student files auto-open — `student_a.html`, `student_b.html`,
  `pretask_student.html`, `posttask.html`.
- **Oral gap:** three student files auto-open — `student.html`, `pretask_student.html`,
  `posttask.html`.

The three **teacher** files (`teacher_key.html`, `pretask_teacher.html`,
`posttask_teacher.html`) are opened **only after the teacher confirms** with a
single prompt — *"Open teacher files now? (YES to open)"* — to avoid projecting
answer keys when the student display is visible (ADR 0019). This is the same
open-after-confirm discipline applied to the teacher key at Gate B (ADR 0019).

### Phase 8 callouts

See *Phase 8 Callouts* section above for the three independent callouts (Error-event,
per-course quarantine, cross-course quarantine). All three are evaluated and surfaced
at Phase 8 before the `session_completed` event.

### `session_completed` event  *(ADR 0021 — SSD §14)*

At Phase 8 close-out, after the callouts, the orchestrator emits a `session_completed`
event (severity `Telemetry`) via `safe_write()` to the per-course diagnostic log.
This is the **positive completion signal** — a session with no `session_completed` row
in the diagnostic log is, by construction, incomplete or abandoned (ADR 0021; the
absence of a `session_completed` row paired with a Trial Journal entry denotes an
abandoned session without requiring a `session_abandoned` event — ADR 0007 silence
preserved). Fields per SSD §14:

- `session_id`, `course_id`
- `gates_passed` — list of gates that received explicit `YES` confirmation
- `rejections_per_gate` — per-gate rejection count map (`{B: n, C: n, D: n}`)
- `inspector_revision_count` — how many FEEDBACK rounds `tblt-inspector` ran
- `f6_halt_count` — how many times F6 halted a round before log write
- `f7_halt_count` — how many times F7 halted a round before log write
- `reach_in_free` — boolean; set by one builder confirmation at close-out:
  *"Was this a reach-in session where you revised content directly? (YES/NO)"*
  The operator's answer sets this flag; no new artifact is written by the system.
- `checklist_flags` — checklist-relevant boolean flags observed during the session
