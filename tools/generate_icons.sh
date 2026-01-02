#!/bin/bash

# Generate random icons for Space Invaders app
# Supports all platforms: Android, iOS, Web, Windows, macOS, Linux

echo ""
echo "================================"
echo "  Space Invaders Icon Generator"
echo "================================"
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 is not installed"
    echo "Please install Python 3 from https://www.python.org/"
    exit 1
fi

# Check if Pillow is installed
python3 -c "import PIL" 2>/dev/null
if [ $? -ne 0 ]; then
    echo ""
    echo "Installing required package: Pillow..."
    pip3 install Pillow
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to install Pillow"
        echo "Try running: pip3 install Pillow"
        exit 1
    fi
fi

# Run the icon generator
echo "Generating random icons for all platforms..."
echo ""
python3 tools/generate_icons.py

if [ $? -eq 0 ]; then
    echo ""
    echo "================================"
    echo "  Icon generation successful! ✓"
    echo "================================"
    echo ""
    echo "Next steps:"
    echo "  1. flutter clean"
    echo "  2. flutter pub get"
    echo "  3. flutter run"
    echo ""
else
    echo ""
    echo "ERROR: Icon generation failed!"
    echo ""
    exit 1
fi
