---
comet_change: refactor-standard-skill-layout
role: technical-design
canonical_spec: openspec
---

# Design: Refactor to Standard Skill Layout

**Date**: 2026-08-03  
**Status**: Approved  
**Change**: `refactor-standard-skill-layout`

---

## Problem

chart-toolkit 当前使用自定义目录布局（`adapters/` + `knowledge/`），不符合 skill-creator 定义的标准 skill 解剖结构：

```
skill-name/
├── SKILL.md
├── scripts/    - Executable code
├── references/ - Docs loaded as needed
└── assets/     - Files used in output
```

具体问题：

1. **`adapters/` + `knowledge/` 分两个目录**：标准 skill 把所有"按需加载的参考文档"统一放 `references/`，当前分两个目录增加了 agent 的认知负担
2. **SKILL.md 偏大（398 行）**：包含大量详细步骤（Runtime Check、Language Rule、Hard Rules），这些内容应该移到 `references/` 让 agent 按需读取
3. **description 触发率未优化**：当前 description 列举了大量中英文触发词，但未跑过 trigger eval 验证

## Goal

按标准 skill 布局重组 chart-toolkit，让它符合 skill-creator 的"渐进式披露"原则，提升可维护性和触发准确率。

## Non-Goals

- ❌ 不改 `engines/` 目录（保持原位，它是 vendored 上游引擎）
- ❌ 不改 `setup.sh/ps1/bat` 的安装逻辑
- ❌ 不改 `engines.json` 的配置结构
- ❌ 不改 adapter 的实际内容（只移位置）
- ❌ 不改 `scripts/`、`agents/`、`docs/`、`tools/` 的结构

## Scope

### In Scope

✅ **目录重组**：`adapters/` + `knowledge/` → `references/`（扁平结构）  
✅ **SKILL.md 瘦身**：398 行 → ~200 行，抽出 3 个文件到 `references/`  
✅ **description 优化**：跑 `run_loop.py` 提升触发率  
✅ **测试验证**：写 `evals/evals.json`，跑 with-skill + baseline 对比测试

### Out of Scope

- `engines/` 目录保持原位（改动面大、收益小）
- 安装脚本逻辑不变
- adapter/knowledge 文件内容不变（只移位置）

## Approach: Atomic Refactoring

**决策**：一次性完成目录重组 + SKILL.md 瘦身 + 指针更新，用 git 分支隔离，失败可整体回滚。

**理由**：
1. 改动面不大（10 个文件移动 + 1 个 SKILL.md 重写）
2. git 分支保护足够，回滚简单
3. 避免中间状态（渐进迁移要让 SKILL.md 改 3 次，容易出错）
4. 符合 ponytail 原则：最短路径到 done

## Target Directory Structure

```
chart-toolkit/
├── SKILL.md                          # 瘦身到 ~200 行（流程骨架 + 指针）
├── references/                       # 所有按需加载的参考文档（扁平）
│   ├── fireworks-adapter.md          # ← 从 adapters/
│   ├── drawio-adapter.md             # ← 从 adapters/
│   ├── mermaid-adapter.md            # ← 从 adapters/
│   ├── excalidraw-adapter.md         # ← 从 adapters/
│   ├── canvas-adapter.md             # ← 从 adapters/
│   ├── dataviz-adapter.md            # ← 从 adapters/
│   ├── capability-matrix.md          # ← 从 knowledge/
│   ├── decision-tree.md              # ← 从 knowledge/
│   ├── examples.md                   # ← 从 knowledge/
│   ├── style-catalog.md              # ← 从 knowledge/
│   ├── runtime-check.md              # ← 从 SKILL.md Phase 4 Step 2 抽出
│   ├── language-rule.md              # ← 从 SKILL.md "Language Rule" 节抽出
│   └── hard-rules.md                 # ← 从 SKILL.md "Hard Rules" 节抽出
├── scripts/                          # 保留（安装/合并/诊断脚本）
├── engines/                          # 保留（不纳入本次重构）
├── engines.json                      # 保留
├── agents/                           # 保留
├── setup.sh / setup.ps1 / setup.bat  # 保留
├── evals/                            # 新增（测试用例）
│   └── evals.json
├── docs/ openspec/ tools/            # 不动
└── (adapters/ knowledge/ 删除)
```

## SKILL.md Slimming Strategy

**当前 398 行 → 目标 ~200 行**

### 保留在主文件的内容

