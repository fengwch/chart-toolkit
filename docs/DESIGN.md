# Chart Toolkit — 设计文档

> 版本: 1.0.0 | 日期: 2026-07-22 | 状态: Draft

## 1. 项目概述

**Chart Toolkit** 是一个跨 Agent、跨平台的图表生成统一入口。输入自然语言描述，系统自动分析意图、列举可选图表方案、交互式引导用户明确需求，最后调度最佳后端引擎输出图表。

### 目标

| 维度 | 目标 |
|---|---|
| Agent 覆盖 | Claude Code / Codex / Hermes / Claw / QCoder 及任意支持 Markdown Skill 的 Agent |
| 平台覆盖 | macOS / Linux / Windows |
| 后端引擎 | Drawio MCP / Fireworks Tech Graph / Mermaid / Excalidraw / Obsidian Canvas / Dataviz |
| 安装体验 | 一条命令安装所有依赖 + 配置 + 符号链接 |
| 使用体验 | 自然语言输入 → 图表建议清单 → 交互式引导 → 输出 |

### 非目标 (v1.0)

- 跨格式转换（Mermaid ↔ Excalidraw ↔ Drawio）
- GUI 界面
- SaaS 服务

## 2. 架构设计

### 2.1 五层架构

```
┌──────────────────────────────────────────────┐
│               用户输入层                        │
│   "画一个微服务架构图"  "帮我可视化这个流程"      │
└──────────────────┬───────────────────────────┘
                   ↓
┌──────────────────────────────────────────────┐
│           ① 意图分析引擎 (Prompt Router)        │
│   提取: 领域·复杂度·受众·约束                    │
│   加载: knowledge/ 领域知识库                   │
└──────────────────┬───────────────────────────┘
                   ↓
┌──────────────────────────────────────────────┐
│           ② 图表建议清单 (Chart Proposal)       │
│   列举 3-5 种可选图表类型                       │
│   每种带: 名称+描述+推荐工具+场景+风格            │
│   用户从中选择 1-N 个                           │
└──────────────────┬───────────────────────────┘
                   ↓
┌──────────────────────────────────────────────┐
│           ③ 深度访谈 (Deep Interview)           │
│   4 个深度问题 → 4 个标准问题                   │
│   逐步细化用户的真实需求                         │
└──────────────────┬───────────────────────────┘
                   ↓
┌──────────────────────────────────────────────┐
│           ④ 工具编排层 (Orchestrator)           │
│   根据决策 + 用户选择，逐个调用适配器             │
│   每个适配器加载对应的 adapter + upstream engine │
└──┬───────┬───────┬───────┬───────┬────────────┘
   ↓       ↓       ↓       ↓       ↓
┌──┐  ┌───┐  ┌───┐  ┌───┐  ┌──────┐  ┌───────┐
│Dr│  │Fi │  │Me │  │Ex │  │Canvas│  │Data  │
│aw│  │re │  │rm │  │ca │  │Creat │  │viz   │
│io│  │wo │  │ai │  │li │  │or    │  │      │
│  │  │rks│  │d  │  │dr │  │      │  │      │
└──┘  └───┘  └───┘  └───┘  └──────┘  └───────┘
   ↓       ↓       ↓       ↓       ↓         ↓
┌──────────────────────────────────────────────┐
│           ⑤ 输出层                             │
│   .drawio  .svg  .png  .md  .excalidraw      │
│   .canvas  离线交互 HTML                      │
└──────────────────────────────────────────────┘
```

### 2.2 核心设计原则

| # | 原则 | 实现方式 |
|---|------|---------|
| 1 | **Prompt 即代码** | 路由、分析、引导、适配全部在 `.md` 文件中用 prompt 实现 |
| 2 | **Agent 无关** | `SKILL.md` 是纯 Markdown，任何 Agent 加载后即使用 |
| 3 | **平台无关** | 三套安装脚本 (sh / ps1 / bat)，引擎均跨平台 |
| 4 | **不做格式转换** | 每个引擎产自己最擅长的格式，不在引擎间互转 |
| 5 | **开源优先** | Git clone 上游仓库，不 fork、不嵌入 |
| 6 | **可观测** | 每个决策输出原因，用户知道"为什么选这个工具" |

