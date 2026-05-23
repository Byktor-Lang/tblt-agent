# HTML Structure Schema

The structural conformance schema for rendered HTML artifacts produced by the
TBLT pipeline. This file is the single source of truth for the structural
validator (F6): a hand-authored declaration of the required elements, classes,
and YAML↔HTML correspondences that every rendered artifact must satisfy
before its round's log write.

This file is **agent-agnostic** — it describes the artifact, not which
process produces it. Multiple distinct content-producing processes may load
this schema and execute the checks; on identical input every loader returns
identical results.

## How F6 uses this file

F6 performs two sequential checks against every rendered HTML artifact before
the round's log write:

**Check A — Schema conformance.** The HTML contains every required element
for its declared artifact type (global requirements plus the
artifact-type-specific list below). A missing required element emits
`structural_validation_failed` (Error) naming the missing class and the
artifact type.

**Check B — YAML correspondence.** Observable HTML features match the
companion `ab_representation.yaml`. A mismatch emits
`structural_validation_failed` (Error) naming the YAML field that diverged
and the expected vs. actual value where applicable.

**Ordering.** Check A runs first. A Check A failure halts before Check B
runs — Check B is **never** executed when Check A has failed. Either failure
prevents the round's log write.

**Scope and idempotence.** F6 runs once at generation time, on the
freshly-rendered HTML files in the lesson output directory. The
`structural_validation_passed: true | false` field in the round manifest is
the sole result carrier on session resume — F6 is not re-invoked at gate
crossings (cold-resume design). Post-generation human edits to HTML files
are tolerated by convention; F6 cannot and does not re-run on edited files.

## Global requirements (Check A — all artifacts)

Applied before artifact-type checks. A violation of any global requirement
is a Check A failure naming the violating element and the artifact.

1. `<!DOCTYPE html>` present.
2. `<html lang="en">` — primary language English; Spanish content carried in
   `<em>` or `<span lang="es">`.
3. `<meta charset="UTF-8">` present.
4. `<title>` present and non-empty.
5. `<style>` block present containing all of:
   - A `:root { }` block declaring at minimum these design tokens:
     `--font-family`, `--page-width: 21cm`, `--primary-color`,
     `--border-color`. (Course profile additive overrides may add tokens;
     base tokens are required.)
   - An `@page { size: A4 portrait; margin: 1cm; }` rule.
   - An `@media print { }` block.
6. No `<link rel="stylesheet">` element — every style is inline.
7. No `<script src="...">` element — no external scripts.
8. No element bearing class `.teacher-page`. Teacher content is **always** in
   a separate file. This global rule applies to every artifact, including
   teacher artifacts (which carry their own `.teacher-header` instead).

## Artifact-type requirements (Check A)

Each artifact type below lists the elements / classes / nesting required for
that artifact. Course-profile additive overrides may add further required
elements (see "Course override protocol"); they may not remove or relax
any base requirement.

### `student.html` — Round 1, oral gap

- One `.activity-header` containing `.activity-title` and `.activity-subtitle`.
- At least one `.step-container`, each containing `.step-header` as a direct
  or descendant child.

### `student_a.html`, `student_b.html` — Round 1, resource gap

The `student.html` baseline plus:

- Each file contains a `.resource-panel` element with the student's
  information-card content.
- The two files must contain **distinct** content inside `.resource-panel`.
  Check B verifies this against the YAML
  `student_a_resources` / `student_b_resources` fields (or, in their
  absence, by direct text-content inequality).

### `teacher_key.html` — Round 1, all gap types

- One `.teacher-header` element bearing a "Do Not Distribute" label.
- At least one `.teacher-section`, each containing
  `.teacher-section-title` and `.teacher-note`.
- One `.answer-key` section.

### `pretask_student.html` — Round 2

- One `.activity-header` containing `.activity-title`.
- One `.student-info` block (name / date / class fields).
- At least one `.step-container` containing `.step-header`.

### `pretask_teacher.html` — Round 2

- One `.teacher-header` with the "Do Not Distribute" label.
- At least one `.teacher-section` containing `.teacher-section-title` and
  `.teacher-note`.
- One `.answer-key` section.

### `posttask.html` — Round 3, student

- One `.activity-header` containing `.activity-title`.
- One `.student-info` block (name / date / class fields).
- One `.register-shift-table` — **always required** (the defining structural
  feature of the post-task; its absence signals a design problem, not a
  schema exception).
- One `.writing-task-container` whose `<style>` block declares
  `break-inside: avoid` for that class, containing as **direct children**:
  - One `.writing-prompt-section`.
  - One `.checklist-section` containing `.single-column-list` with at least
    three `.list-item` elements.

  A `.writing-task-container` is **mis-nested** if either of these direct
  children is missing or appears under any intermediate element. The
  diagnostic distinguishes "container absent" from "container present, child
  X missing or mis-nested."

