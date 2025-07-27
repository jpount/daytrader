#!/bin/bash

# Validate all Mermaid diagrams in the documentation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DOCS_DIR="${PROJECT_ROOT}/docs"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Mermaid Diagram Validation"
echo "========================="
echo ""

# Check for mmdc (Mermaid CLI)
if ! command -v mmdc &> /dev/null; then
    echo -e "${YELLOW}Warning: Mermaid CLI (mmdc) not installed${NC}"
    echo "Install with: npm install -g @mermaid-js/mermaid-cli"
    echo ""
    echo "Performing basic syntax check instead..."
    BASIC_CHECK=true
else
    BASIC_CHECK=false
fi

# Find all .mmd files
TOTAL=0
VALID=0
ERRORS=0

while IFS= read -r -d '' file; do
    TOTAL=$((TOTAL + 1))
    echo -n "Checking: ${file#$PROJECT_ROOT/}... "
    
    if [ "$BASIC_CHECK" = true ]; then
        # Basic syntax validation
        if head -n 1 "$file" | grep -qE "^(graph|sequenceDiagram|classDiagram|stateDiagram|erDiagram|flowchart|gantt|pie|gitGraph|journey)"; then
            echo -e "${GREEN}✓${NC}"
            VALID=$((VALID + 1))
        else
            echo -e "${RED}✗ Invalid diagram type${NC}"
            ERRORS=$((ERRORS + 1))
        fi
    else
        # Full validation with mmdc
        if mmdc -i "$file" -o "/tmp/test.svg" -q 2>/dev/null; then
            echo -e "${GREEN}✓${NC}"
            VALID=$((VALID + 1))
            rm -f "/tmp/test.svg"
        else
            echo -e "${RED}✗ Syntax error${NC}"
            ERRORS=$((ERRORS + 1))
        fi
    fi
done < <(find "${DOCS_DIR}" -name "*.mmd" -type f -print0)

echo ""
echo "Summary:"
echo "  Total diagrams: $TOTAL"
echo "  Valid: $VALID"
echo "  Errors: $ERRORS"

if [ $ERRORS -eq 0 ] && [ $TOTAL -gt 0 ]; then
    echo -e "${GREEN}All diagrams are valid!${NC}"
    exit 0
elif [ $TOTAL -eq 0 ]; then
    echo -e "${YELLOW}No diagrams found${NC}"
    exit 0
else
    echo -e "${RED}Found $ERRORS invalid diagrams${NC}"
    exit 1
fi