```markdown
---
name: chart-toolkit
description: ... (待优化)
---

# Chart Toolkit

Unified chart generation — describe what you need, get a curated list of chart
types, choose, then receive a polished diagram from the best backend engine.

## Language Rule
Detect the language of the user's FIRST input. All subsequent output follows.
→ 详见 `references/language-rule.md`

## Hard Rules
0. ALWAYS run Phase 0 first.
1. ALWAYS complete Phase 2 before generation.
2. Present 3-5 chart type options.
3. Wait for user selection.
4. Deep Interview before Standard 4 Questions.
5. Load adapters on demand.
6. Do NOT convert between formats.
7. If user didn't provide source content, ask for it.
→ 详见 `references/hard-rules.md`

## Phase 0: Environment Check
Scan `engines/*/SKILL.md` to discover available backends.
- Zero engines → stop, guide user to run setup
- Some engines → only propose chart types whose engine is installed
→ 引擎映射表详见 `references/runtime-check.md`

## Phase 1: Intent Analysis
Extract domain, complexity, audience, output medium.
Load `references/decision-tree.md` to narrow options.

## Phase 2: Chart Proposal (MANDATORY)
Load `references/capability-matrix.md` to build the proposal.
Present 3-5 options with: name, engine, output format, best-for scenario.
Ask user to choose.

## Phase 3: Interactive Deep Interview
Ask 4 deep questions (one at a time), then 4 standard questions.

## Phase 4: Orchestration
### Step 1: Load Adapter
Load `references/<engine>-adapter.md` for the selected engine.

### Step 2: Runtime Environment Check (MANDATORY)
Check runtime prerequisites before generating.
→ 详细检查步骤和 auto-fix 命令见 `references/runtime-check.md`

### Step 3: Generate
Follow adapter's execution instructions.

## Capability Overview (Quick Reference)

| Need | Best Engine | Output |
|---|---|---|
| Architecture / system design | fireworks | SVG+PNG |
| Flowchart / workflow | Mermaid | .md code block |
| Sequence / API interaction | Mermaid | .md / SVG |
| Mind map / brainstorming | Canvas (MindMap) | .canvas |
| Hand-drawn sketch | Excalidraw | .md (Obsidian) |
| Data dashboard/chart | Dataviz | HTML/SVG/PNG |
| Editable diagram | Drawio | .drawio |
```

### 移入 references/ 的内容

1. **`language-rule.md`**（~35 行）
   - 从 SKILL.md "Language Rule" 节抽出
   - 包含完整的语言检测规则和输出语言约束

2. **`hard-rules.md`**（~20 行）
   - 从 SKILL.md "Hard Rules" 节抽出
   - 包含 7 条硬规则的详细说明

3. **`runtime-check.md`**（~160 行）
   - 从 SKILL.md Phase 4 Step 2 抽出
   - 包含：
     - Engine → Directory Mapping 表
     - Runtime Prerequisites Matrix 表
     - Per-engine check procedures（fireworks / Drawio / Mermaid / etc.）
     - Auto-fix commands（macOS / Linux / Windows）
     - Severity table（BLOCKER vs WARNING）
     - Report format 示例

## Implementation Steps

1. **创建 git 分支**：`git checkout -b refactor/standard-skill-layout`
2. **移动文件**：
   ```bash
   mkdir references
   mv adapters/* references/
   mv knowledge/* references/
   rmdir adapters knowledge
   ```
3. **抽出 3 个文件**：
   - 从 SKILL.md 抽出 `language-rule.md`、`hard-rules.md`、`runtime-check.md` 到 `references/`
4. **重写 SKILL.md**：按上述瘦身策略重写（~200 行）
5. **更新指针**：SKILL.md 里的路径引用从 `adapters/` 改为 `references/`，从 `knowledge/` 改为 `references/`
6. **Commit**：`git add -A && git commit -m "refactor: restructure to standard skill layout"`
7. **写测试用例**：`evals/evals.json`（3 个测试用例）
8. **跑测试**：with-skill + baseline subagent 对比
9. **生成 eval viewer**：`generate_review.py`
10. **用户 review 反馈** → 迭代
11. **description 优化**：跑 `run_loop.py` 优化 description
12. **Merge**：测试通过后 merge 到 master

## Testing Strategy

### Test Cases (evals.json)

1. **基础触发**：用户说"画一个微服务架构图" → skill 触发 → 走完整 Phase 0-4 流程 → 输出 SVG+PNG
2. **缺失引擎处理**：用户说"帮我画流程图" → skill 触发 → 检测到 engines/ 缺失 → 引导安装
3. **Dataviz 引擎**：用户说"生成一个数据看板" → skill 触发 → 选择 Dataviz 引擎 → 输出 HTML

### Evaluation Metrics

- **触发准确率**：should-trigger queries 的触发率
- **流程完整性**：是否走完整 Phase 0-4 流程
- **输出正确性**：是否生成正确格式的文件
- **错误处理**：缺失引擎时是否正确引导安装

## Risks

1. **瘦身后的 SKILL.md 是否会让 agent 遗漏关键步骤？**
   - 缓解：通过 eval 测试验证，如果 agent 跳过 Phase 0 或 Runtime Check，说明指针不够明显，需要加强
   - 回滚：git reset 到重构前

2. **description 优化后是否会误触发？**
   - 缓解：跑 trigger eval 时包含 10 个 should-not-trigger queries，验证误触发率 < 10%
   - 回滚：description 可以单独回滚

3. **references/ 扁平结构在 10+ 文件时是否仍清晰？**
   - 缓解：当前 13 个文件，扁平结构仍清晰。如果未来超过 20 个，可以考虑分引擎子目录
   - 回滚：可以重新引入子目录结构

## Rollback Plan

如果测试发现问题，整体回滚：

```bash
git checkout master
git branch -D refactor/standard-skill-layout
```

所有文件恢复到重构前状态。

## Success Criteria

- ✅ 目录结构符合标准 skill 布局（`references/` 扁平）
- ✅ SKILL.md < 250 行
- ✅ 3 个 eval 测试用例全部通过（with-skill 版本）
- ✅ description 触发率 > 80%（should-trigger queries）
- ✅ 误触发率 < 10%（should-not-trigger queries）

---

**Approved by**: 用户  
**Date**: 2026-08-03
