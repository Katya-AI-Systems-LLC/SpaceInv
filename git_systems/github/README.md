# GitHub Configuration for Space Invaders

This directory contains GitHub-specific configuration files for the Space Invaders project.

## Files

- `.gitignore` - GitHub-specific ignore patterns
- `.gitattributes` - Text/binary normalization
- `hooks/pre-commit.sh` - Quality checks before commit
- `hooks/post-commit.sh` - Automation after commit

## Usage

To use these configurations in your GitHub repository:

1. Copy these files to your repository root
2. Adjust as needed for your specific project requirements
3. Ensure hooks have execute permissions: `chmod +x hooks/*.sh`

## GitHub Actions

For CI/CD on GitHub, see `DEPLOYMENT.md` in the project root which contains GitHub Actions configuration examples.