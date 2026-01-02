# GitFlic Configuration for Space Invaders

This directory contains GitFlic-specific configuration files for the Space Invaders project.

## Files

- `.gitignore` - GitFlic-specific ignore patterns
- `.gitattributes` - Text/binary normalization
- `hooks/pre-commit.sh` - Quality checks before commit
- `hooks/post-commit.sh` - Automation after commit

## Usage

To use these configurations in your GitFlic repository:

1. Copy these files to your repository root
2. Adjust as needed for your specific project requirements
3. Ensure hooks have execute permissions: `chmod +x hooks/*.sh`

## GitFlic CI/CD

GitFlic supports GitHub Actions workflows, so you can use the GitHub Actions configuration files with GitFlic as well.