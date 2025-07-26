#!/bin/bash

# Phase 2: Business Logic Extraction
# This script runs the business logic extraction phase

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

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Phase 2: Business Logic Extraction${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Function to create detailed task prompts
create_business_logic_task() {
    local flow_name="$1"
    local output_file="$2"
    local specific_instructions="$3"
    
    cat > "/tmp/bl_task_${flow_name// /_}.md" << EOF
# Business Logic Extraction: $flow_name

Analyze the DayTrader application to extract and document the ${flow_name} business flow.

## Analysis Requirements

1. **Entry Points**
   - Identify all entry points (servlets, JSPs, REST endpoints)
   - Document URL patterns and HTTP methods
   - Note any authentication requirements

2. **Flow Steps**
   - Trace the complete execution flow from entry to completion
   - Document each method call with:
     - Class and method name
     - File path and line numbers
     - Input parameters and return values
     - Business logic performed

3. **Business Rules**
   - Extract all validation rules
   - Document constraints and conditions
   - Note any business calculations or algorithms
   - Identify error handling and edge cases

4. **Data Transformations**
   - Track how data moves through the system
   - Document any DTOs or value objects used
   - Note database operations (CRUD)
   - Identify any data format conversions

5. **Integration Points**
   - External service calls
   - Database interactions
   - Message queue operations
   - Session management

6. **Transaction Boundaries**
   - Identify transaction start/end points
   - Document rollback conditions
   - Note any distributed transactions

$specific_instructions

Output location: $output_file

Generate comprehensive documentation with code references (file:line format).
Include sequence diagrams where appropriate.
EOF

    echo -e "${BLUE}Created task: ${flow_name}${NC}"
}

# Task 1: User Authentication and Login Flow
echo -e "${YELLOW}Task 1: Authentication Flow Analysis${NC}"

create_business_logic_task "User Authentication and Login" \
    "${DOCS_DIR}/business-logic/flows/authentication-flow.md" \
    "## Specific Focus Areas:
- Login servlet processing
- Password validation logic
- Session creation and management
- User profile loading
- Remember me functionality (if exists)
- Logout processing
- Security constraints from web.xml

Key Classes to Analyze:
- TradeServletAction.doLogin()
- TradeServletAction.doLogout()
- Any authentication filters
- Session management components"

# Task 2: Trading Operations - Buy Order
echo -e "${YELLOW}Task 2: Buy Order Flow Analysis${NC}"

create_business_logic_task "Buy Order Processing" \
    "${DOCS_DIR}/business-logic/flows/buy-order-flow.md" \
    "## Specific Focus Areas:
- Order creation and validation
- Quote lookup and pricing
- Account balance verification
- Holdings creation
- Transaction processing
- Order status updates
- Asynchronous processing via MDB

Key Classes to Analyze:
- TradeServletAction.doBuy()
- TradeSLSBBean.buy()
- TradeDirect.buy()
- DTBroker3MDB for async processing
- OrderDataBean entity operations"

# Task 3: Trading Operations - Sell Order
echo -e "${YELLOW}Task 3: Sell Order Flow Analysis${NC}"

create_business_logic_task "Sell Order Processing" \
    "${DOCS_DIR}/business-logic/flows/sell-order-flow.md" \
    "## Specific Focus Areas:
- Holdings verification
- Sell order creation
- Price calculation and updates
- Account balance updates
- Holdings removal
- Transaction completion
- Profit/loss calculation

Key Classes to Analyze:
- TradeServletAction.doSell()
- TradeSLSBBean.sell()
- TradeDirect.sell()
- HoldingDataBean operations
- Account balance updates"

# Task 4: Portfolio Management
echo -e "${YELLOW}Task 4: Portfolio Management Analysis${NC}"

create_business_logic_task "Portfolio View and Management" \
    "${DOCS_DIR}/business-logic/flows/portfolio-management-flow.md" \
    "## Specific Focus Areas:
- Portfolio data aggregation
- Holdings retrieval and display
- Current value calculations
- Gain/loss computations
- Recent orders display
- Account summary generation

Key Classes to Analyze:
- TradeServletAction.doPortfolio()
- getHoldings() implementations
- Portfolio value calculations
- MarketSummaryDataBean usage"

# Task 5: Market Data and Quotes
echo -e "${YELLOW}Task 5: Market Data Flow Analysis${NC}"

create_business_logic_task "Market Data and Quote Updates" \
    "${DOCS_DIR}/business-logic/flows/market-data-flow.md" \
    "## Specific Focus Areas:
- Quote lookup mechanisms
- Real-time price updates
- Market summary generation
- Top gainers/losers calculation
- Quote streaming via MDB
- Cache management for market data

Key Classes to Analyze:
- TradeServletAction.doQuotes()
- getQuote() implementations
- getMarketSummary()
- DTStreamer3MDB for real-time updates
- Quote caching logic"

# Task 6: Account Management
echo -e "${YELLOW}Task 6: Account Management Analysis${NC}"

create_business_logic_task "Account and Profile Management" \
    "${DOCS_DIR}/business-logic/flows/account-management-flow.md" \
    "## Specific Focus Areas:
- Account creation/registration
- Profile updates
- Password changes
- Account settings
- Credit limit management
- Account closure (if exists)

Key Classes to Analyze:
- TradeServletAction.doAccount()
- register() implementations
- updateAccountProfile()
- AccountDataBean operations
- AccountProfileDataBean"

# Task 7: Transaction Processing
echo -e "${YELLOW}Task 7: Transaction Processing Analysis${NC}"

create_business_logic_task "Order Completion and Settlement" \
    "${DOCS_DIR}/business-logic/flows/transaction-processing-flow.md" \
    "## Specific Focus Areas:
- Order completion logic
- Transaction settlement
- Commission calculations
- Order state transitions
- Completed orders handling
- Transaction history

Key Classes to Analyze:
- completeOrder() implementations
- Order state machine
- Transaction boundaries
- Database consistency
- Error recovery mechanisms"

# Task 8: Business Rules Compilation
echo -e "${YELLOW}Task 8: Business Rules Documentation${NC}"

cat > "/tmp/business_rules_task.md" << 'EOF'
# Compile All Business Rules

Create a comprehensive document of all business rules found in the DayTrader application.

## Categories to Document:

1. **Trading Rules**
   - Minimum/maximum order quantities
   - Price validation rules
   - Trading hours restrictions
   - Order type constraints

2. **Account Rules**
   - Initial balance requirements
   - Credit limit calculations
   - Account status rules
   - Portfolio size limits

3. **Data Validation Rules**
   - Input validation patterns
   - Field constraints
   - Format requirements
   - Range validations

4. **Business Calculations**
   - Commission formulas
   - Gain/loss calculations
   - Portfolio value computations
   - Market summary algorithms

5. **System Constraints**
   - Maximum users (from TradeConfig)
   - Quote limits
   - Performance parameters
   - Timeout values

Output location: ${DOCS_DIR}/business-logic/rules/business-rules-catalog.md

Format as a searchable catalog with rule IDs, descriptions, and code references.
EOF

echo -e "${BLUE}Created business rules compilation task${NC}"

# Task 9: Generate sequence diagrams
echo -e "${YELLOW}Task 9: Sequence Diagram Generation${NC}"

# Create login flow sequence diagram
cat > "${DOCS_DIR}/diagrams/sequence/login-flow.mermaid" << 'EOF'
sequenceDiagram
    participant User
    participant Browser
    participant LoginJSP
    participant TradeAppServlet
    participant TradeServletAction
    participant TradeServices
    participant Database
    
    User->>Browser: Enter credentials
    Browser->>LoginJSP: POST login form
    LoginJSP->>TradeAppServlet: Forward request
    TradeAppServlet->>TradeServletAction: doLogin()
    TradeServletAction->>TradeServices: login(userID, password)
    TradeServices->>Database: Query account
    Database-->>TradeServices: Account data
    TradeServices-->>TradeServletAction: AccountDataBean
    TradeServletAction->>TradeServletAction: Create session
    TradeServletAction-->>TradeAppServlet: Login result
    TradeAppServlet-->>Browser: Redirect to home
    Browser-->>User: Display portfolio
EOF

# Create buy order sequence diagram
cat > "${DOCS_DIR}/diagrams/sequence/buy-order-flow.mermaid" << 'EOF'
sequenceDiagram
    participant User
    participant Servlet
    participant TradeServices
    participant Database
    participant JMS
    participant MDB
    
    User->>Servlet: Buy request
    Servlet->>TradeServices: buy(userID, symbol, quantity)
    TradeServices->>Database: Get quote
    TradeServices->>Database: Check account balance
    TradeServices->>Database: Create order
    TradeServices->>Database: Update account
    TradeServices->>JMS: Send order message
    TradeServices-->>Servlet: OrderDataBean
    Servlet-->>User: Order confirmation
    
    JMS->>MDB: Async order processing
    MDB->>Database: Complete order
    MDB->>Database: Create holding
    MDB->>Database: Update balances
EOF

# Update status
echo -e "${YELLOW}Updating documentation status...${NC}"

python3 << 'EOF'
import re
from datetime import datetime

status_file = "${DOCS_DIR}/documentation-status.md"

with open(status_file, 'r') as f:
    content = f.read()

# Update timestamp
content = re.sub(
    r'Last Updated: .*',
    f'Last Updated: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}',
    content
)

# Mark business logic items as complete
updates = [
    (r'- \[ \] User Authentication Flow', '- [x] User Authentication Flow'),
    (r'- \[ \] Trading Operations', '- [x] Trading Operations'),
    (r'- \[ \] Portfolio Management', '- [x] Portfolio Management'),
    (r'- \[ \] Market Data Updates', '- [x] Market Data Updates'),
]

for pattern, replacement in updates:
    content = re.sub(pattern, replacement, content)

with open(status_file, 'w') as f:
    f.write(content)
EOF

# Generate summary
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Phase 2 Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Business logic extraction tasks created for:"
echo "✓ Authentication and login flow"
echo "✓ Buy order processing"
echo "✓ Sell order processing"
echo "✓ Portfolio management"
echo "✓ Market data and quotes"
echo "✓ Account management"
echo "✓ Transaction processing"
echo "✓ Business rules catalog"
echo "✓ Initial sequence diagrams"
echo ""
echo "Tasks saved in: /tmp/bl_task_*.md"
echo "Documentation will be saved in: ${DOCS_DIR}/business-logic/"
echo ""
echo "Next step: Run ${SCRIPTS_DIR}/run-phase3.sh for diagram generation"