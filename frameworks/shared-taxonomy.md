---
instruction_version: "F4.2"
hitl_status: "HITL draft — Teacher-approved 2026-05-23 (F4.0) + ADR 0025 extension 2026-05-26 (F4.1) + Session I item 5 dangling-reference strike 2026-08-03 (F4.2)"
---

# Shared Taxonomy

Canonical naming module for the TBLT five-agent pipeline. Every specialist consults
this file before composing a log row. Using labels defined here ensures that Spanish
General and Spanish Health logs share a consistent vocabulary, enabling exact-match
cross-course pattern discovery.

**Scope.** This file defines canonical labels for five structural element types:
Paso structures, exercise types, complication patterns, writing genres, and
register-shift patterns. It is self-contained — no agent-specific context.

---

## Update Discipline

A label must be added to this file *before* any specialist uses it in a log row or
manifest. Adding a label requires: (1) choosing a descriptive snake_case key, (2)
writing a short description, and (3) supplying one illustrative example. Labels are
never renamed or removed once published — only new siblings are added. If a new
course introduces a label that is close to, but not identical with, an existing one,
record both in the Flagged Ambiguities section.

---

## Category 1 — Paso Structures

Canonical names for the holistic structural pattern of a Main Task. A Paso structure
describes the task type as a whole (not individual Paso slots). The `paso_structure`
field in the manifest and activity-log row holds exactly one label from this category.

### `categorization_interview_synthesis`
**Description:** A five-Paso task in which students classify vocabulary items into categories, contribute student-generated examples, interview a partner to collect their data, evaluate results collaboratively, and consolidate findings into a class-wide profile.
**Example:** Students sort household chores by effort level, add two personal examples, interview a partner, vote on a class ranking, and report the top three findings to the group.

### `info_gap_resource_negotiation`
**Description:** A task in which each student holds information or resources the other lacks; meaningful exchange is required to complete a shared goal that neither student can accomplish alone.
**Example:** Student A has a floor plan with three rooms missing; Student B has the complementary section. They describe their halves to reconstruct the complete layout together.

### `opinion_ranking_debate`
**Description:** A task in which students independently rank items along a dimension, compare their rankings with a partner, resolve disagreements through negotiation, and defend a joint ranking to the class.
**Example:** Students rank five daily routines by health impact, compare their lists with a partner, reconcile differences, and present their consensus top choice with reasons.

### `role_play_transaction`
**Description:** A five-Paso task in which students take on fixed asymmetric social roles (customer/provider, student/counselor, guest/host) and conduct a real-world transaction or service interaction; one student holds a need or problem, the other holds the resources or institutional authority to address it.
**Example:** Student A is a student requesting a schedule change; Student B is a guidance counselor reviewing available options. They negotiate a mutually acceptable solution, confirm it, and close the transaction.
**Selection rule:** Use this label when the *social-role authority asymmetry* is the primary driver of the task. Use `info_gap_resource_negotiation` when the primary driver is the *data split* between cards, even if the cards carry social-role context.

### `scenario_planning_merge`
**Description:** A five-Paso task in which students each independently develop a complete plan or scenario for a shared hypothetical situation (event, trip, schedule), compare their plans with a partner, negotiate a unified version satisfying key constraints, and present the agreed plan.
**Example:** Students each design a two-day class trip itinerary; they compare plans, identify conflicts (budget, timing, interest), negotiate a merged itinerary, and present it with justifications.
**Distinction from `sequential_task_completion`:** `sequential_task_completion` builds one product through interdependent steps (each Paso feeds the next); `scenario_planning_merge` starts with two complete competing plans that must be merged.

### `sequential_task_completion`
**Description:** A task structured as a series of interdependent steps where each Paso produces an output consumed by the next, culminating in a unified product or plan.
**Example:** Students plan a class trip by choosing a destination (Paso 1), building a day schedule (Paso 2), calculating shared costs (Paso 3), and presenting the complete itinerary (Paso 4).
**Best used when** the task is designed as a dependency chain — each step is blocked until the previous one is complete — rather than as two competing plans that are later merged.

---

## Category 2 — Exercise Types

Canonical codes for pre-task exercise types. The `exercise_types` field in the
manifest and activity-log row holds the ordered sequence of codes used (e.g.,
`TF → ODD → FREQ`). Each code below is a single label.

### `TF`
**Description:** True/False Logical Statements. Students judge whether statements about vocabulary items are logically true or false, based on semantic reasoning rather than surface cues or collocational frequency.
**Example:** "Las escobas se usan para cocinar." → False (logical mismatch between cleaning tool and cooking action).

