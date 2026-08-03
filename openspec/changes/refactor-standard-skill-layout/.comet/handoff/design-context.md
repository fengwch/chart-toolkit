# Comet Design Handoff

- Change: refactor-standard-skill-layout
- Phase: design
- Mode: compact
- Context hash: 078c86bedadb8e25e20f4e5eb023025b0913d18b3ecfc830567c78f81617db53

Generated-by: comet-handoff.sh

OpenSpec remains the canonical capability spec. This handoff is a deterministic, source-traceable context pack, not an agent-authored summary.

## openspec/changes/refactor-standard-skill-layout/proposal.md

- Source: openspec/changes/refactor-standard-skill-layout/proposal.md
- Lines: 1-61
- SHA256: 5806e93ece7f4bcb42cb1e38ad502e182cac0f7ddf807e2b2be28239d638d201

```md
## Why

chart-toolkit 当前使用自定义目录布局（`adapters/` + `knowledge/`），不符合 skill-creator 定义的标准 skill 解剖结构。这导致：
1. agent 需要在两个目录间切换查找参考文档，增加认知负担
2. SKILL.md 主体偏大（398 行），包含大量详细步骤，不符合"渐进式披露"原则
3. description 触发率未经过 trigger eval 验证，可能存在误触发或漏触发

按标准 skill 布局重组后，chart-toolkit 将成为一个符合 skill-creator 规范的"标准 skill"，提升可维护性、触发准确率和 agent 执行效率。

## What Changes

- **目录重组**：`adapters/` + `knowledge/` → `references/`（扁平结构，13 个文件）
- **SKILL.md 瘦身**：398 行 → ~200 行，抽出 3 个文件到 `references/`：
  - `language-rule.md`（~35 行）
  - `hard-rules.md`（~20 行）
  - `runtime-check.md`（~160 行）
- **description 优化**：跑 `run_loop.py` 优化 description，提升触发准确率
- **测试验证**：写 `evals/evals.json`（3 个测试用例），跑 with-skill + baseline 对比测试

**不变更的内容**：
- `engines/` 目录保持原位（vendored 上游引擎，改动面大、收益小）
- `setup.sh/ps1/bat` 的安装逻辑不变
- `engines.json` 的配置结构不变
- `scripts/`、`agents/`、`docs/`、`tools/` 的结构不变
- 6 个 adapter 文件和 4 个 knowledge 文件的实际内容不变（只移位置）

## Capabilities

### New Capabilities

- `standard-skill-layout`: 按 skill-creator 规范重组目录结构，实现渐进式披露
- `description-optimization`: 通过 trigger eval 优化 description，提升触发准确率
- `eval-framework`: 建立 evals.json 测试框架，支持 with-skill + baseline 对比测试

### Modified Capabilities

（无现有 capability 的 REQUIREMENTS 变更，本次仅为结构重组）

## Impact

**Affected files**:
- `SKILL.md`：重写（398 行 → ~200 行）
- `adapters/`：整个目录移动到 `references/`
- `knowledge/`：整个目录移动到 `references/`
- `references/`：新增目录，包含 13 个文件（6 adapters + 4 knowledge + 3 抽出文件）
- `evals/`：新增目录，包含 `evals.json`

**Affected code**:
- SKILL.md 中的路径引用从 `adapters/` 改为 `references/`，从 `knowledge/` 改为 `references/`
- 无其他代码需要修改（adapter/knowledge 文件内容不变）

**Dependencies**:
- 无新增依赖
- setup.sh/ps1/bat 的安装逻辑不变，不受影响

**Systems**:
- Agent 加载 skill 时，路径从 `adapters/` 和 `knowledge/` 统一改为 `references/`
- description 优化后，触发行为可能变化（需要 eval 验证）

**Breaking changes**:
- 无 breaking changes（仅内部结构重组，对外接口不变）
```

## openspec/changes/refactor-standard-skill-layout/design.md

- Source: openspec/changes/refactor-standard-skill-layout/design.md
- Lines: 1-209
- SHA256: e79f0c97ee6c8189c758c3b7ade05fd2a7f2deddafd5eea59eb992370fa3d70f

[TRUNCATED]

