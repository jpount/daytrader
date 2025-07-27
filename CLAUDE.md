# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Project Overview

**Application Name:** DayTrader 3
**Business Domain:** Financial Services / Stock Trading
**Technology Stack:** Java EE 6, EJB 3.1, JPA 2.0, JSF 2.0, WebSphere Liberty
**Architecture Style:** Modular Monolith (single EAR with multiple modules)

### Purpose
DayTrader 3 is a benchmark application that simulates an online stock trading system. Originally developed by IBM for WebSphere Application Server demos, it serves as a comprehensive example of Java EE 6 capabilities. The application allows users to register, login, view stock quotes, buy/sell stocks, and manage their portfolios.

### Key Features
- User registration and authentication
- Real-time stock quote display
- Buy/sell order execution (synchronous and asynchronous modes)
- Portfolio management and account tracking
- Market summary and trending stocks
- Performance benchmarking capabilities

## Architecture

### High-Level Architecture
DayTrader 3 follows a traditional n-tier architecture deployed as a modular monolith. All components run within a single WebSphere Liberty instance, sharing a common Apache Derby database. The application uses both synchronous (direct EJB calls) and asynchronous (JMS) communication patterns.

### Module Structure
```
daytrader3/
├── daytrader3-ee6-ejb/      # Business logic and data access (EJB/JPA)
├── daytrader3-ee6-web/      # Web UI layer (Servlets/JSF/JSP)
├── daytrader3-ee6-rest/     # RESTful services
├── daytrader3-ee6/          # EAR packaging module
└── daytrader3-ee6-wlpcfg/   # Liberty server configuration
```

### Key Components
| Component | Type | Responsibility | Location |
|-----------|------|----------------|----------|
| TradeSLSBBean | Stateless EJB | Core trading operations | com.ibm.websphere.samples.daytrader.ejb3 |
| TradeDirect | JDBC DAO | Direct database access | com.ibm.websphere.samples.daytrader.direct |
| TradeAppServlet | Servlet | Main web interface | com.ibm.websphere.samples.daytrader.web |
| DTBroker3MDB | Message-Driven Bean | Async order processing | com.ibm.websphere.samples.daytrader.ejb3 |
| AccountDataBean | JPA Entity | User account data | com.ibm.websphere.samples.daytrader |

### Design Patterns Used
- **Service Locator:** TradeAction routes to appropriate service implementation
- **Data Access Object:** TradeDirect provides direct JDBC access
- **Session Facade:** TradeSLSBBean encapsulates business logic
- **Message-Driven:** Asynchronous order processing via JMS

## Common Development Commands

### Building the Application
```bash
# Primary build command
mvn clean install

# Build without tests
mvn clean install -DskipTests

# Build specific module
mvn clean install -pl daytrader3-ee6-ejb
```

### Running the Application
```bash
# Start Liberty server
cd daytrader3-ee6-wlpcfg/servers/daytrader3Sample
./server run

# Access application
# URL: http://localhost:9083/daytrader3/
# Admin URL: http://localhost:9083/daytrader3/config
```

### Database Operations
```bash
# Database is embedded Derby - auto-created on first run
# To reset database:
# 1. Stop server
# 2. Delete: daytrader3-ee6-wlpcfg/servers/daytrader3Sample/shared/data/tradedb
# 3. Restart server
# 4. Navigate to: http://localhost:9083/daytrader3/config
# 5. Click "(Re)-create DayTrader Database Tables and Indexes"
```

### Testing
```bash
# No automated tests exist in the codebase
# Manual testing via:
# 1. Performance primitives: http://localhost:9083/daytrader3/TestServlet
# 2. Scenario testing: http://localhost:9083/daytrader3/scenario
```

## Key Patterns and Conventions

### Code Organisation
- **Package Structure:** com.ibm.websphere.samples.daytrader
- **Subpackages:** direct/ (JDBC), ejb3/ (EJBs), util/, web/, web.jsf/, web.prims/
- **Entity Naming:** *DataBean suffix for JPA entities
- **Service Pattern:** TradeServices interface with multiple implementations

### Coding Standards
- **Language Version:** Java 7 (outdated, no lambdas or streams)
- **Style Guide:** IBM conventions (verbose, explicit)
- **Naming:** camelCase methods, PascalCase classes
- **Comments:** Minimal inline documentation

