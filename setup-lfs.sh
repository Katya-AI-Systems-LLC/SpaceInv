#!/bin/bash

# Git LFS (Large File Storage) Configuration for Space Invaders

# Install Git LFS if not already installed
if ! command -v git-lfs &> /dev/null; then
    echo "Installing Git LFS..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y git-lfs
    elif command -v yum &> /dev/null; then
        sudo yum install -y git-lfs
    elif command -v brew &> /dev/null; then
        brew install git-lfs
    elif command -v choco &> /dev/null; then
        choco install git-lfs
    else
        echo "Please install Git LFS manually: https://git-lfs.github.com/"
        exit 1
    fi
fi

# Initialize Git LFS
echo "Initializing Git LFS..."
git lfs install

# Track large file types
echo "Configuring Git LFS file tracking..."

# Flutter build artifacts
git lfs track "*.apk"
git lfs track "*.aab"
git lfs track "*.ipa"
git lfs track "*.dmg"
git lfs track "*.pkg"
git lfs track "*.msi"
git lfs track "*.exe"

# Large media files
git lfs track "*.mp4"
git lfs track "*.avi"
git lfs track "*.mov"
git lfs track "*.wmv"
git lfs track "*.flv"
git lfs track "*.webm"

# Large audio files
git lfs track "*.wav"
git lfs track "*.flac"
git lfs track "*.aac"
git lfs track "*.ogg"
git lfs track "*.wma"

# Large image files
git lfs track "*.psd"
git lfs track "*.ai"
git lfs track "*.eps"
git lfs track "*.tiff"
git lfs track "*.bmp"

# Archive files
git lfs track "*.zip"
git lfs track "*.tar.gz"
git lfs track "*.tar.bz2"
git lfs track "*.tar.xz"
git lfs track "*.7z"
git lfs track "*.rar"

# Database files
git lfs track "*.db"
git lfs track "*.sqlite"
git lfs track "*.sqlite3"

# Large configuration files
git lfs track "*.keystore"
git lfs track "*.jks"
git lfs track "*.p12"
git lfs track "*.pfx"

# Test data files
git lfs track "test_data/**"
git lfs track "fixtures/**"
git lfs track "samples/**"

# Documentation PDFs
git lfs track "*.pdf"

# Large JSON/XML files
git lfs track "*.jsonl"
git lfs track "*.xmll"

# Add .gitattributes to staging
git add .gitattributes

echo "Git LFS configuration completed!"
echo ""
echo "Tracked file types:"
git lfs track
echo ""
echo "To track additional files, use:"
echo "  git lfs track \"<pattern>\""
echo ""
echo "To untrack files, use:"
echo "  git lfs untrack \"<pattern>\""
echo ""
echo "To see LFS status, use:"
echo "  git lfs status"
