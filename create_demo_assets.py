#!/usr/bin/env python3
"""
Wisbee デモアセット生成スクリプト
- OGP画像
- デモGIFアニメーション
- スクリーンショット
"""

import os
from PIL import Image, ImageDraw, ImageFont, ImageSequence
import numpy as np

def create_og_image():
    """OGP画像を生成"""
    # 1200x630の画像を作成
    img = Image.new('RGB', (1200, 630), color='#0a0a0a')
    draw = ImageDraw.Draw(img)
    
    # グラデーション背景を追加
    for i in range(630):
        color_intensity = int(255 * (1 - i / 630) * 0.1)
        color = (124 + color_intensity//2, 58 + color_intensity//2, 237 + color_intensity//2)
        draw.rectangle([(0, i), (1200, i+1)], fill=color)
    
    # テキストを追加
    try:
        # システムフォントを使用
        title_font = ImageFont.truetype("/System/Library/Fonts/ヒラギノ角ゴシック W6.ttc", 72)
        subtitle_font = ImageFont.truetype("/System/Library/Fonts/ヒラギノ角ゴシック W3.ttc", 36)
        emoji_font = ImageFont.truetype("/System/Library/Fonts/Apple Color Emoji.ttc", 120)
    except:
        # フォールバック
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
        emoji_font = ImageFont.load_default()
    
    # ロゴ
    draw.text((550, 100), "🐝", font=emoji_font, fill='white')
    
    # タイトル
    draw.text((150, 250), "Wisbee", font=title_font, fill='white')
    
    # サブタイトル
    draw.text((150, 350), "ChatGPTより安全・無料・オープンなAI", font=subtitle_font, fill='#a78bfa')
    
    # 特徴
    features = [
        "✅ 完全無料（月額料金なし）",
        "✅ プライバシー100%保護",
        "✅ オフライン動作可能",
        "✅ 制限なしで使い放題"
    ]
    
    y_pos = 450
    for feature in features:
        draw.text((150, y_pos), feature, font=subtitle_font, fill='white')
        y_pos += 40
    
    # ファイル保存
    os.makedirs('assets', exist_ok=True)
    img.save('assets/og-image.png', 'PNG', optimize=True)
    print("✅ OGP画像を生成しました: assets/og-image.png")

def create_demo_gif():
    """デモGIFアニメーションを生成"""
    frames = []
    
    # 10フレームのアニメーションを作成
    for frame_num in range(10):
        img = Image.new('RGB', (800, 600), color='#0a0a0a')
        draw = ImageDraw.Draw(img)
        
        # アニメーション効果
        offset = frame_num * 10
        
        # Wisbeeロゴアニメーション
        logo_y = 100 + np.sin(frame_num * 0.5) * 20
        draw.ellipse([(350, logo_y), (450, logo_y + 100)], fill='#7c3aed')
        
        # タイピングアニメーション
        text = "ChatGPTより高速・安全・無料"
        visible_chars = min(len(text), frame_num * 3)
        draw.text((200, 300), text[:visible_chars], fill='white', font=ImageFont.load_default())
        
        # プログレスバー
        progress = (frame_num + 1) / 10
        draw.rectangle([(100, 500), (700, 520)], outline='#7c3aed', width=2)
        draw.rectangle([(100, 500), (100 + 600 * progress, 520)], fill='#7c3aed')
        
        frames.append(img)
    
    # GIFとして保存
    frames[0].save(
        'assets/demo.gif',
        save_all=True,
        append_images=frames[1:],
        duration=200,
        loop=0,
        optimize=True
    )
    print("✅ デモGIFを生成しました: assets/demo.gif")

def create_comparison_image():
    """ChatGPTとの比較画像を生成"""
    img = Image.new('RGB', (1200, 800), color='white')
    draw = ImageDraw.Draw(img)
    
    # ヘッダー
    draw.rectangle([(0, 0), (1200, 100)], fill='#0a0a0a')
    draw.text((500, 30), "Wisbee vs ChatGPT", fill='white', font=ImageFont.load_default())
    
    # 比較表
    comparisons = [
        ("料金", "完全無料", "月額$20 (約3,000円)"),
        ("プライバシー", "100%ローカル処理", "クラウドにデータ送信"),
        ("速度", "2-5倍高速", "ネットワーク遅延あり"),
        ("制限", "無制限", "GPT-4は3時間40メッセージ"),
        ("オフライン", "完全対応", "インターネット必須")
    ]
    
    y_pos = 150
    for item, wisbee, chatgpt in comparisons:
        # 項目名
        draw.text((50, y_pos), item, fill='black', font=ImageFont.load_default())
        
        # Wisbee（緑）
        draw.rectangle([(300, y_pos - 5), (580, y_pos + 35)], fill='#10b981', outline='#10b981')
        draw.text((310, y_pos + 5), wisbee, fill='white', font=ImageFont.load_default())
        
        # ChatGPT（赤）
        draw.rectangle([(620, y_pos - 5), (900, y_pos + 35)], fill='#ef4444', outline='#ef4444')
        draw.text((630, y_pos + 5), chatgpt, fill='white', font=ImageFont.load_default())
        
        y_pos += 100
    
    img.save('assets/comparison.png', 'PNG', optimize=True)
    print("✅ 比較画像を生成しました: assets/comparison.png")

def create_banner_set():
    """各種バナー画像を生成"""
    sizes = [
        (728, 90, 'banner-728x90'),    # リーダーボード
        (300, 250, 'banner-300x250'),  # レクタングル
        (160, 600, 'banner-160x600'),  # ワイドスカイスクレイパー
        (320, 50, 'banner-320x50'),    # モバイルバナー
    ]
    
    for width, height, name in sizes:
        img = Image.new('RGB', (width, height), color='#7c3aed')
        draw = ImageDraw.Draw(img)
        
        # コンテンツを中央に配置
        if width > 300:
            draw.text((width//2 - 50, height//2 - 20), "Wisbee", fill='white', font=ImageFont.load_default())
            draw.text((width//2 - 100, height//2 + 10), "ChatGPTより安全・無料", fill='white', font=ImageFont.load_default())
        else:
            draw.text((10, height//2 - 10), "Wisbee", fill='white', font=ImageFont.load_default())
        
        img.save(f'assets/{name}.png', 'PNG', optimize=True)
    
    print("✅ バナーセットを生成しました")

if __name__ == "__main__":
    print("🎨 Wisbeeデモアセット生成を開始...")
    
    try:
        create_og_image()
        create_demo_gif()
        create_comparison_image()
        create_banner_set()
        
        print("\n✨ すべてのアセットの生成が完了しました！")
        print("📁 生成されたファイル:")
        for file in os.listdir('assets'):
            if file.endswith(('.png', '.gif')):
                print(f"   - assets/{file}")
                
    except Exception as e:
        print(f"❌ エラーが発生しました: {e}")
        print("Pillowをインストールしてください: pip install Pillow")