### Data Access Patterns
- **Dual Mode:** JPA 2.0 (primary) and direct JDBC (alternative)
- **Entity Manager:** Container-managed persistence context
- **Named Queries:** Pre-defined JPQL queries on entities
- **Transaction Management:** Container-managed (CMT)

### API Conventions
- **Servlet URLs:** /app (main), /config, /scenario
- **REST Endpoints:** Limited REST API in separate module
- **Request Parameters:** Form-based, not JSON
- **Session State:** Heavy reliance on HttpSession

### Security Patterns
- **Authentication:** Form-based with plain text passwords (CRITICAL ISSUE)
- **Authorization:** None implemented
- **Session Management:** Container-managed HttpSession
- **No CSRF/XSS Protection:** Major vulnerability

## Important Notes

### Critical Business Logic
- **Core Trading Logic:** TradeSLSBBean.buy() and sell() methods
- **Order Processing:** DTBroker3MDB for async order completion
- **Account Management:** Direct database updates, no proper domain model
- **Market Summary:** Cached for 15 minutes in MarketSummaryDataBean

### Performance Considerations
- **No Distributed Caching:** Only basic time-based market summary cache
- **N+1 Query Problem:** Portfolio loading fetches each holding separately
- **Large Classes:** TradeDirect.java has 2,311 lines
- **Connection Pool:** Min 10, max 70 connections to Derby

### Security Considerations
- **CRITICAL: Plain Text Passwords:** Stored unhashed in database
- **No HTTPS Enforcement:** Credentials sent in clear text
- **No Authorization:** Any authenticated user can access any data
- **SQL Injection Protected:** Uses PreparedStatements consistently

### Configuration
- **Server Config:** daytrader3-ee6-wlpcfg/servers/daytrader3Sample/server.xml
- **Data Source:** java:comp/env/jdbc/TradeDataSource
- **JMS Queue:** jms/TradeBrokerQueue
- **Port:** 9083 (HTTP), 9443 (HTTPS)

### Known Issues and Limitations
- **0% Test Coverage:** No unit or integration tests
- **15-20% Code Duplication:** Especially between JDBC and JPA paths
- **Hard-coded Values:** URLs, timeouts, and config scattered in code
- **Technology Debt:** Java EE 6 (EOL 2013), Java 7 (EOL 2015)

### Development Tips
- **Reset State:** Delete Derby database directory to start fresh
- **Debug Mode:** Enable in TradeConfig.setDebug(true)
- **Performance Testing:** Use primitive servlets in web.prims package
- **Dual Implementations:** Switch between JPA/JDBC in config page

## Modernisation Context

### Current State Assessment
- **Technology Currency:** Severely outdated (12+ years behind)
- **Maintenance Burden:** High - deprecated APIs, security vulnerabilities
- **Technical Debt Level:** High - no tests, large classes, duplication

### Recommended Migration Path
- **Target Stack:** Spring Boot 3.x, Java 17 LTS, PostgreSQL, React
- **Migration Strategy:** Strangler Fig pattern with domain extraction
- **Architecture:** Microservices with Kubernetes deployment
- **Timeline:** 14 months with 5-person team

### Priority Areas for Modernisation
1. **Immediate (Month 1):**
   - Fix plain text password storage (BCrypt)
   - Enable HTTPS-only access
   - Upgrade to Java 17

2. **Short-term (Months 2-6):**
   - Extract Market Data service (easiest domain)
   - Implement Spring Security
   - Add test coverage (target 60%)

3. **Long-term (Months 7-14):**
   - Full microservices extraction
   - Replace JSF with React SPA
   - Implement event-driven architecture

### Domain Boundaries Identified
1. **User Management:** Authentication, profiles (Easy extraction)
2. **Market Data:** Quotes, summaries (Easy extraction)
3. **Trading Operations:** Buy/sell orders (Hard - coupled to portfolio)
4. **Portfolio Management:** Holdings, balances (Hard - coupled to trading)
5. **Platform Services:** Config, testing (Remove in modernisation)

---

*Last update: 2025-07-27 - Comprehensive analysis completed for modernisation initiative*