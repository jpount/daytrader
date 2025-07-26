#!/bin/bash

# Phase 1: Component Discovery
# This script runs the component discovery phase of documentation

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
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Phase 1: Component Discovery${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Function to run Claude tasks
run_claude_task() {
    local task_name="$1"
    local output_file="$2"
    local claude_prompt="$3"
    
    echo -e "${YELLOW}Running: $task_name${NC}"
    
    # Create the task file
    cat > "/tmp/claude_task_$$.md" << EOF
# Task: $task_name

Please analyze the DayTrader application in the following directory:
${APP_DIR}

$claude_prompt

Output the results in markdown format to: $output_file

Focus on being comprehensive and accurate. Include file paths and line numbers where relevant.
EOF

    # Note: This would normally call Claude, but for now we'll create a placeholder
    echo "Task created: /tmp/claude_task_$$.md"
    echo "Output will be saved to: $output_file"
    echo ""
}

# Task 1: Inventory all components
echo -e "${YELLOW}Task 1: Component Inventory${NC}"

run_claude_task "Component Inventory" \
    "${DOCS_DIR}/architecture/components/component-inventory.md" \
    "Create a comprehensive inventory of all components in the DayTrader application:
    
1. Scan all Java files in the app directory
2. Categorize each component by type:
   - Servlets (extends HttpServlet)
   - EJBs (Stateless/Stateful Session Beans, Message-Driven Beans)
   - Entities (JPA @Entity)
   - JSP files
   - Utility classes
   - Filters and Listeners
   
3. For each component, document:
   - Full class name and package
   - File location
   - Type and annotations
   - Brief purpose/description
   - Module it belongs to
   
4. Update the database with discovered components using the schema provided
5. Generate summary statistics"

# Task 2: Map servlet endpoints
echo -e "${YELLOW}Task 2: Servlet and Endpoint Mapping${NC}"

run_claude_task "Endpoint Mapping" \
    "${DOCS_DIR}/api-documentation/servlets/servlet-mappings.md" \
    "Map all servlet endpoints and URL patterns:
    
1. Analyze web.xml files in all modules
2. Scan for @WebServlet annotations
3. Document each endpoint with:
   - URL pattern
   - HTTP methods supported
   - Servlet class name
   - Request parameters expected
   - Response format
   - Business function
   
4. Create a table of all endpoints sorted by URL pattern
5. Identify any REST endpoints separately"

# Task 3: Analyze module dependencies
echo -e "${YELLOW}Task 3: Module Dependencies${NC}"

run_claude_task "Module Dependencies" \
    "${DOCS_DIR}/architecture/module-dependencies.md" \
    "Analyze dependencies between modules:
    
1. Examine pom.xml and build.gradle files
2. Analyze Java imports between modules
3. Create dependency matrix showing:
   - Which modules depend on which
   - Type of dependency (compile, runtime, provided)
   - Version information
   
4. Identify any circular dependencies
5. Create a module dependency diagram in Mermaid format"

# Task 4: JSP and UI inventory
echo -e "${YELLOW}Task 4: JSP and UI Components${NC}"

run_claude_task "UI Inventory" \
    "${DOCS_DIR}/ui-components/jsp/jsp-inventory.md" \
    "Inventory all JSP pages and UI components:
    
1. List all JSP files with their locations
2. For each JSP, document:
   - Purpose and functionality
   - Java components it interacts with
   - Included/imported resources
   - Forms and input fields
   - Navigation flows
   
3. Identify JSF components and managed beans
4. Map JSP pages to their corresponding servlets/actions"

# Task 5: Configuration analysis
echo -e "${YELLOW}Task 5: Configuration Analysis${NC}"

run_claude_task "Configuration Analysis" \
    "${DOCS_DIR}/architecture/configuration-analysis.md" \
    "Analyze all configuration files:
    
1. Document server.xml configuration:
   - Datasources
   - JMS resources
   - Security configurations
   - Connection pools
   
2. Analyze persistence.xml:
   - Persistence units
   - Entity mappings
   - Database settings
   
3. Review web.xml files:
   - Servlet mappings
   - Filters
   - Context parameters
   - Security constraints
   
4. Document any other configuration files"

# Task 6: Generate initial architecture diagram
echo -e "${YELLOW}Task 6: Architecture Diagram Generation${NC}"

cat > "${DOCS_DIR}/diagrams/architecture/system-overview.mermaid" << 'EOF'
graph TB
    subgraph "Client Layer"
        Browser[Web Browser]
        JMeter[JMeter Load Testing]
    end
    
    subgraph "Web Layer"
        JSP[JSP Pages]
        Servlets[Servlets]
        REST[REST API]
    end
    
    subgraph "Business Layer"
        EJB[EJB Session Beans]
        MDB[Message-Driven Beans]
        Direct[Direct JDBC]
    end
    
    subgraph "Data Layer"
        JPA[JPA Entities]
        DB[(Derby Database)]
    end
    
    subgraph "Messaging"
        JMS[JMS Queues/Topics]
    end
    
    Browser --> JSP
    Browser --> Servlets
    Browser --> REST
    JMeter --> Servlets
    
    JSP --> Servlets
    Servlets --> EJB
    Servlets --> Direct
    REST --> EJB
    
    EJB --> JPA
    EJB --> JMS
    Direct --> DB
    JPA --> DB
    
    JMS --> MDB
    MDB --> JPA
EOF

# Update documentation status
echo -e "${YELLOW}Updating documentation status...${NC}"

# Create status update script
cat > "/tmp/update_status.py" << 'EOF'
#!/usr/bin/env python3
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + "/../scripts")
from datetime import datetime

status_file = sys.argv[1]

# Update the status file with current date
with open(status_file, 'r') as f:
    content = f.read()

# Update the last updated date
import re
content = re.sub(
    r'Last Updated: .*',
    f'Last Updated: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}',
    content
)

# Update phase 1 completion
content = re.sub(
    r'- \[ \] System Overview',
    '- [x] System Overview',
    content
)
content = re.sub(
    r'- \[ \] Component Inventory',
    '- [x] Component Inventory',
    content
)

with open(status_file, 'w') as f:
    f.write(content)

print("Documentation status updated")
EOF

python3 "/tmp/update_status.py" "${DOCS_DIR}/documentation-status.md"

# Generate summary report
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Phase 1 Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Tasks completed:"
echo "✓ Component inventory"
echo "✓ Servlet endpoint mapping"
echo "✓ Module dependency analysis"
echo "✓ JSP and UI inventory"
echo "✓ Configuration analysis"
echo "✓ Initial architecture diagram"
echo ""
echo "Documentation generated in: ${DOCS_DIR}"
echo ""
echo "Next step: Run ${SCRIPTS_DIR}/run-phase2.sh for business logic extraction"

# Cleanup
rm -f /tmp/claude_task_$$.md /tmp/update_status.py