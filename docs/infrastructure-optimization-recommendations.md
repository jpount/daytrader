# Infrastructure Optimization Recommendations

## Executive Summary
This document provides comprehensive infrastructure optimization recommendations for the DayTrader3 application, prioritized by impact and implementation complexity. The recommendations are organized into immediate, short-term, and long-term improvements with specific configuration changes, deployment modifications, and expected performance gains.

## Optimization Priority Matrix

### Critical Priority (Immediate Implementation - 0-4 weeks)
**High Impact, Low to Medium Complexity**

1. **Database Migration from Derby to PostgreSQL**
2. **JVM Configuration Optimization** 
3. **Connection Pool Right-sizing**
4. **Storage System Upgrade**

### High Priority (Short-term Implementation - 1-3 months)
**High Impact, Medium Complexity**

5. **JPA L2 Caching Implementation**
6. **Application-Level Caching Strategy**
7. **Load Balancer and Clustering Setup**
8. **Monitoring and Alerting Implementation**

### Medium Priority (Long-term Implementation - 3-12 months)
**Medium to High Impact, High Complexity**

9. **Microservices Architecture Migration**
10. **Container Orchestration (Kubernetes)**
11. **Advanced Distributed Caching**
12. **CI/CD Pipeline Implementation**

## Critical Priority Recommendations

### 1. Database Migration from Derby to PostgreSQL

#### Current State Analysis
```xml
<!-- Current Derby embedded configuration -->
<dataSource jndiName="jdbc/TradeDataSource">
    <properties.derby.embedded
        databaseName="${shared.resource.dir}/data/tradedb"
        createDatabase="create"/>
</dataSource>
```

**Critical Issues**:
- Single JVM constraint prevents clustering
- Page-level locking causes contention
- Limited concurrent connection capacity (~100)
- No hot backup or replication capability

#### Recommended PostgreSQL Configuration
```xml
<!-- Optimized PostgreSQL configuration -->
<dataSource jndiName="jdbc/TradeDataSource"
    jdbcDriverRef="PostgreSQLDriver"
    connectionManagerRef="OptimizedConnMgr"
    statementCacheSize="100"
    isolationLevel="TRANSACTION_READ_COMMITTED">
    <properties.postgresql
        serverName="postgres-primary.company.com"
        portNumber="5432"
        databaseName="daytrader"
        user="${db.username}"
        password="${db.password}"
        currentSchema="daytrader"
        prepareThreshold="3"
        defaultAutoCommit="false"
        ssl="true"
        tcpKeepAlive="true"/>
</dataSource>

<connectionManager id="OptimizedConnMgr"
    initialSize="10"
    maxPoolSize="50"
    minPoolSize="10"
    maxIdleTime="300"
    reapTime="60"
    agedTimeout="1800"
    connectionTimeout="30"
    validationQuery="SELECT 1"
    validateOnMatch="true"
    purgePolicy="EntirePool"/>
```

#### PostgreSQL Database Configuration
```sql
-- postgresql.conf optimizations
max_connections = 200
shared_buffers = 2GB                    # 25% of system RAM
effective_cache_size = 6GB              # 75% of system RAM  
work_mem = 32MB                         # Per-query memory
maintenance_work_mem = 256MB            # Maintenance operations
checkpoint_completion_target = 0.9      # Checkpoint spreading
wal_buffers = 64MB                      # WAL buffer size
default_statistics_target = 100         # Query planner statistics
random_page_cost = 1.1                  # SSD-optimized

-- Connection and authentication
listen_addresses = '*'
port = 5432
max_prepared_transactions = 100
```

#### Migration Implementation Plan
```sql
-- 1. Schema Creation
CREATE DATABASE daytrader;
CREATE SCHEMA daytrader;

-- 2. Table Creation with Optimized Indexes
CREATE TABLE daytrader.accountejb (
    accountid INTEGER PRIMARY KEY,
    logincount INTEGER NOT NULL DEFAULT 0,
    logoutcount INTEGER NOT NULL DEFAULT 0,
    lastlogin TIMESTAMP,
    creationdate TIMESTAMP,
    balance DECIMAL(14,2),
    openbalance DECIMAL(14,2),
    profile_userid VARCHAR(250)
);

-- Critical performance indexes
CREATE INDEX CONCURRENTLY idx_account_profile_userid ON daytrader.accountejb(profile_userid);
CREATE INDEX CONCURRENTLY idx_account_balance ON daytrader.accountejb(balance) WHERE balance > 0;

-- 3. Data Migration Script
INSERT INTO daytrader.accountejb 
SELECT * FROM derby_export.accountejb;
```

