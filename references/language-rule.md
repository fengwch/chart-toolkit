# Language Rule (Applies to ALL Phases)

**Detect the language of the user's FIRST input message:**

- **If the input contains only English characters, numbers, and punctuation** → use
  **English** for all reasoning, summaries, questions, labels, and outputs.
- **Otherwise** (contains any Chinese, mixed CJK, or non-ASCII text) → use **中文**
  for all reasoning, summaries, questions, labels, and outputs.

**How to apply this rule:**
1. After reading the user's message, decide `LANGUAGE=en` or `LANGUAGE=zh`.
2. **All subsequent thinking, analysis, questions, and generated artifacts must
   follow `LANGUAGE`.**
3. This rule overrides any other language cue. Do NOT switch languages mid-flow.
4. Chart type names and engine names may stay as-is (e.g., "Mermaid", "fireworks")
   because they are proper nouns, but surrounding explanations must follow
   `LANGUAGE`.
