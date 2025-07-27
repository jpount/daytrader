# Start Here - Documentation Generation Instructions

## Quick Start for Claude Code

After running `./scripts/clean.sh`, follow these steps:

### 1. Ensure your codebase is in the `app/` directory
```bash
ls app/  # Should show your codebase files
```

### 2. Initialize the documentation structure
```bash
./scripts/init.sh
```

### 3. Initialize Task Automation (if needed)
If taskmaster hasn't been initialized:
```bash
Initialize taskmaster project for claude code
# Task master will create a folder structure and then ask to proceed with initialise_project
# It will then advise on creating a PRD but instead you can ask it to: 
Copy my existing task.json file to .taskmaster/tasks/
# Then generate the task files:
Generate individual task files
```

### 4. Use Tasks
Tell Claude one of these - the **first option** is the suggested approach:
- "Run the documentation tasks using taskmaster"
- "Use task automation to generate documentation"

Or manually start with:
- "Run task 01-codebase-analysis"
- Continue through all tasks...

### 4. Key Files
- `tasks.json` - Contains all 15 documentation tasks
- `README.md` - Detailed instructions
- `scripts/` - Utility scripts

### What Gets Generated
- `docs/` - All documentation
- `CLAUDE.md` - Codebase-specific guidance for future sessions

### Tips
- Tasks are sequential - let each complete before moving to the next
- Task 02 (codebase analysis) adapts all following tasks to your technology
- Diagrams use .mmd extension (Mermaid format)
- Run `./scripts/validate-mermaid.sh` to check diagram syntax

## For Different Codebases
1. Run `./scripts/clean.sh`
2. Copy new code to `app/`
3. Start from step 2 above