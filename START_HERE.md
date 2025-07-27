# Start Here - Documentation Generation Instructions

## Quick Start for Claude Code

After running `./scripts/clean.sh`, follow these steps:

### 1. Ensure your codebase is in the `app/` directory
```bash
ls app/  # Should show your codebase files
```

### 2. Initialize the documentation structure
```bash
./scripts/clean.sh
./scripts/init.sh
```

### 3. Initialize Task Automation (if needed)
**IMPORTANT: Always run taskmaster commands from the project root directory, NOT from the app/ directory**

If taskmaster hasn't been initialized:
```bash
# Make sure you're in the project root, not in app/
cd /path/to/project/root  # Replace with your actual project path
# Start Claude
claude
```

Then tell Claude:
```
Initialize taskmaster project for claude code - do not create a PRD as there is already a tasks.json file. Copy the file to .taskmaster/tasks/ and generate the individual task files
```

**Known Issues & Workarounds:**
- If TaskMaster reports "Task X not found" when trying to update status, this is a known bug
- The tasks ARE properly imported and can be viewed with `task-master list`
- To work around status updates, you can:
  1. View tasks with `task-master list` and `task-master show <id>`
  2. Manually track completion in the documentation
  3. Edit .taskmaster/tasks/tasks.json directly if needed

**Verification Steps:**
1. Run `task-master list` - you should see all 15 tasks
2. Run `task-master show 1` - you should see task details
3. If dependencies show as "Not found", run `task-master validate-dependencies` (but be careful - it may remove all dependencies)
4. Keep the root tasks.json as backup

### 4. Use Tasks
Tell Claude one of these - the **first option** is the suggested approach:
- "Run the documentation tasks using taskmaster"
- "Use task automation to generate documentation"

Or manually start with:
- "Run task 1"
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