# DayTrader3 Documentation Style Guide

## Overview

This style guide ensures consistency across all DayTrader3 documentation. Follow these guidelines when creating or updating documentation.

## Document Structure

### File Naming
- Use lowercase with hyphens: `security-assessment.md`
- Be descriptive but concise: `api-authentication-guide.md`
- Version documents when needed: `migration-guide-v2.md`

### Standard Document Header
```markdown
# Document Title

**Last Updated**: YYYY-MM-DD  
**Version**: X.Y.Z  
**Status**: Draft | In Progress | Complete | Under Review

## Table of Contents
[Generated or manual TOC]
```

## Markdown Standards

### Headings
- **H1 (#)**: Document title only (one per document)
- **H2 (##)**: Major sections
- **H3 (###)**: Subsections
- **H4 (####)**: Sub-subsections (use sparingly)
- Always include a space after the hash marks
- Use sentence case for headings

### Text Formatting
- **Bold** for emphasis: `**important text**`
- *Italic* for new terms: `*first occurrence*`
- `Code` for inline code: `` `ClassName` ``
- ~~Strikethrough~~ for deprecated items: `~~old method~~`

### Lists
#### Unordered Lists
- Use `-` for all unordered lists
- Maintain consistent indentation (2 spaces)
- Example:
  ```markdown
  - Main point
    - Sub-point
      - Sub-sub-point
  ```

#### Ordered Lists
1. Use `1.` for all items (auto-numbering)
2. Use when sequence matters
3. Example:
   ```markdown
   1. First step
   1. Second step
   1. Third step
   ```

### Code Blocks
Always specify the language for syntax highlighting:

````markdown
```java
public class Example {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
    }
}
```
````

### Tables
- Use pipes and hyphens
- Align columns for readability
- Include header row

```markdown
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Data 1   | Data 2   | Data 3   |
| Data 4   | Data 5   | Data 6   |
```

### Links
- **Internal links**: Use relative paths `[Link Text](../path/to/file.md)`
- **External links**: Use full URLs `[Link Text](https://example.com)`
- **Anchor links**: Use lowercase with hyphens `[Section](#section-name)`

## Content Guidelines

### Writing Style
- Use active voice
- Keep sentences concise (< 25 words when possible)
- Define acronyms on first use: "Java Enterprise Edition (Java EE)"
- Use present tense for current functionality
- Use future tense for planned features

### Technical Terminology
- Be consistent with technical terms
- Use official product names correctly
- Capitalize properly:
  - Java (not java)
  - WebSphere Liberty (not websphere liberty)
  - REST API (not Rest API)

### Code Documentation

#### Method Documentation Format
```java
/**
 * Brief description of what the method does.
 * 
 * @param paramName Description of parameter
 * @return Description of return value
 * @throws ExceptionType When this exception occurs
 */
```

#### Example Code
- Provide context before code blocks
- Keep examples concise and focused
- Include comments for complex logic
- Show both correct and incorrect usage when helpful

## Diagram Guidelines

### Mermaid.js Standards
- Use consistent node shapes
- Apply color scheme from diagram template
- Keep text concise in nodes
- Use subgraphs for logical grouping

### Diagram Types
- **Architecture**: System-wide views
- **Sequence**: User interactions and flows
- **Class**: Object relationships
- **ERD**: Database structures
- **State**: Object lifecycle
- **Flowchart**: Process flows

## Cross-References

### Internal Cross-References
```markdown
See [Security Assessment](../security-assessment.md#authentication) for details.
```

### External Cross-References
```markdown
Refer to the [Official Java EE Documentation](https://javaee.github.io/).
```

## Special Sections

### Notes and Warnings
```markdown
> **Note**: Important information that doesn't fit in the main text.

> **Warning**: Critical information about potential issues.

> **Tip**: Helpful suggestions for best practices.
```

### TODOs and Placeholders
```markdown
*[TODO: Add description of authentication flow]*

*[PLACEHOLDER: Performance metrics will be added after testing]*
```

## File Organization

### Directory Structure
```
docs/
├── architecture.md          # Main architecture document
├── technical-documentation.md
├── security-assessment.md
├── performance-assessment.md
├── diagrams/               # All diagram source files
│   ├── *.mmd              # Mermaid diagram files
│   └── *.png/svg          # Generated diagrams
├── images/                # Screenshots and visuals
├── templates/             # Documentation templates
└── archive/              # Old versions for reference
```

## Version Control

### Commit Messages
- Use imperative mood: "Add security assessment" not "Added security assessment"
- Reference issue numbers when applicable
- Keep under 72 characters

### Change Documentation
- Update "Last Updated" date
- Increment version number for significant changes
- Note major changes in a changelog section if needed

## Review Checklist

Before submitting documentation:
- [ ] Spell check completed
- [ ] Links verified
- [ ] Code examples tested
- [ ] Markdown renders correctly
- [ ] TOC updated
- [ ] Cross-references valid
- [ ] Follows style guide
- [ ] Technical accuracy verified