#!/bin/bash

# Phase 3: Comprehensive Diagram Generation
# This script generates all architectural and flow diagrams

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
echo -e "${GREEN}Phase 3: Diagram Generation${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Create diagram directories if they don't exist
mkdir -p "${DOCS_DIR}/diagrams"/{architecture,sequence,class,data,deployment}

# Task 1: Component Architecture Diagram
echo -e "${YELLOW}Creating Component Architecture Diagram...${NC}"

cat > "${DOCS_DIR}/diagrams/architecture/component-architecture.mermaid" << 'EOF'
graph TB
    subgraph "Presentation Tier"
        subgraph "Web Module [daytrader3-ee6-web]"
            JSP[JSP Pages<br/>- login.jsp<br/>- portfolio.jsp<br/>- quote.jsp]
            SERVLETS[Servlets<br/>- TradeAppServlet<br/>- TradeConfigServlet<br/>- TradeBuildDB]
            FILTERS[Filters<br/>- OrdersAlertFilter]
            JSF[JSF Beans<br/>- AccountBean<br/>- QuoteBean]
        end
        
        subgraph "REST Module [daytrader3-ee6-rest]"
            REST[REST Services<br/>- AddressBook API]
        end
    end
    
    subgraph "Business Tier"
        subgraph "EJB Module [daytrader3-ee6-ejb]"
            SLSB[Session Beans<br/>- TradeSLSBBean<br/>- DirectSLSBBean]
            MDB[Message Beans<br/>- DTBroker3MDB<br/>- DTStreamer3MDB]
            DIRECT[Direct Access<br/>- TradeDirect<br/>- KeySequenceDirect]
        end
    end
    
    subgraph "Integration Tier"
        JMS[JMS Queues/Topics<br/>- TradeBrokerQueue<br/>- TradeStreamerTopic]
        JDBC[JDBC Connections]
    end
    
    subgraph "Data Tier"
        ENTITIES[JPA Entities<br/>- AccountDataBean<br/>- OrderDataBean<br/>- QuoteDataBean<br/>- HoldingDataBean]
        DB[(Derby Database<br/>Tables:<br/>- accountejb<br/>- orderejb<br/>- quoteejb<br/>- holdingejb)]
    end
    
    JSP --> SERVLETS
    SERVLETS --> SLSB
    SERVLETS --> DIRECT
    JSF --> SLSB
    REST --> SLSB
    
    SLSB --> ENTITIES
    SLSB --> JMS
    DIRECT --> JDBC
    
    JMS --> MDB
    MDB --> ENTITIES
    ENTITIES --> DB
    JDBC --> DB
EOF

# Task 2: Deployment Architecture
echo -e "${YELLOW}Creating Deployment Architecture Diagram...${NC}"

cat > "${DOCS_DIR}/diagrams/deployment/deployment-architecture.mermaid" << 'EOF'
graph TB
    subgraph "Client Tier"
        BROWSER[Web Browser]
        JMETER[JMeter Load Testing]
    end
    
    subgraph "Application Server [WebSphere Liberty]"
        subgraph "EAR [daytrader3-ee6.ear]"
            WAR1[daytrader3-ee6-web.war]
            WAR2[daytrader3-ee6-rest.war]
            JAR[daytrader3-ee6-ejb.jar]
        end
        
        subgraph "Server Resources"
            DS[DataSources<br/>- TradeDataSource<br/>- NoTxTradeDataSource]
            CF[JMS ConnectionFactory]
            QUEUES[JMS Destinations<br/>- Queues<br/>- Topics]
            POOL[Connection Pool<br/>Max: 70]
        end
    end
    
    subgraph "Database Server"
        DERBY[(Apache Derby<br/>Embedded Mode)]
    end
    
    BROWSER -->|HTTP/HTTPS :9083| WAR1
    JMETER -->|Load Testing| WAR1
    WAR1 --> JAR
    WAR2 --> JAR
    JAR --> DS
    JAR --> CF
    CF --> QUEUES
    DS --> POOL
    POOL --> DERBY
