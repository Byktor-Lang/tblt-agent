# Lee-Schell Evaluation Framework — TBLT Main Task Assessment

**Version:** 1.0 · 2026-05-19  
**ADR basis:** ADR 0005 (structural validation separate), ADR 0009 (novelty signature, freshness anchors), ADR 0024 (Layer B additive 5 items; two-state denominator)  
**Status:** Teacher-approved 2026-05-23 — no changes required (ADR 0011 / F2.6)

---

## Application Notes

This framework is used in two distinct modes. The mode is determined by the calling context, not by the framework itself.

### Generative use

Applied *during activity authoring*, before the artifact is complete. Use each criterion as a design target:

- Ask: "Does my current design satisfy the minimum threshold for this criterion?"
- For kill criteria: verify that none are triggered before proceeding.
- For Layer A: each criterion must reach ≥ 2 in the final artifact. Use the observable indicators to self-check design decisions at each Paso.
- For Layer B (excluding Structural freshness): each criterion must reach ≥ 1, and at least one must reach 3. Use the anchors to identify which criterion your design is naturally strongest on, and design toward that.
- Structural freshness is read-only in generative mode: it is computed from the course history log at generation time, not designed for.
- Extended Discourse Check: treat YES answers as design goals; design Paso 3 and Paso 5 to earn them.

### Evaluative use

Applied *after the artifact is complete*, on the finished Main Task package. Assign a score to each criterion:

- Score each criterion independently using only the observable indicators and the artifact in front of you.
- Do not confer with generative-mode assessments or internal design notes.
- Kill criteria that are triggered generate highest-priority revision instructions regardless of rubric scores.
- Layer A criteria below 2 generate required revision instructions. Layer B criteria at 0 generate required revision instructions.
- Extended Discourse Check items that return NO generate optional improvement suggestions.
- After scoring, apply the Convergence Rule to determine verdict.

---

## Kill Criteria

Five conditions that, when triggered, generate the highest-priority revision instructions. Kill criteria do not halt the loop — they produce specific structural revision instructions that must be addressed before the next evaluation round.

Kill criteria are evaluated before Layer A and Layer B. In evaluative mode, a triggered kill criterion appears as the first item in the required revision list.

| Criterion | YAML key | How to check |
|---|---|---|
| Task is individually solvable | `individually_solvable` | Could one student complete the full worksheet without a partner? If YES → triggered. |
| Only yes/no answers required | `yes_no_only` | Does task resolution require no elaboration beyond binary responses? If YES → triggered. |
| No negotiation required | `no_negotiation` | Does any Paso contain a decision point where partners must align on an answer? If NO decision point exists → triggered. |
| Completable without target language | `exploit_detected` | Could game mechanics (tallying, checking boxes, pointing) replace Spanish production? If YES → triggered. |
| Speaking avoidable | `speaking_avoidable` | Are all Pasos write-only with no moment requiring spoken Spanish? If YES → triggered. |

**`no_negotiation` direction note:** this criterion is triggered (= `true`) when NO negotiation is present. Set `no_negotiation: true` to flag a problem — the activity lacks a required alignment decision point.

In evaluative mode, record `any_triggered: true` if one or more criteria are triggered.

---

## Layer A — Lee's Hardware (Pedagogical Validity)

**Scoring threshold (evaluative):** all four criteria must score ≥ 2. Any criterion below 2 generates a required revision instruction.

**Design target (generative):** design decisions should move each criterion toward ≥ 2.

---

### A1 — Information Gap (0–3)

*Does the task structurally require partners to exchange information they cannot access alone?*

| Score | Anchor |
|---|---|
| 0 | No gap. One student could answer all questions alone. |
| 1 | Gap is optional. Students could skip the exchange. |
| 2 | Gap is structurally needed for at least one Paso. |
| 3 | Gap is essential across all major Pasos. No Paso is completable without partner input. |

**Observable indicator:** Mentally remove one student from the pair. Can the remaining student complete more than 50% of the activity? If yes → score ≤ 1.

---

### A2 — Interaction Dependency (0–3)

*Does the task require sustained partner interaction, not just a single exchange?*

| Score | Anchor |
|---|---|
| 0 | Task individually completable. |
| 1 | Partner adds convenience but is not required. |
| 2 | At least 2 Pasos require partner input to proceed. |
| 3 | Every Paso builds on the partner's previous response. Dependency is cumulative. |

**Observable indicator:** Identify which Pasos stall if the partner gives no response. Count them. Score 2 requires at least 2 stalling Pasos; score 3 requires all Pasos.

---

### A3 — Target Structure Deployment (0–3)

*Are the target grammar structures required in student production, not just referenced in instructions?*

