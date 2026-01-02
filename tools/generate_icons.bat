@echo off
REM Generate random icons for Space Invaders app
REM Supports all platforms: Android, iOS, Web, Windows, macOS, Linux

echo.
echo ================================
echo   Space Invaders Icon Generator
echo ================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python from https://www.python.org/
    pause
    exit /b 1
)

REM Check if Pillow is installed
python -c "import PIL" >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo Installing required package: Pillow...
    pip install Pillow
    if %errorlevel% neq 0 (
        echo ERROR: Failed to install Pillow
        echo Try running: pip install Pillow
        pause
        exit /b 1
    )
)

REM Run the icon generator
echo Generating random icons for all platforms...
echo.
python tools/generate_icons.py

if %errorlevel% equ 0 (
    echo.
    echo ================================
    echo   Icon generation successful! ✓
    echo ================================
    echo.
    echo Next steps:
    echo   1. flutter clean
    echo   2. flutter pub get
    echo   3. flutter run
    echo.
) else (
    echo.
    echo ERROR: Icon generation failed!
    echo.
)

pause
