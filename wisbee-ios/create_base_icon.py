#!/usr/bin/env python3
"""
Create a base app icon for Wisbee
"""

from PIL import Image, ImageDraw, ImageFont
import os

# Create 1024x1024 base icon
size = 1024
img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Background gradient
for y in range(size):
    progress = y / size
    r = int(67 + (147 - 67) * progress)  # From blue to purple
    g = int(56 + (51 - 56) * progress)
    b = int(202 + (234 - 202) * progress)
    draw.rectangle([(0, y), (size, y+1)], fill=(r, g, b))

# Rounded corners
corner_radius = 180
mask = Image.new('L', (size, size), 0)
mask_draw = ImageDraw.Draw(mask)
mask_draw.rounded_rectangle([(0, 0), (size, size)], corner_radius, fill=255)
img.putalpha(mask)

# Center circle
center = size // 2
circle_radius = 300
draw.ellipse(
    [(center - circle_radius, center - circle_radius),
     (center + circle_radius, center + circle_radius)],
    fill=(255, 255, 255, 30)
)

# Add "W" text
try:
    # Try to use system font
    font_size = 400
    font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
except:
    font = ImageFont.load_default()

text = "W"
bbox = draw.textbbox((0, 0), text, font=font)
text_width = bbox[2] - bbox[0]
text_height = bbox[3] - bbox[1]
text_x = (size - text_width) // 2
text_y = (size - text_height) // 2 - 50
draw.text((text_x, text_y), text, fill=(255, 255, 255), font=font)

# Save base icon
img.save('icon_base.png')
print("Created icon_base.png")

# Generate all iOS icon sizes
sizes = [
    (16, 1), (16, 2), (16, 3),
    (20, 1), (20, 2), (20, 3),
    (29, 1), (29, 2), (29, 3),
    (32, 1), (32, 2), (32, 3),
    (40, 1), (40, 2), (40, 3),
    (58, 1), (58, 2), (58, 3),
    (60, 2), (60, 3),
    (64, 2), (64, 3),
    (76, 1), (76, 2),
    (80, 2), (80, 3),
    (87, 3),
    (120, 2), (120, 3),
    (128, 2), (128, 3),
    (152, 1), (152, 2),
    (167, 2),
    (180, 3),
    (256, 2), (256, 3),
    (512, 2), (512, 3),
    (1024, 1)
]

output_dir = 'Wisbee/Assets.xcassets/AppIcon.appiconset'
os.makedirs(output_dir, exist_ok=True)

for base_size, scale in sizes:
    actual_size = base_size * scale
    resized = img.resize((actual_size, actual_size), Image.Resampling.LANCZOS)
    filename = f'icon_{base_size}x{base_size}@{scale}x.png' if scale > 1 else f'icon_{base_size}x{base_size}.png'
    resized.save(os.path.join(output_dir, filename))
    print(f"Created {filename}")

print("All iOS icons created!")