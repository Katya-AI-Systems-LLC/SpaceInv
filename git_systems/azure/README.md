# Azure DevOps Configuration for Space Invaders

This directory contains Azure DevOps-specific configuration files for the Space Invaders project.

## Files

- `.gitignore` - Azure DevOps-specific ignore patterns
- `.gitattributes` - Text/binary normalization
- `hooks/pre-commit.sh` - Quality checks before commit
- `hooks/post-commit.sh` - Automation after commit
- `azure-pipelines.yml` - CI/CD configuration for Azure Pipelines

## Usage

To use these configurations in your Azure DevOps repository:

1. Copy these files to your repository root
2. Adjust as needed for your specific project requirements
3. Ensure hooks have execute permissions: `chmod +x hooks/*.sh`

## Azure Pipelines

The `azure-pipelines.yml` file contains CI/CD configuration for automated testing and deployment.