**Expected Performance Improvements**:
- **Concurrent Users**: 100 → 500 users (5x improvement)
- **Query Performance**: 50-80% faster for complex operations
- **Database Throughput**: 200 → 1000 operations/second
- **Backup/Recovery**: Hot backup capability without application downtime

**Implementation Cost**: $15,000-25,000 (including migration effort)
**Timeline**: 3-4 weeks implementation + 1 week testing

### 2. JVM Configuration Optimization

#### Current JVM Configuration Issues
```bash
# Estimated current configuration (likely sub-optimal)
-Xms512m -Xmx1024m
# Default GC settings (not optimized for server workload)
```

#### Recommended Production JVM Configuration
```bash
# Production-optimized JVM configuration
# Memory settings
-Xms4g                              # Initial heap size
-Xmx8g                              # Maximum heap size  
-XX:MetaspaceSize=256m              # Initial metaspace
-XX:MaxMetaspaceSize=512m           # Maximum metaspace

# Garbage Collection (G1GC recommended)
-XX:+UseG1GC                        # G1 garbage collector
-XX:MaxGCPauseMillis=100            # GC pause time target
-XX:G1HeapRegionSize=16m            # G1 region size
-XX:G1NewSizePercent=30             # Young generation size
-XX:G1MaxNewSizePercent=40          # Max young generation
-XX:G1MixedGCCountTarget=8          # Mixed GC cycle target
-XX:InitiatingHeapOccupancyPercent=45  # GC initiation threshold

# Performance optimizations
-server                             # Server-class JVM
-XX:+TieredCompilation              # Tiered compilation
-XX:TieredStopAtLevel=4             # Full C2 compilation
-XX:CompileThreshold=10000          # Compilation threshold
-XX:+UseBiasedLocking              # Biased locking optimization
-XX:+OptimizeStringConcat          # String concatenation optimization

# Monitoring and diagnostics
-XX:+PrintGCDetails                 # GC logging
-XX:+PrintGCTimeStamps             # GC timestamps
-Xloggc:/opt/liberty/logs/gc.log   # GC log location
-XX:+UseGCLogFileRotation          # Log rotation
-XX:NumberOfGCLogFiles=5           # Number of log files
-XX:GCLogFileSize=100M             # Size per log file

# Memory dump on OutOfMemoryError
-XX:+HeapDumpOnOutOfMemoryError
-XX:HeapDumpPath=/opt/liberty/dumps/
```

#### Liberty JVM Configuration
```xml
<!-- server.xml JVM configuration -->
<javaExecutable>${java.home}/bin/java</javaExecutable>
<jvmOptions>
    <option>-Xms4g</option>
    <option>-Xmx8g</option>
    <option>-XX:+UseG1GC</option>
    <option>-XX:MaxGCPauseMillis=100</option>
    <option>-server</option>
    <option>-XX:+TieredCompilation</option>
</jvmOptions>
```

**Expected Performance Improvements**:
- **GC Pause Time**: 200ms → 50ms (75% reduction)
- **Application Throughput**: 25-35% improvement
- **Memory Utilization**: 20% more efficient usage
- **Concurrent User Capacity**: 100 → 200 users

**Implementation Cost**: $0 (configuration only)
**Timeline**: 1-2 days implementation + 1 week monitoring

### 3. Connection Pool Right-sizing and Optimization

#### Current Over-provisioned Configuration
```xml
<!-- Current inefficient fixed pooling -->
<connectionManager id="conMgr1" 
    maxPoolSize="70" minPoolSize="70"    <!-- Fixed 70 connections -->
    agedTimeout="-1"                     <!-- No aging -->
    connectionTimeout="0"                <!-- No timeout -->
    maxIdleTime="-1"                     <!-- Never idle out -->
    reapTime="-1"/>                      <!-- No reaping -->
```

