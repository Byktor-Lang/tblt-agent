---
instruction_version: "F4.0"
hitl_status: "Teacher-approved 2026-05-23 — no changes required (F4.4, J6)"
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

### `sequential_task_completion`
**Description:** A task structured as a series of interdependent steps where each Paso produces an output consumed by the next, culminating in a unified product or plan.
**Example:** Students plan a class trip by choosing a destination (Paso 1), building a day schedule (Paso 2), calculating shared costs (Paso 3), and presenting the complete itinerary (Paso 4).

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
**Description:** Odd-One-Out. Students identify the one item in a group of three or four that does not belong, for semantic reasons only, and explain their choice. Groups contain no more than four items.
**Example:** [la escoba / el trapeador / la lavadora / el plumero] → "la lavadora" (appliance, not a manual cleaning tool).

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
**Description:** Schema Activation / Brainstorm. A pre-exposure exercise in which students generate their own words or ideas on a topic before any vocabulary is introduced. When included, it is always Exercise 1; it is not a receptive exercise and does not count toward the minimum-receptive-exercise requirement.
**Example:** "Escribe cinco palabras que se te ocurran cuando piensas en 'limpiar la casa'." Students then compare their list with the target vocabulary introduced in the next exercise.

---

## Category 3 — Complication Patterns

Canonical names for complication archetypes. The `complication_pattern` field in
the manifest holds exactly one label from this category.

### `resource_scarcity`
**Description:** A resource needed to complete the task is limited and must be allocated, rationed, or negotiated among participants; not everyone can have what they want.
**Example:** Only one bus seat remains for the class trip; students must negotiate who needs it most based on their stated circumstances.

### `time_constraint`
**Description:** A deadline or time pressure forces students to prioritize, cut options, or make decisions faster than they otherwise would, creating productive urgency.
**Example:** The booking window for a class trip closes in ten minutes; students must reach agreement before the option disappears.

### `values_conflict`
**Description:** Students hold genuinely differing priorities or preferences that cannot all be satisfied simultaneously, requiring negotiation and compromise to reach a shared outcome.
**Example:** Student A prioritizes low cost; Student B prioritizes proximity. They must find a trip option both find acceptable rather than one that fully satisfies either.

### `role_asymmetry`
**Description:** Students occupy structurally unequal roles with different permissions, responsibilities, or information access; the power imbalance shapes the negotiation and cannot be ignored.
**Example:** One student plays a building inspector with authority to approve or reject; the other plays a prospective renter making a case for the apartment.

---

## Category 4 — Writing Genres

Canonical names for post-task writing genres. The `writing_genre` field in the
manifest holds exactly one label from this category. The genre is elicited from the
teacher at Phase 0 (Recommendations Rule applies) and frozen in the SCB; the
reflective specialist reads it from the SCB — it does not choose independently.

### `formal_email`
**Description:** A formal email addressed to the task interlocutor, summarizing the task outcome using standard salutation, body, and closing conventions for formal written Spanish.
**Example:** An email to a landlord confirming the outcome of an apartment-search negotiation conducted during the main task.

### `formal_itinerary`
**Description:** A structured, itemized plan for a trip or scheduled event, listing times, locations, and activities in formal written Spanish, addressed to a future traveler or companion.
**Example:** A day-by-day itinerary for a class trip, including departure times, planned stops, and activity descriptions.

### `formal_recommendation`
**Description:** A formal recommendation letter or memo addressed to an institution (school board, community committee, employer), arguing for a specific course of action with supporting reasons.
**Example:** A memo to the school principal recommending a specific class trip destination, with three reasons grounded in educational value.

### `formal_complaint_letter`
**Description:** A formal written complaint addressed to a business or service provider, describing a problem experienced and requesting a specific remedy in measured, formal language.
**Example:** A letter to a hotel manager describing an unresolved room issue encountered during a simulated booking negotiation, requesting a room change or refund.

---

## Category 5 — Register-Shift Patterns

Canonical names for the structural type of register shift rehearsed in the post-task
Register-Shift Table. The `register_shift_pattern` field in the manifest holds
exactly one label from this category. The pattern is elicited from the teacher at
Phase 0 and frozen in the SCB.

### `informal_to_formal_verb_phrase`
**Description:** Colloquial or spoken verb phrases are replaced by their formal written equivalents; the shift operates at the level of verb selection and collocational pattern — not a vocabulary swap that merely replaces one word with a synonym.
**Example:** "vamos a limpiar" (spoken) → "procederemos a la limpieza de" (formal written phrase involving a nominalization and a different verb).

### `hedge_to_formal_opener`
**Description:** Spoken hedges, discourse markers, and fillers are transformed into formal sentence-opening phrases appropriate for written correspondence or formal address.
**Example:** "Bueno, creo que..." (spoken) → "Considerando los factores expuestos, ..." (formal opener that names the reasoning basis rather than hedging).

### `frequency_to_formal_adverb`
**Description:** Informal frequency expressions used naturally in speech are replaced by their formal adverbial equivalents appropriate for written text.
**Example:** "a veces" (spoken) → "en ocasiones" (formal); "siempre" → "de manera constante" or "habitualmente."

---

## Flagged Ambiguities

Labels that are close but not identical; recorded here to prevent vocabulary drift
across courses and to give future cross-course tooling a starting point for grouping.

| Labels | Distinction | Resolution |
|---|---|---|
| `formal_email` vs a potential future `formal_confirmation_email` | A confirmation email after a booking/negotiation is structurally similar to a general formal email but frames content as a transaction confirmation with reference number, dates, and agreed terms. | Use `formal_email` as the base label for all formal emails. Add `formal_confirmation_email` as a sibling (Update Discipline) only if a course requires the confirmation framing as a distinct instructional target in its own right. |
| `categorization_interview_synthesis` vs sequence variants | Variants in which the middle Pasos differ (e.g., no student-generated-list Paso, or a different bridge exercise type) produce a qualitatively different novelty signature and should not share the same label. | Add each structurally distinct variant as a new sibling label rather than reusing this label with an informal modifier. |
| `values_conflict` vs `role_asymmetry` | Values conflict involves symmetric parties with differing preferences; role asymmetry involves structurally unequal roles. A task may exhibit both. | Assign the label that best describes the primary complication driver. When both are equally central, prefer `role_asymmetry` (the structural constraint is stronger and harder for students to work around). |