EOF

# Task 3: Data Model ER Diagram
echo -e "${YELLOW}Creating Entity Relationship Diagram...${NC}"

cat > "${DOCS_DIR}/diagrams/data/entity-relationship.mermaid" << 'EOF'
erDiagram
    ACCOUNTEJB ||--o{ ORDEREJB : places
    ACCOUNTEJB ||--o{ HOLDINGEJB : owns
    ACCOUNTEJB ||--|| ACCOUNTPROFILEEJB : has
    HOLDINGEJB }o--|| QUOTEEJB : references
    ORDEREJB }o--|| QUOTEEJB : references
    ORDEREJB ||--o| HOLDINGEJB : creates
    
    ACCOUNTEJB {
        string USERID PK
        timestamp CREATIONDATE
        decimal OPENBALANCE
        decimal BALANCE
        timestamp LASTLOGIN
        int LOGINCOUNT
        int LOGOUTCOUNT
        string PROFILE_USERID FK
    }
    
    ACCOUNTPROFILEEJB {
        string USERID PK
        string PASSWORD
        string FULLNAME
        string ADDRESS
        string EMAIL
        string CREDITCARD
    }
    
    ORDEREJB {
        int ORDERID PK
        string ORDERTYPE
        string ORDERSTATUS
        timestamp OPENDATE
        timestamp COMPLETIONDATE
        decimal QUANTITY
        decimal PRICE
        decimal ORDERFEE
        string ACCOUNT_USERID FK
        string QUOTE_SYMBOL FK
        int HOLDING_HOLDINGID FK
    }
    
    HOLDINGEJB {
        int HOLDINGID PK
        decimal QUANTITY
        decimal PURCHASEPRICE
        timestamp PURCHASEDATE
        string ACCOUNT_USERID FK
        string QUOTE_SYMBOL FK
    }
    
    QUOTEEJB {
        string SYMBOL PK
        string COMPANYNAME
        decimal PRICE
        decimal OPEN1
        decimal LOW
        decimal HIGH
        decimal CHANGE1
        decimal VOLUME
    }
    
    KEYGENEJB {
        string KEYNAME PK
        int KEYVAL
    }
EOF

# Task 4: Class Hierarchy Diagram
echo -e "${YELLOW}Creating Class Hierarchy Diagram...${NC}"

cat > "${DOCS_DIR}/diagrams/class/service-class-hierarchy.mermaid" << 'EOF'
classDiagram
    class TradeServices {
        <<interface>>
        +login(String, String) AccountDataBean
        +buy(String, String, double) OrderDataBean
        +sell(String, Integer) OrderDataBean
        +getQuote(String) QuoteDataBean
        +getHoldings(String) Collection
        +getClosedOrders(String) Collection
        +getMarketSummary() MarketSummaryDataBean
        +register(String, String, String, String, String, String, BigDecimal) AccountDataBean
    }
    
    class TradeSLSBBean {
        <<Stateless EJB>>
        -EntityManager em
        -SessionContext ctx
        -TradeDirect tradeDirect
        +All TradeServices methods
    }
    
    class TradeDirect {
        -DataSource datasource
        -DataSource datasourceNoTx
        +All TradeServices methods
        -getConnection() Connection
        -commit(Connection)
        -rollback(Connection)
    }
    
    class DirectSLSBBean {
        <<Stateless EJB>>
        -SessionContext ctx
        -TradeDirect tradeDirect
        +All TradeServices methods
    }
    
    class TradeAction {
        <<Factory>>
        -TradeServices tradeServices
        +createTrade() TradeServices
        +getTradeServices() TradeServices
    }
    
    TradeServices <|.. TradeSLSBBean : implements
    TradeServices <|.. TradeDirect : implements
    TradeServices <|.. DirectSLSBBean : implements
    TradeAction --> TradeServices : creates
    TradeSLSBBean --> TradeDirect : delegates to
    DirectSLSBBean --> TradeDirect : delegates to
