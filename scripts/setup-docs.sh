#!/bin/bash

# DayTrader Documentation Setup Script
# This script sets up the complete documentation structure for DayTrader migration

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCS_DIR="${PROJECT_ROOT}/docs"
SCRIPTS_DIR="${PROJECT_ROOT}/scripts"
DB_DIR="${PROJECT_ROOT}/.doc-db"
DB_NAME="daytrader_docs.db"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}DayTrader Documentation Setup${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Function to print status
print_status() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Step 1: Create directory structure
print_status "Setting up documentation directory structure..."

# Create main directories
mkdir -p "${DOCS_DIR}"/{architecture,business-logic,data-models,api-documentation,ui-components}
mkdir -p "${DOCS_DIR}/diagrams"/{architecture,sequence,class,data}
mkdir -p "${DB_DIR}"

# Create subdirectories
mkdir -p "${DOCS_DIR}/architecture"/{components,patterns,deployment}
mkdir -p "${DOCS_DIR}/business-logic"/{flows,rules,validations}
mkdir -p "${DOCS_DIR}/data-models"/{entities,relationships,migrations}
mkdir -p "${DOCS_DIR}/api-documentation"/{rest,servlets,messaging}
mkdir -p "${DOCS_DIR}/ui-components"/{jsp,jsf,static}

print_success "Directory structure created"

# Step 2: Create README files for each directory
print_status "Creating README files..."

cat > "${DOCS_DIR}/README.md" << 'EOF'
# DayTrader Documentation

This directory contains comprehensive documentation for the DayTrader3 application, organized to support migration to Spring Boot and Angular.

## Directory Structure

- **architecture/**: System architecture, design patterns, and technology stack
- **business-logic/**: Core business flows, rules, and validations
- **data-models/**: Entity relationships, database schema, and JPA mappings
- **api-documentation/**: REST endpoints, servlet mappings, and messaging interfaces
- **ui-components/**: JSP pages, JSF components, and frontend flows
- **diagrams/**: Visual representations in Mermaid format

## Documentation Status

See [documentation-status.md](./documentation-status.md) for current progress.
EOF

cat > "${DOCS_DIR}/architecture/README.md" << 'EOF'
# Architecture Documentation

This directory contains architectural documentation for DayTrader3.

## Contents

- `overview.md`: High-level system architecture
- `components/`: Detailed component analysis
- `patterns/`: Design patterns identification
- `deployment/`: Deployment architecture
EOF

print_success "README files created"

# Step 3: Initialize database
print_status "Setting up documentation database..."

# Check if sqlite3 is installed
if ! command -v sqlite3 &> /dev/null; then
    print_error "sqlite3 is not installed. Please install it first:"
    echo "  macOS: brew install sqlite"
    echo "  Ubuntu/Debian: sudo apt-get install sqlite3"
    echo "  RHEL/CentOS: sudo yum install sqlite"
    exit 1
fi

# Run database initialization script
if [ -f "${SCRIPTS_DIR}/init-database.sql" ]; then
    sqlite3 "${DB_DIR}/${DB_NAME}" < "${SCRIPTS_DIR}/init-database.sql"
    print_success "Database initialized"
else
    print_error "Database initialization script not found. Creating it..."
    # Create the init script if it doesn't exist
    "${SCRIPTS_DIR}/create-db-scripts.sh"
    sqlite3 "${DB_DIR}/${DB_NAME}" < "${SCRIPTS_DIR}/init-database.sql"
    print_success "Database created and initialized"
fi

# Step 4: Create documentation templates
print_status "Creating documentation templates..."

# Architecture overview template
cat > "${DOCS_DIR}/architecture/overview.md" << 'EOF'
# DayTrader3 Architecture Overview

## Executive Summary

[Brief description of the system]

## System Architecture

### High-Level Architecture
[Architecture diagram and description]

### Key Components
1. **Component Name**
   - Purpose:
   - Technology:
   - Location:

### Technology Stack
- Application Server:
- Framework:
- Database:
- Messaging:

## Architectural Patterns

[List and describe patterns used]

## Non-Functional Requirements

### Performance
[Performance characteristics]

### Scalability
[Scalability approach]

### Security
[Security implementation]
EOF

# Business flow template
cat > "${DOCS_DIR}/business-logic/trading-flow-template.md" << 'EOF'
# Trading Flow: [Flow Name]

## Overview
[Brief description of the business flow]

## Actors
- **Actor 1**: [Role and responsibilities]
- **Actor 2**: [Role and responsibilities]

## Pre-conditions
- [Condition 1]
- [Condition 2]

## Flow Steps

### Main Flow
1. [Step description]
   - Component: `ClassName.methodName()`
   - Location: `path/to/file.java:lineNumber`
   - Business Rule: [Any applicable rules]

2. [Next step]

### Alternative Flows
[Document any alternative paths]

### Exception Flows
[Document error handling]

## Post-conditions
- [Expected state after flow completion]

## Business Rules
- **BR001**: [Rule description]
- **BR002**: [Rule description]

## Data Transformations
[Describe any data transformations]

## Sequence Diagram
```mermaid
sequenceDiagram
    participant User
    participant Component1
    participant Component2
    
    User->>Component1: Action
    Component1->>Component2: Process
    Component2-->>User: Response
```
EOF

print_success "Templates created"

# Step 5: Create tracking file
print_status "Creating documentation tracking file..."

cat > "${DOCS_DIR}/documentation-status.md" << 'EOF'
# Documentation Status

Last Updated: $(date)

## Progress Overview

| Category | Total Items | Documented | Percentage |
|----------|-------------|------------|------------|
| Servlets | 0 | 0 | 0% |
| EJBs | 0 | 0 | 0% |
| Entities | 0 | 0 | 0% |
| JSP Pages | 0 | 0 | 0% |
| Business Flows | 0 | 0 | 0% |

## Detailed Status

### Architecture Documentation
- [ ] System Overview
- [ ] Component Inventory
- [ ] Design Patterns
- [ ] Technology Stack
- [ ] Deployment Architecture

### Business Logic
- [ ] User Authentication Flow
- [ ] Trading Operations
- [ ] Portfolio Management
- [ ] Market Data Updates
- [ ] Order Processing

### Data Models
- [ ] Entity Relationships
- [ ] Database Schema
- [ ] JPA Mappings
- [ ] Data Migration Strategy

### API Documentation
- [ ] REST Endpoints
- [ ] Servlet Mappings
- [ ] Message Queue Interfaces
- [ ] Integration Points

### UI Components
- [ ] JSP Page Inventory
- [ ] JSF Component Analysis
- [ ] Frontend Flow Mapping
- [ ] Static Resource Catalog
EOF

print_success "Documentation tracking file created"

# Step 6: Create .gitignore for documentation
print_status "Creating .gitignore for documentation..."

cat > "${DOCS_DIR}/.gitignore" << 'EOF'
# Temporary files
*.tmp
*.swp
*.bak

# Generated files
*.generated.md

# Database files
*.db-journal
*.db-wal

# IDE files
.idea/
.vscode/
EOF

print_success ".gitignore created"

# Step 7: Create environment file
print_status "Creating environment configuration..."

cat > "${PROJECT_ROOT}/.env.documentation" << EOF
# Documentation Environment Configuration
PROJECT_ROOT="${PROJECT_ROOT}"
DOCS_DIR="${DOCS_DIR}"
SCRIPTS_DIR="${SCRIPTS_DIR}"
DB_DIR="${DB_DIR}"
DB_NAME="${DB_NAME}"
APP_DIR="${PROJECT_ROOT}/app"

# Claude Configuration
CLAUDE_PROJECT_DIR="${PROJECT_ROOT}"
CLAUDE_DOCS_OUTPUT="${DOCS_DIR}"

# Documentation Phases
PHASE_1_DAYS=2
PHASE_2_DAYS=3
PHASE_3_DAYS=2
PHASE_4_DAYS=3
EOF

print_success "Environment configuration created"

# Final summary
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Documentation structure created at: ${DOCS_DIR}"
echo "Database created at: ${DB_DIR}/${DB_NAME}"
echo ""
echo "Next steps:"
echo "1. Run: source ${PROJECT_ROOT}/.env.documentation"
echo "2. Run: ${SCRIPTS_DIR}/run-phase1.sh to start component discovery"
echo "3. View progress: ${DOCS_DIR}/documentation-status.md"
echo ""
echo -e "${YELLOW}Tip: Add ${PROJECT_ROOT}/.env.documentation to your shell profile for persistence${NC}"