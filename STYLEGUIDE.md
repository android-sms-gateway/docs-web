# 📖 Comprehensive Style Guidelines for SMS Gateway Documentation

This document provides a complete reference for maintaining consistency across all documentation files. Follow these guidelines to ensure a professional, cohesive user experience.

## 📝 1. Typography

### Headings
- Use consistent hierarchy with `#`, `##`, `###` levels
- **Always place emoji at the beginning** of 1st and 2nd level headings
- Follow the pattern: `# 🎯 Title` not `# Title 🎯`
- Use relevant emojis that match section content

### Emphasis
- **Bold** (`**text**`) for key terms, mode names, and important concepts
- *Italics* for occasional emphasis or introducing new terms
- Use emphasis sparingly for maximum impact

### Code
- Inline code (`` `code` ``) for API endpoints, parameters, and technical terms
- Code blocks with language specification (```json, ```bash, ```python, etc.)
- Use `title` attribute for code blocks to describe purpose

### Font
- Roboto family (already included in fonts directory)
- Let Material theme handle font rendering

## 🎨 2. Color Scheme

Maintain current Material theme palette (light/dark modes). Use admonition blocks consistently:

| Admonition      | Usage                                                |
| --------------- | ---------------------------------------------------- |
| `!!! note`      | Additional information, supplementary details        |
| `!!! tip`       | Recommendations, best practices, helpful hints       |
| `!!! warning`   | Cautions, potential issues, things to watch out for  |
| `!!! failure`   | Troubleshooting, error explanations, what went wrong |
| `!!! important` | Critical notes, must-know information                |
| `!!! success`   | Verification steps, successful outcomes              |
| `!!! info`      | General information, contextual details              |
| `!!! danger`    | Security warnings, irreversible actions              |
| `!!! example`   | Code examples, usage demonstrations                  |

### Example Usage
```markdown
!!! tip "Best Practices"
    - Use short TTLs for tokens
    - Store credentials securely

!!! warning "Important"
    This action cannot be undone. Proceed with caution.
```

## 🎯 3. Visual Elements

### Emoji Usage
- **Position**: Always at the **start** of 1st and 2nd level headings
- **Relevance**: Choose emojis that match section content
  - 🔒 for security/authentication
  - ⚙️ for technical/configuration
  - 📱 for mobile/device
  - 🚀 for getting started
  - 📚 for references/see also
  - 🛡️ for privacy/protection
  - ☁️ for cloud services
- **Material Design Icons**: Use for additional visual categorization (e.g., `:material-message-question:`, `:material-lock-question:`)

### Images
- Center-align with `<center>` tags or `align=center` attribute
- Specify width for screenshots (e.g., `width="480"`)
- Use descriptive alt text
- Include captions with `<figcaption>` when appropriate

### Diagrams
- Use Mermaid for flowcharts and sequence diagrams
- Add descriptive titles to diagrams
- Keep diagrams simple and focused
- Use consistent styling (colors, shapes)

### Grids
- Use Material grid cards (`<div class="grid cards">`) for feature listings
- Keep card content concise
- Use consistent card structure

### Tabs
- Use tabbed content for multi-language code examples
- Use `===` syntax for tab groups
- Keep tab labels short and descriptive

## 📐 4. Content Structure

### Lists
- **Bullet points** (`-`) for features, options, and non-sequential items
- **Numbered lists** (`1.`) for steps, procedures, and sequential content
- Keep list items parallel in structure
- Use sub-lists for nested information

### Tables
- Use for comparison of modes, options, or structured data
- Include descriptive headers
- Keep columns aligned and consistent
- Use tables sparingly for readability

### Sections
- **Start** with brief overview paragraph
- **Break** into logical subsections with clear headings
- **End** with "See Also" references when appropriate
- Maintain consistent section depth across documents

## 💻 5. Code Examples

### Multi-language Support
- Use tabbed content for examples in multiple languages
- Include source links when available
- Prioritize commonly used languages (Python, JavaScript, cURL)

### Formatting
- Use `title` attribute for code blocks to describe purpose
- Add annotations with `// (1)!` and footnotes when needed
- Specify language for syntax highlighting
- Keep code blocks focused and concise

### Completeness
- Include complete, runnable examples when relevant
- Show both request and response when helpful
- Include error handling examples for complex operations
- Add comments for non-obvious code sections

### Example Structure
````markdown
=== "cURL"
    ```bash title="Generate JWT Token"
    curl -X POST "https://api.sms-gate.app/3rdparty/v1/auth/token" \
      -u "username:password" \
      -H "Content-Type: application/json" \
      -d '{
        "ttl": 3600,
        "scopes": ["messages:send"]
      }'
    ```

=== "Python"
    ```python title="Generate JWT Token"
    import requests
    
    response = requests.post(
        "https://api.sms-gate.app/3rdparty/v1/auth/token",
        auth=("username", "password"),
        json={"ttl": 3600, "scopes": ["messages:send"]}
    )
    ```
````

## 🏗️ 6. Documentation Structure

### Section Headers
- **Start with emoji + title** (e.g., `## 🔐 Authentication`)
- Follow hierarchy consistently (don't skip levels)
- Keep titles concise and descriptive
- Use parallel structure across similar sections

### Content Flow
- **Start** with overview paragraph explaining what/why
- **Break** into logical subsections with clear headings
- **End** with "See Also" references linking to related content
- Maintain consistent depth across similar documents

### Cross-linking
- Maintain consistent link formatting with `[]()`
- Use relative paths for internal links (`../file.md`)
- Use descriptive link text (avoid "click here")
- Include relevant links in "See Also" sections
- Verify all links are functional before publishing

### File Organization
- Keep related content in the same directory
- Use consistent naming conventions (lowercase, hyphens)
- Include index files for major sections
- Maintain logical navigation structure in `mkdocs.yml`

## 📋 7. Quick Reference

### Do ✅
- Place emojis at the **start** of headings
- Use consistent terminology throughout
- Include overview paragraphs for major sections
- Add "See Also" sections with relevant links
- Test code examples before publishing
- Use admonitions appropriately for different content types

### Don't ❌
- Place emojis at the **end** of headings
- Skip heading levels (e.g., `##` directly to `####`)
- Use multiple exclamation marks or excessive emphasis
- Include broken or relative links without testing
- Mix different list styles in the same section
- Use code blocks without language specification

## 📚 8. Examples

### Good Heading Structure
```markdown
# 🔐 Authentication Guide

## 📋 Overview
Brief introduction...

## 🔑 JWT Tokens
Details about JWT...

### Token Generation
How to generate tokens...

## 📚 See Also
- [API Reference](../integration/api.md)
```

### Admonition Examples
```markdown
!!! tip "Pro Tip"
    Use refresh tokens to avoid frequent re-authentication.

!!! warning "Security Notice"
    Never commit tokens to version control.

!!! note "Important"
    JWT authentication is only available in Cloud and Private Server modes.
```