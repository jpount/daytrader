# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

DayTrader3 is a Java EE6 benchmark application that simulates an online stock trading system. It's built as a multi-module Maven/Gradle project using WebSphere Liberty as the application server.

## Architecture

The project uses a multi-module structure:
- **daytrader3-ee6-ejb**: Core business logic with EJB3 beans, JPA entities, and trading services
- **daytrader3-ee6-web**: Web tier with servlets, JSPs, and JSF components
- **daytrader3-ee6-rest**: REST API implementation
- **daytrader3-ee6**: Enterprise application packaging (EAR)
- **daytrader3-ee6-wlpcfg**: WebSphere Liberty server configuration and deployment

## Common Development Commands

### Building the Application

```bash
# Build with Maven (requires Java 7 compatibility)
mvn clean install -Dmaven.compiler.source=1.7 -Dmaven.compiler.target=1.7 -DskipTests

# Build with Gradle
gradle build
```

### Running the Application

```bash
# Using Docker Compose (recommended)
docker-compose up

# The application will be available at:
# - http://localhost:9083/daytrader (main web interface)
# - http://localhost:9083/daytrader/api/trade (REST API)
```

### Database Setup

After starting the server, initialize the database:
1. Create tables: http://localhost:9083/daytrader/config?action=buildDBTables
2. Populate data: http://localhost:9083/daytrader/config?action=buildDB

Default login: uid:0 / password: xxx

### Docker Build

```bash
# Build the Java 7 compatible Docker image
docker build -f Dockerfile.java7 -t daytrader-java7 .
```

## Key Components and Patterns

### Business Logic (daytrader3-ee6-ejb)
- **TradeServices**: Main service interface defining trading operations
- **TradeDirect**: Direct JDBC implementation of trading services
- **TradeSLSBBean**: Stateless session bean implementation
- **JPA Entities**: AccountDataBean, OrderDataBean, QuoteDataBean, HoldingDataBean
- **Message-Driven Beans**: DTBroker3MDB, DTStreamer3MDB for async processing

### Web Layer (daytrader3-ee6-web)
- **TradeAppServlet**: Main application servlet handling user interactions
- **TradeServletAction**: Controller logic for web operations
- **TradeBuildDB**: Database initialization servlet
- **Primitives**: Performance testing servlets (PingServlet*)

### Configuration
- JPA persistence configured via persistence.xml
- WebSphere Liberty server configuration in server.xml
- Derby database used by default (can be changed)

## Testing Approach

The application includes:
- Performance primitives for testing individual Java EE components
- JMeter test files in jmeter_files/ for load testing
- No unit tests in the codebase - testing is done via integration/load testing

## Important Notes

- The application targets Java EE6 specification
- Uses Java 7 compatibility for compilation
- Derby database files are stored in daytrader3-ee6-wlpcfg/shared/resources/data/tradedb/
- Transaction logs stored in daytrader3-ee6-wlpcfg/servers/daytrader3_Sample/tranlog/