```md
## Context

chart-toolkit 是一个跨 Agent 的 skill 项目，支持 Claude Code、Codex、TeleAgent 等多个平台。当前使用自定义目录布局：

```
chart-toolkit/
├── SKILL.md (398 行)
├── adapters/ (6 个 adapter 文件)
├── knowledge/ (4 个 knowledge 文件)
├── engines/ (4 个 vendored 引擎)
├── scripts/ agents/ docs/ tools/
└── setup.sh/ps1/bat engines.json
```

问题：
1. `adapters/` + `knowledge/` 分两个目录，不符合 skill-creator 的标准 skill 解剖结构（`references/` 扁平）
2. SKILL.md 主体偏大（398 行），包含大量详细步骤，不符合"渐进式披露"原则
3. description 触发率未经过 trigger eval 验证

约束：
- 不改变 `engines/` 目录（vendored 上游引擎，改动面大、收益小）
- 不改变安装脚本逻辑
- 不改变 adapter/knowledge 文件的实际内容（只移位置）

## Goals / Non-Goals

**Goals:**
- ✅ 按标准 skill 布局重组目录结构（`references/` 扁平）
- ✅ SKILL.md 瘦身到 ~200 行，抽出 3 个文件到 `references/`
- ✅ description 优化，提升触发准确率
- ✅ 建立 eval 测试框架，验证 skill 行为

**Non-Goals:**
- ❌ 不改 `engines/` 目录
- ❌ 不改 `setup.sh/ps1/bat` 的安装逻辑
- ❌ 不改 `engines.json` 的配置结构
- ❌ 不改 adapter/knowledge 文件的实际内容
- ❌ 不改 `scripts/`、`agents/`、`docs/`、`tools/` 的结构

## Decisions

### Decision 1: 目录重组策略

**选择**: `adapters/` + `knowledge/` → `references/`（扁平结构）

**理由**:
- 标准 skill 把所有"按需加载的参考文档"统一放 `references/`
- 扁平结构在 13 个文件时仍清晰，agent 一眼看到全部参考物
- 避免多一层子目录增加认知负担

**备选方案**:
- 保留子目录（`references/adapters/` + `references/knowledge/`）：语义分组清晰，但多一层目录
- 按引擎分目录（`references/fireworks/` + `references/drawio/`）：每个引擎集中，但当前每个引擎只有一个 adapter 文件，过度设计

### Decision 2: SKILL.md 瘦身程度

**选择**: 轻度瘦身（398 行 → ~200 行），抽出 3 个文件到 `references/`

**理由**:
- 主文件保留流程骨架 + 指针，agent 一眼看到流程全貌
- 抽出 `language-rule.md`、`hard-rules.md`、`runtime-check.md` 到 `references/`
- 避免过度瘦身导致 agent 每次都要读多个 references

**备选方案**:
- 中度瘦身（~150 行）：主文件极简，但 agent 每次都要读多个 references，可能遗漏
- 不瘦身：改动最小，但主文件仍然臃肿

### Decision 3: 重构方式

**选择**: 原子重组（一次性完成）

**理由**:
- 改动面不大（10 个文件移动 + 1 个 SKILL.md 重写）
- git 分支保护足够，回滚简单
- 避免中间状态（渐进迁移要让 SKILL.md 改 3 次，容易出错）
- 符合 ponytail 原则：最短路径到 done

**备选方案**:
- 渐进迁移：每步可独立验证，但中间状态多，耗时长
- 双轨并行：旧结构可随时回退，但临时存在重复文件，git 历史复杂
```

Full source: openspec/changes/refactor-standard-skill-layout/design.md

## openspec/changes/refactor-standard-skill-layout/tasks.md

- Source: openspec/changes/refactor-standard-skill-layout/tasks.md
- Lines: 1-58
- SHA256: cc2d9f8e403a3dedc4ccfbf944cac9634d19370ec9899f63fb9e071eeac3c1b0