### `SORT`
**Description:** Logical/Illogical Two-Column Sort. Students classify phrases as logical or illogical and must articulate a semantic reason; items are illogical for principled, articulable reasons — not merely because they sound unusual.
**Example:** "Sacudir los muebles con agua" → Illogical column (furniture is dusted, not washed with water).

### `MATCH`
**Description:** Word–Description Matching. Students match vocabulary terms to short descriptions, with one or two distractors included to prevent process-of-elimination answers.
**Example:** Match "el polvo" → "fine particles that settle on flat surfaces."

### `MC`
**Description:** Multiple-Choice Cloze Paragraph. Students select the correct near-synonym or collocate to complete a coherent paragraph, testing recognition in meaningful context.
**Example:** A paragraph about cleaning routines with blanks for verb choices between near-synonyms such as "sacudir" vs. "barrer."

### `WB`
**Description:** Gap-Fill with Word Bank. Students complete sentences using a provided word bank; optional distractors increase challenge. All word-bank items are drawn from the planned vocabulary set (PVS).
**Example:** "Primero necesito ___ la aspiradora y luego ___ el polvo." Word bank: [pasar, sacudir, barrer].

### `ODD`
**Description:** Odd-One-Out. Students identify the one item in a group of three or four that does not belong, for semantic reasons only, and explain their choice. Groups contain no more than four items. The odd item's position within each group must vary across groups — it is never fixed at the same index (e.g., always last) — so the answer cannot be found by position instead of meaning.
**Example:** [la escoba / el trapeador / la lavadora / el plumero] → "la lavadora" (appliance, not a manual cleaning tool; note the odd item sits third, not last).

### `FREQ`
**Description:** Frequency Survey Grid. Students interview a partner and record how often the partner performs each listed action; frequency expressions from the PVS serve as row or column labels. Results feed a reporting sentence frame.
**Example:** "¿Con qué frecuencia limpias tu cuarto?" Grid options: nunca / a veces / siempre. Reporting frame: "Mi compañero/a ___ [frequency expression]."

### `FRAME`
**Description:** Sentence Frame Completion. Students complete partially written sentences using target vocabulary and grammar structures, producing a personally meaningful statement without teacher support.
**Example:** "Para mí, la tarea más difícil en casa es ___ porque ___."

### `RANK`
**Description:** Semantic Ranking. Students order up to eight items along a labeled dimension (scale labels in Spanish), then report using a sentence frame. Maximum eight items to respect working-memory limits.
**Example:** Rank cinco quehaceres de "menos esfuerzo" a "más esfuerzo." Reporting: "El quehacer que requiere más esfuerzo es ___."

### `ASSOC`
**Description:** Schema Activation / Brainstorm. A pre-exposure exercise in which students generate their own words or ideas on a topic before any vocabulary is introduced. When included, it is always Exercise 1.
**Example:** "Escribe cinco palabras que se te ocurran cuando piensas en 'limpiar la casa'." Students then compare their list with the target vocabulary introduced in the next exercise.

---

## Category 3 — Complication Patterns

Canonical names for complication archetypes. The `complication_pattern` field in
the manifest holds exactly one label from this category.

### `competing_constraints`
**Description:** Two simultaneously limiting *objective* requirements conflict with each other (e.g., within budget AND all required activities covered); fully satisfying one constraint makes the other harder to meet, demanding principled trade-off reasoning rather than preference negotiation.
**Example:** A class trip must fit both a strict budget cap AND a minimum list of required activities; students must argue which trade-off is more defensible when they cannot satisfy both fully.
**Selection rule:** Use this label when the constraints are externally imposed and identical for both students. Use `values_conflict` when the constraints reflect the students' own differing priorities.

### `incomplete_information`
**Description:** A critical piece of information needed to complete the task is absent from *both* students' role cards; they must identify the gap, agree on a justified assumption, state it explicitly to each other and to the class, and proceed.
**Example:** Students negotiate a party guest list but neither student's card specifies how many guests the venue holds; they must agree on a plausible capacity assumption, state it explicitly, and defend their choices within it.
**Distinction from `info_gap_resource_negotiation`:** `info_gap_resource_negotiation` involves information held by one student that the other needs (known data split); `incomplete_information` involves data held by neither student, requiring collaborative inference.