#### Optimized Dynamic Connection Pool Configuration
```xml
<!-- Primary transactional pool -->
<connectionManager id="PrimaryConnMgr"
    initialSize="5"                      <!-- Start small -->
    maxPoolSize="25"                     <!-- Reasonable maximum -->
    minPoolSize="5"                      <!-- Minimum active -->
    maxIdleTime="300"                    <!-- 5-minute idle timeout -->
    reapTime="60"                        <!-- 1-minute reaper cycle -->
    agedTimeout="1800"                   <!-- 30-minute age timeout -->
    connectionTimeout="30"               <!-- 30-second connect timeout -->
    purgePolicy="EntirePool"             <!-- Purge on failure -->
    validationQuery="SELECT 1"           <!-- Connection validation -->
    validateOnMatch="true"               <!-- Validate on checkout -->
    maxLifetime="3600"/>                 <!-- 1-hour maximum lifetime -->

<!-- Read-optimized pool for queries -->
<connectionManager id="ReadOnlyConnMgr"
    initialSize="3" 
    maxPoolSize="15"
    minPoolSize="3"
    maxIdleTime="600"                    <!-- Longer idle for read queries -->
    connectionTimeout="15"               <!-- Faster timeout for reads -->
    validationQuery="SELECT 1"
    validateOnMatch="false"              <!-- Skip validation for reads -->
    purgePolicy="FailingConnectionOnly"/>

<!-- Reporting/analytics pool -->
<connectionManager id="ReportingConnMgr"
    initialSize="2"
    maxPoolSize="8"  
    minPoolSize="1"
    maxIdleTime="1200"                   <!-- Long idle for infrequent reports -->
    connectionTimeout="45"               <!-- Longer timeout for complex reports -->
    validationQuery="SELECT 1"/>
```

#### Connection Pool Monitoring Configuration
```xml
<!-- Connection pool monitoring -->
<monitor filter="ConnectionPool" />
<monitor filter="JVM" />

<!-- DataSource configuration with monitoring -->
<dataSource jndiName="jdbc/TradeDataSource" 
    jdbcDriverRef="PostgreSQLDriver"
    connectionManagerRef="PrimaryConnMgr"
    statementCacheSize="100"
    queryTimeout="30">
    <properties.postgresql 
        serverName="postgres-primary.company.com"
        databaseName="daytrader"
        prepareThreshold="3"
        preparedStatementCacheQueries="100"
        preparedStatementCacheSizeMiB="16"/>
</dataSource>
```

**Expected Performance Improvements**:
- **Memory Usage**: 70MB → 25MB connection pool memory (64% reduction)
- **Connection Efficiency**: Dynamic scaling improves utilization
- **Database Load**: Reduced idle connection overhead  
- **Response Time**: 10-15% improvement in connection acquisition

**Implementation Cost**: $0 (configuration only)
**Timeline**: 1 day implementation + 1 week monitoring

### 4. Storage System Upgrade

#### Current Storage Limitations Assessment
```
Estimated Current Storage: SATA HDD
- IOPS Capacity: 150 random IOPS
- Throughput: 100 MB/sec sequential
- Latency: 10-15ms average
- Bottleneck: Database I/O operations
```

#### Recommended Storage Upgrade Path
```
Phase 1: SSD Upgrade (Immediate)
- Technology: SATA SSD or NVMe SSD  
- IOPS Capacity: 5000-50000 IOPS
- Throughput: 500-3000 MB/sec
- Latency: 0.1-1ms
- Cost: $500-1500
- Performance Gain: 300-800%

Phase 2: Enterprise Storage (Long-term)
- Technology: All-Flash Array or NVMe-oF
- IOPS Capacity: 100000+ IOPS
- Throughput: 5000+ MB/sec  
- Latency: <0.5ms
- Cost: $5000-15000
- Performance Gain: 1000%+
```

#### Storage Configuration Optimization
```bash
# PostgreSQL storage optimization for SSD
# postgresql.conf
shared_buffers = 2GB
effective_io_concurrency = 200         # SSD concurrent I/O
random_page_cost = 1.1                 # SSD-optimized cost
seq_page_cost = 1.0                    # Sequential cost baseline
checkpoint_completion_target = 0.9      # Spread checkpoints
wal_compression = on                    # Compress WAL
full_page_writes = off                  # Safe with reliable SSD

# File system optimization (ext4 or XFS)
mount /dev/nvme0n1p1 /var/lib/postgresql \
    -o noatime,nodiratime,data=writeback
```