```md
## 1. Directory Restructuring

- [ ] 1.1 Create `references/` directory at repository root
- [ ] 1.2 Move all 6 adapter files from `adapters/` to `references/` (fireworks-adapter.md, drawio-adapter.md, mermaid-adapter.md, excalidraw-adapter.md, canvas-adapter.md, dataviz-adapter.md)
- [ ] 1.3 Move all 4 knowledge files from `knowledge/` to `references/` (capability-matrix.md, decision-tree.md, examples.md, style-catalog.md)
- [ ] 1.4 Remove empty `adapters/` and `knowledge/` directories
- [ ] 1.5 Verify all 10 files exist in `references/` with unchanged content

## 2. SKILL.md Slimming

- [ ] 2.1 Extract "Language Rule" section from SKILL.md into `references/language-rule.md` (~35 lines)
- [ ] 2.2 Extract "Hard Rules" section from SKILL.md into `references/hard-rules.md` (~20 lines)
- [ ] 2.3 Extract Phase 4 Step 2 "Runtime Environment Check" detailed content from SKILL.md into `references/runtime-check.md` (~160 lines), including: Engine → Directory Mapping table, Runtime Prerequisites Matrix table, per-engine check procedures, auto-fix commands, severity table, report format examples
- [ ] 2.4 Rewrite SKILL.md to ~200 lines with flow skeleton and pointers to reference files
- [ ] 2.5 Update all path references in SKILL.md from `adapters/` to `references/` and from `knowledge/` to `references/`
- [ ] 2.6 Verify SKILL.md is under 250 lines and all pointers correctly reference files in `references/`

## 3. Git Commit

- [ ] 3.1 Create git branch `refactor/standard-skill-layout`
- [ ] 3.2 Stage all changes: `git add -A`
- [ ] 3.3 Commit with message: `refactor: restructure to standard skill layout`

## 4. Eval Framework Setup

- [ ] 4.1 Create `evals/` directory at repository root
- [ ] 4.2 Create `evals/evals.json` with 3 test cases: (1) basic trigger with full workflow, (2) missing engine handling, (3) alternative engine selection (Dataviz)
- [ ] 4.3 Define assertions for each test case (trigger accuracy, workflow completeness, output correctness, error handling)

## 5. Test Execution

- [ ] 5.1 Run with-skill test cases (3 tests) with skill loaded, save outputs to workspace
- [ ] 5.2 Run baseline test cases (3 tests) without skill, save outputs to workspace
- [ ] 5.3 Capture timing data (tokens, duration) for each test run
- [ ] 5.4 Grade each test run against assertions, save results to grading.json

## 6. Benchmark and Review

- [ ] 6.1 Aggregate benchmark results: run `python -m scripts.aggregate_benchmark` to produce benchmark.json and benchmark.md
- [ ] 6.2 Generate eval viewer: run `eval-viewer/generate_review.py` with benchmark data
- [ ] 6.3 Present eval viewer to user for human review and feedback collection
- [ ] 6.4 Read feedback.json and identify test cases with specific complaints
- [ ] 6.5 Apply targeted improvements to SKILL.md or reference files based on feedback
- [ ] 6.6 Re-run test cases in new iteration directory if improvements were made

## 7. Description Optimization

- [ ] 7.1 Create 20 trigger evaluation queries (10 should-trigger, 10 should-not-trigger) and save to JSON
- [ ] 7.2 Review trigger eval queries with user for approval
- [ ] 7.3 Run `python -m scripts.run_loop` with eval set, skill path, and model ID for up to 5 iterations
- [ ] 7.4 Apply best description from optimization loop to SKILL.md frontmatter
- [ ] 7.5 Verify trigger rate >80% for should-trigger queries and false trigger rate <10% for should-not-trigger queries

## 8. Finalization

- [ ] 8.1 Run final verification: confirm directory structure, SKILL.md line count, all reference files present
- [ ] 8.2 Merge `refactor/standard-skill-layout` branch to master
- [ ] 8.3 Clean up workspace directories
```

## openspec/changes/refactor-standard-skill-layout/specs/description-optimization/spec.md

- Source: openspec/changes/refactor-standard-skill-layout/specs/description-optimization/spec.md
- Lines: 1-47
- SHA256: b1cd47821b9353bd2af1a448a21e7350a2ed669f74a415c8a2103b25b4cc3ffd

```md
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
```

## openspec/changes/refactor-standard-skill-layout/specs/eval-framework/spec.md

- Source: openspec/changes/refactor-standard-skill-layout/specs/eval-framework/spec.md
- Lines: 1-99
- SHA256: a545904f0e0cda1d0ba94961d08d30698074d8074d16e8e30f8d64764a8bf4e9

