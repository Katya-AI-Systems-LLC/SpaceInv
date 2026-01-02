#!/usr/bin/env python3
"""
Quick icon generator and rebuild helper.
Generates new icons and optionally rebuilds the app.
"""

import os
import subprocess
import sys
import argparse

def run_command(cmd, description):
    """Run a shell command with error handling."""
    print(f"\n▶️  {description}...")
    result = subprocess.run(cmd, shell=True)
    if result.returncode != 0:
        print(f"❌ {description} failed!")
        return False
    print(f"✅ {description} completed!")
    return True

def main():
    parser = argparse.ArgumentParser(
        description='Generate random icons and optionally rebuild the app'
    )
    parser.add_argument(
        '--rebuild',
        action='store_true',
        help='Rebuild the app after generating icons (runs: flutter clean, pub get, run)'
    )
    parser.add_argument(
        '--clean-only',
        action='store_true',
        help='Only run flutter clean'
    )
    parser.add_argument(
        '--web',
        action='store_true',
        help='Build for web platform'
    )
    parser.add_argument(
        '--android',
        action='store_true',
        help='Build for Android platform'
    )
    
    args = parser.parse_args()
    
    print("\n" + "="*50)
    print("  Space Invaders - Icon Generator & Rebuild")
    print("="*50)
    
    # Generate icons
    if not run_command('python tools/generate_icons.py', 'Icon generation'):
        sys.exit(1)
    
    if args.clean_only:
        if not run_command('flutter clean', 'Flutter clean'):
            sys.exit(1)
        print("\n✅ Clean complete! Run 'flutter run' to rebuild.")
        return
    
    if args.rebuild:
        if not run_command('flutter clean', 'Flutter clean'):
            sys.exit(1)
        if not run_command('flutter pub get', 'Flutter pub get'):
            sys.exit(1)
        
        platform_cmd = 'flutter run'
        if args.web:
            platform_cmd += ' -d chrome'
        elif args.android:
            platform_cmd += ' -d android'
        
        if not run_command(platform_cmd, 'Flutter run'):
            sys.exit(1)
    
    print("\n" + "="*50)
    print("  ✅ Complete!")
    print("="*50 + "\n")
    print("💡 Available commands:")
    print("   python tools/quick_icons.py              # Just generate icons")
    print("   python tools/quick_icons.py --clean-only # Clean and prepare")
    print("   python tools/quick_icons.py --rebuild    # Generate + rebuild")
    print("   python tools/quick_icons.py --rebuild --web    # Generate + rebuild for web")
    print("   python tools/quick_icons.py --rebuild --android # Generate + rebuild for android")
    print()

if __name__ == '__main__':
    main()