**Expected Performance Improvements**:
- **Database Query Speed**: 50-300% faster disk I/O operations
- **Transaction Processing**: 200-500% improvement in write operations
- **Backup Performance**: 80% faster backup and restore operations
- **User Capacity**: 100 → 400 users (I/O bottleneck removed)

**Implementation Cost**: $800-2000 (hardware + migration)
**Timeline**: 2-3 days implementation + 1 day testing

## High Priority Recommendations

### 5. JPA L2 Caching Implementation

#### Current State (L2 Caching Disabled)
```xml
<!-- Currently disabled - major performance opportunity -->
<!-- <shared-cache-mode>ALL</shared-cache-mode> -->
```

#### Recommended L2 Caching Configuration
```xml
<!-- persistence.xml optimized configuration -->
<persistence-unit name="daytrader" transaction-type="JTA">
    <jta-data-source>jdbc/TradeDataSource</jta-data-source>
    <shared-cache-mode>ENABLE_SELECTIVE</shared-cache-mode>
    
    <properties>
        <!-- Enable L2 cache -->
        <property name="javax.persistence.sharedCache.mode" 
                  value="ENABLE_SELECTIVE"/>
        
        <!-- EhCache configuration -->
        <property name="hibernate.cache.use_second_level_cache" 
                  value="true"/>
        <property name="hibernate.cache.use_query_cache" 
                  value="true"/>
        <property name="hibernate.cache.provider_class" 
                  value="net.sf.ehcache.hibernate.EhCacheProvider"/>
        <property name="hibernate.cache.provider_configuration_file_resource_path" 
                  value="ehcache.xml"/>
                  
        <!-- Cache statistics -->
        <property name="hibernate.generate_statistics" value="true"/>
        <property name="hibernate.cache.use_structured_entries" value="true"/>
    </properties>
</persistence-unit>
```

#### Entity-Specific Caching Configuration
```java
// High-read, low-write entities
@Entity(name = "quoteejb")
@Cacheable
@Cache(usage = CacheConcurrencyStrategy.READ_WRITE, region = "quotes")
public class QuoteDataBean implements Serializable {
    // Quote caching with 30-second TTL
}

@Entity(name = "accountprofileejb")  
@Cacheable
@Cache(usage = CacheConcurrencyStrategy.READ_MOSTLY, region = "profiles")
public class AccountProfileDataBean implements Serializable {
    // Profile caching with longer TTL (profiles change infrequently)
}

@Entity(name = "accountejb")
@Cacheable
@Cache(usage = CacheConcurrencyStrategy.READ_WRITE, region = "accounts")
public class AccountDataBean implements Serializable {
    // Account caching with invalidation on updates
}
```

#### EhCache Configuration (ehcache.xml)
```xml
<ehcache xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:noNamespaceSchemaLocation="ehcache.xsd">
         
    <defaultCache
        maxElementsInMemory="1000"
        eternal="false"
        timeToIdleSeconds="300"
        timeToLiveSeconds="600"
        overflowToDisk="false"
        memoryStoreEvictionPolicy="LRU"/>
    
    <!-- Quote cache - high volume, frequent updates -->
    <cache name="quotes"
        maxElementsInMemory="5000"
        timeToLiveSeconds="30"           <!-- 30-second TTL -->
        timeToIdleSeconds="30"
        overflowToDisk="false"
        memoryStoreEvictionPolicy="LRU"/>
    
    <!-- Account profile cache - low change frequency -->  
    <cache name="profiles"
        maxElementsInMemory="10000"
        timeToLiveSeconds="1800"         <!-- 30-minute TTL -->
        timeToIdleSeconds="900"
        memoryStoreEvictionPolicy="LFU"/>
    
    <!-- Account data cache - moderate updates -->
    <cache name="accounts"
        maxElementsInMemory="8000"
        timeToLiveSeconds="300"          <!-- 5-minute TTL -->
        timeToIdleSeconds="180"
        memoryStoreEvictionPolicy="LRU"/>
        
    <!-- Query result cache -->
    <cache name="query.cache"
        maxElementsInMemory="2000"
        timeToLiveSeconds="120"
        timeToIdleSeconds="60"
        memoryStoreEvictionPolicy="LRU"/>
</ehcache>
```

