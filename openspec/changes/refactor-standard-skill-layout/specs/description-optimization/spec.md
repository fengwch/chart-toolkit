## ADDED Requirements

### Requirement: Description optimization through trigger evaluation
The system SHALL optimize the SKILL.md description field by running automated trigger evaluation to improve triggering accuracy across different AI agent platforms.

#### Scenario: Trigger evaluation queries created
- **WHEN** description optimization begins
- **THEN** the system SHALL create 20 trigger evaluation queries (10 should-trigger, 10 should-not-trigger) saved in a JSON file

#### Scenario: Should-trigger queries cover diverse use cases
- **WHEN** should-trigger queries are created
- **THEN** they SHALL include formal requests, casual requests, requests without explicitly naming chart types, uncommon use cases, and cases where this skill competes with other skills

#### Scenario: Should-not-trigger queries test edge cases
- **WHEN** should-not-trigger queries are created
- **THEN** they SHALL include near-miss queries that share keywords but need different tools, ambiguous phrasing, and queries that touch related domains

#### Scenario: Automated optimization loop executed
- **WHEN** trigger evaluation queries are ready
- **THEN** the system SHALL run `run_loop.py` with the eval set, skill path, and model ID for up to 5 iterations

#### Scenario: Description optimized based on test results
- **WHEN** the optimization loop completes
- **THEN** the system SHALL update the SKILL.md description field with the best-performing version selected by test score

#### Scenario: Trigger accuracy improved
- **WHEN** the optimized description is deployed
- **THEN** should-trigger queries SHALL achieve >80% trigger rate

#### Scenario: False trigger rate minimized
- **WHEN** the optimized description is deployed
- **THEN** should-not-trigger queries SHALL achieve <10% false trigger rate

### Requirement: Description maintains semantic accuracy
The system SHALL ensure the optimized description accurately represents the skill's capabilities while improving trigger rates.

#### Scenario: Core capabilities preserved
- **WHEN** the description is optimized
- **THEN** it SHALL still mention: unified chart generation, multiple engine support (fireworks, mermaid, excalidraw, canvas, drawio, dataviz), cross-agent compatibility, and the 17 chart types

#### Scenario: No misleading claims introduced
- **WHEN** the description is optimized
- **THEN** it SHALL NOT introduce capabilities or behaviors not actually implemented in the skill

#### Scenario: Language preserved
- **WHEN** the description is optimized
- **THEN** it SHALL maintain bilingual trigger support (Chinese and English) as in the original description