## 3. 目录结构

```
chart-toolkit/
├── setup.sh                     # macOS / Linux 一键安装
├── setup.ps1                    # Windows PowerShell 安装
├── setup.bat                    # Windows CMD 备用
├── SKILL.md                     # 核心 Prompt（Agent 无关，Claude Code 自动加载）
│
├── engines/                     # 上游引擎 (git clone, 指定版本 tag)
│   ├── fireworks-tech-graph/    #   yizhiyanhua-ai/fireworks-tech-graph
│   ├── mermaid-visualizer/      #   axtonliu/axton-obsidian-visual-skills
│   ├── excalidraw-diagram/      #   同上
│   └── canvas-creator/          #   同上
│
├── adapters/                    # 引擎适配层（Agent 无关，prompt 封装）
│   ├── fireworks-adapter.md
│   ├── mermaid-adapter.md
│   ├── excalidraw-adapter.md
│   ├── canvas-adapter.md
│   ├── drawio-adapter.md
│   └── dataviz-adapter.md
│
├── knowledge/                   # 领域知识库
│   ├── capability-matrix.md     #   图表类型 ↔ 工具映射
│   ├── decision-tree.md         #   场景 → 推荐工具 决策树
│   ├── style-catalog.md         #   所有可用风格一览
│   └── examples.md              #   典型案例 + prompt 模板
│
├── agents/                      # Agent 专属安装脚本
│   ├── install-claude.sh        #   → ~/.claude/skills/chart-toolkit/
│   ├── install-codex.sh         #   → ~/.agents/skills/chart-toolkit/
│   ├── install-all.sh           #   一键安装所有已检测到的 Agent
│   │
│   ├── install-hermes.sh        #   (v1.1 待调研路径)
│   ├── install-claw.sh          #   (v1.1 待调研路径)
│   └── install-qcoder.sh        #   (v1.1 待调研路径)
│
├── scripts/                     # 跨平台辅助脚本
│   ├── doctor.sh / doctor.ps1   #   依赖检测
│   ├── deps-macos.sh            #   macOS 依赖安装
│   ├── deps-linux.sh            #   Linux 依赖安装
│   ├── deps-windows.ps1         #   Windows 依赖安装
│   └── merge-mcp.sh             #   合并 Drawio MCP 配置
│
├── docs/                        # 文档
│   ├── README.md / README.zh.md
│   ├── install.md
│   ├── usage.md
│   └── DESIGN.md (本文件)
│
├── .gitignore
└── LICENSE (MIT)
```

## 4. 组件设计

### 4.1 核心 Prompt — `SKILL.md`

**这是整个项目的灵魂文件。** 结构如下：

```
---
name: chart-toolkit
description: 统一图表生成入口。支持架构图/流程图/时序图/思维导图/手绘/数据可视化等所有类型。
---

# Chart Toolkit

## 工作流程 (Workflow)

### Phase 1: 意图分析
(分析用户输入，提取领域/复杂度/受众/输出格式需求)

### Phase 2: 图表建议清单
(加载 capability-matrix.md，列举 3-5 种最佳匹配)

### Phase 3: 深度访谈
(4 个深度问题 + 4 个标准问题)

### Phase 4: 工具编排
(按选定类型，逐个加载 adapter + engine 执行)

## 能力矩阵
(内嵌 capability-matrix.md 的核心内容)

## 适配器加载规则
(按选定类型，动态加载对应的 adapters/*.md)
```

**体积控制**: 核心 prompt 控制在 ~300 行以内；详细知识通过 `@` 引用加载。

### 4.2 适配器 — `adapters/*.md`

每个适配器是一个薄封装对上游引擎的调用约定：

```markdown
# Fireworks Adapter

## 能力范围
- 擅长: SVG 技术图 (架构/流程图/UML/ER/时序/甘特)
- 输出: .svg + .png (通过 cairosvg 或 rsvg-convert)
- 风格: 12 种 (扁平/暗黑/蓝图/Notion/玻璃/Claude/OpenAI/...)

## 调用方式
1. 加载 engines/fireworks-tech-graph/SKILL.md
2. 按原 skill 的 Workflow 执行
3. 输出到用户指定目录

## 依赖
- Python 3.9+, cairosvg (推荐) 或 rsvg-convert
- 参见: engines/fireworks-tech-graph/scripts/
```

