## 1. Directory Restructuring

- [x] 1.1 Create `references/` directory at repository root
- [x] 1.2 Move all 6 adapter files from `adapters/` to `references/` (fireworks-adapter.md, drawio-adapter.md, mermaid-adapter.md, excalidraw-adapter.md, canvas-adapter.md, dataviz-adapter.md)
- [x] 1.3 Move all 4 knowledge files from `knowledge/` to `references/` (capability-matrix.md, decision-tree.md, examples.md, style-catalog.md)
- [x] 1.4 Remove empty `adapters/` and `knowledge/` directories
- [x] 1.5 Verify all 10 files exist in `references/` with unchanged content

## 2. SKILL.md Slimming

- [x] 2.1 Extract "Language Rule" section from SKILL.md into `references/language-rule.md` (~35 lines)
- [x] 2.2 Extract "Hard Rules" section from SKILL.md into `references/hard-rules.md` (~20 lines)
- [x] 2.3 Extract Phase 4 Step 2 "Runtime Environment Check" detailed content from SKILL.md into `references/runtime-check.md` (~160 lines), including: Engine → Directory Mapping table, Runtime Prerequisites Matrix table, per-engine check procedures, auto-fix commands, severity table, report format examples
- [x] 2.4 Rewrite SKILL.md to ~200 lines with flow skeleton and pointers to reference files
- [x] 2.5 Update all path references in SKILL.md from `adapters/` to `references/` and from `knowledge/` to `references/`
- [x] 2.6 Verify SKILL.md is under 250 lines and all pointers correctly reference files in `references/`

## 3. Git Commit

- [x] 3.1 Create git branch `refactor/standard-skill-layout`
- [x] 3.2 Stage all changes: `git add -A`
- [x] 3.3 Commit with message: `refactor: restructure to standard skill layout`

## 4. Eval Framework Setup

- [x] 4.1 Create `evals/` directory at repository root
- [x] 4.2 Create `evals/evals.json` with 3 test cases: (1) basic trigger with full workflow, (2) missing engine handling, (3) alternative engine selection (Dataviz)
- [x] 4.3 Define assertions for each test case (trigger accuracy, workflow completeness, output correctness, error handling)

## 5. Test Execution

- [x] 5.1 Run with-skill test cases (3 tests) with skill loaded, save outputs to workspace
- [x] 5.2 Run baseline test cases (3 tests) without skill, save outputs to workspace
- [x] 5.3 Capture timing data (tokens, duration) for each test run
- [x] 5.4 Grade each test run against assertions, save results to grading.json

## 6. Benchmark and Review

- [ ] 6.1 Aggregate benchmark results: run `python -m scripts.aggregate_benchmark` to produce benchmark.json and benchmark.md
- [ ] 6.2 Generate eval viewer: run `eval-viewer/generate_review.py` with benchmark data
- [ ] 6.3 Present eval viewer to user for human review and feedback collection
- [ ] 6.4 Read feedback.json and identify test cases with specific complaints
- [ ] 6.5 Apply targeted improvements to SKILL.md or reference files based on feedback
- [ ] 6.6 Re-run test cases in new iteration directory if improvements were made

## 7. Description Optimization

- [x] 7.1 Create 20 trigger evaluation queries (10 should-trigger, 10 should-not-trigger) and save to JSON
- [x] 7.2 Review trigger eval queries with user for approval
- [ ] 7.3 Run `python -m scripts.run_loop` with eval set, skill path, and model ID for up to 5 iterations (requires skill-creator infrastructure)
- [ ] 7.4 Apply best description from optimization loop to SKILL.md frontmatter (requires skill-creator infrastructure)
- [ ] 7.5 Verify trigger rate >80% for should-trigger queries and false trigger rate <10% for should-not-trigger queries (requires skill-creator infrastructure)

## 8. Finalization

- [x] 8.1 Run final verification: confirm directory structure, SKILL.md line count, all reference files present
- [x] 8.2 Merge `refactor/standard-skill-layout` branch to master
- [x] 8.3 Clean up workspace directories
