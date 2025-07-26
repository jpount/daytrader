# DayTrader3 Architecture Diagrams

This directory contains all Mermaid.js diagrams for the DayTrader3 application architecture documentation.

## Diagram Index

### System Architecture
- **[system-overview.mmd](./system-overview.mmd)** - Complete system architecture overview showing all tiers, components, and relationships

### Database Schema
- **[database-schema.mmd](./database-schema.mmd)** - Entity relationship diagram showing all database tables and relationships

### Data Flow
- **[data-flow.mmd](./data-flow.mmd)** - Multi-tier data flow architecture showing information movement through the system

### Sequence Diagrams
- **[sequence-auth.mmd](./sequence-auth.mmd)** - User authentication flow including login, session management, and logout
- **[sequence-trading.mmd](./sequence-trading.mmd)** - Stock trading transactions for buy/sell orders with async processing
- **[sequence-portfolio.mmd](./sequence-portfolio.mmd)** - Portfolio and account management operations
- **[async-message-flow.mmd](./async-message-flow.mmd)** - Asynchronous message processing with JMS and MDBs
- **[jsp-trading-sequence.mmd](./jsp-trading-sequence.mmd)** - Complete JSP-to-Java interaction flow for trading operations

### JSP Component Architecture
- **[jsp-request-flow.mmd](./jsp-request-flow.mmd)** - Complete request-response flow from JSP through servlets to business logic
- **[jsp-component-dependencies.mmd](./jsp-component-dependencies.mmd)** - Static component relationships between JSPs and Java classes

## Viewing Diagrams

These diagrams are written in Mermaid.js format and can be viewed:

1. **In Documentation**: Embedded in the main [architecture.md](../architecture.md) file
2. **GitHub**: GitHub automatically renders .mmd files as diagrams
3. **Mermaid Live Editor**: Copy content to [mermaid.live](https://mermaid.live) for editing
4. **VS Code**: Use the Mermaid extension for preview and editing

## Diagram Standards

All diagrams follow these conventions:

### Color Scheme
- **External Systems**: Light Blue (#e1f5fe)
- **Presentation Layer**: Light Orange (#fff3e0)
- **Business Layer**: Light Purple (#f3e5f5)
- **Data Layer**: Light Green (#e8f5e9)
- **Infrastructure**: Light Pink (#fce4ec)

### Arrow Types
- `-->` Synchronous calls
- `-.->` Asynchronous messages or dependencies
- `==>` Data flow

### Naming
- Components use descriptive names with details in brackets
- Relationships are labeled with operation types
- Subgraphs group related components