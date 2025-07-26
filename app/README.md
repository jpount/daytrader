# sample.daytrader3 [![Build Status](https://travis-ci.org/WASdev/sample.daytrader3.svg?branch=master)](https://travis-ci.org/WASdev/sample.daytrader3)

# Java EE6: DayTrader3 Sample

Java EE6 DayTrader3 Sample 

(Git Repo)[https://github.com/WASdev/sample.daytrader3/tree/master]

This sample contains the DayTrader 3 benchmark, which is an application built around the paradigm of an online stock trading system. The application allows users to login, view their portfolio, lookup stock quotes, and buy or sell stock shares. With the aid of a Web-based load driver such as Apache JMeter, the real-world workload provided by DayTrader can be used to measure and compare the performance of Java Platform, Enterprise Edition (Java EE) application servers offered by a variety of vendors. In addition to the full workload, the application also contains a set of primitives used for functional and performance testing of various Java EE components and common design patterns.

DayTrader is an end-to-end benchmark and performance sample application. It provides a real world Java EE workload. 

## Getting Started

### Build the docker image for Java7
```
cd daytrader
# Build Docker image
docker build -f Dockerfile.java7 -t daytrader-java7 .
```

### Download the DB jars (if needed)
```
curl -o derby-10.10.1.1.jar https://repo1.maven.org/maven2/org/apache/derby/derby/10.10.1.1/derby-10.10.1.1.jar

# Copy to shared resources
cp derby-10.10.1.1.jar /workspace/daytrader3-ee6-wlpcfg/shared/resources/
```

### Build the project using docker and maven
```
cd daytrader
# Maven Install (with a target of 1.7)
docker run --rm -v $(pwd):/workspace -w /workspace daytrader-java7 mvn clean install -Dmaven.compiler.source=1.7 -Dmaven.compiler.target=1.7 -DskipTests
```

### Copy the EAR and JDBC jars to the app deployment folder
```
cd daytrader
# EAR
cp daytrader3-ee6/target/daytrader3-ee6-1.0-SNAPSHOT.ear daytrader3-ee6-wlpcfg/servers/daytrader3_Sample/apps/daytrader3-ee6.ear

# JDBC
cp daytrader3-ee6-wlpcfg/shared/resources/derby-10.10.1.1.jar daytrader3-ee6-wlpcfg/shared/resources/Daytrader3_SampleDerbyLibs
```

# Run in WAS container using docker-compose
docker compose up

## Configure DB
### (Re)-create  DayTrader Database Tables and Indexes
http://localhost:9083/daytrader/config?action=buildDBTables
### (Re)-populate  DayTrader Database
http://localhost:9083/daytrader/config?action=buildDB

## Login Web
http://localhost:9083/daytrader
Default user/pwd - uid:0/xxx

## API
http://localhost:9083/daytrader/api/trade

```

