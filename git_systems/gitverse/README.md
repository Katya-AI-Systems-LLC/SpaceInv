# GitVerse Configuration for Space Invaders

This directory contains GitVerse-specific configuration files for the Space Invaders project.

## Files

- `.gitignore` - GitVerse-specific ignore patterns
- `.gitattributes` - Text/binary normalization
- `hooks/pre-commit.sh` - Quality checks before commit
- `hooks/post-commit.sh` - Automation after commit

## Usage

To use these configurations in your GitVerse repository:

1. Copy these files to your repository root
2. Adjust as needed for your specific project requirements
3. Ensure hooks have execute permissions: `chmod +x hooks/*.sh`

## GitVerse CI/CD

GitVerse supports GitHub Actions workflows, so you can use the GitHub Actions configuration files with GitVerse as well.