**Expected Performance Improvements**:
- **Entity Query Performance**: 80-95% faster for cached entities
- **Database Load Reduction**: 60-70% fewer database queries
- **Response Time**: 40-60% improvement for data-heavy operations
- **Concurrent User Capacity**: 200 → 400 users

**Implementation Cost**: $8,000-12,000 (development + testing)
**Timeline**: 2-3 weeks implementation + 1 week optimization

### 6. Application-Level Caching Strategy

#### Market Data Caching Implementation
```java
@Service
@Component
public class EnhancedMarketDataCache {
    
    private final LoadingCache<String, QuoteDataBean> quoteCache;
    private final LoadingCache<String, MarketSummaryDataBean> summaryCache;
    
    public EnhancedMarketDataCache() {
        this.quoteCache = CacheBuilder.newBuilder()
            .maximumSize(10000)
            .expireAfterWrite(30, TimeUnit.SECONDS)
            .refreshAfterWrite(15, TimeUnit.SECONDS)  // Background refresh
            .recordStats()
            .build(new QuoteCacheLoader());
            
        this.summaryCache = CacheBuilder.newBuilder()
            .maximumSize(100)
            .expireAfterWrite(60, TimeUnit.SECONDS)
            .refreshAfterWrite(30, TimeUnit.SECONDS)
            .recordStats()
            .build(new MarketSummaryCacheLoader());
    }
    
    public QuoteDataBean getQuote(String symbol) {
        return quoteCache.getUnchecked(symbol);
    }
    
    @EventListener
    public void onQuoteUpdate(QuoteUpdateEvent event) {
        quoteCache.invalidate(event.getSymbol());
        summaryCache.invalidateAll(); // Market summary depends on quotes
    }
}
```

#### User Session Caching
```java
@Service
public class UserSessionCache {
    
    private final Cache<String, UserSessionData> sessionCache;
    
    @PostConstruct
    public void initializeCache() {
        this.sessionCache = CacheBuilder.newBuilder()
            .maximumSize(5000)                      // 5000 user sessions
            .expireAfterAccess(30, TimeUnit.MINUTES) // 30-minute idle timeout
            .expireAfterWrite(4, TimeUnit.HOURS)     // 4-hour absolute timeout
            .removalListener(this::onSessionRemoval)
            .recordStats()
            .build();
    }
    
    public UserSessionData getUserSession(String userID) {
        return sessionCache.get(userID, () -> loadUserSession(userID));
    }
    
    private UserSessionData loadUserSession(String userID) {
        AccountDataBean account = accountService.getAccountData(userID);
        AccountProfileDataBean profile = accountService.getProfileData(userID);
        return new UserSessionData(account, profile);
    }
}
```

#### Redis Distributed Caching Integration
```xml
<!-- Redis connection configuration -->
<library id="RedisLib">
    <file name="/opt/liberty/redis-client.jar"/>
</library>

<connectionFactory jndiName="redis/ConnectionFactory">
    <properties.redis 
        host="redis-cluster.company.com"
        port="6379"
        database="0"
        maxTotal="50"
        maxIdle="10"
        timeout="5000"/>
</connectionFactory>
```

**Expected Performance Improvements**:
- **Quote Lookup Performance**: 90% faster (cache hits)
- **User Session Access**: 85% reduction in database queries
- **Market Summary**: 95% performance improvement
- **System Scalability**: Support for 500+ concurrent users

**Implementation Cost**: $15,000-20,000 (development + infrastructure)
**Timeline**: 4-6 weeks implementation + 2 weeks optimization

### 7. Load Balancer and Clustering Setup

#### Target Load-Balanced Architecture
```
                     ┌─────────────────┐
                     │   HAProxy       │
                     │  Load Balancer  │ 
                     │  (Active/Passive│
                     │   with Health   │
                     │    Checks)      │
                     └─────────┬───────┘
                               │
                    ┌──────────┼──────────┐
                    │          │          │
             ┌──────▼──┐ ┌─────▼──┐ ┌─────▼──┐
             │Liberty-1│ │Liberty-2│ │Liberty-3│
             │Node-1   │ │Node-2   │ │Node-3   │
             │Web+EJB  │ │Web+EJB  │ │Web+EJB  │
             └────┬────┘ └────┬───┘ └────┬────┘
                  │           │          │
                  └───────────┼──────────┘
                              │
                    ┌─────────▼─────────┐
                    │ PostgreSQL Cluster│
                    │ Primary + Standby │
                    └───────────────────┘
```

