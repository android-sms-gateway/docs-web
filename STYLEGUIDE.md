# Comprehensive Style Guidelines for SMS Gateway Documentation

## 1. Typography
- **Headings**: Use consistent hierarchy with `#`, `##`, `###` levels
- **Emphasis**: 
  - Bold (`**text**`) for key terms and mode names
  - Italics for occasional emphasis
- **Code**: 
  - Inline code (`` `code` ``) for API endpoints and parameters
  - Code blocks with language specification (```json, ```bash, etc.)
- **Font**: Roboto family (already included in fonts directory)

## 2. Color Scheme
- Maintain current Material theme palette (light/dark modes)
- Use theme components consistently:
  - `!!! note` for additional information
  - `!!! tip` for recommendations
  - `!!! warning` for cautions
  - `!!! failure` for troubleshooting
  - `!!! important` for critical notes

## 3. Visual Elements
- **Emoji**:
  - Use in all 1st and 2nd level headers for visual categorization
  - Choose emojis relevant to section content (e.g., 🔒 for security, ⚙️ for technical)
  - Use Material Design icons (e.g., `:material-message-question:`, `:material-lock-question:`) for additional visual categorization
- **Images**:
  - Center-align with `<center>` or `align=center`
  - Specify width for screenshots (e.g., `width="480"`)
- **Diagrams**:
  - Use Mermaid for flowcharts and sequence diagrams
  - Add descriptive titles to diagrams
- **Grids**: Use Material grid cards (`<div class="grid cards">`) for feature listings
- **Tabs**: Use tabbed content for multi-language code examples

## 4. Content Structure
- **Lists**: Use bullet points for features/options, numbered for steps
- **Tables**: For comparison of modes/options
- **Sections**: 
  - Start with brief overview paragraph
  - Break into logical subsections
  - End with references/links

## 5. Code Examples
- **Multi-language Support**:
  - Use tabbed content for examples in multiple languages
  - Include source links when available
- **Formatting**:
  - Use `title` attribute for code blocks to describe purpose
  - Add annotations with `// (1)!` and footnotes when needed
  - Specify language for syntax highlighting
- **Completeness**: Include complete, runnable examples when relevant

## 6. Documentation Structure
- **Section Headers**:
  - Start with emoji + title
  - Follow hierarchy consistently
- **Content Flow**:
  - Start with overview paragraph
  - Break into logical subsections
  - End with "See Also" references
- **Cross-linking**:
  - Maintain consistent link formatting with `[]()`
  - Use relative paths for internal links (`../file.md`)
  - Include relevant links in "See Also" sections