EOF

# Task 5: Order Processing State Diagram
echo -e "${YELLOW}Creating Order State Diagram...${NC}"

cat > "${DOCS_DIR}/diagrams/sequence/order-state-machine.mermaid" << 'EOF'
stateDiagram-v2
    [*] --> Open: Order Created
    
    Open --> Processing: Process Order
    Processing --> Completed: Success
    Processing --> Cancelled: Cancel/Error
    
    Completed --> Closed: Close Order
    Cancelled --> Closed: Close Order
    
    Closed --> [*]
    
    state Open {
        [*] --> Pending
        Pending --> Queued: Send to JMS
    }
    
    state Processing {
        [*] --> Executing
        Executing --> Settling: Update Holdings
        Settling --> Confirming: Update Balances
    }
    
    note right of Open
        Order Status: "open"
        Order placed but not processed
    end note
    
    note right of Processing
        Order Status: "processing"
        Being handled by MDB
    end note
    
    note right of Completed
        Order Status: "completed"
        Successfully executed
    end note
    
    note right of Cancelled
        Order Status: "cancelled"
        Failed or cancelled
    end note
    
    note right of Closed
        Order Status: "closed"
        Finalized and archived
    end note
EOF

# Task 6: Portfolio View Sequence
echo -e "${YELLOW}Creating Portfolio View Sequence...${NC}"

cat > "${DOCS_DIR}/diagrams/sequence/portfolio-view.mermaid" << 'EOF'
sequenceDiagram
    participant User
    participant PortfolioJSP
    participant TradeAppServlet
    participant TradeServletAction
    participant TradeServices
    participant Cache
    participant Database
    
    User->>PortfolioJSP: View Portfolio
    PortfolioJSP->>TradeAppServlet: doPortfolio
    TradeAppServlet->>TradeServletAction: doPortfolio()
    
    par Fetch Account Data
        TradeServletAction->>TradeServices: getAccountData(userID)
        TradeServices->>Database: SELECT FROM accountejb
        Database-->>TradeServices: AccountDataBean
    and Fetch Holdings
        TradeServletAction->>TradeServices: getHoldings(userID)
        TradeServices->>Database: SELECT FROM holdingejb
        Database-->>TradeServices: Collection<HoldingDataBean>
    and Fetch Recent Orders
        TradeServletAction->>TradeServices: getClosedOrders(userID)
        TradeServices->>Database: SELECT FROM orderejb
        Database-->>TradeServices: Collection<OrderDataBean>
    and Fetch Market Summary
        TradeServletAction->>Cache: Check cache
        alt Cache Hit
            Cache-->>TradeServletAction: MarketSummaryDataBean
        else Cache Miss
            TradeServletAction->>TradeServices: getMarketSummary()
            TradeServices->>Database: Complex query
            Database-->>TradeServices: Market data
            TradeServices-->>TradeServletAction: MarketSummaryDataBean
            TradeServletAction->>Cache: Store in cache
        end
    end
    
    TradeServletAction->>TradeServletAction: Calculate totals
    TradeServletAction-->>TradeAppServlet: Portfolio data
    TradeAppServlet-->>PortfolioJSP: Forward
    PortfolioJSP-->>User: Display portfolio
EOF

# Task 7: Market Data Flow
echo -e "${YELLOW}Creating Market Data Flow Diagram...${NC}"