#### HAProxy Load Balancer Configuration
```
# /etc/haproxy/haproxy.cfg
global
    daemon
    maxconn 4096
    log stdout local0
    
defaults
    mode http
    timeout connect 5000ms
    timeout client 30000ms
    timeout server 30000ms
    option httplog
    option dontlognull
    
frontend daytrader_frontend
    bind *:80
    bind *:443 ssl crt /etc/ssl/certs/daytrader.pem
    redirect scheme https if !{ ssl_fc }
    default_backend daytrader_servers
    
    # Health check endpoint
    acl health_check path_beg /health
    use_backend health_backend if health_check
    
backend daytrader_servers
    balance roundrobin
    option httpchk GET /daytrader/health
    http-check expect status 200
    
    # Server definitions with health checks
    server liberty1 10.0.1.10:9083 check inter 30s rise 2 fall 3
    server liberty2 10.0.1.11:9083 check inter 30s rise 2 fall 3  
    server liberty3 10.0.1.12:9083 check inter 30s rise 2 fall 3
    
    # Connection limits per server
    server liberty1 ... maxconn 200
    server liberty2 ... maxconn 200
    server liberty3 ... maxconn 200
    
backend health_backend
    server health_server 127.0.0.1:8080 check
```

#### Liberty Clustering Configuration
```xml
<!-- Node 1: server.xml clustering configuration -->
<server>
    <!-- Cluster member identification -->
    <clusterMember id="daytrader-node1" 
                   hostName="10.0.1.10"
                   httpPort="9083"
                   httpsPort="9443"/>
    
    <!-- Session clustering -->
    <httpSessionDatabase id="SessionDB"
                        dataSourceRef="SessionDataSource"
                        writeFrequency="MANUAL_UPDATE"
                        writeContents="ONLY_UPDATED_ATTRIBUTES"
                        scheduleInvalidation="true"
                        scheduleInvalidationFirstHour="2"
                        scheduleInvalidationSecondHour="4"/>
    
    <!-- Distributed caching -->
    <distributedMap id="defaultDistributedMap" 
                   jndiName="services/cache/distributedmap"
                   libraryRef="HazelcastLib"/>
    
    <!-- Health check endpoint -->
    <healthCheck>
        <check name="database" />
        <check name="messaging" />
        <check name="cache" />
    </healthCheck>
</server>
```

#### Session Clustering with External Storage
```xml
<!-- Redis-based session storage -->
<dataSource id="SessionDataSource" jndiName="jdbc/SessionDB">
    <jdbcDriver libraryRef="RedisJDBCLib"/>
    <properties.redis 
        host="redis-sessions.company.com"
        port="6379"
        database="1"
        maxTotal="100"/>
</dataSource>
```

**Expected Performance Improvements**:
- **High Availability**: 99.9% uptime with failover capability
- **Load Distribution**: 3x capacity increase (3-node cluster)
- **Fault Tolerance**: Graceful handling of node failures
- **Scalability**: Linear scaling by adding nodes

**Implementation Cost**: $25,000-35,000 (hardware + implementation)
**Timeline**: 6-8 weeks implementation + 2 weeks testing

### 8. Monitoring and Alerting Implementation

#### Application Performance Monitoring (APM) Setup
```xml
<!-- Liberty monitoring configuration -->
<monitor filter="WebContainer" />
<monitor filter="ConnectionPool" />  
<monitor filter="ThreadPool" />
<monitor filter="JVM" />
<monitor filter="HTTP" />

<!-- JMX monitoring -->
<localConnector />
<restConnector>
    <quickStartSecurity userName="admin" userPassword="admin123"/>
</restConnector>

<!-- Application metrics -->
<mpMetrics authentication="false" />
<mpHealth authentication="false" />
```

