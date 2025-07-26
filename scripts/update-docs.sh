#!/bin/bash

# Utility script to update documentation status and track progress

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
RED='\033[0;31m'
NC='\033[0m'

# Function to show usage
show_usage() {
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  status              Show documentation status"
    echo "  mark-complete       Mark a component as documented"
    echo "  add-component       Add a new component to track"
    echo "  add-flow           Add a new business flow"
    echo "  search             Search documentation"
    echo "  validate           Validate documentation completeness"
    echo ""
    echo "Examples:"
    echo "  $0 status"
    echo "  $0 mark-complete servlet TradeAppServlet"
    echo "  $0 add-component MyServlet servlet daytrader3-ee6-web /path/to/file.java"
    echo "  $0 search 'login flow'"
}

# Check command
if [ $# -eq 0 ]; then
    show_usage
    exit 1
fi

COMMAND=$1
shift

case $COMMAND in
    status)
        echo -e "${GREEN}Documentation Status${NC}"
        echo "===================="
        echo ""
        
        # Show database status if available
        if [ -f "${DB_DIR}/${DB_NAME}" ]; then
            python3 "${SCRIPTS_DIR}/db_helper.py" "${DB_DIR}/${DB_NAME}" status | python3 -m json.tool
        else
            echo -e "${RED}Database not found. Run setup-docs.sh first.${NC}"
        fi
        
        # Show file counts
        echo ""
        echo -e "${YELLOW}Documentation Files:${NC}"
        echo "Architecture docs: $(find ${DOCS_DIR}/architecture -name "*.md" 2>/dev/null | wc -l)"
        echo "Business logic docs: $(find ${DOCS_DIR}/business-logic -name "*.md" 2>/dev/null | wc -l)"
        echo "API docs: $(find ${DOCS_DIR}/api-documentation -name "*.md" 2>/dev/null | wc -l)"
        echo "Diagrams: $(find ${DOCS_DIR}/diagrams -name "*.mermaid" 2>/dev/null | wc -l)"
        ;;
        
    mark-complete)
        if [ $# -lt 2 ]; then
            echo "Usage: $0 mark-complete <type> <name>"
            echo "Types: component, flow, endpoint"
            exit 1
        fi
        
        TYPE=$1
        NAME=$2
        
        echo -e "${YELLOW}Marking $TYPE '$NAME' as documented...${NC}"
        
        # Update database
        case $TYPE in
            component|servlet|ejb|entity)
                sqlite3 "${DB_DIR}/${DB_NAME}" "UPDATE components SET documented = 1 WHERE name = '$NAME';"
                ;;
            flow)
                sqlite3 "${DB_DIR}/${DB_NAME}" "UPDATE business_flows SET documented = 1 WHERE name = '$NAME';"
                ;;
            endpoint)
                sqlite3 "${DB_DIR}/${DB_NAME}" "UPDATE api_endpoints SET documented = 1 WHERE path = '$NAME';"
                ;;
        esac
        
        echo -e "${GREEN}✓ Marked as complete${NC}"
        ;;
        
    add-component)
        if [ $# -lt 4 ]; then
            echo "Usage: $0 add-component <name> <type> <module> <file_path>"
            exit 1
        fi
        
        NAME=$1
        TYPE=$2
        MODULE=$3
        FILE_PATH=$4
        
        echo -e "${YELLOW}Adding component '$NAME'...${NC}"
        
        python3 "${SCRIPTS_DIR}/db_helper.py" "${DB_DIR}/${DB_NAME}" add-component "$NAME" "$TYPE" "$MODULE" "$FILE_PATH"
        
        echo -e "${GREEN}✓ Component added${NC}"
        ;;
        
    add-flow)
        if [ $# -lt 3 ]; then
            echo "Usage: $0 add-flow <name> <category> <description>"
            echo "Categories: trading, user-management, portfolio, market-data, admin"
            exit 1
        fi
        
        NAME=$1
        CATEGORY=$2
        DESCRIPTION=$3
        
        echo -e "${YELLOW}Adding business flow '$NAME'...${NC}"
        
        sqlite3 "${DB_DIR}/${DB_NAME}" << EOF
INSERT INTO business_flows (name, category, description, steps, documented)
VALUES ('$NAME', '$CATEGORY', '$DESCRIPTION', '[]', 0);
EOF
        
        echo -e "${GREEN}✓ Business flow added${NC}"
        ;;
        
    search)
        if [ $# -eq 0 ]; then
            echo "Usage: $0 search <query>"
            exit 1
        fi
        
        QUERY="$*"
        echo -e "${YELLOW}Searching for: $QUERY${NC}"
        echo ""
        
        # Search in markdown files
        echo -e "${BLUE}In documentation files:${NC}"
        grep -r "$QUERY" "${DOCS_DIR}" --include="*.md" 2>/dev/null | head -20 || echo "No matches found"
        
        # Search in database
        echo ""
        echo -e "${BLUE}In database:${NC}"
        sqlite3 "${DB_DIR}/${DB_NAME}" << EOF
SELECT 'Component: ' || name || ' (' || type || ')' 
FROM components 
WHERE name LIKE '%$QUERY%' OR description LIKE '%$QUERY%'
LIMIT 10;
EOF
        ;;
        
    validate)
        echo -e "${GREEN}Validating Documentation${NC}"
        echo "======================="
        echo ""
        
        # Check for missing files
        echo -e "${YELLOW}Checking for missing documentation...${NC}"
        
        MISSING=0
        
        # Check key files exist
        for file in \
            "architecture/overview.md" \
            "business-logic/trading-flows.md" \
            "data-models/entity-relationships.md" \
            "api-documentation/servlet-mappings.md"
        do
            if [ ! -f "${DOCS_DIR}/$file" ]; then
                echo -e "${RED}✗ Missing: $file${NC}"
                ((MISSING++))
            else
                echo -e "${GREEN}✓ Found: $file${NC}"
            fi
        done
        
        echo ""
        if [ $MISSING -eq 0 ]; then
            echo -e "${GREEN}All key documentation files present!${NC}"
        else
            echo -e "${RED}Missing $MISSING key files${NC}"
        fi
        
        # Check for undocumented items
        echo ""
        echo -e "${YELLOW}Undocumented items:${NC}"
        python3 "${SCRIPTS_DIR}/db_helper.py" "${DB_DIR}/${DB_NAME}" undocumented | python3 -m json.tool | head -50
        ;;
        
    *)
        echo -e "${RED}Unknown command: $COMMAND${NC}"
        show_usage
        exit 1
        ;;
esac