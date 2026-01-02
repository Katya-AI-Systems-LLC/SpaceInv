# Translation Guide

## Introduction

This document provides guidelines for translating the Space Invaders project into different languages. We welcome contributions from the community to make our project accessible to a wider audience.

## Supported Languages

Currently, we support the following languages:
- English (en)
- Russian (ru)

We're planning to add support for more languages in the future.

## How to Contribute Translations

1. Fork the repository
2. Create a new branch for your translation work
3. Add or update translation files in the appropriate language directory
4. Test your translations
5. Submit a pull request with your changes

## Translation Files Structure

Translation files are located in the `assets/translations/` directory, organized by language code:

```
assets/
  translations/
    en/
      strings.json
    ru/
      strings.json
```

## Translation File Format

Translation files use JSON format with key-value pairs:

```json
{
  "game_title": "Space Invaders",
  "start_game": "Start Game",
  "settings": "Settings",
  "language": "Language"
}
```

## Best Practices

1. Maintain consistency with existing translations
2. Keep translations concise and clear
3. Test translations in the actual game interface
4. Follow cultural conventions for the target language
5. Avoid hardcoding text in the source code - use translation keys instead

## Review Process

All translation contributions will be reviewed by the maintainers to ensure quality and consistency.

## Questions?

If you have any questions about translation contributions, please open an issue or contact the maintainers.