### `resource_scarcity`
**Description:** A resource needed to complete the task is limited and must be allocated, rationed, or negotiated among participants; not everyone can have what they want.
**Example:** Only one bus seat remains for the class trip; students must negotiate who needs it most based on their stated circumstances.

### `role_asymmetry`
**Description:** Students occupy structurally unequal roles with different permissions, responsibilities, or information access; the power imbalance shapes the negotiation and cannot be ignored.
**Example:** One student plays a building inspector with authority to approve or reject; the other plays a prospective renter making a case for the apartment.

### `time_constraint`
**Description:** A deadline or time pressure forces students to prioritize, cut options, or make decisions faster than they otherwise would, creating productive urgency.
**Example:** The booking window for a class trip closes in ten minutes; students must reach agreement before the option disappears.
**Best used when** deadline pressure is the *primary* obstacle — not a secondary condition that incidentally limits other options alongside a more central complication.

### `values_conflict`
**Description:** Students hold genuinely differing priorities or preferences that cannot all be satisfied simultaneously, requiring negotiation and compromise to reach a shared outcome.
**Example:** Student A prioritizes low cost; Student B prioritizes proximity. They must find a trip option both find acceptable rather than one that fully satisfies either.

---

## Category 4 — Writing Genres

Canonical names for post-task writing genres. The `writing_genre` field in the
manifest holds exactly one label from this category. The genre is elicited from the
teacher at Phase 0 (Recommendations Rule applies) and frozen in the SCB; the
reflective specialist reads it from the SCB — it does not choose independently.

### `formal_complaint_letter`
**Description:** A formal written complaint addressed to a business or service provider, describing a problem experienced and requesting a specific remedy in measured, formal language.
**Example:** A letter to a hotel manager describing an unresolved room issue encountered during a simulated booking negotiation, requesting a room change or refund.

### `formal_email`
**Description:** A formal email addressed to the task interlocutor, summarizing the task outcome using standard salutation, body, and closing conventions for formal written Spanish.
**Example:** An email to a landlord confirming the outcome of an apartment-search negotiation conducted during the main task.

### `formal_itinerary`
**Description:** A structured, itemized plan for a trip or scheduled event, listing times, locations, and activities in formal written Spanish, addressed to a future traveler or companion.
**Example:** A day-by-day itinerary for a class trip, including departure times, planned stops, and activity descriptions.
**Best used when** the task outcome is a scheduled plan (trip, event, timetable) and the writing target is the plan document itself — not advocacy for a decision or reporting of findings.

### `formal_proposal`
**Description:** A structured proposal addressed to a decision-maker (committee, director, principal), describing a project or initiative the student would initiate or lead, requesting approval or resources — written in formal Spanish with a conventional salutation, body, and closing.
**Example:** A proposal to the school's activities committee requesting approval for a new after-school club, including purpose, expected participants, resource needs, and anticipated benefits.
**Distinction from `formal_recommendation`:** A recommendation advocates for what someone else should do; a proposal advocates for something the writer would initiate or lead. Both use the same structural form (salutation / body / closing) but differ in requestive frame: recommendation uses `se recomienda` / `sería conveniente`; proposal uses `solicito` / `me permito proponer`.

### `formal_recommendation`
**Description:** A formal recommendation letter or memo addressed to an institution (school board, community committee, employer), arguing for a specific course of action with supporting reasons.
**Example:** A memo to the school principal recommending a specific class trip destination, with three reasons grounded in educational value.

### `formal_summary_report`
**Description:** A summary report presenting the findings or outcomes of an activity, survey, or investigation, addressed to a supervising institution or teacher, organized as context → methodology → findings → conclusion in formal written Spanish. For simple partner surveys, the methodology component is one or two sentences describing the data-collection format — the four-part structure is not required to be equal in length across sections.
**Example:** A report to the class teacher summarizing the results of a partner survey on school-subject preferences, including aggregate findings and a conclusion about the most and least popular subjects.
**Distinction from `formal_recommendation`:** The summary report describes what was found; the formal recommendation advocates for what should be done. A summary report may lead to a recommendation but is structurally distinct.

---

## Category 5 — Register-Shift Patterns

Canonical names for the structural type of register shift rehearsed in the post-task
Register-Shift Table. The `register_shift_pattern` field in the manifest holds
exactly one label from this category. The pattern is elicited from the teacher at
Phase 0 and frozen in the SCB.

### `frequency_to_formal_adverb`
**Description:** Informal frequency expressions used naturally in speech are replaced by their formal adverbial equivalents appropriate for written text.
**Example:** "a veces" (spoken) → "en ocasiones" (formal); "siempre" → "de manera constante" or "habitualmente."

