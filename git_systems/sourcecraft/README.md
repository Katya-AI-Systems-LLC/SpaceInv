# SourceCraft Configuration for Space Invaders

This directory contains SourceCraft-specific configuration files for the Space Invaders project.

## Files

- `.gitignore` - SourceCraft-specific ignore patterns
- `.gitattributes` - Text/binary normalization
- `hooks/pre-commit.sh` - Quality checks before commit
- `hooks/post-commit.sh` - Automation after commit

## Usage

To use these configurations in your SourceCraft repository:

1. Copy these files to your repository root
2. Adjust as needed for your specific project requirements
3. Ensure hooks have execute permissions: `chmod +x hooks/*.sh`

## SourceCraft CI/CD

SourceCraft supports GitHub Actions workflows, so you can use the GitHub Actions configuration files with SourceCraft as well.