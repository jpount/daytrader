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
# Claude will automatically initialize taskmaster when you mention tasks
# Or you can manually ensure it's set up:
mkdir -p .taskmaster
cp tasks.json .taskmaster/
```

### 4. Use Task Automation
Tell Claude one of these - the **first option** is the suggested approach:
- "Initialize taskmaster and run the documentation tasks" 
- "Please run the documentation tasks using taskmaster"
- "Use task automation to generate documentation"

Or manually start with:
- "Run task 01-init to set up the documentation structure"
- "Run task 02-codebase-analysis to identify the technology stack"
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