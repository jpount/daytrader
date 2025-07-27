#!/bin/bash

# Comprehensive validation script for all documentation
# Runs after documentation generation to ensure quality

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DOCS_DIR="${PROJECT_ROOT}/docs"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}Documentation Validation${NC}"
echo "======================="
echo ""

# Initialize counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
WARNINGS=0
ERRORS=0

# Validation report
REPORT="${DOCS_DIR}/validation/final-validation-report.md"
mkdir -p "${DOCS_DIR}/validation"

cat > "$REPORT" << EOF
# Documentation Validation Report

Generated: $(date)

## Summary

EOF

# Function to check if file exists and has content
check_file() {
    local file=$1
    local description=$2
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [ -f "$file" ]; then
        if [ -s "$file" ]; then
            # Check for placeholder text
            if grep -q "\[To be filled\]\|\[This section will be filled\]\|TODO\|PLACEHOLDER" "$file" 2>/dev/null; then
                echo -e "${YELLOW}⚠ $description has placeholders${NC}"
                echo "- ⚠️ $description: Has placeholder content" >> "$REPORT"
                WARNINGS=$((WARNINGS + 1))
            else
                echo -e "${GREEN}✓ $description${NC}"
                echo "- ✅ $description: Complete" >> "$REPORT"
                PASSED_CHECKS=$((PASSED_CHECKS + 1))
            fi
        else
            echo -e "${RED}✗ $description is empty${NC}"
            echo "- ❌ $description: Empty file" >> "$REPORT"
            ERRORS=$((ERRORS + 1))
        fi
    else
        echo -e "${RED}✗ $description not found${NC}"
        echo "- ❌ $description: File not found" >> "$REPORT"
        ERRORS=$((ERRORS + 1))
    fi
}

# Function to validate Mermaid diagram
validate_mermaid() {
    local file=$1
    local name=$(basename "$file")
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [ -f "$file" ]; then
        # Basic syntax check - look for required mermaid keywords
        if grep -q "graph\|sequenceDiagram\|classDiagram\|flowchart\|erDiagram\|stateDiagram" "$file"; then
            # Check if mmdc is available
            if command -v mmdc &> /dev/null; then
                if mmdc -i "$file" -o "/tmp/test-$name.png" 2>/dev/null; then
                    echo -e "${GREEN}✓ $name syntax valid${NC}"
                    echo "- ✅ Diagram $name: Valid syntax" >> "$REPORT"
                    PASSED_CHECKS=$((PASSED_CHECKS + 1))
                    rm -f "/tmp/test-$name.png"
                else
                    echo -e "${RED}✗ $name has syntax errors${NC}"
                    echo "- ❌ Diagram $name: Syntax errors" >> "$REPORT"
                    ERRORS=$((ERRORS + 1))
                fi
            else
                # Fallback validation without mmdc
                echo -e "${YELLOW}⚠ $name (no mmdc for full validation)${NC}"
                echo "- ⚠️ Diagram $name: Basic check passed (mmdc not available)" >> "$REPORT"
                WARNINGS=$((WARNINGS + 1))
            fi
        else
            echo -e "${RED}✗ $name missing diagram type${NC}"
            echo "- ❌ Diagram $name: No valid diagram type found" >> "$REPORT"
            ERRORS=$((ERRORS + 1))
        fi
    else
        echo -e "${RED}✗ Diagram $name not found${NC}"
        echo "- ❌ Diagram $name: File not found" >> "$REPORT"
        ERRORS=$((ERRORS + 1))
    fi
}

