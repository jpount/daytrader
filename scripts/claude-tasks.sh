#!/bin/bash

# Claude task execution helper
# This script helps create and manage Claude tasks for documentation

set -e

# Load environment
if [ -f "$(dirname "${BASH_SOURCE[0]}")/../.env.documentation" ]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../.env.documentation"
else
    echo "Error: Environment file not found. Run setup-docs.sh first."
    exit 1
fi

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Task templates directory
TASK_DIR="${PROJECT_ROOT}/.claude-tasks"
mkdir -p "${TASK_DIR}"

# Function to create a Claude task
create_task() {
    local task_name="$1"
    local task_type="$2"
    local output_file="$3"
    local task_id=$(date +%s)
    local task_file="${TASK_DIR}/task_${task_id}_${task_name// /_}.md"
    
    case $task_type in
        component-scan)
            cat > "$task_file" << EOF
# Task: Component Scan - $task_name

## Objective
Scan and document all components in the specified module.

## Instructions

1. Analyze all Java files in: ${APP_DIR}/$task_name
2. For each component found, document:
   - Full class name and package
   - Component type (Servlet, EJB, Entity, etc.)
   - Key annotations (@WebServlet, @Stateless, @Entity, etc.)
   - Public methods and their purposes
   - Dependencies (what it imports/uses)
   - Business purpose

3. Update the documentation database with findings
4. Generate summary statistics

## Output
Save comprehensive documentation to: $output_file

## Code Reference Format
Always use: filename.java:lineNumber format for references

## Focus Areas
- Be thorough but concise
- Identify patterns and conventions
- Note any deprecated or unusual code
- Flag potential migration challenges
EOF
            ;;
            
        business-flow)
            cat > "$task_file" << EOF
# Task: Business Flow Analysis - $task_name

## Objective
Extract and document the complete business flow for: $task_name

## Instructions

1. Start from entry points (servlets, REST endpoints, JSPs)
2. Trace execution through all layers:
   - Web tier (servlets, filters)
   - Business tier (EJBs, services)
   - Data tier (entities, DAOs)

3. Document each step:
   - Method calls with parameters
   - Business logic and rules
   - Data transformations
   - Error handling
   - Transaction boundaries

4. Create sequence diagram showing the flow

## Key Information to Extract
- Pre-conditions and post-conditions
- Business rules and validations
- Side effects (emails, messages, etc.)
- Performance considerations

## Output
Save to: $output_file

Include:
- Narrative description
- Step-by-step breakdown
- Sequence diagram in Mermaid format
- Business rules catalog
EOF
            ;;
            
        api-mapping)
            cat > "$task_file" << EOF
# Task: API Endpoint Mapping - $task_name

## Objective
Map all API endpoints in the $task_name module.

## Instructions

1. Scan web.xml for servlet mappings
2. Look for @WebServlet annotations
3. Check for REST endpoints (@Path, @GET, @POST, etc.)
4. Document each endpoint:
   - URL pattern
   - HTTP methods
   - Request parameters/body
   - Response format
   - Authentication requirements
   - Business function

5. Create API specification table

## Output Format
| Endpoint | Method | Servlet/Class | Purpose | Auth Required |
|----------|--------|---------------|---------|---------------|
| /app/trade | POST | TradeAppServlet | Execute trade | Yes |

Save to: $output_file
EOF
            ;;
            
        migration-analysis)
            cat > "$task_file" << EOF
# Task: Migration Analysis - $task_name

## Objective
Analyze $task_name for Spring Boot/Angular migration.

## Instructions

1. Identify current implementation:
   - Technologies used
   - Design patterns
   - Dependencies
   - Configuration

2. Map to Spring Boot equivalents:
   - EJB → Spring Service
   - Servlet → REST Controller
   - JSP → Angular Component
   - JNDI → Spring Configuration

3. Document migration steps:
   - Code changes required
   - Configuration migration
   - Testing approach
   - Risk assessment

4. Flag challenges:
   - Complex transactions
   - Stateful components
   - Legacy dependencies
   - Security changes

## Output
Save migration plan to: $output_file

Include:
- Current vs. target architecture
- Step-by-step migration guide
- Code examples
- Risk mitigation strategies
EOF
            ;;
    esac
    
    echo -e "${GREEN}✓ Created task: $task_file${NC}"
    echo ""
    echo "Task ID: $task_id"
    echo "To execute with Claude:"
    echo "  claude --task @$task_file"
}

# Function to list tasks
list_tasks() {
    echo -e "${YELLOW}Available Claude Tasks:${NC}"
    echo ""
    
    if [ -d "$TASK_DIR" ] && [ "$(ls -A $TASK_DIR 2>/dev/null)" ]; then
        for task in "$TASK_DIR"/*.md; do
            if [ -f "$task" ]; then
                basename "$task"
                head -n 3 "$task" | tail -n 1 | sed 's/^/  /'
                echo ""
            fi
        done
    else
        echo "No tasks found."
    fi
}

# Function to execute task
execute_task() {
    local task_id="$1"
    local task_file=$(find "$TASK_DIR" -name "*${task_id}*.md" | head -1)
    
    if [ -z "$task_file" ]; then
        echo -e "${RED}Task not found: $task_id${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Executing task from: $task_file${NC}"
    echo ""
    
    # Here you would normally call Claude with the task
    # For now, we'll just display the task
    cat "$task_file"
    
    echo ""
    echo -e "${BLUE}Note: In production, this would execute:${NC}"
    echo "  claude --task @$task_file"
}

# Main script logic
case "${1:-help}" in
    create)
        if [ $# -lt 4 ]; then
            echo "Usage: $0 create <name> <type> <output_file>"
            echo "Types: component-scan, business-flow, api-mapping, migration-analysis"
            exit 1
        fi
        create_task "$2" "$3" "$4"
        ;;
        
    list)
        list_tasks
        ;;
        
    execute)
        if [ $# -lt 2 ]; then
            echo "Usage: $0 execute <task_id>"
            exit 1
        fi
        execute_task "$2"
        ;;
        
    clean)
        echo -e "${YELLOW}Cleaning old tasks...${NC}"
        find "$TASK_DIR" -name "*.md" -mtime +7 -delete
        echo -e "${GREEN}✓ Cleaned tasks older than 7 days${NC}"
        ;;
        
    help|*)
        echo "Claude Task Manager"
        echo "=================="
        echo ""
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  create <name> <type> <output>  Create a new Claude task"
        echo "  list                          List all tasks"
        echo "  execute <task_id>             Execute a task"
        echo "  clean                         Remove old tasks"
        echo ""
        echo "Task Types:"
        echo "  component-scan     Scan and document components"
        echo "  business-flow      Analyze business flows"
        echo "  api-mapping        Map API endpoints"
        echo "  migration-analysis Analyze for migration"
        echo ""
        echo "Examples:"
        echo "  $0 create daytrader3-ee6-ejb component-scan docs/ejb-components.md"
        echo "  $0 create 'Login Flow' business-flow docs/login-flow.md"
        echo "  $0 list"
        echo "  $0 execute 1234567890"
        ;;
esac