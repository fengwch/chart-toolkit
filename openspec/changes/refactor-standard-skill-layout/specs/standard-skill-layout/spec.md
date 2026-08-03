## ADDED Requirements

### Requirement: Directory structure conforms to standard skill layout
The system SHALL reorganize all reference documents into a flat `references/` directory structure, merging the existing `adapters/` and `knowledge/` directories.

#### Scenario: All adapter files moved to references
- **WHEN** the refactoring is complete
- **THEN** all 6 adapter files (fireworks-adapter.md, drawio-adapter.md, mermaid-adapter.md, excalidraw-adapter.md, canvas-adapter.md, dataviz-adapter.md) SHALL exist in `references/`

#### Scenario: All knowledge files moved to references
- **WHEN** the refactoring is complete
- **THEN** all 4 knowledge files (capability-matrix.md, decision-tree.md, examples.md, style-catalog.md) SHALL exist in `references/`

#### Scenario: Old directories removed
- **WHEN** the refactoring is complete
- **THEN** the `adapters/` and `knowledge/` directories SHALL NOT exist at the repository root

### Requirement: SKILL.md slimmed to ~200 lines with pointers
The system SHALL reduce SKILL.md from 398 lines to approximately 200 lines by extracting detailed content into reference files while maintaining clear pointers.

#### Scenario: SKILL.md line count reduced
- **WHEN** the refactoring is complete
- **THEN** SKILL.md SHALL contain no more than 250 lines

#### Scenario: Language rule extracted
- **WHEN** the refactoring is complete
- **THEN** `references/language-rule.md` SHALL exist and contain the complete language detection rules extracted from SKILL.md

#### Scenario: Hard rules extracted
- **WHEN** the refactoring is complete
- **THEN** `references/hard-rules.md` SHALL exist and contain the complete 7 hard rules extracted from SKILL.md

#### Scenario: Runtime check extracted
- **WHEN** the refactoring is complete
- **THEN** `references/runtime-check.md` SHALL exist and contain the complete runtime prerequisites matrix, per-engine check procedures, auto-fix commands, severity table, and report format examples extracted from SKILL.md Phase 4 Step 2

#### Scenario: SKILL.md contains pointers to references
- **WHEN** SKILL.md is read
- **THEN** it SHALL contain explicit pointers (e.g., "详见 `references/language-rule.md`") for Language Rule, Hard Rules, and Runtime Check sections

### Requirement: Path references updated throughout SKILL.md
The system SHALL update all path references in SKILL.md from `adapters/` and `knowledge/` to `references/`.

#### Scenario: Adapter paths updated
- **WHEN** SKILL.md references adapter files
- **THEN** all paths SHALL use `references/<engine>-adapter.md` format instead of `adapters/<engine>-adapter.md`

#### Scenario: Knowledge paths updated
- **WHEN** SKILL.md references knowledge files
- **THEN** all paths SHALL use `references/<filename>.md` format instead of `knowledge/<filename>.md`

### Requirement: engines/ directory unchanged
The system SHALL NOT modify the `engines/` directory structure or its contents during the refactoring.

#### Scenario: engines/ directory preserved
- **WHEN** the refactoring is complete
- **THEN** the `engines/` directory SHALL contain the same 4 engine subdirectories (fireworks-tech-graph, mermaid-visualizer, excalidraw-diagram, canvas-creator) with unchanged contents

#### Scenario: setup scripts unchanged
- **WHEN** the refactoring is complete
- **THEN** setup.sh, setup.ps1, and setup.bat SHALL remain unchanged and continue to function correctly

### Requirement: Adapter and knowledge file contents unchanged
The system SHALL NOT modify the actual content of adapter and knowledge files, only their location.

#### Scenario: Adapter file contents preserved
- **WHEN** the refactoring is complete
- **THEN** each adapter file in `references/` SHALL have identical content to its original location in `adapters/`

#### Scenario: Knowledge file contents preserved
- **WHEN** the refactoring is complete
- **THEN** each knowledge file in `references/` SHALL have identical content to its original location in `knowledge/`
