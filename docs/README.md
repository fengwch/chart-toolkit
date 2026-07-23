# Chart Toolkit

> One prompt. Six engines. Any diagram.

[![GitHub release](https://img.shields.io/github/v/release/fengwch/chart-toolkit?include_prereleases&style=flat-square)](https://github.com/fengwch/chart-toolkit/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)
[![Platform: macOS | Linux | Windows](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-blue?style=flat-square)](#platform-support)
[![Agents: Claude Code | Codex](https://img.shields.io/badge/agents-Claude%20Code%20%7C%20Codex-green?style=flat-square)](#supported-agents)
[![Engines: 6](https://img.shields.io/badge/engines-6-orange?style=flat-square)](#supported-engines)

Chart Toolkit is a cross-Agent, cross-platform Skill that turns natural language into polished diagrams. Describe what you need — the toolkit analyzes your intent, proposes the best chart types, asks a few clarifying questions, and produces the diagram from the optimal backend engine.

## Supported Engines

| Engine | Best For | Output |
|---|---|---|
| **Fireworks Tech Graph** | Architecture, UML, ER, data flow | SVG + PNG (1920px) |
| **Mermaid** | Flowcharts, sequences, Gantt | .md (GitHub/Obsidian native) |
| **Excalidraw** | Hand-drawn sketches | .md / .excalidraw |
| **Obsidian Canvas** | Mind maps, concept maps | .canvas |
| **Drawio** | Editable diagrams, collaboration | .drawio / .png / .svg |
| **Dataviz** | Dashboards, charts, KPIs | HTML / SVG / PNG |

## Supported Agents

- Claude Code (verified)
- OpenAI Codex CLI (verified)
- Any Agent that supports Markdown Skill files (manual install)

## Quick Install

```bash
# Clone and install
git clone https://github.com/fengwch/chart-toolkit.git
cd chart-toolkit
./setup.sh

# Or one-liner
curl -fsSL https://raw.githubusercontent.com/fengwch/chart-toolkit/main/setup.sh | bash
```

## Quick Start

After install, restart your Agent and say:

```
"画一个微服务架构图"
"Create a flowchart for our CI/CD pipeline"
"Turn this article into a mind map"
"Make a data dashboard for Q2 sales"
```

The toolkit will guide you interactively.

## How It Works

```
Your request
    → Intent Analysis (what domain? what complexity?)
    → Chart Proposal (3-5 best-fit chart types for you to choose)
    → Deep Interview (clarifying questions)
    → Generation (best engine produces the diagram)
    → Output (SVG/PNG/.md/.drawio/.canvas)
```

## Project Structure

```
chart-toolkit/
├── SKILL.md                  ← The soul — Claude Code auto-loads this
├── adapters/                 ← Engine wrappers
├── knowledge/                ← Decision guides
├── engines/                  ← Upstream tools (cloned at setup)
├── scripts/                  ← Doctor, deps, MCP merge
├── agents/                   ← Agent-specific installers
└── docs/                     ← You are here
```

## License

MIT