# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

DayTrader3 is a Java EE6 benchmark application simulating an online stock trading system. It's a multi-module Maven/Gradle project designed to run on WebSphere Liberty Server.

## Key Commands

### Build Commands
```bash
# Build with Maven (requires Java 7 compatibility)
cd app
mvn clean install -Dmaven.compiler.source=1.7 -Dmaven.compiler.target=1.7

# Build with Gradle (alternative)
cd app
gradle clean build

# Build using Docker (recommended)
docker run --rm -v $(pwd):/workspace -w /workspace daytrader-java7 mvn clean install -Dmaven.compiler.source=1.7 -Dmaven.compiler.target=1.7 -DskipTests
```

### Running the Application
```bash
# Start with docker-compose
cd app
docker compose up

# The application will be available at:
# - Web UI: http://localhost:9083/daytrader
# - REST API: http://localhost:9083/daytrader/api/trade
# - Config: http://localhost:9083/daytrader/config
```

### Database Setup
```bash
# After starting the application, initialize the database:
# 1. Create tables: http://localhost:9083/daytrader/config?action=buildDBTables
# 2. Populate data: http://localhost:9083/daytrader/config?action=buildDB
```

### Testing
```bash
# Run unit tests
cd app
mvn test

# Skip tests during build
mvn clean install -DskipTests
```

## Architecture Overview

### Module Structure
- **daytrader3-ee6-ejb**: Business logic layer with EJBs, JPA entities, and message-driven beans
- **daytrader3-ee6-web**: Web presentation layer with servlets, JSPs, and web controllers
- **daytrader3-ee6-rest**: RESTful API endpoints
- **daytrader3-ee6**: EAR packaging module that bundles all components
- **daytrader3-ee6-wlpcfg**: WebSphere Liberty server configuration and Derby database setup

### Key Technologies
- **Runtime**: WebSphere Liberty Server (Java EE6)
- **Database**: Apache Derby (embedded)
- **Build**: Maven (primary) and Gradle
- **Container**: Docker with docker-compose
- **API**: JAX-RS REST services at `/daytrader/api/trade`
- **UI**: Servlets and JSPs at `/daytrader`

### Important Paths
- Server configuration: `app/daytrader3-ee6-wlpcfg/servers/daytrader3_Sample/server.xml`
- JPA configuration: `app/daytrader3-ee6-ejb/src/main/resources/META-INF/persistence.xml`
- Web deployment descriptor: `app/daytrader3-ee6-web/src/main/webapp/WEB-INF/web.xml`
- EJB configuration: `app/daytrader3-ee6-ejb/src/main/resources/META-INF/ejb-jar.xml`

### Core Business Logic
The trading services are implemented in the EJB module:
- **TradeServices**: Main interface for trading operations
- **TradeAction**: Implementation of trading logic
- **Entities**: Account, AccountProfile, Holding, Order, Quote in `com.ibm.websphere.samples.daytrader.entities`
- **Message Beans**: TradeBrokerMDB, TradeStreamerMDB for asynchronous processing

### Documentation Requirements
The project requires comprehensive documentation including:
1. Architecture diagrams (Mermaid) in `docs/diagrams/`
2. Technical class documentation in `docs/technical-documentation.md`
3. Security assessment in `docs/security-assessment.md`
4. Performance assessment in `docs/performance-assessment.md`

### Development Notes
- The application targets Java 7 but runs on Java 8 runtime
- Default login credentials: uid:0/xxx
- Derby database files are stored in the Liberty server directory
- JMeter test files are included for performance testing
- The application includes performance testing primitives accessible via the web UI

## Task Master AI Instructions
**Import Task Master's development workflow commands and guidelines, treat as if import is in the main CLAUDE.md file.**
@./.taskmaster/CLAUDE.md


## Key Requirements
Create a full set of detailed documentation and diagrams about the system