[TRUNCATED]

```md
## ADDED Requirements

### Requirement: Eval testing framework established
The system SHALL establish a testing framework using `evals/evals.json` to validate skill behavior through with-skill and baseline comparison tests.

#### Scenario: Evals directory created
- **WHEN** the eval framework is set up
- **THEN** an `evals/` directory SHALL exist at the repository root

#### Scenario: evals.json file created
- **WHEN** the eval framework is set up
- **THEN** `evals/evals.json` SHALL exist and contain test cases in the schema defined by skill-creator

#### Scenario: Test cases defined for core workflows
- **WHEN** evals.json is created
- **THEN** it SHALL contain at least 3 test cases covering: (1) basic trigger with full workflow, (2) missing engine handling, (3) alternative engine selection

### Requirement: With-skill and baseline comparison tests executed
The system SHALL execute test cases with both the skill loaded and without the skill (baseline) to measure the skill's impact on agent behavior.

#### Scenario: With-skill runs executed
- **WHEN** tests are run
- **THEN** each test case SHALL be executed with the skill loaded, saving outputs to `evals/<test-id>/with-skill/`

#### Scenario: Baseline runs executed
- **WHEN** tests are run
- **THEN** each test case SHALL be executed without the skill (baseline), saving outputs to `evals/<test-id>/baseline/`

#### Scenario: Timing data captured
- **WHEN** each test run completes
- **THEN** timing data (tokens, duration) SHALL be captured and saved for benchmark analysis

### Requirement: Eval viewer generated for human review
The system SHALL generate an interactive HTML viewer using `eval-viewer/generate_review.py` to enable human review of test outputs and feedback collection.

#### Scenario: Eval viewer generated
- **WHEN** all test runs complete
- **THEN** the system SHALL run `generate_review.py` to create an HTML viewer with both qualitative outputs and quantitative benchmarks

#### Scenario: Viewer displays with-skill outputs
- **WHEN** the viewer is opened
- **THEN** it SHALL display the outputs from with-skill runs for each test case

#### Scenario: Viewer displays baseline outputs
- **WHEN** the viewer is opened
- **THEN** it SHALL display the outputs from baseline runs for comparison

#### Scenario: Viewer collects feedback
- **WHEN** the user reviews outputs in the viewer
- **THEN** the viewer SHALL allow the user to submit feedback for each test case, saved to `feedback.json`

### Requirement: Benchmark aggregation and analysis
The system SHALL aggregate test results into benchmark metrics and provide analysis of the skill's performance compared to baseline.

#### Scenario: Benchmark JSON generated
- **WHEN** all test runs complete and are graded
- **THEN** the system SHALL generate `benchmark.json` containing pass_rate, time, and tokens for each configuration (with-skill vs baseline)

#### Scenario: Benchmark markdown generated
- **WHEN** benchmark.json is generated
- **THEN** the system SHALL also generate `benchmark.md` with human-readable summary statistics

#### Scenario: Pass rate calculated
- **WHEN** benchmark is aggregated
- **THEN** it SHALL calculate the pass rate for each configuration based on assertion evaluations

#### Scenario: Performance metrics compared
- **WHEN** benchmark is aggregated
- **THEN** it SHALL compare time and token usage between with-skill and baseline configurations

### Requirement: Iteration based on feedback
The system SHALL support iterative improvement by reading feedback from the eval viewer and applying improvements to the skill.

#### Scenario: Feedback read from viewer
- **WHEN** the user submits feedback in the viewer
- **THEN** the system SHALL read `feedback.json` and identify test cases with specific complaints

#### Scenario: Improvements applied
- **WHEN** feedback indicates issues
- **THEN** the system SHALL apply targeted improvements to SKILL.md or reference files based on the feedback
```

Full source: openspec/changes/refactor-standard-skill-layout/specs/eval-framework/spec.md

## openspec/changes/refactor-standard-skill-layout/specs/standard-skill-layout/spec.md

- Source: openspec/changes/refactor-standard-skill-layout/specs/standard-skill-layout/spec.md
- Lines: 1-72
- SHA256: b76c6ac055ddd46a606716e321b4f09da127fba16fa43047414e639061e5a7bd

```md
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
```

