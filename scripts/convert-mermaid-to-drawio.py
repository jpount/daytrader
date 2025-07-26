#!/usr/bin/env python3
"""
Convert Mermaid diagrams to Draw.io format

This script provides a basic conversion from Mermaid .mmd files to Draw.io .drawio files.
Note: This is a simplified conversion that creates placeholder diagrams. 
For production use, consider using more sophisticated conversion tools or manual conversion
for complex diagrams.
"""

import os
import sys
import re
from pathlib import Path
import xml.etree.ElementTree as ET
from xml.dom import minidom

def create_drawio_template():
    """Create a basic draw.io XML template"""
    return '''<?xml version="1.0" encoding="UTF-8"?>
<mxfile host="app.diagrams.net" modified="2025-01-22T00:00:00.000Z" agent="5.0" etag="mermaid-conversion" version="21.0.0" type="device">
  <diagram name="Converted Diagram" id="converted-diagram">
    <mxGraphModel dx="1426" dy="794" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="1654" pageHeight="1169" math="0" shadow="0">
      <root>
        <mxCell id="0" />
        <mxCell id="1" parent="0" />
        {content}
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>'''

def create_info_node(title, description, diagram_type):
    """Create an information node for the converted diagram"""
    return f'''
        <mxCell id="info-box" value="{title}" style="swimlane;fontStyle=1;childLayout=stackLayout;horizontal=1;startSize=30;horizontalStack=0;resizeParent=1;resizeParentMax=0;resizeLast=0;collapsible=1;marginBottom=0;fillColor=#e1f5fe;strokeColor=#0277bd;strokeWidth=2;fontSize=16" vertex="1" parent="1">
          <mxGeometry x="40" y="40" width="800" height="200" as="geometry" />
        </mxCell>
        <mxCell id="info-desc" value="Diagram Type: {diagram_type}" style="text;strokeColor=none;fillColor=none;align=left;verticalAlign=top;spacingLeft=4;spacingRight=4;overflow=hidden;rotatable=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;fontSize=14;fontStyle=1" vertex="1" parent="info-box">
          <mxGeometry y="30" width="800" height="30" as="geometry" />
        </mxCell>
        <mxCell id="info-note" value="{description}" style="text;strokeColor=none;fillColor=none;align=left;verticalAlign=top;spacingLeft=4;spacingRight=4;overflow=hidden;rotatable=0;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;fontSize=12;whiteSpace=wrap" vertex="1" parent="info-box">
          <mxGeometry y="60" width="800" height="140" as="geometry" />
        </mxCell>'''

def extract_mermaid_info(content):
    """Extract basic information from Mermaid diagram"""
    diagram_type = "Unknown"
    title = "Converted Mermaid Diagram"
    
    # Detect diagram type
    if content.strip().startswith('graph'):
        diagram_type = "Graph/Flowchart"
    elif content.strip().startswith('flowchart'):
        diagram_type = "Flowchart"
    elif content.strip().startswith('sequenceDiagram'):
        diagram_type = "Sequence Diagram"
    elif content.strip().startswith('erDiagram'):
        diagram_type = "Entity Relationship Diagram"
    elif content.strip().startswith('classDiagram'):
        diagram_type = "Class Diagram"
    elif content.strip().startswith('stateDiagram'):
        diagram_type = "State Diagram"
    
    # Try to extract title
    title_match = re.search(r'title\s+(.+?)(?:\n|$)', content)
    if title_match:
        title = title_match.group(1).strip()
    
    return diagram_type, title

def convert_mermaid_to_drawio(mermaid_file, output_file):
    """Convert a Mermaid file to Draw.io format"""
    try:
        # Read Mermaid content
        with open(mermaid_file, 'r', encoding='utf-8') as f:
            mermaid_content = f.read()
        
        # Extract diagram information
        diagram_type, title = extract_mermaid_info(mermaid_content)
        
        # Create description
        description = f"""This diagram was automatically converted from Mermaid format.
Original file: {os.path.basename(mermaid_file)}
Diagram type: {diagram_type}

For accurate representation, please use one of these methods:
1. Copy the original Mermaid code into draw.io's Mermaid plugin
2. Use mermaid.live to render and export as SVG, then import to draw.io
3. Manually recreate the diagram using draw.io's native tools

Original Mermaid content is preserved below for reference."""
        
        # Create the draw.io content
        info_node = create_info_node(title, description, diagram_type)
        
        # Add a text node with the original Mermaid content (escaped)
        escaped_content = mermaid_content.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;').replace('"', '&quot;')
        mermaid_node = f'''
        <mxCell id="mermaid-content" value="Original Mermaid Code:&#xa;&#xa;{escaped_content}" style="text;html=1;strokeColor=#666666;fillColor=#f5f5f5;align=left;verticalAlign=top;whiteSpace=pre;rounded=1;fontSize=10;fontFamily=Courier New;overflow=auto;spacingLeft=10;spacingTop=10;spacingRight=10;spacingBottom=10" vertex="1" parent="1">
          <mxGeometry x="40" y="280" width="800" height="400" as="geometry" />
        </mxCell>'''
        
        # Combine all content
        drawio_content = create_drawio_template().format(content=info_node + mermaid_node)
        
        # Write the draw.io file
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(drawio_content)
        
        return True, f"Successfully converted {os.path.basename(mermaid_file)}"
    
    except Exception as e:
        return False, f"Error converting {os.path.basename(mermaid_file)}: {str(e)}"

def main():
    """Main conversion function"""
    diagrams_dir = Path("/Users/jp/work/ai-messin/daytrader/docs/diagrams")
    
    # List of files to convert (excluding already converted ones)
    mermaid_files = [
        "system-overview.mmd",
        "sequence-auth.mmd",
        "sequence-trading.mmd",
        "sequence-portfolio.mmd",
        "async-message-flow.mmd",
        "jsp-request-flow.mmd",
        "jsp-trading-sequence.mmd",
        "jsp-component-dependencies.mmd",
        "dependency-injection-service-layer.mmd",
        "ejb-component-architecture.mmd",
        "jpa-persistence-architecture.mmd",
        "module-dependencies-package-structure.mmd",
        "portfolio-account-management-sequence.mmd",
        "stock-trading-sequence.mmd",
        "web-tier-component-architecture.mmd"
    ]
    
    print(f"Converting {len(mermaid_files)} Mermaid diagrams to Draw.io format...")
    print("-" * 60)
    
    success_count = 0
    error_count = 0
    
    for mermaid_file in mermaid_files:
        input_path = diagrams_dir / mermaid_file
        output_path = diagrams_dir / mermaid_file.replace('.mmd', '.drawio')
        
        if not input_path.exists():
            print(f"❌ {mermaid_file} - File not found")
            error_count += 1
            continue
        
        success, message = convert_mermaid_to_drawio(input_path, output_path)
        
        if success:
            print(f"✅ {message}")
            success_count += 1
        else:
            print(f"❌ {message}")
            error_count += 1
    
    print("-" * 60)
    print(f"Conversion complete: {success_count} successful, {error_count} errors")
    
    if success_count > 0:
        print("\nNote: These are placeholder conversions that preserve the original Mermaid code.")
        print("For production use, consider:")
        print("1. Using draw.io's Mermaid plugin to import the diagrams")
        print("2. Manually recreating complex diagrams for better visual quality")
        print("3. Using specialized Mermaid-to-Draw.io conversion tools")

if __name__ == "__main__":
    main()