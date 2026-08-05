# Spanish Health Course Profile

## Profile Schema

```yaml
course_id: spanish_health
course_name: Spanish for Health Professions
updated_on: 2026-05-22
staleness_threshold_days: 365
domain: Healthcare communication — patient–provider interactions, clinical intake, 9th-grade introduction to health-career vocabulary and medical register
target_register_defaults:
  - formal_spoken
  - professional_medical
dialect_profile:
  target_variety: latin_american_neutral
  excluded_features:
    - vosotros
    - vos
    - leismo
    - tuteo_formal_asymmetry
  preferred_lexemes:
    computer: computadora
    prescription: receta
    appointment: cita
    nurse: enfermero/enfermera
    doctor: médico/médica
    hospital: hospital
    clinic: clínica
    medication: medicamento
    symptom: síntoma
    allergy: alergia
    emergency_room: sala de emergencias
    patient: paciente
    insurance: seguro médico
vocabulary_fence:
  function_word_allowlist:
    - articles
    - prepositions
    - subject_pronouns
    - ser
    - estar
    - tener
    - haber
    - poder
    - necesitar
    - querer
    - doler
  domain_glossary_required: true
  paso_size_caps:
    paso_1: 8
    default: 12
exercise_type_restrictions: []
output_template_overrides:
  main_task: |
    <!-- Medical Glossary Sidebar (Spanish Health course override) -->
    <aside class="medical-glossary-sidebar">
      <h3>Vocabulario de salud / Health Vocabulary</h3>
      <p><em>Key terms from today's activity — for reference during the task.</em></p>
      {{medical_glossary_terms}}
    </aside>
  pretask: null
  post_task: null
  html_structure_schema: null
evaluation_framework:
  threshold_overrides:
    layer_a_minimum: 2
    layer_b_minimum: 1
    layer_b_at_least_one_at: 3
  supplementary_criteria: []
```

## Teacher Notes

**Dialect commitment:** This course uses Latin American Neutral — the variety most commonly encountered in US healthcare contexts. Medical terminology prioritizes forms used in public health materials targeting Spanish-speaking patients in the northeastern US.

**Glossary sidebar override:** The `output_template_overrides.main_task` block adds a medical vocabulary reference sidebar to every Main Task activity. The `{{medical_glossary_terms}}` placeholder is populated at generation time from the activity's confirmed PVS items. This override is specific to this course and does not affect Spanish General output.

**Paso size caps:** Reduced from the Spanish General defaults (10/15) to 8/12 to reflect the cognitive load of acquiring medical vocabulary alongside task performance. The orchestrator reads these from this file via `vocabulary_fence.paso_size_caps`.

**Teacher audit required (ADR 0011 — HITL):** This file was drafted per the standing HITL pre-delegation (J6). Teacher should review `dialect_profile.excluded_features`, `preferred_lexemes`, and `evaluation_framework.threshold_overrides` before the first scored session.