# Function to check cross-references
check_references() {
    local file=$1
    local name=$(basename "$file")
    
    # Find all .md references in the file
    local refs=$(grep -oE '\[([^]]+)\]\(([^)]+\.md[^)]*)\)' "$file" 2>/dev/null | grep -oE '\([^)]+\)' | tr -d '()')
    
    for ref in $refs; do
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        # Handle relative and absolute paths
        if [[ "$ref" = /* ]]; then
            # Absolute path
            full_path="${PROJECT_ROOT}${ref}"
        else
            # Relative path
            full_path="$(dirname "$file")/$ref"
        fi
        
        if [ -f "$full_path" ]; then
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            echo -e "${RED}✗ Broken reference in $name: $ref${NC}"
            echo "- ❌ Broken link in $name: $ref" >> "$REPORT"
            ERRORS=$((ERRORS + 1))
        fi
    done
}

echo "## Checking Documentation Files" | tee -a "$REPORT"
echo "" | tee -a "$REPORT"

# Check all expected documentation files
echo -e "\n${YELLOW}Checking core documentation...${NC}"
echo "### Core Documentation" >> "$REPORT"
echo "" >> "$REPORT"

check_file "${DOCS_DIR}/analysis/codebase-overview.md" "Codebase Overview"
check_file "${DOCS_DIR}/analysis/component-inventory.md" "Component Inventory"
check_file "${DOCS_DIR}/architecture/architecture-analysis.md" "Architecture Analysis"
check_file "${DOCS_DIR}/api/api-documentation.md" "API Documentation"
check_file "${DOCS_DIR}/data-models/data-model-analysis.md" "Data Model Analysis"
check_file "${DOCS_DIR}/business-logic/business-flows.md" "Business Flows"
check_file "${DOCS_DIR}/modernization/domain-analysis.md" "Domain Analysis"
check_file "${DOCS_DIR}/modernization/modernization-assessment.md" "Modernization Assessment"
check_file "${DOCS_DIR}/modernization/migration-roadmap.md" "Migration Roadmap"
check_file "${DOCS_DIR}/executive-summary.md" "Executive Summary"
check_file "${PROJECT_ROOT}/CLAUDE.md" "CLAUDE.md"

echo -e "\n${YELLOW}Validating Mermaid diagrams...${NC}"
echo -e "\n### Mermaid Diagrams" >> "$REPORT"
echo "" >> "$REPORT"

# Validate all Mermaid diagrams
for diagram in "${DOCS_DIR}"/diagrams/*.mmd; do
    if [ -f "$diagram" ]; then
        validate_mermaid "$diagram"
    fi
done

echo -e "\n${YELLOW}Checking cross-references...${NC}"
echo -e "\n### Cross-References" >> "$REPORT"
echo "" >> "$REPORT"

# Check references in all markdown files
for mdfile in $(find "${DOCS_DIR}" -name "*.md" -type f); do
    check_references "$mdfile"
done

# Check for orphaned diagrams
echo -e "\n${YELLOW}Checking for orphaned diagrams...${NC}"
echo -e "\n### Orphaned Resources" >> "$REPORT"
echo "" >> "$REPORT"

for diagram in "${DOCS_DIR}"/diagrams/*.mmd; do
    if [ -f "$diagram" ]; then
        diagram_name=$(basename "$diagram")
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        
        # Search for references to this diagram
        if grep -r "$diagram_name" "${DOCS_DIR}" --include="*.md" >/dev/null 2>&1; then
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            echo -e "${YELLOW}⚠ Orphaned diagram: $diagram_name${NC}"
            echo "- ⚠️ Orphaned diagram: $diagram_name (no references found)" >> "$REPORT"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
done

# Summary
echo -e "\n${GREEN}Validation Summary${NC}"
echo "=================="
echo -e "Total checks: $TOTAL_CHECKS"
echo -e "${GREEN}Passed: $PASSED_CHECKS${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
echo -e "${RED}Errors: $ERRORS${NC}"

# Add summary to report
cat >> "$REPORT" << EOF

## Final Summary

- **Total Checks:** $TOTAL_CHECKS
- **Passed:** $PASSED_CHECKS ✅
- **Warnings:** $WARNINGS ⚠️
- **Errors:** $ERRORS ❌

### Status: $([ $ERRORS -eq 0 ] && echo "✅ PASSED" || echo "❌ FAILED")

EOF

if [ $ERRORS -gt 0 ]; then
    echo -e "\n${RED}Documentation validation FAILED with $ERRORS errors${NC}"
    echo "See full report: ${REPORT}"
    exit 1
else
    echo -e "\n${GREEN}Documentation validation PASSED${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}Note: $WARNINGS warnings found - review recommended${NC}"
    fi
    echo "Full report: ${REPORT}"
fi