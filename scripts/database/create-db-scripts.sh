#!/bin/bash

# Create database initialization scripts

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DB_DIR="${PROJECT_ROOT}/.doc-db"

# Ensure database directory exists
mkdir -p "${DB_DIR}"

# Create SQL initialization script
cat > "${SCRIPT_DIR}/init-database.sql" << 'EOF'
-- DayTrader Documentation Database Schema
-- This database stores structured information about the DayTrader application

-- Enable foreign keys
PRAGMA foreign_keys = ON;

-- Drop existing tables if they exist
DROP TABLE IF EXISTS documentation_log;
DROP TABLE IF EXISTS api_endpoints;
DROP TABLE IF EXISTS data_models;
DROP TABLE IF EXISTS dependencies;
DROP TABLE IF EXISTS business_flows;
DROP TABLE IF EXISTS components;
DROP TABLE IF EXISTS modules;

-- Modules table (top-level organization)
CREATE TABLE modules (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    type TEXT CHECK(type IN ('ear', 'war', 'jar', 'config')),
    path TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Components table (classes, servlets, beans, etc.)
CREATE TABLE components (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    type TEXT CHECK(type IN ('servlet', 'ejb', 'entity', 'jsp', 'service', 'util', 'mdb', 'filter', 'listener')),
    module_id INTEGER NOT NULL,
    package_name TEXT,
    class_name TEXT,
    file_path TEXT NOT NULL,
    description TEXT,
    business_purpose TEXT,
    annotations TEXT, -- JSON array of annotations
    methods_count INTEGER DEFAULT 0,
    lines_of_code INTEGER DEFAULT 0,
    complexity_score INTEGER,
    documented BOOLEAN DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(module_id) REFERENCES modules(id)
);

-- Business flows table
CREATE TABLE business_flows (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    category TEXT CHECK(category IN ('trading', 'user-management', 'portfolio', 'market-data', 'admin')),
    entry_point TEXT,
    entry_component_id INTEGER,
    steps JSON, -- JSON array of flow steps
    actors TEXT, -- Comma-separated list
    preconditions TEXT,
    postconditions TEXT,
    business_rules TEXT, -- JSON array of rules
    documented BOOLEAN DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(entry_component_id) REFERENCES components(id)
);

-- Dependencies table
CREATE TABLE dependencies (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_component_id INTEGER NOT NULL,
    target_component_id INTEGER NOT NULL,
    dependency_type TEXT CHECK(dependency_type IN ('import', 'injection', 'inheritance', 'composition', 'usage')),
    details TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(source_component_id) REFERENCES components(id),
    FOREIGN KEY(target_component_id) REFERENCES components(id),
    UNIQUE(source_component_id, target_component_id, dependency_type)
);

-- API endpoints table
CREATE TABLE api_endpoints (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    path TEXT NOT NULL,
    method TEXT CHECK(method IN ('GET', 'POST', 'PUT', 'DELETE', 'PATCH')),
    component_id INTEGER,
    servlet_name TEXT,
    url_pattern TEXT,
    request_format JSON, -- JSON schema
    response_format JSON, -- JSON schema
    query_params JSON, -- JSON array
    path_params JSON, -- JSON array
    headers JSON, -- JSON array
    business_function TEXT,
    authentication_required BOOLEAN DEFAULT 1,
    roles_required TEXT, -- Comma-separated
    documented BOOLEAN DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(component_id) REFERENCES components(id)
);

-- Data models table (entities and DTOs)
CREATE TABLE data_models (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    type TEXT CHECK(type IN ('entity', 'dto', 'vo', 'bean')),
    table_name TEXT,
    entity_class TEXT,
    module_id INTEGER,
    attributes JSON, -- JSON array of attributes
    relationships JSON, -- JSON array of relationships
    indexes JSON, -- JSON array of indexes
    constraints JSON, -- JSON array of constraints
    jpa_annotations JSON, -- JSON array
    documented BOOLEAN DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(module_id) REFERENCES modules(id)
);

-- Documentation log table (track progress)
CREATE TABLE documentation_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    component_type TEXT,
    component_id INTEGER,
    action TEXT CHECK(action IN ('discovered', 'analyzed', 'documented', 'reviewed', 'migrated')),
    details TEXT,
    user TEXT DEFAULT 'claude',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better query performance
CREATE INDEX idx_components_type ON components(type);
CREATE INDEX idx_components_module ON components(module_id);
CREATE INDEX idx_components_documented ON components(documented);
CREATE INDEX idx_dependencies_source ON dependencies(source_component_id);
CREATE INDEX idx_dependencies_target ON dependencies(target_component_id);
CREATE INDEX idx_api_endpoints_path ON api_endpoints(path);
CREATE INDEX idx_business_flows_category ON business_flows(category);
CREATE INDEX idx_data_models_type ON data_models(type);

-- Create views for common queries
CREATE VIEW component_summary AS
SELECT 
    m.name as module_name,
    c.type as component_type,
    COUNT(*) as count,
    SUM(CASE WHEN c.documented = 1 THEN 1 ELSE 0 END) as documented_count,
    ROUND(100.0 * SUM(CASE WHEN c.documented = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) as documented_percentage
FROM components c
JOIN modules m ON c.module_id = m.id
GROUP BY m.name, c.type;

CREATE VIEW undocumented_components AS
SELECT 
    m.name as module_name,
    c.type,
    c.name,
    c.file_path
FROM components c
JOIN modules m ON c.module_id = m.id
WHERE c.documented = 0
ORDER BY m.name, c.type, c.name;

CREATE VIEW business_flow_summary AS
SELECT 
    category,
    COUNT(*) as total_flows,
    SUM(CASE WHEN documented = 1 THEN 1 ELSE 0 END) as documented_flows,
    ROUND(100.0 * SUM(CASE WHEN documented = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) as documented_percentage
FROM business_flows
GROUP BY category;

-- Insert initial module data
INSERT INTO modules (name, type, path, description) VALUES
('daytrader3-ee6', 'ear', '/app/daytrader3-ee6', 'Enterprise Application Archive'),
('daytrader3-ee6-ejb', 'jar', '/app/daytrader3-ee6-ejb', 'EJB and Business Logic Module'),
('daytrader3-ee6-web', 'war', '/app/daytrader3-ee6-web', 'Web Application Module'),
('daytrader3-ee6-rest', 'war', '/app/daytrader3-ee6-rest', 'REST API Module'),
('daytrader3-ee6-wlpcfg', 'config', '/app/daytrader3-ee6-wlpcfg', 'WebSphere Liberty Configuration');

-- Create triggers to update timestamps
CREATE TRIGGER update_components_timestamp 
AFTER UPDATE ON components
BEGIN
    UPDATE components SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

CREATE TRIGGER update_business_flows_timestamp 
AFTER UPDATE ON business_flows
BEGIN
    UPDATE business_flows SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

CREATE TRIGGER update_api_endpoints_timestamp 
AFTER UPDATE ON api_endpoints
BEGIN
    UPDATE api_endpoints SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

CREATE TRIGGER update_data_models_timestamp 
AFTER UPDATE ON data_models
BEGIN
    UPDATE data_models SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;
EOF

# Create Python database helper script
cat > "${SCRIPT_DIR}/db_helper.py" << 'EOF'
#!/usr/bin/env python3
"""
Database helper utilities for DayTrader documentation
"""

import sqlite3
import json
import os
from datetime import datetime
from typing import List, Dict, Any, Optional

class DocDatabase:
    def __init__(self, db_path: str):
        self.db_path = db_path
        self.conn = sqlite3.connect(db_path)
        self.conn.row_factory = sqlite3.Row
        self.cursor = self.conn.cursor()
        self.cursor.execute("PRAGMA foreign_keys = ON")
    
    def __enter__(self):
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.conn.close()
    
    def add_component(self, name: str, component_type: str, module_name: str, 
                     file_path: str, **kwargs) -> int:
        """Add a new component to the database"""
        module_id = self._get_module_id(module_name)
        
        query = """
        INSERT INTO components (name, type, module_id, file_path, package_name, 
                               class_name, description, business_purpose)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        self.cursor.execute(query, (
            name, component_type, module_id, file_path,
            kwargs.get('package_name'), kwargs.get('class_name'),
            kwargs.get('description'), kwargs.get('business_purpose')
        ))
        self.conn.commit()
        return self.cursor.lastrowid
    
    def add_business_flow(self, name: str, category: str, description: str,
                         steps: List[Dict], **kwargs) -> int:
        """Add a new business flow"""
        query = """
        INSERT INTO business_flows (name, category, description, steps, 
                                   entry_point, actors, preconditions, postconditions)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        self.cursor.execute(query, (
            name, category, description, json.dumps(steps),
            kwargs.get('entry_point'), kwargs.get('actors'),
            kwargs.get('preconditions'), kwargs.get('postconditions')
        ))
        self.conn.commit()
        return self.cursor.lastrowid
    
    def add_api_endpoint(self, path: str, method: str, component_name: str, **kwargs) -> int:
        """Add a new API endpoint"""
        component_id = self._get_component_id(component_name) if component_name else None
        
        query = """
        INSERT INTO api_endpoints (path, method, component_id, servlet_name,
                                  url_pattern, business_function, request_format, response_format)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        self.cursor.execute(query, (
            path, method, component_id, kwargs.get('servlet_name'),
            kwargs.get('url_pattern'), kwargs.get('business_function'),
            json.dumps(kwargs.get('request_format', {})),
            json.dumps(kwargs.get('response_format', {}))
        ))
        self.conn.commit()
        return self.cursor.lastrowid
    
    def mark_documented(self, table: str, item_id: int):
        """Mark an item as documented"""
        query = f"UPDATE {table} SET documented = 1 WHERE id = ?"
        self.cursor.execute(query, (item_id,))
        self.conn.commit()
    
    def get_documentation_status(self) -> Dict[str, Any]:
        """Get overall documentation status"""
        status = {}
        
        # Component status
        self.cursor.execute("SELECT * FROM component_summary")
        status['components'] = [dict(row) for row in self.cursor.fetchall()]
        
        # Business flow status
        self.cursor.execute("SELECT * FROM business_flow_summary")
        status['business_flows'] = [dict(row) for row in self.cursor.fetchall()]
        
        # API endpoints status
        self.cursor.execute("""
            SELECT COUNT(*) as total, 
                   SUM(CASE WHEN documented = 1 THEN 1 ELSE 0 END) as documented
            FROM api_endpoints
        """)
        row = self.cursor.fetchone()
        status['api_endpoints'] = {
            'total': row['total'],
            'documented': row['documented'],
            'percentage': round(100.0 * row['documented'] / row['total'], 2) if row['total'] > 0 else 0
        }
        
        return status
    
    def get_undocumented_items(self) -> Dict[str, List[Dict]]:
        """Get all undocumented items"""
        items = {}
        
        # Undocumented components
        self.cursor.execute("SELECT * FROM undocumented_components")
        items['components'] = [dict(row) for row in self.cursor.fetchall()]
        
        # Undocumented flows
        self.cursor.execute("""
            SELECT id, name, category FROM business_flows 
            WHERE documented = 0 ORDER BY category, name
        """)
        items['business_flows'] = [dict(row) for row in self.cursor.fetchall()]
        
        # Undocumented endpoints
        self.cursor.execute("""
            SELECT id, path, method FROM api_endpoints 
            WHERE documented = 0 ORDER BY path, method
        """)
        items['api_endpoints'] = [dict(row) for row in self.cursor.fetchall()]
        
        return items
    
    def _get_module_id(self, module_name: str) -> int:
        """Get module ID by name"""
        self.cursor.execute("SELECT id FROM modules WHERE name = ?", (module_name,))
        row = self.cursor.fetchone()
        if not row:
            raise ValueError(f"Module '{module_name}' not found")
        return row['id']
    
    def _get_component_id(self, component_name: str) -> Optional[int]:
        """Get component ID by name"""
        self.cursor.execute("SELECT id FROM components WHERE name = ?", (component_name,))
        row = self.cursor.fetchone()
        return row['id'] if row else None

# CLI interface
if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 3:
        print("Usage: db_helper.py <db_path> <command> [args...]")
        print("Commands:")
        print("  status - Show documentation status")
        print("  undocumented - List undocumented items")
        print("  add-component <name> <type> <module> <path> - Add a component")
        sys.exit(1)
    
    db_path = sys.argv[1]
    command = sys.argv[2]
    
    with DocDatabase(db_path) as db:
        if command == "status":
            status = db.get_documentation_status()
            print(json.dumps(status, indent=2))
        
        elif command == "undocumented":
            items = db.get_undocumented_items()
            print(json.dumps(items, indent=2))
        
        elif command == "add-component" and len(sys.argv) >= 7:
            component_id = db.add_component(
                sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6]
            )
            print(f"Added component with ID: {component_id}")
EOF

chmod +x "${SCRIPT_DIR}/db_helper.py"

echo "Database scripts created successfully!"