# Mermaid Visualizer Adapter

## Engine
`engines/mermaid-visualizer/SKILL.md` — axtonliu/axton-obsidian-visual-skills (MIT)

## Capabilities
- Process Flow (graph TB/LR) — workflows, decision trees
- Circular Flow — cyclic processes, feedback loops
- Comparison Diagram — A vs B, before/after
- Mindmap — hierarchical knowledge
- Sequence Diagram — API calls, message flows
- State Diagram — lifecycle, status transitions
- Class Diagram, ER Diagram, Gantt Chart

## Output
- `.md` with ````mermaid` code fence — rendered natively by Obsidian, GitHub, GitLab, Notion
- Configurable: layout, detail level, color scheme

## Prerequisites
- None. Mermaid is rendered by the platform (Obsidian/GitHub), not locally.
- The output `.md` file IS the diagram.

## Execution

1. **Load the upstream skill**: Read `engines/mermaid-visualizer/SKILL.md`
2. **Follow its Workflow**:
   a. Analyze content — identify concepts, relationships, hierarchy
   b. Select diagram type from Mermaid's supported types
   c. Choose configuration — layout direction, detail level, color scheme
   d. Generate Mermaid code — follow Critical Syntax Rules strictly
   e. Quality checklist before output:
      - [ ] No "number. space" patterns in node text (use circled numbers ①②③ or `[Step N:]` prefix)
      - [ ] All subgraphs use `subgraph id["Display Name"]` format
      - [ ] All node references use IDs, not display names
      - [ ] Special chars: `"` → `『』`, `()` → `「」`
      - [ ] No Emoji in node text
      - [ ] Colors from the standard palette
3. **Output** wrapped in ````mermaid` code fence with brief explanation
4. **Report** file path and rendering platforms (Obsidian, GitHub, etc.)

## Critical Syntax Rules (from upstream)

1. Node text: NO `1. ` patterns → use `[1.Perception]` or `[① Perception]`
2. Subgraph: ALWAYS `subgraph id["Label"]` NOT `subgraph Label`
3. Arrows: `-->` solid, `-.->` dashed, `==>` thick, `~~~` invisible
4. Quotes for text with spaces: `["text with spaces"]`