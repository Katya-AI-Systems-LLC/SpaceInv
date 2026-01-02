#!/bin/bash
# SourceCraft post-commit hook for Space Invaders project
# This script runs after each commit

echo "Running post-commit actions for Space Invaders project..."

# Get the current commit hash
COMMIT_HASH=$(git rev-parse HEAD)
echo "Commit $COMMIT_HASH completed successfully."

# Check if this is a tagged release
if git describe --tags --exact-match HEAD >/dev/null 2>&1; then
    TAG=$(git describe --tags --exact-match HEAD)
    echo "This commit is tagged as release $TAG"
    
    # In a real scenario, you might want to trigger a build process here
    # For example, you could:
    # - Trigger a CI/CD pipeline
    # - Send a notification to a team chat
    # - Update documentation
    # - Create a GitHub release
fi

# Update the commit count in a file (for version tracking)
COMMIT_COUNT=$(git rev-list --count HEAD)
echo "Total commits: $COMMIT_COUNT" > commit_count.txt
git add commit_count.txt

# If you have any post-commit automation, you can add it here
# For example, you might want to:
# - Run additional tests
# - Generate documentation
# - Update a changelog
# - Send notifications

echo "Post-commit actions completed."