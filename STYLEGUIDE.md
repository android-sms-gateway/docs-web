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
- **Emoji**: Use for visual categorization (e.g., ❓ for FAQs, 📩 for events)
- **Images**: 
  - Center-align with `<center>` or `align=center`
  - Specify width for screenshots (e.g., `width="360"`)
- **Diagrams**: Use Mermaid for flowcharts when appropriate
- **Grids**: Use Material grid cards (`<div class="grid cards">`) for feature listings

## 4. Content Structure
- **Lists**: Use bullet points for features/options, numbered for steps
- **Tables**: For comparison of modes/options
- **Sections**: 
  - Start with brief overview paragraph
  - Break into logical subsections
  - End with references/links

## 5. Code Examples
- Include complete, runnable examples in multiple languages when relevant
- Use `title` attribute for code blocks to describe purpose
- Add annotations with `// (1)!` and footnotes when needed

## 6. Navigation
- Maintain consistent link formatting with `[]()`
- Use relative paths for internal links (`../file.md`)
- Include clear "See Also" sections with relevant links
