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
