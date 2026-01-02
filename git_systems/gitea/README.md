# Gitea Configuration for Space Invaders

This directory contains Gitea-specific configuration files for the Space Invaders project.

## Files

- `.gitignore` - Gitea-specific ignore patterns
- `.gitattributes` - Text/binary normalization
- `hooks/pre-commit.sh` - Quality checks before commit
- `hooks/post-commit.sh` - Automation after commit
- `gitea-ci.yml` - CI/CD configuration for Gitea Actions

## Usage

To use these configurations in your Gitea repository:

1. Copy these files to your repository root
2. Adjust as needed for your specific project requirements
3. Ensure hooks have execute permissions: `chmod +x hooks/*.sh`

## Gitea Actions

The `gitea-ci.yml` file contains CI/CD configuration for automated testing and deployment.