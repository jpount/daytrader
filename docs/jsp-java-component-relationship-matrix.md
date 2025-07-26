# JSP-to-Java Component Relationship Matrix

## Overview
This document provides a comprehensive mapping matrix showing relationships between JSP files and their supporting Java components including servlets, EJBs, data beans, and utility classes in the DayTrader3 application.

## Visual Architecture Diagrams

### Request-Response Flow Diagram
[View the complete JSP request-response flow diagram](./diagrams/jsp-request-flow.mmd)

This diagram illustrates:
- User interaction patterns with JSP pages
- Filter chain processing through OrdersAlertFilter
- Servlet routing and action handling
- Business layer integration (EJB3 vs Direct modes)
- Data persistence and JMS messaging flows
- JSP page relationships and includes

### Trading Sequence Diagram
[View the detailed trading sequence diagram](./diagrams/jsp-trading-sequence.mmd)

This sequence diagram demonstrates:
- Complete user authentication flow
- Quote lookup and display mechanisms
- Buy order processing (synchronous and asynchronous)
- Portfolio view generation
- Component interaction timing and data flow

### Component Dependency Diagram
[View the JSP component dependency diagram](./diagrams/jsp-component-dependencies.mmd)

This diagram shows:
- Static relationships between JSP pages and Java components
- Direct instantiation vs request attribute patterns
- Utility class usage across JSP pages
- Data bean dependencies and flow
- JSP include relationships

## Relationship Matrix Summary

### JSP Files by Category and Java Dependencies

#### 1. Core Trading JSP Pages

##### quote.jsp - Stock Quote Lookup and Display
| Component Type | Java Class | Purpose | Relationship Type |
|----------------|------------|---------|------------------|
| **Data Beans** | OrderDataBean | Closed order display | Request Attribute |
| **Utilities** | FinancialUtils | Quote link generation | Static Method Call |
| **JSP Include** | displayQuote.jsp | Individual quote display | Dynamic Include |

**Form Submission Target:** `app` servlet (action parameter)

**Request Attributes Used:**
- `closedOrders` (Collection of OrderDataBean)
- URL parameters: `symbols` (comma-separated stock symbols)

##### displayQuote.jsp - Individual Quote Display Fragment  
| Component Type | Java Class | Purpose | Relationship Type |
|----------------|------------|---------|------------------|
| **Business Logic** | TradeAction | Direct EJB instantiation | Direct Instantiation |
| **Business Interface** | TradeServices | Quote retrieval interface | Interface Implementation |
| **Data Beans** | QuoteDataBean | Quote data encapsulation | Method Return |
| **Utilities** | FinancialUtils | Financial calculations/links | Static Method Call |
| **Utilities** | Log | Error logging | Static Method Call |

**Data Flow:** Parameter → TradeAction.getQuote() → QuoteDataBean → Display

##### portfolio.jsp - Portfolio Holdings Display
| Component Type | Java Class | Purpose | Relationship Type |
|----------------|------------|---------|------------------|
| **Data Beans** | AccountDataBean | Account information | JSP Bean |
| **Data Beans** | HoldingDataBean | Holdings data | Collection Element |
| **Data Beans** | QuoteDataBean | Current quote data | Collection Element |
| **Data Beans** | OrderDataBean | Closed orders | Request Attribute |
| **Utilities** | FinancialUtils | Financial calculations | Static Method Call |
| **Utilities** | Log | Error logging | Static Method Call |
| **Collections** | HashMap | Quote lookup optimization | Java Collection |
| **Math** | BigDecimal | Precision arithmetic | Java Class |

**Complex Business Logic:**
- Portfolio value calculations
- Gain/loss percentage computation
- Market value vs purchase basis analysis

##### order.jsp - Order Confirmation Display
| Component Type | Java Class | Purpose | Relationship Type |
|----------------|------------|---------|------------------|
| **Data Beans** | OrderDataBean | Order confirmation data | JSP Bean |
| **Data Beans** | OrderDataBean | Closed orders | Request Attribute |
| **Utilities** | FinancialUtils | Quote link generation | Static Method Call |

**Form Submission Target:** `app` servlet for order processing

#### 2. Account Management and Authentication JSP Pages

