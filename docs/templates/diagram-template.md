# Mermaid.js Diagram Template

## Diagram Types and Examples

### 1. System Architecture Diagram

```mermaid
graph TB
    subgraph "Presentation Layer"
        UI[Web UI]
        API[REST API]
    end
    
    subgraph "Business Layer"
        BL[Business Logic]
        SVC[Services]
    end
    
    subgraph "Data Layer"
        DB[(Database)]
        CACHE[Cache]
    end
    
    UI --> BL
    API --> SVC
    BL --> DB
    SVC --> DB
    BL --> CACHE
    
    style UI fill:#e1f5fe
    style API fill:#e1f5fe
    style BL fill:#fff3e0
    style SVC fill:#fff3e0
    style DB fill:#f3e5f5
    style CACHE fill:#f3e5f5
```

### 2. Component Diagram

```mermaid
graph LR
    subgraph "Component Name"
        A[Module A]
        B[Module B]
        C[Module C]
    end
    
    A --> B
    B --> C
    C --> A
```

### 3. Sequence Diagram

```mermaid
sequenceDiagram
    participant U as User
    participant UI as Web UI
    participant S as Service
    participant DB as Database
    
    U->>UI: Request Action
    UI->>S: Process Request
    S->>DB: Query Data
    DB-->>S: Return Data
    S-->>UI: Response
    UI-->>U: Display Result
```

### 4. Class Diagram

```mermaid
classDiagram
    class BaseClass {
        <<abstract>>
        +String name
        +void abstractMethod()
        #void protectedMethod()
    }
    
    class ConcreteClass {
        -int privateField
        +void publicMethod()
        -void privateMethod()
    }
    
    class Interface {
        <<interface>>
        +void interfaceMethod()
    }
    
    BaseClass <|-- ConcreteClass : extends
    Interface <|.. ConcreteClass : implements
```

### 5. Entity Relationship Diagram

```mermaid
erDiagram
    USER ||--o{ ORDER : places
    ORDER ||--|{ ORDER_ITEM : contains
    PRODUCT ||--o{ ORDER_ITEM : "ordered in"
    
    USER {
        int user_id PK
        string username
        string email
        datetime created_at
    }
    
    ORDER {
        int order_id PK
        int user_id FK
        datetime order_date
        decimal total_amount
    }
    
    ORDER_ITEM {
        int item_id PK
        int order_id FK
        int product_id FK
        int quantity
        decimal price
    }
    
    PRODUCT {
        int product_id PK
        string name
        decimal price
        int stock_quantity
    }
```

### 6. State Diagram

```mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> Processing : Start Process
    Processing --> Success : Complete
    Processing --> Error : Fail
    Success --> [*]
    Error --> Idle : Retry
    Error --> [*] : Give Up
```

### 7. Flowchart

```mermaid
flowchart TD
    Start([Start]) --> Input[/Input Data/]
    Input --> Validate{Valid?}
    Validate -->|Yes| Process[Process Data]
    Validate -->|No| Error[Show Error]
    Process --> Store[(Store Result)]
    Store --> Output[/Output Result/]
    Error --> Input
    Output --> End([End])
```

## Diagram Standards

### Color Scheme
- **Presentation Layer**: Light Blue (#e1f5fe)
- **Business Layer**: Light Orange (#fff3e0)
- **Data Layer**: Light Purple (#f3e5f5)
- **External Systems**: Light Green (#e8f5e9)
- **Error/Warning**: Light Red (#ffebee)

### Naming Conventions
- Use PascalCase for classes and components
- Use camelCase for methods and variables
- Use UPPERCASE for constants and enums
- Use lowercase_with_underscores for database entities

### Best Practices
1. Keep diagrams simple and focused on one aspect
2. Use consistent shapes and colors
3. Add clear labels and descriptions
4. Avoid overcrowding - split complex diagrams
5. Include a legend if using special symbols
6. Use subgraphs to group related components

### Mermaid Configuration
```mermaid
%%{init: {
  'theme': 'default',
  'themeVariables': {
    'primaryColor': '#fff',
    'primaryTextColor': '#000',
    'primaryBorderColor': '#7C4DFF',
    'lineColor': '#F44336',
    'background': '#fff',
    'mainBkg': '#e1f5fe',
    'secondBkg': '#fff3e0',
    'tertiaryColor': '#f3e5f5'
  }
}}%%
```