cat > "${DOCS_DIR}/diagrams/architecture/market-data-flow.mermaid" << 'EOF'
graph LR
    subgraph "Quote Updates"
        TRADE[Trade Execution] --> QUOTE_UPDATE[Update Quote Price]
        QUOTE_UPDATE --> CALC[Calculate Change %]
        CALC --> VOLUME[Update Volume]
    end
    
    subgraph "Market Summary"
        TIMER[20-second Timer] --> CACHE_CHECK{Cache Valid?}
        CACHE_CHECK -->|No| FETCH[Fetch Market Data]
        CACHE_CHECK -->|Yes| RETURN_CACHED[Return Cached Data]
        
        FETCH --> TOPGAINERS[Get Top Gainers]
        FETCH --> TOPLOSERS[Get Top Losers]
        FETCH --> SUMMARYDATA[Get Summary Stats]
        FETCH --> VOLUME_DATA[Get Volume Leaders]
        
        TOPGAINERS --> BUILD[Build MarketSummaryDataBean]
        TOPLOSERS --> BUILD
        SUMMARYDATA --> BUILD
        VOLUME_DATA --> BUILD
        
        BUILD --> UPDATE_CACHE[Update Cache]
        UPDATE_CACHE --> RETURN_NEW[Return New Data]
    end
    
    subgraph "Real-time Streaming"
        QUOTE_UPDATE --> JMS_TOPIC[TradeStreamerTopic]
        JMS_TOPIC --> DTSTREAMER[DTStreamer3MDB]
        DTSTREAMER --> SUBSCRIBERS[Quote Subscribers]
    end
EOF

# Task 8: Authentication Flow
echo -e "${YELLOW}Creating Authentication Flow Diagram...${NC}"

cat > "${DOCS_DIR}/diagrams/sequence/authentication-flow.mermaid" << 'EOF'
graph TB
    START([User Access]) --> CHECK_AUTH{Authenticated?}
    CHECK_AUTH -->|No| LOGIN_PAGE[Show Login Page]
    CHECK_AUTH -->|Yes| CHECK_PATH{Protected Resource?}
    
    LOGIN_PAGE --> SUBMIT[Submit Credentials]
    SUBMIT --> VALIDATE{Valid?}
    
    VALIDATE -->|No| ERROR[Show Error]
    ERROR --> LOGIN_PAGE
    
    VALIDATE -->|Yes| CREATE_SESSION[Create Session]
    CREATE_SESSION --> SET_USER[Set User in Session]
    SET_USER --> LOAD_PROFILE[Load Account Profile]
    LOAD_PROFILE --> UPDATE_LOGIN[Update Last Login]
    UPDATE_LOGIN --> REDIRECT[Redirect to Home]
    
    CHECK_PATH -->|Yes| CHECK_ROLE{Has Role?}
    CHECK_PATH -->|No| ALLOW[Allow Access]
    
    CHECK_ROLE -->|Yes| ALLOW
    CHECK_ROLE -->|No| DENY[Access Denied]
    
    REDIRECT --> PORTFOLIO[Show Portfolio]
    ALLOW --> RESOURCE[Access Resource]
    
    subgraph "Session Management"
        SESSION_TIMEOUT[Session Timeout]
        LOGOUT[User Logout]
        SESSION_INVALID[Invalidate Session]
        
        SESSION_TIMEOUT --> SESSION_INVALID
        LOGOUT --> SESSION_INVALID
        SESSION_INVALID --> LOGIN_PAGE
    end
EOF

# Task 9: Technology Migration Mapping
echo -e "${YELLOW}Creating Technology Migration Map...${NC}"

