# GitLab Configuration for Space Invaders

This directory contains GitLab-specific configuration files for the Space Invaders project.

## Files

- `.gitignore` - GitLab-specific ignore patterns
- `.gitattributes` - Text/binary normalization
- `hooks/pre-commit.sh` - Quality checks before commit
- `hooks/post-commit.sh` - Automation after commit

## Usage

To use these configurations in your GitLab repository:

1. Copy these files to your repository root
2. Adjust as needed for your specific project requirements
3. Ensure hooks have execute permissions: `chmod +x hooks/*.sh`

## GitLab CI/CD

For CI/CD on GitLab, see `DEPLOYMENT.md` in the project root which contains GitLab CI/CD configuration examples.