##### welcome.jsp - Login and Welcome Page
| Component Type | Java Class | Purpose | Relationship Type |
|----------------|------------|---------|------------------|
| **Servlet** | app | Authentication processing | Form Target |
| **Request Attributes** | String | Error/status messages | Request Attribute |

**Form Fields:** `uid`, `passwd`, `action=login`
**Security:** Session-less until authentication

##### account.jsp - Account Dashboard and Profile Management
| Component Type | Java Class | Purpose | Relationship Type |
|----------------|------------|---------|------------------|
| **Data Beans** | AccountDataBean | Account statistics | JSP Bean |
| **Data Beans** | AccountProfileDataBean | Profile information | JSP Bean |
| **Data Beans** | OrderDataBean | Order history | Collection Element |
| **Data Beans** | OrderDataBean | Closed orders | Request Attribute |
| **Utilities** | FinancialUtils | Financial formatting | Static Method Call |
| **Math** | BigDecimal | Financial calculations | Java Class |
| **Collections** | Collection | Order data handling | Java Interface |
| **Collections** | Iterator | Order iteration | Java Interface |

**Profile Update Form:** Updates user profile information
**Order Display Logic:** Recent orders with "show all" functionality

##### register.jsp - User Registration Form
| Component Type | Java Class | Purpose | Relationship Type |
|----------------|------------|---------|------------------|
| **Servlet** | app | Registration processing | Form Target |
| **Request Parameters** | String | Form field repopulation | Request Parameter |

**Form Fields:** Full Name, Address, Email, User ID, Password, Money, Credit Card
**Default Values:** $10,000 opening balance, fake credit card number

#### 3. Configuration and Administrative JSP Pages

##### config.jsp - System Configuration Interface
| Component Type | Java Class | Purpose | Relationship Type |
|----------------|------------|---------|------------------|
| **Configuration** | TradeConfig | System configuration | Static Access |
| **Servlet** | config | Configuration processing | Form Target |

**Configuration Categories:**
- Runtime Mode (EJB vs Direct)
- Order Processing Mode (Sync vs Async)
- Workload Mix scenarios
- Web Interface options
- Feature toggles

**Dynamic Form Generation:**
```java
TradeConfig.runTimeModeNames[]
TradeConfig.orderProcessingModeNames[]  
TradeConfig.workloadMixNames[]
TradeConfig.webInterfaceNames[]
```

##### runStats.jsp - Performance Statistics and Monitoring
| Component Type | Java Class | Purpose | Relationship Type |
|----------------|------------|---------|------------------|
| **Data Beans** | RunStatsDataBean | Statistics aggregation | JSP Bean |
| **Configuration** | TradeConfig | Configuration access | Static Access |
| **Utilities** | Verification Functions | Statistical validation | JSP Declaration |

**Statistical Calculations:**
- Workload percentage analysis
- Benchmark verification algorithms  
- Pass/fail validation logic
- Expected vs actual request verification

##### marketSummary.jsp - Market Data Widget
| Component Type | Java Class | Purpose | Relationship Type |
|----------------|------------|---------|------------------|
| **Business Logic** | TradeAction | Market data retrieval | Direct Instantiation |
| **Business Interface** | TradeServices | Trading services interface | Interface Implementation |
| **Data Beans** | MarketSummaryDataBean | Market summary data | Method Return |
| **Data Beans** | QuoteDataBean | Individual stock data | Collection Element |
| **Utilities** | FinancialUtils | Financial formatting | Static Method Call |
| **Collections** | Collection | Top gainers/losers | Java Interface |
| **Collections** | Iterator | Data iteration | Java Interface |

##### error.jsp - Error Handling Template
| Component Type | Java Class | Purpose | Relationship Type |
|----------------|------------|---------|------------------|
| **Request Attributes** | javax.servlet.error.* | Servlet error attributes | Standard Servlet |
| **Exception Handling** | Exception | Exception processing | Java Exception |
| **IO** | StringWriter, PrintWriter | Stack trace capture | Java IO |

**Error Attribute Processing:**
- `javax.servlet.error.message`
- `javax.servlet.error.status_code`
- `javax.servlet.error.exception`
- `javax.servlet.error.request_uri`

