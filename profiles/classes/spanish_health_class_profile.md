# Spanish Health Class Profile

## Profile Metadata

```yaml
updated_on: 2026-05-22
staleness_threshold_days: 90
```

## Section Constants

| Field | Value |
|---|---|
| `actfl_level` | Novice-Mid |
| `interest_hooks` | (see bullet list below) |
| `target_register` | Formal patient–provider communication (audience: healthcare professional or intake staff) |

### `interest_hooks`

- health careers and medical professions
- sports medicine and athletic training
- community health and school nurse scenarios
- emergency first-aid roleplay

## Differentiation Notes

### Scaffolding Defaults

| Scenario | Default scaffold |
|---|---|
| Novice + unfamiliar medical vocabulary | Provide a labeled diagram or medical term card alongside the task prompt |
| Mixed-ability pair | Assign the lower-proficiency student the role with more receptive support (listener, patient role) for the first Paso |
| Low-rating Paso format flagged in session log | Substitute a simpler intake-form variant before reusing the format |
| Time-pressured class period (under 35 min) | Cut Paso 4 (extension); preserve Pasos 1–3 and the closing reflection |

### Classroom Constraints

- Class size 28 students; pair work is the default, groups of three only when numbers are odd
- One Chromebook cart shared across the department — assume no in-class device access unless booked in advance
- Pairing rule: rotate partners every two weeks; do not pair the same two students for consecutive TBLT cycles
- Class block is 47 minutes; transitions between activities should be budgeted at 3 minutes

## Conductor Read Rules

This section tells future orchestrator sessions how to re-read this file.

- Phase −2 extracts `actfl_level`, `interest_hooks`, and `target_register` from
  `## Section Constants` (the table plus the `interest_hooks` bullet list directly below it).
- Phase −2 reads the `## Differentiation Notes → Scaffolding Defaults` table as
  `{scaffolding_defaults}` and the `## Differentiation Notes → Classroom Constraints`
  bullets as `{classroom_constraints}`.
- Phase −2 checks `updated_on` and `staleness_threshold_days` in `## Profile Metadata`
  for the per-profile staleness gate (default 90 days for class profiles — SSD §3.4).
- The orchestrator never overwrites this file. Phase −2 read-back is create-if-not-exists only.
  Teacher edits are authoritative.

## Teacher Notes

**Class profile:** This class profile mirrors the Spanish General class (same students, same
school constraints). The health-career interest hooks are appropriate for students who have
opted into the Spanish Health strand. Teacher should review interest hooks and scaffolding
defaults before the first session.

**Teacher audit required (ADR 0011 — HITL):** Drafted per standing HITL pre-delegation (J6).
