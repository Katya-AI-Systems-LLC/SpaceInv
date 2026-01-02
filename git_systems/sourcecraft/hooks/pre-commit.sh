#!/bin/bash
# SourceCraft pre-commit hook for Space Invaders project
# This script runs before each commit to ensure code quality

# Exit on any error
set -e

echo "Running pre-commit checks for Space Invaders project..."

# Flutter specific checks
if command -v flutter &> /dev/null; then
    echo "Running Flutter analyzer..."
    flutter analyze
    
    echo "Running Flutter tests..."
    flutter test
else
    echo "Flutter is not installed. Skipping Flutter-specific checks."
fi

# Check for TODOs and FIXMEs in the code
echo "Checking for TODOs and FIXMEs..."
TODO_COUNT=$(grep -r "TODO\|FIXME" lib/ test/ --include="*.dart" | wc -l)
if [ $TODO_COUNT -gt 0 ]; then
    echo "Warning: Found $TODO_COUNT TODOs/FIXMEs in the code."
fi

# Check if pubspec.yaml has changed and dependencies need updating
if git diff --cached --name-only | grep -q "pubspec.yaml"; then
    echo "pubspec.yaml has changed. Remember to run 'flutter pub get' after commit."
fi

echo "Pre-commit checks completed."