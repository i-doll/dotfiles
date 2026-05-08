## Planning vs. Exploration
When asked to 'plan' a feature, propose an approach and discuss BEFORE launching autonomous codebase exploration with parallel agents. Ask the user if they want a quick discussion or deep-dive exploration first.

## Version control
 - When committing do not include "Co-Authored-by" or similar co authoring attributions
 - When starting a new task, check out main, pull the latest changes and create a new branch using feat/, chore/ etc. prefixes
 - When setting up a new repo, put tasks/todo.md in the .gitignore
## Workflow Orchestration

### 1. Plan Mode Default
- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately - don't keep pushing
- Use plan mode for verification steps, not just building
- Write detailed specs upfront to reduce ambiguity

### 2. Subagent Strategy to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One task per subagent for focused execution

### 3. Self-Improvement Loop
- After ANY correction from the user: update 'tasks/lessons.md' with the pattern
- Write rules for yourself that prevent the same mistake
- Ruthlessly iterate on these lessons until mistake rate drops
- Review lessons at session start for relevant project

### 4. Verification Before Done
- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness

### 5. Demand Elegance (Balanced)
- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple, obvious fixes - don't over-engineer
- Challenge your own work before presenting it

### 6. Autonomous Bug Fixing
- When given a bug report: just fix it. Don't ask for hand-holding
- Point at logs, errors, failing tests -> then resolve them
- Zero context switching required from the user
- Go fix failing CI tests without being told how

## Task Management
1. **Plan First**: Write plan to 'tasks/todo.md' with checkable items
2. **Verify Plan**: Check in before starting implementation
3. **Track Progress**: Mark items complete as you go
4. **Explain Changes**: High-level summary at each step
5. **Document Results**: Add review to 'tasks/todo.md'
6. **Capture Lessons**: Update 'tasks/lessons.md' after corrections

## Core Principles
- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.

## Testing & Commit Hygiene

### Verification Before Committing
After implementing changes: (1) run lint AND type-check (including any pipeline-specific second-pass like mypy), (2) run the full test suite, (3) verify all related files are staged in a single commit (no split commits for one logical change).

## Security

### Security-Sensitive UI
When building UI for permissions, sharing, or delegation, default to hiding/disabling controls that could enable privilege escalation. Explicitly call out any checkbox/toggle that affects authorization in the PR description.

## LSL Specifics
Always apply llUnescapeURL to URL-encoded strings received from RLV/HTTP-in (including force-teleport commands and warning strings). Verify llLinksetData* edge cases: empty values, missing keys, and unprotected entries with non-empty passwords.