| Score | Anchor |
|---|---|
| 0 | Both target grammar structures absent from student production slots. |
| 1 | Structures appear in instructions or example chrome only — not in student output requirements. |
| 2 | At least one structure is required in student production (sentence frames or dialogue slots). |
| 3 | Both structures required in student production AND appear in Paso 3 live exchange slots. |

**Observable indicator:** Read every sentence frame and model dialogue exchange in the artifact. Are both target grammar structures present in slots students must fill or speak? If neither appears in Paso 3 specifically → cannot score 3.

---

### A4 — Linguistic Payoff Alignment (0–3)

*Is Spanish production — using target vocabulary and grammar — the only path to resolving the task's central problem?*

| Score | Anchor |
|---|---|
| 0 | Task resolvable without any Spanish. Gestures or pointing suffice. |
| 1 | Target language incidental. Game mechanics could replace Spanish production. |
| 2 | Target language required to exchange the key information that closes the gap. |
| 3 | Without target forms (vocabulary + grammar), the central problem stated in the task cannot be resolved. |

**Observable indicator:** Identify the Paso 5 resolution condition — the moment where the activity's driving problem is answered. Does it require Spanish production using target vocabulary and at least one target grammar structure? If the resolution could happen through tallying numbers or pointing at a board without Spanish → score ≤ 1.

---

## Layer B — Schell's Software + Structural Freshness (Engagement Quality)

**Scoring threshold (evaluative):** all scored criteria must score ≥ 1, and at least one must score 3. Criteria scoring 0 generate required revision instructions. Criteria scoring 1 or 2 generate optional improvement suggestions (placed after required revisions).

**Design target (generative):** identify which criterion your design is strongest on; design toward score 3 on that criterion. Ensure no criterion lands at 0.

**Structural freshness note:** B5 is scored from the course history log (manifest `novelty_signature`), not from the artifact content. It is always evaluative-mode only.

---

### B1 — Curiosity and Surprise Capacity (0–3)

*Does the task generate genuine uncertainty about what a partner will say?*

| Score | Anchor |
|---|---|
| 0 | All partner responses predictable. Only 1–2 distinct answers exist. |
| 1 | Some unpredictability, but limited to surface variation. |
| 2 | At least one Paso produces genuinely open responses (≥ 4 plausible distinct answers). |
| 3 | Paso 3 contains a prompt where ≥ 5 distinct answers are plausible and a student could genuinely be surprised by their partner's response. |

**Observable indicator:** List the 3 most likely partner answers to the Paso 3 central interview question. If those 3 answers cover more than 80% of plausible responses, surprise capacity is low → score ≤ 1.

---

### B2 — Flow Curve Integrity (0–3)

*Does cognitive demand rise smoothly across Pasos without cliffs or flat lines?*

| Score | Anchor |
|---|---|
| 0 | Difficulty flat or declining across Pasos. |
| 1 | Difficulty climbs but has at least one jump of more than 2 points between adjacent Pasos. |
| 2 | Difficulty climbs monotonically with at most one small dip allowed. |
| 3 | Smooth climb. Paso 5 is at least 2 difficulty points harder than Paso 1. No cliffs (jump > 2 between adjacent Pasos). |

**Observable indicator:** Map each Paso to a 1–5 cognitive demand scale calibrated to 9th grade. Reference scale: categorization table = 1, list generation = 2, partner interview = 3, evaluation/rating = 4, class synthesis/argumentation = 5. Check the sequence for cliffs (jump > 2) or flat lines.

---

### B3 — Meaningful Choice Carry-Forward (0–3)

*Does a student decision made early in the activity have explicit consequences in a later Paso?*

| Score | Anchor |
|---|---|
| 0 | No consequential student decision exists in any Paso. |
| 1 | A choice exists but does not affect any later Paso. |
| 2 | A choice point exists and a later Paso references it. |
| 3 | The carry-forward is explicit in the instruction text. Students are told "You will use this in Paso N." |

**Observable indicator:** Find the meaningful-choice Paso. Does the text of the referenced later Paso explicitly name the earlier decision by Paso number or output label? If the connection exists only implicitly → score 2 at most.

---

### B4 — Ending and Payoff (0–3)

*Does Paso 5 deliver a designed conclusion that references earlier student outputs?*

| Score | Anchor |
|---|---|
| 0 | Activity ends with open sharing or time's up. No designed conclusion. |
| 1 | Paso 5 has a synthesis activity but no reference to earlier Paso outputs. |
| 2 | Paso 5 references at least one earlier Paso output by name. |
| 3 | Paso 5 references at least 2 earlier Paso outputs by name AND the ending type is one of: reveal (pairs share most-surprising finding), verdict (class votes), tally/profile (shared visual artifact builds during Paso 5), or public commitment (each pair states one action). |

**Observable indicator:** Read Paso 5 instructions only. Count how many earlier Pasos are named by number or by their output. Identify the ending type from the four listed. If Paso 5 describes none of these ending types → score ≤ 1.

---

