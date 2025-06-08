#!/usr/bin/env python3
"""
Create App Store screenshots for Wisbee
"""

from PIL import Image, ImageDraw, ImageFont
import os

# Device sizes for App Store screenshots
devices = {
    'iphone_6.9': (1320, 2868),  # iPhone 15 Pro Max
    'iphone_6.7': (1290, 2796),  # iPhone 15 Plus
    'iphone_6.5': (1284, 2778),  # iPhone 14 Pro Max
    'iphone_6.1': (1179, 2556),  # iPhone 15 Pro
    'iphone_5.5': (1242, 2208),  # iPhone 8 Plus
    'ipad_12.9': (2048, 2732),  # iPad Pro 12.9"
    'ipad_11': (1668, 2388),    # iPad Pro 11"
}

def create_gradient_background(size):
    """Create gradient background"""
    img = Image.new('RGB', size)
    draw = ImageDraw.Draw(img)
    
    for y in range(size[1]):
        progress = y / size[1]
        r = int(20 + (40 - 20) * progress)
        g = int(20 + (20 - 20) * progress)
        b = int(30 + (50 - 30) * progress)
        draw.rectangle([(0, y), (size[0], y+1)], fill=(r, g, b))
    
    return img

def draw_chat_interface(draw, size, font):
    """Draw chat interface mockup"""
    width, height = size
    
    # Header
    header_height = int(height * 0.1)
    draw.rectangle([(0, 0), (width, header_height)], fill=(30, 30, 40))
    
    # Title
    title = "Wisbee AI Chat"
    bbox = draw.textbbox((0, 0), title, font=font)
    text_width = bbox[2] - bbox[0]
    text_x = (width - text_width) // 2
    text_y = header_height // 2 - 20
    draw.text((text_x, text_y), title, fill=(255, 255, 255), font=font)
    
    # Chat bubbles
    bubble_y = header_height + 50
    bubble_margin = 40
    bubble_spacing = 30
    
    # User message
    user_msg = "AIアシスタントの使い方を教えて"
    bubble_width = int(width * 0.7)
    bubble_height = 80
    bubble_x = width - bubble_width - bubble_margin
    
    draw.rounded_rectangle(
        [(bubble_x, bubble_y), (bubble_x + bubble_width, bubble_y + bubble_height)],
        radius=20,
        fill=(67, 56, 202)
    )
    
    msg_bbox = draw.textbbox((0, 0), user_msg, font=font)
    msg_width = msg_bbox[2] - msg_bbox[0]
    msg_x = bubble_x + (bubble_width - msg_width) // 2
    msg_y = bubble_y + (bubble_height - 40) // 2
    draw.text((msg_x, msg_y), user_msg, fill=(255, 255, 255), font=font)
    
    # AI response
    bubble_y += bubble_height + bubble_spacing
    ai_msg = "こんにちは！私はWisbee AIです。"
    bubble_width = int(width * 0.8)
    bubble_height = 120
    
    draw.rounded_rectangle(
        [(bubble_margin, bubble_y), (bubble_margin + bubble_width, bubble_y + bubble_height)],
        radius=20,
        fill=(50, 50, 60)
    )
    
    # AI message with line breaks
    lines = [
        "こんにちは！私はWisbee AIです。",
        "どんなことでもお手伝いします。"
    ]
    
    line_y = bubble_y + 20
    for line in lines:
        draw.text((bubble_margin + 20, line_y), line, fill=(255, 255, 255), font=font)
        line_y += 40
    
    # Input field
    input_y = height - int(height * 0.15)
    input_margin = 30
    input_height = 60
    
    draw.rounded_rectangle(
        [(input_margin, input_y), (width - input_margin, input_y + input_height)],
        radius=30,
        fill=(40, 40, 50)
    )
    
    placeholder = "メッセージを入力..."
    draw.text((input_margin + 30, input_y + 15), placeholder, fill=(150, 150, 160), font=font)

def create_screenshot(device_name, size):
    """Create a screenshot for specific device"""
    img = create_gradient_background(size)
    draw = ImageDraw.Draw(img)
    
    # Try to load font
    try:
        font_size = int(size[1] * 0.02)
        font = ImageFont.truetype("/System/Library/Fonts/ヒラギノ角ゴシック W3.ttc", font_size)
    except:
        try:
            font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
        except:
            font = ImageFont.load_default()
    
    # Draw UI
    draw_chat_interface(draw, size, font)
    
    # Save
    os.makedirs('screenshots', exist_ok=True)
    filename = f'screenshots/{device_name}_screenshot.png'
    img.save(filename)
    print(f"Created {filename}")

# Create all screenshots
for device_name, size in devices.items():
    create_screenshot(device_name, size)

print("\nAll screenshots created in 'screenshots' folder!")
print("\nApp Store screenshot requirements:")
print("- Upload these to App Store Connect")
print("- At least one screenshot per device size is required")
print("- Recommended: 3-5 screenshots showing different features")