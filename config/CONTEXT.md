# DayTrader Documentation Project - Context Retention

## Purpose
This file helps retain critical context across Claude sessions, especially after compaction.

## CRITICAL: Validation Scripts Must Run After Each Task!
The validation scripts were being run before compaction but this context was lost. They MUST be run:
- After creating any Mermaid diagram: `bash scripts/validate-mermaid.sh`
- After completing any task: `bash scripts/validate-all.sh`

## Key Workflows

### After Each Task Completion

1. **Update Task Status**
   - Update status in both `/tasks.json` and `/.taskmaster/tasks/tasks.json`
   - Run `mcp__taskmaster-ai__generate` to regenerate task files

2. **Run Validation Scripts**
   - After creating Mermaid diagrams: `bash scripts/validate-mermaid.sh`
   - After completing any task: `bash scripts/validate-all.sh`
   - Fix any issues reported before marking task as complete

### Task Status Tracking

#### Completed Tasks:
- Task 1: Codebase Analysis and Technology Detection ✓
- Task 2: Component Inventory ✓  
- Task 3: Architecture Analysis ✓

#### Current Issues to Fix:
- Mermaid diagram syntax validation pending
- Need to run validation scripts after Task 3

### Important Files Created

#### Task 1 Output:
- `/docs/analysis/codebase-overview.md`

#### Task 2 Output:
- `/docs/analysis/component-inventory.md`

#### Task 3 Output:
- `/docs/architecture/architecture-analysis.md`
- `/docs/diagrams/system-architecture.mmd` (needs validation)

### Known Issues

1. **TaskMaster Synchronization**
   - Manual updates to tasks.json require running `mcp__taskmaster-ai__generate`
   - Task dependencies show as "Not found" but this is a known bug
   - TaskMaster correctly shows task status (verified with `mcp__taskmaster-ai__get_tasks`)

2. **Validation Requirements**
   - All Mermaid diagrams must pass `validate-mermaid.sh`
   - All documentation must pass `validate-all.sh`
   - These scripts are in the `/scripts/` directory
   - Mermaid diagrams cannot use special characters in node labels (/, <br/>, quotes in subgraph names)

### Technology Stack (from Task 1)
- **Application**: DayTrader 3 stock trading benchmark
- **Type**: Java EE 6 application  
- **Architecture**: Modular monolith (3 modules in EAR)
- **Modules**: EJB (27 components), Web (43 components), REST (6 components)
- **Database**: Apache Derby
- **Server**: WebSphere Liberty

### Next Steps
1. Run validation scripts for Task 3
2. Fix any Mermaid syntax errors
3. Proceed to Task 4: API and Interface Documentation

## Validation Command Reference
```bash
# Validate Mermaid diagrams
bash scripts/validate-mermaid.sh

# Validate all documentation
bash scripts/validate-all.sh

# Regenerate task files after manual edits
mcp__taskmaster-ai__generate --projectRoot /Users/jp/work/ai-messin/daytrader
```