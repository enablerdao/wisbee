#!/usr/bin/env python3

import os
from PIL import Image, ImageDraw, ImageFont
import math

def create_wisbee_icon(size):
    """Create Wisbee bee icon at specified size"""
    # Create new image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Calculate dimensions
    center_x = size // 2
    center_y = size // 2
    body_radius = size // 3
    
    # Colors
    yellow = '#FFD700'
    dark_yellow = '#FFA500'
    black = '#000000'
    white = '#FFFFFF'
    
    # Draw bee body (oval)
    body_width = int(body_radius * 1.5)
    body_height = body_radius
    body_left = center_x - body_width // 2
    body_top = center_y - body_height // 2
    body_right = center_x + body_width // 2
    body_bottom = center_y + body_height // 2
    
    # Body with stripes
    draw.ellipse([body_left, body_top, body_right, body_bottom], fill=yellow)
    
    # Black stripes
    stripe_width = body_height // 4
    for i in range(3):
        stripe_y = body_top + stripe_width * (i * 2 + 1)
        if stripe_y + stripe_width <= body_bottom:
            # Create stripe mask
            stripe_img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
            stripe_draw = ImageDraw.Draw(stripe_img)
            stripe_draw.rectangle([body_left, stripe_y, body_right, stripe_y + stripe_width], fill=black)
            
            # Mask with ellipse shape
            mask = Image.new('L', (size, size), 0)
            mask_draw = ImageDraw.Draw(mask)
            mask_draw.ellipse([body_left, body_top, body_right, body_bottom], fill=255)
            
            stripe_img.putalpha(mask)
            img.paste(stripe_img, (0, 0), stripe_img)
    
    # Head
    head_radius = body_radius // 2
    head_x = body_left - head_radius // 2
    draw.ellipse([head_x - head_radius, center_y - head_radius, 
                  head_x + head_radius, center_y + head_radius], fill=black)
    
    # Eyes
    eye_radius = head_radius // 3
    eye_y = center_y - head_radius // 3
    draw.ellipse([head_x - head_radius // 2 - eye_radius, eye_y - eye_radius,
                  head_x - head_radius // 2 + eye_radius, eye_y + eye_radius], fill=white)
    draw.ellipse([head_x + head_radius // 2 - eye_radius, eye_y - eye_radius,
                  head_x + head_radius // 2 + eye_radius, eye_y + eye_radius], fill=white)
    
    # Wings
    wing_width = body_radius
    wing_height = int(body_radius * 0.8)
    
    # Top wing
    wing_top_y = body_top - wing_height // 2
    draw.ellipse([center_x - wing_width // 4, wing_top_y - wing_height,
                  center_x + wing_width * 3 // 4, wing_top_y], 
                 fill=(255, 255, 255, 180), outline=black, width=max(1, size//100))
    
    # Bottom wing
    wing_bottom_y = body_bottom + wing_height // 2
    draw.ellipse([center_x - wing_width // 4, wing_bottom_y,
                  center_x + wing_width * 3 // 4, wing_bottom_y + wing_height], 
                 fill=(255, 255, 255, 180), outline=black, width=max(1, size//100))
    
    # Antennae
    antenna_length = head_radius
    antenna_start_x = head_x
    antenna_start_y = center_y - head_radius
    
    # Left antenna
    draw.line([antenna_start_x, antenna_start_y, 
               antenna_start_x - antenna_length // 2, antenna_start_y - antenna_length], 
              fill=black, width=max(1, size//50))
    draw.ellipse([antenna_start_x - antenna_length // 2 - 3, antenna_start_y - antenna_length - 3,
                  antenna_start_x - antenna_length // 2 + 3, antenna_start_y - antenna_length + 3], 
                 fill=black)
    
    # Right antenna
    draw.line([antenna_start_x, antenna_start_y, 
               antenna_start_x + antenna_length // 2, antenna_start_y - antenna_length], 
              fill=black, width=max(1, size//50))
    draw.ellipse([antenna_start_x + antenna_length // 2 - 3, antenna_start_y - antenna_length - 3,
                  antenna_start_x + antenna_length // 2 + 3, antenna_start_y - antenna_length + 3], 
                 fill=black)
    
    return img

def create_favicon():
    """Create favicon with multiple sizes"""
    sizes = [16, 32, 48, 64, 128, 256]
    images = []
    
    for size in sizes:
        img = create_wisbee_icon(size)
        images.append(img)
    
    # Save as ICO
    images[0].save('/Users/yuki/bench-llm/wisbee/favicon.ico', 
                   format='ICO', 
                   sizes=[(s, s) for s in sizes],
                   append_images=images[1:])
    
    # Also save individual PNGs for web
    for size in [16, 32, 192, 512]:
        img = create_wisbee_icon(size)
        img.save(f'/Users/yuki/bench-llm/wisbee/icon-{size}x{size}.png', 'PNG')
    
    # Apple touch icon
    apple_icon = create_wisbee_icon(180)
    apple_icon.save('/Users/yuki/bench-llm/wisbee/apple-touch-icon.png', 'PNG')

def create_ios_icons():
    """Create all required iOS app icon sizes"""
    ios_sizes = [
        (20, 1), (20, 2), (20, 3),  # Notification
        (29, 1), (29, 2), (29, 3),  # Settings
        (40, 1), (40, 2), (40, 3),  # Spotlight
        (60, 2), (60, 3),           # App
        (76, 1), (76, 2),           # iPad
        (83.5, 2),                  # iPad Pro
        (1024, 1)                   # App Store
    ]
    
    os.makedirs('/Users/yuki/bench-llm/wisbee/ios-icons', exist_ok=True)
    
    for base_size, scale in ios_sizes:
        size = int(base_size * scale)
        img = create_wisbee_icon(size)
        
        if scale == 1:
            filename = f'icon-{base_size}x{base_size}.png'
        else:
            filename = f'icon-{base_size}x{base_size}@{scale}x.png'
        
        img.save(f'/Users/yuki/bench-llm/wisbee/ios-icons/{filename}', 'PNG')

def create_macos_icons():
    """Create macOS .icns file"""
    mac_sizes = [16, 32, 64, 128, 256, 512, 1024]
    
    os.makedirs('/Users/yuki/bench-llm/wisbee/macos-icons', exist_ok=True)
    
    # Create individual PNGs
    for size in mac_sizes:
        img = create_wisbee_icon(size)
        img.save(f'/Users/yuki/bench-llm/wisbee/macos-icons/icon_{size}x{size}.png', 'PNG')
        
        # Also create @2x versions for Retina
        if size <= 512:
            img_2x = create_wisbee_icon(size * 2)
            img_2x.save(f'/Users/yuki/bench-llm/wisbee/macos-icons/icon_{size}x{size}@2x.png', 'PNG')

def main():
    print("🐝 Creating Wisbee icons...")
    
    # Create favicon and web icons
    print("Creating favicon and web icons...")
    create_favicon()
    
    # Create iOS icons
    print("Creating iOS app icons...")
    create_ios_icons()
    
    # Create macOS icons
    print("Creating macOS app icons...")
    create_macos_icons()
    
    print("✅ All icons created successfully!")
    print("\nFiles created:")
    print("- favicon.ico")
    print("- icon-16x16.png, icon-32x32.png, icon-192x192.png, icon-512x512.png")
    print("- apple-touch-icon.png")
    print("- ios-icons/ (all iOS sizes)")
    print("- macos-icons/ (all macOS sizes)")
    print("\nNext step: Use 'iconutil' to create .icns file from macOS PNGs")

if __name__ == "__main__":
    main()