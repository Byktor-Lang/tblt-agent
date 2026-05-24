---
course_id: spanish_general
course_name: Spanish General (9th Grade)
updated_on: 2026-05-23
staleness_threshold_days: 365
domain: general_spanish
---

# Spanish General Course Profile

## Domain
General Spanish instruction for 9th-grade students. Covers everyday family, school, community, and social contexts using TBLT methodology.

## Target Register Defaults
- `target_register`: Formal written Spanish appropriate for school and community contexts.
- Audience default: adult authority figures (teachers, administrators) or peers in formal settings.

## Dialect Profile
- `target_variety`: Latin American Spanish (broadly; not variety-specific)
- `excluded_features`: vosotros, vos, leismo
- `preferred_lexemes`:
  - "autobús" over "bus" / "colectivo"
  - "computadora" over "ordenador"
  - "apartamento" over "piso"

## Vocabulary Fence
- vocabulary_fence:
  - paso_size_caps:
      paso_1: 6
      default: 8
  - function_word_allowlist_note: Standard LAm function words; no vosotros forms.

## Exercise Type Restrictions
None beyond the canonical Exercise Types in shared-taxonomy.md.

## Output Template Overrides
None.

## Evaluation Framework
Lee-Schell rubric loaded from frameworks/lee-schell-framework.md at runtime.