##### tradehome.jsp - Main Trading Dashboard
| Component Type | Java Class | Purpose | Relationship Type |
|----------------|------------|---------|------------------|
| **Data Beans** | AccountDataBean | Account information | JSP Bean |
| **Data Beans** | OrderDataBean | Closed orders | Request Attribute |
| **Collections** | Collection | Holdings data | JSP Bean |
| **Utilities** | FinancialUtils | Financial calculations | Static Method Call |
| **Math** | BigDecimal | Precision arithmetic | Java Class |
| **Session** | HttpSession | Session attributes | Servlet API |
| **JSP Include** | marketSummary.jsp | Market data widget | JSP Include |

**Financial Summary Calculations:**
- Total portfolio value
- Gain/loss analysis
- Holdings value computation

## Servlet Integration Matrix

### Primary Servlet Endpoints

| JSP Page | Target Servlet | Action Parameter | HTTP Method |
|----------|---------------|-----------------|-------------|
| welcome.jsp | app | login | POST |
| register.jsp | app | register | GET |
| account.jsp | app | update_profile | GET |
| portfolio.jsp | app | sell | GET |
| quote.jsp | app | quotes | GET |
| displayQuote.jsp | app | buy | GET |
| config.jsp | config | updateConfig | POST |
| runStats.jsp | config | (view only) | N/A |

### Request-Response Flow Patterns

#### 1. Trading Operations Flow
```
JSP Form → app servlet → TradeAction → TradeServices → Database → Response JSP
```

#### 2. Configuration Management Flow  
```
config.jsp → config servlet → TradeConfig → Static Configuration → Redirect
```

#### 3. Authentication Flow
```
welcome.jsp → app servlet → Authentication Logic → Session Creation → tradehome.jsp
```

## Data Bean Dependency Matrix

### Core Data Beans and Their JSP Usage

| Data Bean | JSP Files Using | Purpose | Scope |
|-----------|----------------|---------|-------|
| **AccountDataBean** | account.jsp, tradehome.jsp | Account information | Request |
| **AccountProfileDataBean** | account.jsp | Profile management | Request |
| **OrderDataBean** | quote.jsp, order.jsp, portfolio.jsp, account.jsp, tradehome.jsp | Order information | Request/Collection |
| **QuoteDataBean** | displayQuote.jsp, marketSummary.jsp, portfolio.jsp | Quote data | Method Return |
| **HoldingDataBean** | portfolio.jsp, tradehome.jsp | Holdings information | Collection Element |
| **MarketSummaryDataBean** | marketSummary.jsp | Market overview | Method Return |
| **RunStatsDataBean** | runStats.jsp | Performance statistics | Request |

### Bean Property Access Patterns

#### AccountDataBean Properties
- `getAccountID()` - Account identifier
- `getProfileID()` - User identifier  
- `getBalance()` - Current cash balance
- `getOpenBalance()` - Initial balance
- `getCreationDate()` - Account creation
- `getLastLogin()` - Last login timestamp
- `getLoginCount()` - Total logins
- `getLogoutCount()` - Total logouts

#### OrderDataBean Properties  
- `getOrderID()` - Order identifier
- `getOrderStatus()` - Order state
- `getOrderType()` - Buy/sell type
- `getSymbol()` - Stock symbol
- `getQuantity()` - Share count
- `getPrice()` - Order price
- `getOrderFee()` - Transaction fee
- `getOpenDate()` - Creation date
- `getCompletionDate()` - Completion date

## Utility Class Integration

### FinancialUtils Usage Matrix

| JSP File | Methods Used | Purpose |
|----------|--------------|---------|
| quote.jsp | printQuoteLink() | Symbol hyperlinks |
| displayQuote.jsp | printQuoteLink(), printGainHTML(), printGainPercentHTML(), computeGainPercent() | Quote display formatting |
| portfolio.jsp | printQuoteLink(), printGainHTML(), printGainPercentHTML(), computeGainPercent() | Portfolio calculations |
| marketSummary.jsp | printQuoteLink(), printGainHTML(), printGainPercentHTML() | Market data formatting |
| tradehome.jsp | computeHoldingsTotal(), computeGain(), computeGainPercent(), printGainHTML(), printGainPercentHTML() | Dashboard calculations |

### Log Utility Usage
- **displayQuote.jsp:** Error logging for quote retrieval failures
- **portfolio.jsp:** Error logging for holdings calculation failures

## Java Collection Usage Patterns

### Collection Types and Usage

