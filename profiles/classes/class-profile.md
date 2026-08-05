# Class Profile

## Profile Metadata

- `updated_on`: 2026-04-15
- `generated_by`: "Teacher"

## Section Constants

| Field | Value |
|---|---|
| `actfl_level` | Novice-Mid |
| `interest_hooks` | (see bullet list below) |
| `target_register` | Formal email to a teacher or school staff member (audience: adult authority figure). |

### `interest_hooks`

- TikTok culture
- school sports teams
- group chats
- gaming

## Differentiation Notes

### Scaffolding Defaults

| Scenario | Default scaffold |
|---|---|
| Novice + abstract topic | Provide sentence frames and a model response in the target language |
| Mixed-ability pair | Assign the lower-proficiency student the role with more receptive support (listener, reader) for the first Paso |
| Low-rating Paso format flagged in session log | Substitute an information-gap variant before reusing the format |
| Time-pressured class period (under 35 min) | Cut Paso 4 (extension); preserve Pasos 1–3 and the closing reflection |

### Classroom Constraints

- Class size 28 students; pair work is the default, groups of three only when numbers are odd
- One Chromebook cart shared across the department — assume no in-class device access unless booked in advance
- Pairing rule: rotate partners every two weeks; do not pair the same two students for consecutive TBLT cycles
- Class block is 47 minutes; transitions between activities should be budgeted at 3 minutes

## Conductor Read Rules

This section tells future Conductor sessions how to re-read this file. Do not edit
unless you are changing the schema itself.

- Phase −2 extracts `actfl_level`, `interest_hooks`, and `target_register` from
  `## Section Constants` (the table plus the `interest_hooks` bullet list directly
  below it).
- Phase −2 reads the `## Differentiation Notes → Scaffolding Defaults` table as
  `{scaffolding_defaults}` and the `## Differentiation Notes → Classroom Constraints`
  bullets as `{classroom_constraints}`.
- Phase −2 checks `updated_on` in `## Profile Metadata` for the 6-month staleness gate.
- The Conductor never overwrites this file. Phase 1d write-back is create-if-not-exists
  only. Teacher edits are authoritative.