### `posttask_teacher.html` — Round 3, teacher

- One `.teacher-header` with the "Do Not Distribute" label.
- One `.scenario-anchor` section carrying genre, audience, complication,
  outcome, and stakes-line content.
- At least one `.teacher-section` containing `.teacher-section-title` and
  `.teacher-note`.

## Check B — YAML correspondence rules

F6 reads `ab_representation.yaml` from the lesson output directory and
verifies the following correspondences. A mismatch emits
`structural_validation_failed` (Error) naming the YAML field that diverged
and (where the rule is a count) the expected and actual values.

| YAML field | HTML check |
|---|---|
| `gap_type: oral` | Only `student.html` is present in the lesson directory; **no** `student_a.html` and **no** `student_b.html`. |
| `gap_type: resource` | **Both** `student_a.html` and `student_b.html` are present; `student.html` is absent. |
| `pasos: [{id: N, …}]` (length N) | Exactly N `.step-container` elements in the student file(s). |
| `pasos: [{id: N, type: TF}]` | Step N's `.step-container` contains a table with True/False-labelled columns. |
| `pasos: [{id: N, type: SORT}]` | Step N's `.step-container` contains a `.two-col` sort layout or equivalent. |
| `pasos: [{id: N, type: MATCH}]` | Step N's `.step-container` contains a matching-pair structure. |
| `pasos: [{id: N, type: FREQ}]` | Step N's `.step-container` contains a frequency-scale table. |
| `register_shift_pair_count: N` | `.register-shift-table` in `posttask.html` contains exactly N data rows. |
| `checklist_item_count: N` | `.checklist-section .list-item` count equals N. |
| `student_a_resources` / `student_b_resources` | `.resource-panel` content differs between `student_a.html` and `student_b.html`. |

The two file-set rules (`gap_type: oral` / `gap_type: resource`) are checked
before the count rules — they decide which student artifact filenames the
remaining checks should consult.

## Course override protocol

A course profile may declare additional required elements per artifact type.
Overrides are **additive only** — a course can require more, never less.
A course profile cannot remove, relax, or replace any base requirement
above.

Declared in the course profile under
`output_template_overrides.html_structure_schema`. Format:

```yaml
output_template_overrides:
  html_structure_schema:
    additional_required_elements:
      pretask_student:
        - class: ".medical-disclaimer"
          description: "Required health-context block; must appear before Paso 1"
      posttask:
        - class: ".health-register-note"
          description: "Required register note for medical contexts"
```

**Application order.** F6 applies the global requirements first, then the
artifact-type base requirements, then the course additions. A missing
course-required element is a Check A failure; the diagnostic message names
the course (and the bound class — see below) alongside the missing class.

**Course + class naming.** When a class profile is bound to the session,
the diagnostic names both the course and the class so that a teacher
running multiple sections can locate the source of the missing element.

## Halt-before-log-write

A Check A or Check B failure halts the round at the structural-validation
step. **No** activity-log row is written for that round; **no**
cross-course telemetry row is appended. The failure surfaces to the caller
for routing (typically: invalidate the artifact, prepare a re-run, leave
prior delivered rows untouched). This fail-fast posture is the source of
F6's guarantee that the activity log contains only structurally-valid
artifacts.

## Two-loader determinism

F6 is a pure function of its inputs (the rendered HTML files in the lesson
output directory plus the companion `ab_representation.yaml`). It has no
randomness, reads no agent-specific state, and consults no external
context. Two distinct loaders that execute the checks described here
return **identical results** for identical input — the same pass/fail
verdict, the same diagnostic class name, the same expected/actual count
where applicable. Loaders run *this* specification verbatim; neither
re-derives nor extends the checks.

## Flagged ambiguities

- **`.resource-panel` content distinctness (Check B).** Establishing that
  `student_a.html` and `student_b.html` have *different* content inside
  `.resource-panel` is a comparison check. The structural rule: the *text
  content* of `.resource-panel` in `student_a.html` must not equal the
  *text content* of `.resource-panel` in `student_b.html`. When the two
  text contents are byte-identical after whitespace normalisation, emit
  `structural_validation_failed` with the message "`student_a` and
  `student_b` resource panels have identical content." The pedagogical
  quality of the difference is **not** F6's concern.

- **Paso-type heuristic depth.** The `pasos[].type` mappings (TF / SORT /
  MATCH / FREQ) check for the structural pattern associated with each
  type. The deeper question of whether the pattern is pedagogically apt
  for the declared type is outside F6's scope.

## Maintenance

This schema is hand-authored. Add new artifact-type sections or
requirements by appending to the relevant list; never silently remove or
relax an existing requirement. When a new artifact type is introduced,
add its section before any process is asked to validate it.
