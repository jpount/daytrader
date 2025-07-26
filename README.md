# DayTrader Documentation

This branch (gen-doc) demonstrates how to document the current codebase apprpriately

## Pre Reqs if you want to run yourself
* Delete existing CLAUDE.md file
* Delete everything out of the docs/diagrams and docs/ folders
* Run claude /init
* Set up MCPs - see below
* Review tasks in tasks.json and reset every status to `pending` if it's not already

## MCPs
* Copy the mcp.json.example file to the root directory and remove the `.example` suffix
* Add your API keys where appropriate

### Investigation
Used claude code with this prompt to generate the `document-gathering.md` file
```
I want to use claude code on the current directory to completely understand the codebase under the app directory. I want to write extremely comprehensive and accurate documentation in markdown and generate diagrams with in mermaid format. The ultimate goal is to rewrite the application in springboot and angular so I need to ensure I capture all business logics, flows, interactions etc. The docs will got in the docs directory and the diagrams in docs/diagrams. I was thinking of using claude task master to guide the exercise and maybe a database mcp to hold the information generated. Provide the best advice for achieving this and document it in a document-gathering.md file
```

## Running
You can either:

* Create tasks and kick of task master
OR
* Run the scripts to create the docs

### Using the scripts

  1. Initial Setup (Run Once)

  cd /Users/jp/work/ai-messin/daytrader

  # First, create the database initialization scripts
  ./scripts/create-db-scripts.sh

  # Then run the main setup
  ./scripts/setup-docs.sh

  # Load the environment variables
  source .env.documentation

  2. Documentation Phases (Run Sequentially)

  # Phase 1: Component Discovery (Days 1-2)
  ./scripts/run-phase1.sh

  # Phase 2: Business Logic Extraction (Days 3-5)
  ./scripts/run-phase2.sh

  # Phase 3: Diagram Generation (Days 6-7)
  ./scripts/run-phase3.sh

  3. Utility Scripts (Run As Needed)

  # Check documentation progress
  ./scripts/update-docs.sh status

  # Create Claude tasks for specific analysis
  ./scripts/claude-tasks.sh create "EJB Analysis" component-scan docs/ejb-analysis.md

  # Mark components as documented
  ./scripts/update-docs.sh mark-complete servlet TradeAppServlet

  # Search documentation
  ./scripts/update-docs.sh search "login flow"

  4. Final Report (Run After Phases Complete)

  # Generate comprehensive documentation report
  ./scripts/generate-report.sh

  Note: The phase scripts create task templates for Claude to execute. In practice, you would run Claude with these tasks between phases to actually
  generate the documentation content.