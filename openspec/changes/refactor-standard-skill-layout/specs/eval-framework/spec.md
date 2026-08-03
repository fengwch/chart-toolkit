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

#### Scenario: Tests re-run after improvements
- **WHEN** improvements are applied
- **THEN** the system SHALL re-run all test cases in a new iteration directory and generate a new eval viewer with `--previous-workspace` pointing to the previous iteration

### Requirement: Test case coverage for skill behaviors
The system SHALL ensure test cases cover critical skill behaviors including triggering, workflow execution, engine selection, and error handling.

#### Scenario: Basic trigger test case
- **WHEN** evals.json is created
- **THEN** it SHALL include a test case where the user requests a diagram (e.g., "画一个微服务架构图"), expecting the skill to trigger and execute the full Phase 0-4 workflow

#### Scenario: Missing engine handling test case
- **WHEN** evals.json is created
- **THEN** it SHALL include a test case where the user requests a diagram but engines are not installed, expecting the skill to detect the missing engines and guide the user to run setup

#### Scenario: Alternative engine selection test case
- **WHEN** evals.json is created
- **THEN** it SHALL include a test case where the user requests a data visualization (e.g., "生成一个数据看板"), expecting the skill to select the Dataviz engine and output HTML