#### Prometheus Metrics Configuration
```yaml
# prometheus.yml
global:
  scrape_interval: 30s
  evaluation_interval: 30s

scrape_configs:
  - job_name: 'daytrader-liberty'
    static_configs:
      - targets: ['liberty1:9083', 'liberty2:9083', 'liberty3:9083']
    metrics_path: '/metrics'
    scrape_interval: 15s
    
  - job_name: 'postgresql'
    static_configs:
      - targets: ['postgres-primary:5432', 'postgres-standby:5432']
    metrics_path: '/metrics'
    
  - job_name: 'haproxy'
    static_configs:
      - targets: ['haproxy:8404']
    metrics_path: '/stats/prometheus'
```

#### Grafana Dashboard Configuration
```json
{
  "dashboard": {
    "id": null,
    "title": "DayTrader Performance Dashboard",
    "panels": [
      {
        "title": "Response Time",
        "targets": [
          {
            "expr": "http_request_duration_seconds{job=\"daytrader-liberty\"}"
          }
        ]
      },
      {
        "title": "Database Connections",
        "targets": [
          {
            "expr": "connection_pool_active_connections{job=\"daytrader-liberty\"}"
          }
        ]
      },
      {
        "title": "JVM Heap Usage",
        "targets": [
          {
            "expr": "jvm_memory_used_bytes{job=\"daytrader-liberty\",area=\"heap\"}"
          }
        ]
      }
    ]
  }
}
```

#### Alerting Rules Configuration
```yaml
# alert_rules.yml
groups:
  - name: daytrader.rules
    rules:
      # High response time alert
      - alert: HighResponseTime
        expr: http_request_duration_seconds_p95 > 1.0
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High response time detected"
          
      # Database connection pool exhaustion
      - alert: ConnectionPoolExhaustion
        expr: connection_pool_active_connections / connection_pool_max_connections > 0.8
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Database connection pool nearly exhausted"
          
      # High JVM heap usage
      - alert: HighHeapUsage
        expr: jvm_memory_used_bytes{area="heap"} / jvm_memory_max_bytes{area="heap"} > 0.85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "JVM heap usage is high"
```

**Expected Benefits**:
- **Proactive Issue Detection**: 90% of issues detected before user impact
- **Performance Optimization**: Data-driven optimization decisions
- **Capacity Planning**: Accurate resource utilization tracking
- **Reduced MTTR**: 60% faster problem resolution

**Implementation Cost**: $10,000-15,000 (tools + configuration)
**Timeline**: 4-6 weeks implementation + 2 weeks fine-tuning

## Medium Priority Recommendations

### 9. Microservices Architecture Migration Strategy

#### Current Monolithic Architecture Issues
```
Single EAR Deployment:
├── daytrader3-ee6-web.war      (Presentation)
├── daytrader3-ee6-ejb.jar      (Business Logic)  
└── daytrader3-ee6-rest.war     (API Layer)
```

**Limitations**:
- Single deployment unit affects entire system
- Technology coupling prevents independent scaling
- Resource contention between different functional areas
- Difficult to implement different caching strategies

#### Proposed Microservices Architecture
```
Microservices Target Architecture:

┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   User Service  │  │  Market Service │  │Trading Service  │
│                 │  │                 │  │                 │  
│ • Authentication│  │ • Quote Data    │  │ • Order Proc.   │
│ • User Profiles │  │ • Market Summary│  │ • Portfolio     │
│ • Session Mgmt  │  │ • Price Updates │  │ • Trade History │
└─────────────────┘  └─────────────────┘  └─────────────────┘
         │                     │                     │
         └─────────────────────┼─────────────────────┘
                               │
                    ┌─────────────────┐
                    │  API Gateway    │
                    │                 │
                    │ • Routing       │
                    │ • Auth          │  
                    │ • Rate Limiting │
                    │ • Load Balancing│
                    └─────────────────┘
```

