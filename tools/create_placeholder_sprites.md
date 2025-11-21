# How to Create Placeholder Sprites

This guide explains how to create simple placeholder sprites for the Space Invaders game.

## Using Image Editing Software

### Player Sprite (`assets/images/player.png`)
- Size: 50x50 pixels
- Color: Green (#00FF00)
- Shape: Triangle pointing up (rocket/spaceship)
- Background: Transparent

### Enemy Sprite (`assets/images/enemy.png`)
- Size: 40x40 pixels
- Color: Yellow (#FFFF00) or Red (#FF0000)
- Shape: Simple alien/spacecraft shape
- Background: Transparent

### Bullet Sprite (`assets/images/bullet.png`)
- Size: 5x15 pixels
- Color: Cyan (#00FFFF) for player, Red (#FF0000) for enemy
- Shape: Rectangle or small dot
- Background: Transparent

## Using Online Tools

### Option 1: Piskel (Free Online Sprite Editor)
1. Go to https://www.piskelapp.com/
2. Create new sprite with appropriate dimensions
3. Draw your sprite
4. Export as PNG
5. Save to `assets/images/`

### Option 2: Aseprite (Paid, Professional)
1. Download from https://www.aseprite.org/
2. Create new sprite
3. Draw and animate
4. Export as PNG

## Using Command Line (ImageMagick)

If you have ImageMagick installed, you can create simple placeholder images:

```bash
# Player sprite (green triangle)
convert -size 50x50 xc:none \
  -draw "polygon 25,5 10,45 40,45" \
  -fill "#00FF00" \
  assets/images/player.png

# Enemy sprite (yellow circle with details)
convert -size 40x40 xc:none \
  -draw "circle 20,20 20,5" \
  -fill "#FFFF00" \
  assets/images/enemy.png

# Bullet sprite (cyan rectangle)
convert -size 5x15 xc:"#00FFFF" \
  assets/images/bullet.png
```

## Quick Python Script

Create a file `tools/create_sprites.py`:

```python
from PIL import Image, ImageDraw

# Player sprite
player = Image.new('RGBA', (50, 50), (0, 0, 0, 0))
draw = ImageDraw.Draw(player)
draw.polygon([(25, 5), (10, 45), (40, 45)], fill=(0, 255, 0, 255))
player.save('assets/images/player.png')

# Enemy sprite
enemy = Image.new('RGBA', (40, 40), (0, 0, 0, 0))
draw = ImageDraw.Draw(enemy)
draw.ellipse([5, 5, 35, 35], fill=(255, 255, 0, 255))
enemy.save('assets/images/enemy.png')

# Bullet sprite
bullet = Image.new('RGBA', (5, 15), (0, 255, 255, 255))
bullet.save('assets/images/bullet.png')
```

Run with: `python tools/create_sprites.py`

## Note

The game will work without sprites - it uses colorful widget fallbacks automatically if images are not found.

