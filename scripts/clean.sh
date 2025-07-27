#!/bin/bash

# Clean all generated documentation
# Preserves the app directory and system files

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DOCS_DIR="${PROJECT_ROOT}/docs"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${RED}Documentation Cleanup${NC}"
echo "===================="
echo ""
echo -e "${YELLOW}This will remove all generated documentation.${NC}"
echo "The following will be preserved:"
echo "  - app/ directory (your codebase)"
echo "  - scripts/ directory"
echo "  - config/ directory"
echo "  - requirements/ directory"
echo "  - viewers/ directory"
echo "  - System files:"
echo "    • .gitignore"
echo "    • .mcp.json"
echo "    • tasks.json"
echo "    • README.md"
echo ""

read -p "Continue? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo -e "${YELLOW}Cleaning documentation...${NC}"

# Remove all content in docs subdirectories but keep structure
find "${DOCS_DIR}" -type f -name "*.md" ! -name "README.md" -delete 2>/dev/null || true
find "${DOCS_DIR}" -type f -name "*.mmd" -delete 2>/dev/null || true
find "${DOCS_DIR}" -type f -name "*.json" -delete 2>/dev/null || true
find "${DOCS_DIR}" -type f -name "*.yaml" -delete 2>/dev/null || true
find "${DOCS_DIR}" -type f -name "*.txt" -delete 2>/dev/null || true

# Remove any database files if they exist
rm -rf "${PROJECT_ROOT}/.doc-db" 2>/dev/null || true
rm -f "${PROJECT_ROOT}/.env.documentation" 2>/dev/null || true

# Remove CLAUDE.md as it's codebase-specific
rm -f "${PROJECT_ROOT}/CLAUDE.md" 2>/dev/null || true

echo -e "${GREEN}✓ Documentation cleaned${NC}"
echo ""
echo "To analyze a new codebase:"
echo "1. Copy your codebase to: ${PROJECT_ROOT}/app"
echo "2. Run: ./scripts/init.sh"
echo "3. Use tasks.json with Claude Code"