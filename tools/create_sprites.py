#!/usr/bin/env python3
"""
Simple script to create placeholder sprites for Space Invaders game.
Requires Pillow library: pip install Pillow
"""

from PIL import Image, ImageDraw
import os

# Create assets/images directory if it doesn't exist
os.makedirs('assets/images', exist_ok=True)

# Player sprite (green triangle/rocket)
player = Image.new('RGBA', (50, 50), (0, 0, 0, 0))
draw = ImageDraw.Draw(player)
# Draw rocket shape (triangle with details)
draw.polygon([(25, 5), (15, 40), (35, 40)], fill=(0, 255, 0, 255))
draw.rectangle([22, 5, 28, 15], fill=(255, 255, 255, 255))  # Window
draw.polygon([(20, 40), (15, 45), (20, 43)], fill=(255, 200, 0, 255))  # Left flame
draw.polygon([(30, 40), (35, 45), (30, 43)], fill=(255, 200, 0, 255))  # Right flame
player.save('assets/images/player.png')
print("Created player.png")

# Enemy sprite (yellow alien)
enemy = Image.new('RGBA', (40, 40), (0, 0, 0, 0))
draw = ImageDraw.Draw(enemy)
# Draw alien shape
draw.ellipse([5, 5, 35, 25], fill=(255, 255, 0, 255))  # Head
draw.ellipse([10, 10, 15, 15], fill=(255, 0, 0, 255))  # Left eye
draw.ellipse([25, 10, 30, 15], fill=(255, 0, 0, 255))  # Right eye
draw.rectangle([15, 20, 25, 22], fill=(255, 0, 0, 255))  # Mouth
draw.rectangle([12, 25, 15, 35], fill=(255, 255, 0, 255))  # Left leg
draw.rectangle([25, 25, 28, 35], fill=(255, 255, 0, 255))  # Right leg
draw.rectangle([15, 25, 25, 30], fill=(255, 255, 0, 255))  # Body
enemy.save('assets/images/enemy.png')
print("Created enemy.png")

# Player bullet sprite (cyan)
bullet = Image.new('RGBA', (5, 15), (0, 255, 255, 255))
draw = ImageDraw.Draw(bullet)
draw.rectangle([0, 0, 5, 15], fill=(0, 255, 255, 255))
bullet.save('assets/images/bullet.png')
print("Created bullet.png")

print("\nAll sprites created successfully!")
print("Note: The game will work with these placeholder sprites.")
print("You can replace them with custom sprites later.")

