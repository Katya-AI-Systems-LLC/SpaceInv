#!/usr/bin/env python3
"""Generate random colorful app icons for Space Invaders game across all platforms."""

import os
import random
from PIL import Image, ImageDraw, ImageFont
import math

# Color schemes for random generation
COLOR_PALETTES = [
    # Neon theme
    [(255, 0, 255), (0, 255, 255), (255, 255, 0)],  # Magenta, Cyan, Yellow
    # Space theme
    [(30, 30, 60), (255, 100, 200), (100, 200, 255)],  # Dark blue, Pink, Light blue
    # Retro arcade
    [(255, 0, 0), (255, 165, 0), (255, 255, 0)],  # Red, Orange, Yellow
    # Cyberpunk
    [(20, 20, 40), (0, 255, 150), (255, 20, 150)],  # Dark, Cyan, Magenta
    # Sunset
    [(255, 87, 34), (255, 152, 0), (255, 193, 7)],  # Deep orange, Orange, Amber
]

def generate_random_icon(size=1024):
    """Generate a random space invaders themed icon."""
    # Create image with random background color
    palette = random.choice(COLOR_PALETTES)
    bg_color = (random.randint(10, 30), random.randint(10, 30), random.randint(20, 40))
    
    img = Image.new('RGB', (size, size), bg_color)
    draw = ImageDraw.Draw(img)
    
    # Draw random geometric shapes (representing space invaders)
    num_shapes = random.randint(5, 12)
    for _ in range(num_shapes):
        x = random.randint(0, size)
        y = random.randint(0, size)
        shape_size = random.randint(int(size * 0.05), int(size * 0.25))
        color = random.choice(palette)
        
        shape_type = random.choice(['circle', 'square', 'triangle', 'star'])
        
        if shape_type == 'circle':
            draw.ellipse(
                [x - shape_size, y - shape_size, x + shape_size, y + shape_size],
                fill=color,
                outline=palette[random.randint(0, len(palette)-1)],
                width=2
            )
        elif shape_type == 'square':
            draw.rectangle(
                [x - shape_size, y - shape_size, x + shape_size, y + shape_size],
                fill=color,
                outline=palette[random.randint(0, len(palette)-1)],
                width=2
            )
        elif shape_type == 'triangle':
            points = [
                (x, y - shape_size),
                (x + shape_size, y + shape_size),
                (x - shape_size, y + shape_size)
            ]
            draw.polygon(points, fill=color, outline=palette[random.randint(0, len(palette)-1)])
        elif shape_type == 'star':
            # Draw a simple star
            star_points = []
            for i in range(10):
                angle = i * math.pi / 5
                if i % 2 == 0:
                    r = shape_size
                else:
                    r = shape_size // 2
                px = x + r * math.sin(angle)
                py = y - r * math.cos(angle)
                star_points.append((px, py))
            draw.polygon(star_points, fill=color, outline=palette[random.randint(0, len(palette)-1)])
    
    # Add a glowing border effect with gradient
    border_width = int(size * 0.02)
    for i in range(border_width):
        alpha = int(255 * (1 - i / border_width))
        color_with_alpha = tuple(int(c * (1 - i / border_width)) for c in palette[0])
        draw.rectangle(
            [i, i, size - i - 1, size - i - 1],
            outline=color_with_alpha,
            width=1
        )
    
    return img

def create_platform_icons():
    """Create and save icons for all platforms."""
    
    base_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    
    # Icon specifications for each platform
    icon_specs = {
        'android': [
            ('android/app/src/main/res/mipmap-ldpi/ic_launcher.png', 36),
            ('android/app/src/main/res/mipmap-mdpi/ic_launcher.png', 48),
            ('android/app/src/main/res/mipmap-hdpi/ic_launcher.png', 72),
            ('android/app/src/main/res/mipmap-xhdpi/ic_launcher.png', 96),
            ('android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png', 144),
            ('android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png', 192),
        ],
        'ios': [
            ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png', 20),
            ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png', 40),
            ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png', 60),
            ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png', 29),
            ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png', 58),
            ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png', 87),
            ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png', 40),
            ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png', 80),
            ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png', 120),
            ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png', 120),
            ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png', 180),
            ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png', 76),
            ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png', 152),
            ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png', 167),
            ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png', 1024),
        ],
        'web': [
            ('web/icons/Icon-192.png', 192),
            ('web/icons/Icon-512.png', 512),
            ('web/icons/Icon-maskable-192.png', 192),
            ('web/icons/Icon-maskable-512.png', 512),
        ],
        'windows': [
            ('windows/runner/resources/app_icon.ico', 256),
        ],
        'macos': [
            ('macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_16.png', 16),
            ('macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_32.png', 32),
            ('macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_64.png', 64),
            ('macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_128.png', 128),
            ('macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png', 256),
            ('macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png', 512),
            ('macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png', 1024),
        ],
        'linux': [
            ('linux/snap/gui/Space Invaders.png', 256),
        ],
    }
    
    print("🎨 Generating random Space Invaders icons for all platforms...\n")
    
    # Generate one base icon that we'll scale for all sizes
    base_icon = generate_random_icon(1024)
    
    for platform, icons in icon_specs.items():
        print(f"📱 Platform: {platform.upper()}")
        for rel_path, size in icons:
            full_path = os.path.join(base_path, rel_path)
            
            # Create directory if it doesn't exist
            os.makedirs(os.path.dirname(full_path), exist_ok=True)
            
            # Resize icon to required size
            icon = base_icon.resize((size, size), Image.Resampling.LANCZOS)
            
            # For ICO files (Windows), we need special handling
            if full_path.endswith('.ico'):
                icon.save(full_path, format='ICO', sizes=[(size, size)])
            else:
                icon.save(full_path, 'PNG')
            
            print(f"  ✓ {rel_path.split('/')[-1]} ({size}x{size})")
        print()
    
    print("✅ Icon generation complete! All platforms updated.\n")
    print("Generated icon characteristics:")
    print("  • Random color palette (Neon, Space, Retro, Cyberpunk, Sunset)")
    print("  • Geometric shapes (circles, squares, triangles, stars)")
    print("  • Glow border effect")
    print("  • Space invaders themed design")
    print("\nTo use new icons, rebuild your app:")
    print("  flutter clean && flutter pub get && flutter run")

if __name__ == '__main__':
    try:
        create_platform_icons()
    except ImportError:
        print("❌ Error: Pillow library not found.")
        print("Install it with: pip install Pillow")
        exit(1)
    except Exception as e:
        print(f"❌ Error generating icons: {e}")
        exit(1)
