# Bitbucket Configuration for Space Invaders

This directory contains Bitbucket-specific configuration files for the Space Invaders project.

## Files

- `.gitignore` - Bitbucket-specific ignore patterns
- `.gitattributes` - Text/binary normalization
- `hooks/pre-commit.sh` - Quality checks before commit
- `hooks/post-commit.sh` - Automation after commit
- `bitbucket-pipelines.yml` - CI/CD configuration for Bitbucket Pipelines

## Usage

To use these configurations in your Bitbucket repository:

1. Copy these files to your repository root
2. Adjust as needed for your specific project requirements
3. Ensure hooks have execute permissions: `chmod +x hooks/*.sh`

## Bitbucket Pipelines

The `bitbucket-pipelines.yml` file contains CI/CD configuration for automated testing and deployment.