cat > "${DOCS_DIR}/diagrams/architecture/migration-mapping.mermaid" << 'EOF'
graph LR
    subgraph "Java EE 6 Stack"
        EJB[EJB 3.0]
        JPA1[JPA 2.0]
        JSF1[JSF 2.0]
        SERVLET[Servlet 3.0]
        JMS1[JMS 1.1]
        CDI1[CDI 1.0]
    end
    
    subgraph "Spring Boot Stack"
        SERVICE[Spring Service]
        JPA2[Spring Data JPA]
        REST[Spring REST]
        MVC[Spring MVC]
        JMS2[Spring JMS]
        DI[Spring DI]
    end
    
    subgraph "Angular Stack"
        COMPONENTS[Angular Components]
        SERVICES[Angular Services]
        ROUTING[Angular Router]
        HTTP[HttpClient]
        RXJS[RxJS]
        MATERIAL[Material UI]
    end
    
    EJB -->|@Service| SERVICE
    JPA1 -->|@Repository| JPA2
    JSF1 -->|Components| COMPONENTS
    SERVLET -->|@RestController| REST
    JMS1 -->|@JmsListener| JMS2
    CDI1 -->|@Autowired| DI
    
    JSF1 -->|Services| SERVICES
    SERVLET -->|Routes| ROUTING
    EJB -->|HTTP calls| HTTP
    JMS1 -->|Observables| RXJS
    JSF1 -->|UI| MATERIAL
EOF

# Task 10: Create diagram index
echo -e "${YELLOW}Creating Diagram Index...${NC}"

cat > "${DOCS_DIR}/diagrams/README.md" << 'EOF'
# DayTrader Diagrams Index

This directory contains all architectural and flow diagrams for the DayTrader application.

## Architecture Diagrams

### System Overview
- [Component Architecture](architecture/component-architecture.mermaid) - High-level component organization
- [System Overview](architecture/system-overview.mermaid) - Basic system architecture
- [Market Data Flow](architecture/market-data-flow.mermaid) - How market data flows through the system
- [Migration Mapping](architecture/migration-mapping.mermaid) - Java EE to Spring Boot/Angular mapping

### Deployment
- [Deployment Architecture](deployment/deployment-architecture.mermaid) - Server and deployment structure

## Sequence Diagrams

### User Flows
- [Login Flow](sequence/login-flow.mermaid) - User authentication sequence
- [Buy Order Flow](sequence/buy-order-flow.mermaid) - Order purchase sequence
- [Portfolio View](sequence/portfolio-view.mermaid) - Portfolio display sequence
- [Authentication Flow](sequence/authentication-flow.mermaid) - Detailed auth flow chart

### State Machines
- [Order State Machine](sequence/order-state-machine.mermaid) - Order lifecycle states

## Data Diagrams

### Entity Models
- [Entity Relationship](data/entity-relationship.mermaid) - Database ER diagram

## Class Diagrams

### Service Architecture
- [Service Class Hierarchy](class/service-class-hierarchy.mermaid) - TradeServices implementations

## Viewing Diagrams

These diagrams are in Mermaid format and can be viewed:

1. **In GitHub** - GitHub automatically renders Mermaid diagrams
2. **In VS Code** - Install the Mermaid preview extension
3. **Online** - Use [Mermaid Live Editor](https://mermaid.live/)
4. **Generate Images** - Use Mermaid CLI to generate PNG/SVG files

### Generating Images

```bash
# Install mermaid-cli
npm install -g @mermaid-js/mermaid-cli

# Generate PNG
mmdc -i architecture/component-architecture.mermaid -o component-architecture.png

# Generate SVG
mmdc -i architecture/component-architecture.mermaid -o component-architecture.svg
```
EOF

# Update documentation status
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

# Mark diagram items as complete
content = re.sub(r'- \[ \] Design Patterns', '- [x] Design Patterns', content)

with open(status_file, 'w') as f:
    f.write(content)
EOF

# Generate summary
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Phase 3 Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Diagrams generated:"
echo "✓ Component Architecture"
echo "✓ Deployment Architecture"
echo "✓ Entity Relationship Diagram"
echo "✓ Service Class Hierarchy"
echo "✓ Order State Machine"
echo "✓ Portfolio View Sequence"
echo "✓ Market Data Flow"
echo "✓ Authentication Flow"
echo "✓ Technology Migration Map"
echo "✓ Diagram Index"
echo ""
echo "All diagrams saved in: ${DOCS_DIR}/diagrams/"
echo ""
echo "Next step: Run ${SCRIPTS_DIR}/run-phase4.sh for migration planning"