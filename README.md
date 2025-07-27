# Universal Codebase Documentation System

This repository provides a reusable documentation system that can analyze any codebase and generate comprehensive documentation with modernization recommendations.

## Overview

The system is designed to:
- Analyze any codebase (Java, .NET, or other technologies)
- Generate detailed technical documentation
- Identify architectural patterns and components
- Provide modernisation recommendations
- Create visual diagrams in Mermaid format

## Repository Structure

```
.
├── app/            # Place your codebase here for analysis
├── config/         # Configuration files (preserved)
├── docs/           # Generated documentation (cleaned/regenerated)
├── requirements/   # System requirements (preserved)
├── scripts/        # Utility scripts (preserved)
├── viewers/        # Documentation viewers (preserved)
└── tasks.json      # Task automation configuration
```

## How to Use

### 1. Setup Claude

Setup MCPs and ENVs:
```bash
# Create local .claude directory
mkdir .claude
cp config/settings.local.json .claude/
# Create local MCP confirm
cp config/.mcp.json.example ./.mcp.json
# Update the new file with any token/api keys
# Create local Env file
cp config/.env.example ./.env
# Update the new file with any env values
```

### 2. Setup

Place your codebase in the `app/` directory:
```bash
# Copy your entire codebase to the app directory
cp -r /path/to/your/codebase/* app/
```

### 3. Initialize Documentation Structure

```bash
./scripts/init.sh
```

This creates the documentation directory structure.

### 4. Run Documentation Generation

Use Claude Code with the provided `tasks.json`:

#### Option A: Let Claude Initialize Taskmaster
1. Open Claude Code in this directory
2. Tell Claude: "Initialize taskmaster and run the documentation tasks"
3. Claude will set up taskmaster and begin the analysis

#### Option B: Manual Taskmaster Setup
1. Initialize taskmaster:
   ```bash
   mkdir -p .taskmaster
   cp tasks.json .taskmaster/
   ```
2. Tell Claude: "Run the documentation tasks using taskmaster"
3. The system will analyze your codebase and generate documentation

#### Option C: Direct Task Execution
1. Tell Claude: "Please run task 01-init from tasks.json"
2. Continue with subsequent tasks as Claude completes them

### 5. Clean and Restart (Optional)

To analyze a different codebase:
```bash
# Clean existing documentation
./scripts/clean.sh

# Copy new codebase to app/
cp -r /path/to/new/codebase/* app/

# Re-initialize
./scripts/init.sh
```

## Documentation Structure

Generated documentation will be organised as follows:

```
docs/
├── analysis/           # Initial codebase analysis
├── architecture/       # System architecture documentation
├── business-logic/     # Business flows and rules
├── data-models/       # Data structures and relationships
├── api/               # API documentation
├── diagrams/          # Visual diagrams (.mmd files)
├── modernisation/     # Migration recommendations
└── executive-summary.md
```

## Features

### Technology Agnostic
- Automatically detects technology stack
- Adapts analysis based on detected technologies
- Supports Java, .NET, and other platforms

### Comprehensive Analysis
- Component inventory
- Architecture patterns
- API documentation
- Data model analysis
- Business flow extraction
- Security assessment
- Performance analysis

### Modernisation Focus
- Identifies outdated technologies
- Provides specific migration paths:
  - Java EE → Spring Boot + Angular
  - .NET Framework → .NET Core/6+
  - Monolith → Microservices
  - Legacy UI → Modern SPA

### Visual Documentation
- Generates Mermaid diagrams
- Architecture diagrams
- Sequence diagrams
- ER diagrams
- Migration roadmaps

## Scripts

- `init.sh` - Initialize documentation structure
- `clean.sh` - Remove all generated documentation
- `validate-mermaid.sh` - Validate Mermaid diagram syntax

## Example: DayTrader

The current `app/` directory contains DayTrader3, a Java EE benchmark application. Running the documentation system on this codebase will generate:
- Complete component analysis
- Java EE → Spring Boot migration plan
- JSP → Angular recommendations
- Detailed architectural documentation

## Requirements

- Bash shell
- Claude Code for task automation
- (Optional) Mermaid CLI for diagram validation: `npm install -g @mermaid-js/mermaid-cli`

## Notes

- All generated documentation is in Markdown format
- Diagrams use Mermaid syntax with .mmd extension
- The system preserves your original codebase in `app/`
- Documentation can be regenerated at any time