### `hedge_to_formal_opener`
**Description:** Spoken hedges, discourse markers, and fillers are transformed into formal sentence-opening phrases appropriate for written correspondence or formal address.
**Example:** "Bueno, creo que..." (spoken) → "Considerando los factores expuestos, ..." (formal opener that names the reasoning basis rather than hedging).

### `informal_to_formal_verb_phrase`
**Description:** Colloquial or spoken verb phrases are replaced by their formal written equivalents; the shift operates at the level of verb selection and collocational pattern — not a vocabulary swap that merely replaces one word with a synonym.
**Example:** "vamos a limpiar" (spoken) → "procederemos a la limpieza de" (formal written phrase involving a nominalization and a different verb).

### `request_to_formal_petition`
**Description:** Informal spoken request expressions (`quiero que`, `necesito que`, `¿me puedes...?`) are transformed into formal written petition structures (`Le solicito que`, `Por la presente, requiero`, `Me permito solicitar`) appropriate for institutional correspondence. The shift operates on the *illocutionary force structure* of the request — changing the pragmatic form, not just vocabulary or verb form.
**Example:** "¿Me puedes dar más tiempo para el proyecto?" (spoken) → "Por la presente, solicito respetuosamente una extensión del plazo para la entrega del proyecto, en consideración de..." (formal petition opener).
**Distinction from existing patterns:** `informal_to_formal_verb_phrase` operates on action verbs; `hedge_to_formal_opener` operates on sentence-opening phrases; `request_to_formal_petition` operates on the illocutionary force structure of a request.

---

## Flagged Ambiguities

Labels that are close but not identical; recorded here to prevent vocabulary drift
across courses and to give future cross-course tooling a starting point for grouping.

| Labels | Distinction | Resolution |
|---|---|---|
| `formal_email` vs a potential future `formal_confirmation_email` | A confirmation email after a booking/negotiation is structurally similar to a general formal email but frames content as a transaction confirmation with reference number, dates, and agreed terms. | Use `formal_email` as the base label for all formal emails. Add `formal_confirmation_email` as a sibling (Update Discipline) only if a course requires the confirmation framing as a distinct instructional target in its own right. |
| `categorization_interview_synthesis` vs sequence variants | Variants in which the middle Pasos differ (e.g., no student-generated-list Paso, or a different bridge exercise type) produce a qualitatively different novelty signature and should not share the same label. | Add each structurally distinct variant as a new sibling label rather than reusing this label with an informal modifier. |
| `values_conflict` vs `role_asymmetry` | Values conflict involves symmetric parties with differing preferences; role asymmetry involves structurally unequal roles. A task may exhibit both. | Assign the label that best describes the primary complication driver. When both are equally central, prefer `role_asymmetry` (the structural constraint is stronger and harder for students to work around). |
| `role_play_transaction` vs `info_gap_resource_negotiation` | Both may involve role cards with social context. The distinction is the primary driver: `role_play_transaction` is driven by social-role authority asymmetry (one student has institutional authority the other lacks); `info_gap_resource_negotiation` is driven by the data split (each card holds what the other needs). | Use `role_play_transaction` when the social-role authority is the structural core of the task. Use `info_gap_resource_negotiation` when the data split is the structural core, even if roles are present. |
| `competing_constraints` vs `values_conflict` | `competing_constraints` involves two objective requirements that are externally imposed and identical for both students; `values_conflict` involves the students' own differing priorities. | Use `competing_constraints` when the constraints come from outside (budget cap, required activity list, venue rules). Use `values_conflict` when the conflict comes from what each student personally prioritizes. |
| `formal_proposal` vs `formal_recommendation` | Both are formal documents addressed to an institution arguing for a course of action. The distinction is the writer's role: a proposal advocates for something the writer would initiate or lead; a recommendation advocates for what someone else should do. | Assign based on whether the writer is the proposed actor (`formal_proposal`) or an external advocate (`formal_recommendation`). Both use salutation / body / closing structure but differ in requestive frame. |
| `role_play_transaction` (paso structure) vs `role_asymmetry` (complication pattern) | These operate on different axes: `role_play_transaction` is the task structure (what the task looks like); `role_asymmetry` is the complication (what makes it hard). | These routinely co-occur and should both be assigned when present. No tie-breaking rule needed — assign `role_play_transaction` as the `paso_structure` field and `role_asymmetry` as the `complication_pattern` field. |
