#!/bin/bash
# GitHub pre-commit hook for Space Invaders

# Run Flutter tests
echo "Running Flutter tests..."
flutter test

# Check for code analysis issues
echo "Running Flutter analyze..."
flutter analyze

# If any command failed, exit with error
if [ $? -ne 0 ]; then
  echo "Pre-commit checks failed. Please fix the issues before committing."
  exit 1
fi

echo "Pre-commit checks passed!"
exit 0