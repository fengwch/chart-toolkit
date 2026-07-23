# Chart Toolkit 图表工具箱

> 一句话描述需求，自动推荐最佳图表方案，交互式引导生成专业图表。

跨 Agent、跨平台的图表生成统一入口。支持架构图、流程图、时序图、思维导图、手绘草图、数据可视化等 17 种图表类型。

## 支持引擎

| 引擎 | 最擅长 | 输出格式 |
|---|---|---|
| Fireworks Tech Graph | 架构图、UML、ER、数据流 | SVG + PNG (1920px) |
| Mermaid | 流程图、时序图、甘特图 | .md (GitHub/Obsidian 原生渲染) |
| Excalidraw | 手绘风格图 | .md / .excalidraw |
| Obsidian Canvas | 思维导图、概念图 | .canvas |
| Drawio | 可编辑图表、协作 | .drawio / .png / .svg |
| Dataviz | 数据看板、图表、KPI | HTML / SVG / PNG |

## 一条命令安装

```bash
git clone https://github.com/<org>/chart-toolkit.git
cd chart-toolkit && ./setup.sh
```

## 使用方法

重启 Agent 后说：

```
画一个微服务架构图
生成 CI/CD 流程图
把这篇文档整理成思维导图
做一个 Q2 销售数据看板
```

工具会自动分析意图、列举可选方案、引导式问答、最终生成图表。

## 架构

```
用户输入 → 意图分析 → 图表建议清单 → 深度访谈 → 工具编排 → 输出
```

## 许可

MIT