### B5 — Structural Freshness (0–3)

*Is this paso structure new relative to the last 5 sessions in the current course?*

This criterion is scored from `paso_structure.count_in_last_5_sessions` in the Round 1 manifest `novelty_signature` block. It is never scored from the artifact text itself.

| Score | Anchor |
|---|---|
| 0 | Paso structure used 3 or more times in the last 5 sessions of this course. |
| 1 | Paso structure used exactly 2 times in the last 5 sessions of this course. |
| 2 | Paso structure used exactly 1 time in the last 5 sessions of this course. |
| 3 | Paso structure not used in the last 5 sessions of this course (count = 0). |

**Observable indicator:** Read `paso_structure.count_in_last_5_sessions` from the `novelty_signature` block of the Round 1 manifest. Apply the score directly from the table above. No interpretation required — the mapping is one-to-one.

**Complication pattern note:** `complication_pattern.count_in_last_5_sessions` is also available in the `novelty_signature` block. When both the paso structure and complication pattern are novel (count = 0 for each), note this as a "double freshness" point in the evaluation report. This does not alter the B5 score; it is contextual information for the teacher.

**Bootstrap:** When `novelty_signature` contains any `null` field (fewer than 5 prior sessions in the course log), suppress B5 entirely. Present the Lee-Schell total as X / 24 with the note: "Structural freshness suppressed — fewer than 5 prior sessions in this course log." See Denominator Model below.

---

## Extended Discourse Check

Three binary checks on Paso 3 and Paso 5. These are not scored into the Lee-Schell total. In evaluative mode, NO answers become optional improvement suggestions placed after required revisions.

| Check | Paso | What to look for |
|---|---|---|
| Justification required | Paso 3 or 5 | Does an instruction say "explain why" or "give a reason for your answer"? Answer YES if present. |
| Disagreement structurally possible | Paso 4 or 5 | Does any instruction say "if your partner disagrees" or create a decision point where partners can hold different positions? Answer YES if present. |
| Multi-turn response required | Paso 3 | Does the model dialogue show at least 2 exchanges — not one question and one answer? Answer YES if present. |

Answer YES or NO for each by reading the instruction text directly. Do not infer intent from the task type — read what is written.

---

## Denominator Model (evaluative mode)

| State | Condition | Layer A | Layer B | Total |
|---|---|---|---|---|
| Full | ≥ 5 prior sessions in the course log | 4 × 3 = 12 | 5 × 3 = 15 | **/27** |
| Bootstrap | < 5 prior sessions (B5 suppressed) | 4 × 3 = 12 | 4 × 3 = 12 | **/24** |

Bootstrap state is detected by the presence of any `null` field in `novelty_signature`. When bootstrap, omit B5 from scoring and present the total as X / 24 with an explanatory note.

---

## Convergence Rule (evaluative mode)

The verdict is **CONVERGED** when **all** of the following are true:
- All kill criteria resolved (none triggered)
- All Layer A scores ≥ 2
- All scored Layer B criteria ≥ 1
- At least one scored Layer B criterion = 3

If any of these conditions fails, the verdict is **FEEDBACK** (revision instructions issued; another round follows).

**Maximum 2 rounds.** If the same Layer A criterion that failed in round 0 is still failing (score < 2) in round 1, the verdict for that criterion is **ESCALATE**. Escalation is surfaced to the teacher at Gate B. New failures in round 1 that were not present in round 0 are treated as normal feedback, not escalation.

---

## Score Recording Format (evaluative mode)

```yaml
lee_schell:
  kill_criteria:
    individually_solvable: true | false
    yes_no_only: true | false
    no_negotiation: true | false
    exploit_detected: true | false
    speaking_avoidable: true | false
    any_triggered: true | false
  layer_a:
    information_gap: 0-3
    interaction_dependency: 0-3
    target_structure_deployment: 0-3
    linguistic_payoff_alignment: 0-3
    all_pass: true | false          # true when all four ≥ 2
  layer_b:
    curiosity_surprise_capacity: 0-3
    flow_curve_integrity: 0-3
    meaningful_choice_carry_forward: 0-3
    ending_and_payoff: 0-3
    structural_freshness: 0-3 | suppressed
    all_pass: true | false          # true when all scored ≥ 1 AND at least one = 3
  denominator: 27 | 24              # 24 when structural_freshness: suppressed
  total: 0-27                       # sum of Layer A scores + scored Layer B scores
  extended_discourse:
    justification_required: true | false
    disagreement_possible: true | false
    multi_turn_paso3: true | false
  convergence:
    verdict: converged | feedback | escalate
    revisions_required: 0-N
    improvements_optional: 0-N
```

`all_pass` for `layer_b` evaluates only scored criteria (excludes suppressed B5). In bootstrap mode, `all_pass` requires all four remaining Layer B criteria ≥ 1 and at least one = 3.
