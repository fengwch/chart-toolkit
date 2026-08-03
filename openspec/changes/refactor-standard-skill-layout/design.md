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

### Decision 4: 测试流程

**选择**: 完整流程（写 evals.json → 跑测试 → 生成 viewer → 迭代）

**理由**:
- 符合 skill-creator 标准，有量化数据支撑
- 通过 eval 测试验证瘦身后的 SKILL.md 是否让 agent 遗漏关键步骤
- 通过 trigger eval 验证 description 优化效果

**备选方案**:
- 轻量验证：快速验证核心流程，但无量化对比
- 跳过测试：最快，但可能遗漏问题

### Decision 5: description 优化方式

**选择**: 跑 `run_loop.py` 自动化优化

**理由**:
- 通过 trigger eval 量化验证触发率
- 自动迭代优化 description
- 包含 should-trigger 和 should-not-trigger queries，验证误触发率

**备选方案**:
- 暂不优化：先把结构重组好，description 优化留作后续独立 change
- 手写优化：不跑自动化 loop，根据经验直接写一版更精准的 description

## Risks / Trade-offs

### Risk 1: 瘦身后的 SKILL.md 是否会让 agent 遗漏关键步骤？

**风险**: agent 可能跳过 Phase 0 或 Runtime Check

**缓解**:
- 通过 eval 测试验证，如果 agent 跳过关键步骤，说明指针不够明显，需要加强
- SKILL.md 中保留关键步骤的编号和一句话摘要，指针指向 `references/` 的详细说明

**回滚**: git reset 到重构前

### Risk 2: description 优化后是否会误触发？

**风险**: 不该触发时触发

**缓解**:
- 跑 trigger eval 时包含 10 个 should-not-trigger queries，验证误触发率 < 10%
- description 可以单独回滚

**回滚**: 恢复原 description

### Risk 3: references/ 扁平结构在 10+ 文件时是否仍清晰？

**风险**: 文件数量增加后，扁平结构变得混乱

**缓解**:
- 当前 13 个文件，扁平结构仍清晰
- 如果未来超过 20 个，可以考虑分引擎子目录

**回滚**: 可以重新引入子目录结构

## Migration Plan

### Step 1: 创建 git 分支

```bash
git checkout -b refactor/standard-skill-layout
```

### Step 2: 移动文件

```bash
mkdir references
mv adapters/* references/
mv knowledge/* references/
rmdir adapters knowledge
```

### Step 3: 抽出 3 个文件

从 SKILL.md 抽出：
- `language-rule.md`（~35 行）
- `hard-rules.md`（~20 行）
- `runtime-check.md`（~160 行）

### Step 4: 重写 SKILL.md

按瘦身策略重写（~200 行），更新指针从 `adapters/` 改为 `references/`，从 `knowledge/` 改为 `references/`

### Step 5: Commit

```bash
git add -A && git commit -m "refactor: restructure to standard skill layout"
```

### Step 6: 写测试用例

`evals/evals.json`（3 个测试用例）

### Step 7: 跑测试

with-skill + baseline subagent 对比

### Step 8: 生成 eval viewer

`generate_review.py`

### Step 9: 用户 review 反馈 → 迭代

### Step 10: description 优化

跑 `run_loop.py` 优化 description

### Step 11: Merge

测试通过后 merge 到 master

### Rollback Strategy

如果测试发现问题，整体回滚：

```bash
git checkout master
git branch -D refactor/standard-skill-layout
```

所有文件恢复到重构前状态。

## Open Questions

（无，所有关键决策已在 brainstorming 阶段确认）