Drawio 适配器不同——它依赖 MCP Server：

```markdown
# Drawio Adapter

## 前置条件
- Drawio MCP Server 已配置在 mcp.json 中
- 可用工具: mcp__drawio__*

## 调用方式
1. mcp__drawio__start_session (首次)
2. mcp__drawio__create_new_diagram (新建)
3. mcp__drawio__edit_diagram (修改)
4. mcp__drawio__export_diagram (导出)
```

### 4.3 知识库 — `knowledge/`

| 文件 | 内容 | 用途 |
|---|---|---|
| `capability-matrix.md` | 15 种图表类型 × 6 种引擎 的能力矩阵表 | Phase 2 生成建议清单 |
| `decision-tree.md` | 场景→推荐工具 的决策树（含优先级权重） | 意图分析辅助 |
| `style-catalog.md` | 所有引擎所有风格汇总（含配色预览说明） | 用户选择风格时参考 |
| `examples.md` | 10+ 典型案例（完整 prompt + 输出截图） | 降低使用门槛 |

### 4.4 安装脚本 — `setup.sh`

```
setup.sh 执行流程:
┌─────────────────────────────────┐
│ 1. check_platform               │ 检测 macOS / Linux
│ 2. check_prerequisites           │ node, python3, git 是否可用
│ 3. install_deps                  │ pip install cairosvg (macOS brew install npm)
│ 4. clone_engines                 │ git clone 四个上游到 engines/
│    - fireworks: v1.0.4           │ 指定版本 tag
│    - mermaid/excalidraw/canvas   │ axton 仓库提取子目录
│ 5. link_agents                   │ 调用 agents/install-*.sh
│    - 检测已安装的 Agent           │
│    - 创建符号链接到对应 skills 目录│
│ 6. merge_mcp_config              │ 检测并合并 Drawio MCP 配置
│ 7. verify                        │ 运行 doctor.sh 确认一切就绪
│ 8. report                        │ 打印成功摘要 + 使用说明
└─────────────────────────────────┘
```

**使用方式**:
```bash
# 在线
curl -fsSL https://raw.github.com/.../setup.sh | bash

# 本地
git clone https://github.com/.../chart-toolkit.git
cd chart-toolkit && ./setup.sh
```

### 4.5 Agent 集成矩阵

| Agent | Skills 目录 | 安装方式 | v1.0 支持 |
|---|---|---|---|
| **Claude Code** | `~/.claude/skills/` | `ln -s` → `chart-toolkit/` | ✅ |
| **Codex** | `~/.agents/skills/` | `ln -s` → `chart-toolkit/` | ✅ |
| **Hermes** | 待调研 | 待调研 | v1.1 |
| **Claw** | 待调研 | 待调研 | v1.1 |
| **QCoder** | 待调研 | 待调研 | v1.1 |
| 通用 (Manual) | 任意目录 | `agent prompt: @/path/to/SKILL.md` | ✅ |

集成原理：所有这类 Agent 都支持"加载外部 Skill 文件"或"引用外部 prompt 文件"的模式。我们的 `SKILL.md` 就是纯粹的 Markdown prompt，不需要 Agent 有任何特殊能力。

### 4.6 平台支持矩阵

| 功能 | macOS | Linux | Windows |
|---|---|---|---|
| setup.sh 安装 | ✅ | ✅ | ❌ (用 WSL) |
| setup.ps1 安装 | ❌ | ❌ | ✅ |
| cairosvg (Python) | ✅ pip | ✅ pip | ✅ pip |
| rsvg-convert | ✅ brew | ✅ apt | ✅ 手动 |
| drawio MCP (npx) | ✅ | ✅ | ✅ |
| 符号链接 | ✅ | ✅ | ✅ (mklink) |
| Git Bash | — | — | ✅ setup.sh 可用 |

## 5. 数据流