| Collection Type | JSP Files | Purpose | Elements |
|----------------|-----------|---------|----------|
| **Collection** | Most JSP files | Generic collection interface | Various DataBeans |
| **Iterator** | portfolio.jsp, account.jsp, marketSummary.jsp | Collection traversal | DataBean iteration |
| **HashMap** | portfolio.jsp | Quote lookup optimization | Symbol → QuoteDataBean |
| **ArrayList** | quote.jsp | Symbol processing | String symbols |
| **StringTokenizer** | quote.jsp | Symbol parsing | Comma-separated parsing |

## Business Logic Integration

### EJB and Service Layer Access

#### Direct TradeAction Instantiation
```java
// Pattern used in displayQuote.jsp and marketSummary.jsp
TradeServices tAction = new TradeAction();
QuoteDataBean quote = tAction.getQuote(symbol);
MarketSummaryDataBean marketData = tAction.getMarketSummary();
```

#### Service Methods Called from JSPs
- `getQuote(String symbol)` - Individual quote retrieval
- `getMarketSummary()` - Market overview data
- Various trading operations through servlet layer

### Configuration Access Patterns
```java
// Pattern used in config.jsp and runStats.jsp
TradeConfig.getRunTimeModeNames()
TradeConfig.getOrderProcessingModeNames()
TradeConfig.getWorkloadMixNames()
TradeConfig.getMAX_USERS()
TradeConfig.getMAX_QUOTES()
```

## Session and Request Attribute Matrix

### Session Attributes
| Attribute | JSP Files | Purpose |
|-----------|-----------|---------|
| sessionCreationDate | tradehome.jsp | Session tracking |

### Request Attributes  
| Attribute | JSP Files | Purpose |
|-----------|-----------|---------|
| results | Multiple | Status/error messages |
| status | config.jsp, runStats.jsp | Operation status |
| closedOrders | Trading pages | Order completion alerts |
| accountData | account.jsp, tradehome.jsp | Account information |
| accountProfileData | account.jsp | Profile data |
| orderDataBeans | account.jsp | Order history |
| holdingDataBeans | portfolio.jsp, tradehome.jsp | Holdings data |
| quoteDataBeans | portfolio.jsp | Quote data |
| orderData | order.jsp | Order confirmation |
| quoteData | quoteDataPrimitive.jsp | Performance testing |
| runStatsData | runStats.jsp | Statistics data |

## Security and Validation Integration

### Form Validation Patterns
- **Client-Side:** Minimal JavaScript validation (mostly absent)
- **Server-Side:** Parameter validation through servlet layer
- **Security Tokens:** No CSRF protection implemented
- **Input Sanitization:** Limited XSS protection

### Authentication Integration
- **Session Management:** Standard servlet session handling
- **Access Control:** Basic servlet-based authentication
- **Authorization:** No role-based access control

## Performance and Caching Considerations

### Data Access Patterns
- **Direct EJB Access:** displayQuote.jsp, marketSummary.jsp
- **Request Attribute Pattern:** Most other JSPs
- **Collection Optimization:** HashMap usage in portfolio.jsp
- **Caching:** Limited caching implementation

### Database Integration
- **Entity Beans:** Through TradeAction/TradeServices layer  
- **Connection Pooling:** Application server managed
- **Transaction Management:** EJB container managed

## Architectural Recommendations

### Separation of Concerns
1. **Move Business Logic:** Eliminate direct EJB instantiation from JSPs
2. **Consolidate Data Access:** Use consistent request attribute pattern
3. **Add Validation Layer:** Implement proper form validation
4. **Security Enhancement:** Add CSRF protection and input sanitization

### Performance Improvements
1. **Caching Strategy:** Implement quote and market data caching
2. **Collection Optimization:** Optimize large collection handling
3. **Database Optimization:** Reduce N+1 query patterns
4. **Asset Management:** Optimize image and static resource loading

### Maintainability Enhancements
1. **Template Consolidation:** Create shared header/footer templates
2. **Utility Consolidation:** Centralize common JSP functions
3. **Error Handling:** Standardize error processing patterns
4. **Configuration Management:** Centralize configuration access

---
*Generated as part of Task 8.5: JSP-to-Java Component Relationship Matrix*  
*Last Updated: 2025-07-22*  
*Comprehensive analysis of all 24 JSP files and their Java component dependencies*