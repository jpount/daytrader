#!/bin/bash

# Initialize documentation structure for any codebase
# This creates the necessary directories for documentation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DOCS_DIR="${PROJECT_ROOT}/docs"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Documentation System Initialization${NC}"
echo "===================================="
echo ""

# Create documentation structure
echo -e "${YELLOW}Creating documentation directories...${NC}"

mkdir -p "${DOCS_DIR}/analysis"
mkdir -p "${DOCS_DIR}/architecture"
mkdir -p "${DOCS_DIR}/business-logic"
mkdir -p "${DOCS_DIR}/data-models"
mkdir -p "${DOCS_DIR}/api"
mkdir -p "${DOCS_DIR}/diagrams"
mkdir -p "${DOCS_DIR}/modernisation"

echo -e "${GREEN}✓ Directory structure created${NC}"

# Create .gitignore for docs
cat > "${DOCS_DIR}/.gitignore" << 'EOF'
# Temporary files
*.tmp
*.swp
*~

# OS files
.DS_Store
Thumbs.db
EOF

# Create initial README
cat > "${DOCS_DIR}/README.md" << 'EOF'
# Documentation

This directory contains comprehensive documentation generated from the codebase analysis.

## Structure

- `analysis/` - Initial codebase analysis and inventory
- `architecture/` - System architecture documentation
- `business-logic/` - Business flows and rules
- `data-models/` - Data structures and relationships
- `api/` - API endpoints and interfaces
- `diagrams/` - Visual representations (Mermaid .mmd files)
- `modernisation/` - Migration and modernisation recommendations

## Generation

This documentation was generated using automated codebase analysis.
To regenerate, run the task automation system.
EOF

# Create CLAUDE.md from template if it doesn't exist
if [ ! -f "${PROJECT_ROOT}/CLAUDE.md" ]; then
    echo -e "${YELLOW}Creating CLAUDE.md from template...${NC}"
    
    # Check which template to use
    if [ -f "${PROJECT_ROOT}/config/CLAUDE-INSTRUCTIONS.md.template" ]; then
        # Use the instructions template for initial setup
        cp "${PROJECT_ROOT}/config/CLAUDE-INSTRUCTIONS.md.template" "${PROJECT_ROOT}/CLAUDE.md"
        echo -e "${GREEN}✓ CLAUDE.md created from CLAUDE-INSTRUCTIONS.md.template${NC}"
    elif [ -f "${PROJECT_ROOT}/config/CLAUDE.md.template" ]; then
        # Fallback to regular template
        cp "${PROJECT_ROOT}/config/CLAUDE.md.template" "${PROJECT_ROOT}/CLAUDE.md"
        echo -e "${GREEN}✓ CLAUDE.md created from CLAUDE.md.template${NC}"
    else
        # Create basic template if no template files exist
        echo -e "${YELLOW}No template found, creating basic CLAUDE.md...${NC}"
        cat > "${PROJECT_ROOT}/CLAUDE.md" << 'EOF'
# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Project Overview

- The application code is located in the `app/` directory
- Documentation is generated in the `docs/` directory
- Use tasks.json for systematic analysis

## Important Notes

Please analyze the codebase and create comprehensive documentation.
EOF
    fi
    echo -e "${GREEN}✓ CLAUDE.md created${NC}"
else
    echo -e "${GREEN}✓ CLAUDE.md already exists${NC}"
fi

echo ""
echo -e "${GREEN}✓ Documentation system initialized${NC}"
echo ""
echo "Ready to analyze codebase in: ${PROJECT_ROOT}/app"
echo "Documentation will be created in: ${DOCS_DIR}"
echo ""
echo "Next step: Use tasks.json with Claude Code to analyze the codebase"