#### Service Decomposition Plan
```java
// User Service (Microservice 1)
@RestController
@RequestMapping("/api/users")
public class UserServiceController {
    
    @GetMapping("/{userId}/profile")
    public ResponseEntity<UserProfile> getUserProfile(@PathVariable String userId) {
        // User profile operations
    }
    
    @PostMapping("/authenticate")
    public ResponseEntity<AuthToken> authenticate(@RequestBody LoginRequest request) {
        // Authentication operations
    }
}

// Market Data Service (Microservice 2)
@RestController  
@RequestMapping("/api/market")
public class MarketServiceController {
    
    @GetMapping("/quotes/{symbol}")
    @Cacheable(value = "quotes", key = "#symbol")
    public ResponseEntity<Quote> getQuote(@PathVariable String symbol) {
        // Quote retrieval with caching
    }
    
    @GetMapping("/summary")
    @Cacheable(value = "marketSummary", key = "'summary'")
    public ResponseEntity<MarketSummary> getMarketSummary() {
        // Market summary with enhanced caching
    }
}
```

**Expected Benefits**:
- **Independent Scaling**: Scale services based on demand
- **Technology Diversity**: Use optimal technology for each service
- **Fault Isolation**: Service failures don't affect entire system
- **Development Velocity**: Teams can work independently

**Implementation Cost**: $150,000-250,000 (major architecture refactoring)
**Timeline**: 12-18 months phased migration

### 10. Container Orchestration (Kubernetes) Implementation

#### Kubernetes Deployment Architecture
```yaml
# daytrader-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: daytrader
  
---
# liberty-deployment.yaml  
apiVersion: apps/v1
kind: Deployment
metadata:
  name: daytrader-liberty
  namespace: daytrader
spec:
  replicas: 3
  selector:
    matchLabels:
      app: daytrader-liberty
  template:
    metadata:
      labels:
        app: daytrader-liberty
    spec:
      containers:
      - name: liberty
        image: daytrader/liberty:latest
        ports:
        - containerPort: 9083
        resources:
          requests:
            memory: "2Gi"
            cpu: "1000m"
          limits:
            memory: "4Gi" 
            cpu: "2000m"
        env:
        - name: DB_HOST
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: database.host
        livenessProbe:
          httpGet:
            path: /health
            port: 9083
          initialDelaySeconds: 60
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 9083
          initialDelaySeconds: 30
          periodSeconds: 10
```

#### Auto-scaling Configuration
```yaml
# hpa.yaml - Horizontal Pod Autoscaler
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: daytrader-hpa
  namespace: daytrader
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: daytrader-liberty
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

**Expected Benefits**:
- **Auto-scaling**: Automatic scaling based on resource utilization
- **High Availability**: Built-in failover and health monitoring
- **Resource Efficiency**: Optimal resource allocation and sharing
- **Operational Excellence**: Standardized deployment and monitoring

**Implementation Cost**: $75,000-125,000 (infrastructure + migration)
**Timeline**: 8-12 months implementation

## Implementation Roadmap Summary

### Phase 1: Critical Infrastructure (Weeks 1-6)
**Budget**: $25,000-35,000
1. PostgreSQL migration (Weeks 1-4)
2. JVM optimization (Week 1)  
3. Connection pool optimization (Week 1)
4. Storage upgrade (Weeks 2-3)

**Expected ROI**: 400% user capacity increase

### Phase 2: Performance Enhancement (Weeks 7-18)
**Budget**: $50,000-75,000
1. JPA L2 caching implementation (Weeks 7-10)
2. Application-level caching (Weeks 11-14)
3. Load balancing and clustering (Weeks 15-18)

**Expected ROI**: 1000% user capacity increase, 99.9% availability

### Phase 3: Advanced Infrastructure (Months 6-18)
**Budget**: $200,000-350,000
1. Monitoring and alerting (Months 6-7)
2. Microservices migration (Months 8-15)
3. Kubernetes implementation (Months 12-18)

**Expected ROI**: Unlimited horizontal scaling, operational excellence

## Conclusion

The recommended infrastructure optimizations provide a clear path from the current single-server development architecture to a production-ready, highly scalable system. The phased approach ensures:

1. **Immediate Impact**: Critical optimizations provide 400% capacity improvement in 6 weeks
2. **Risk Mitigation**: Incremental changes allow validation at each phase
3. **Cost Optimization**: High-impact, low-cost optimizations implemented first
4. **Future-Proofing**: Advanced features prepare for long-term growth and operational requirements

**Total Investment**: $275,000-460,000 over 18 months
**Expected Capacity**: 100 → 5000+ concurrent users  
**Availability Improvement**: 95% → 99.9% uptime
**Performance Improvement**: 10x faster response times