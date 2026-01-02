# Translation Guide

## Overview

This document provides guidelines for translating the Space Invaders game into different languages. Our goal is to make the game accessible to players worldwide while maintaining the quality and consistency of the original content.

## Translation Files

All translation files are located in the `assets/translations/` directory, with subdirectories for each language (e.g., `en`, `ru`, `es`).

Each language directory contains a `strings.json` file with key-value pairs for all in-game text.

## Adding a New Language

To add a new language:

1. Create a new directory in `assets/translations/` with the appropriate language code (e.g., `fr` for French, `de` for German)
2. Copy `strings.json` from an existing language directory to your new directory
3. Translate all values in the JSON file to the new language
4. Update the language selection menu in the game to include the new language

## Translation Guidelines

### Consistency
- Maintain consistent terminology throughout the game
- Use the same translations for recurring elements (e.g., "Level", "Score", "Lives")

### Cultural Sensitivity
- Adapt content to be culturally appropriate for the target audience
- Consider local customs, traditions, and values
- Be mindful of religious and political sensitivities

### Technical Considerations
- Keep translations concise to fit UI elements
- Preserve formatting placeholders (e.g., `%d`, `%s`)
- Maintain special characters and escape sequences

### Quality Assurance
- Proofread all translations for grammar and spelling errors
- Have native speakers review translations when possible
- Test in-game to ensure proper display and functionality

## JSON Format

The translation files use a simple key-value JSON format:

```json
{
  "game_title": "Space Invaders",
  "start_game": "Start Game",
  "settings": "Settings"
}
```

## Review Process

All translations should be reviewed by at least one native speaker before being merged into the main branch. For major releases, consider professional translation services for critical markets.

## Updating Translations

When new text is added to the game:
1. Add new keys to all existing translation files with English text as placeholder
2. Create issues in the repository for translators to update their languages
3. Review and merge updates after quality checks

## Questions and Support

For questions about translations or to volunteer as a translator, please contact [translations@spaceinvaders.game](mailto:translations@spaceinvaders.game).