```
用户输入: "画一个微服务架构图，用于技术文档"
  │
  ▼
Intent Analyzer
  │ 提取: domain=microservices, complexity=medium-high, audience=技术文档
  │ 推断: format=SVG+PNG, style=professional
  ▼
Chart Proposal
  │ 推荐:
  │   A. fireworks Style3 蓝图风 → SVG+PNG ★ 最佳
  │   B. fireworks Style9 C4 Container → SVG+PNG
  │   C. Drawio 在线编辑 → .drawio
  │   D. Mermaid 流程图 → .md 代码块
  ▼
用户选择: "A + D"
  │
  ▼
Deep Interview (4问)
  │ Q1: 这篇文档的受众是谁？ → 后端工程师 + 架构师
  │ Q2: 需要展示哪些具体组件？ → API Gateway, Service Mesh, Kafka, DB
  │ Q3: 数据流方向偏好？ → 从上到下
  │ Q4: 需要多少细节？ → 中等，关键组件+核心交互
  │
  ▼
Standard 4 Questions
  │ Q1: 输出格式？ → SVG 原文件 + PNG 嵌入
  │ Q2: 配色偏好？ → 蓝图风 (蓝白)
  │ Q3: 是否需要动画？ → 否
  │ Q4: 特殊要求？ → 需标注组件技术栈
  │
  ▼
Orchestrator
  ├─[A] → load fireworks-adapter.md → load engines/fireworks-tech-graph/SKILL.md
  │        → 生成 SVG → validate → export PNG ✅
  │
  └─[D] → load mermaid-adapter.md → load engines/mermaid-visualizer/SKILL.md
           → 生成 Mermaid 代码 → 内嵌到 Output.md ✅
  │
  ▼
Output
  ✅ microservices-architecture.svg
  ✅ microservices-architecture.png
  ✅ microservices-flow.mermaid.md
```

## 6. 版本规划

### v1.0 (本周交付)
- [x] 设计文档 (本文件)
- [ ] 目录结构 + .gitignore
- [ ] `SKILL.md` 核心 Prompt（~300行）
- [ ] 6 个 adapter 文件
- [ ] 4 个 knowledge 文件
- [ ] `setup.sh` + `setup.ps1` + `setup.bat`
- [ ] `agents/install-claude.sh` + `install-codex.sh` + `install-all.sh`
- [ ] `scripts/doctor.sh` + `deps-macos.sh` + `deps-linux.sh`
- [ ] `docs/README.md` + `docs/README.zh.md` + `docs/install.md` + `docs/usage.md`
- [ ] Git 仓库初始化 + Push 到 GitHub

### v1.1
- [ ] 调研 Hermes / Claw / QCoder 的 skills 目录路径
- [ ] 增加 `agents/install-hermes.sh` 等
- [ ] Windows 完整测试

### v2.0
- [ ] 跨格式转换 (Mermaid → Excalidraw → Drawio)
- [ ] 批量生成支持
- [ ] Web UI 预览

## 7. 风险与缓解

| 风险 | 影响 | 缓解 |
|---|---|---|
| 上游引擎 breaking change | 生成失败 | 锁定版本 tag，更新前测试 |
| Drawio MCP 不可用 | 缺少交互式图表 | 降级到 Fireworks 静态替代 |
| Agent 不支持外部 prompt 引用 | 无法使用 | 提供手动复制 paste 方案 |
| Windows 符号链接限制 | 安装失败 | 降级为 copy 模式 |
| 依赖冲突 (cairosvg 等) | 安装困难 | doctor.sh 预检 + 详细错误提示 |

## 8. 设计决策记录

| # | 决策 | 理由 | 日期 |
|---|---|---|---|
| 1 | 深度整合而非轻量路由 | 用户需要智能推荐 + 交互引导 | 2026-07-22 |
| 2 | 纯 Prompt 路由 | 零代码依赖，跨 Agent 通用 | 2026-07-22 |
| 3 | Bash 脚本安装 | 最轻量，macOS/Linux 原生 | 2026-07-22 |
| 4 | Git clone 上游仓库 | 保留更新能力，尊重上游 | 2026-07-22 |
| 5 | 跨 Agent 设计 | 扩大用户群，不绑定特定 Agent | 2026-07-22 |
| 6 | 图表建议清单 | 用户不需要知道工具名，只需选图表类型 | 2026-07-22 |
| 7 | 深度访谈(4问) + 标准四问 | 质量与效率平衡 | 2026-07-22 |
