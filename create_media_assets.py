#!/usr/bin/env python3
"""
Wisbee メディア素材自動生成スクリプト
高品質なプレス用画像、比較チャート、ロゴを生成
"""

import os
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from PIL import Image, ImageDraw, ImageFont
import seaborn as sns

# 設定
plt.style.use('dark_background')
sns.set_palette("husl")

# ディレクトリ作成
os.makedirs('assets/press', exist_ok=True)
os.makedirs('assets/logos', exist_ok=True)
os.makedirs('assets/charts', exist_ok=True)

def create_performance_comparison():
    """性能比較チャート生成"""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 8))
    fig.patch.set_facecolor('#0a0a0a')
    
    # 速度比較
    models = ['ChatGPT\nGPT-4', 'ChatGPT\nGPT-3.5', 'Wisbee\nllama3.2:1b', 'Wisbee\nqwen3:1.7b']
    speeds = [15, 40, 54.3, 52.05]
    colors = ['#ef4444', '#f97316', '#10b981', '#06b6d4']
    
    bars1 = ax1.bar(models, speeds, color=colors, alpha=0.8)
    ax1.set_title('処理速度比較 (tokens/秒)', fontsize=16, color='white', pad=20)
    ax1.set_ylabel('tokens/秒', fontsize=12, color='white')
    ax1.tick_params(colors='white')
    
    # 値をバーの上に表示
    for bar, speed in zip(bars1, speeds):
        height = bar.get_height()
        ax1.text(bar.get_x() + bar.get_width()/2., height + 1,
                f'{speed}', ha='center', va='bottom', color='white', fontweight='bold')
    
    # Wisbeeの優位性を強調
    ax1.annotate('3.6倍高速!', xy=(2, 54.3), xytext=(2.5, 65),
                arrowprops=dict(arrowstyle='->', color='#f59e0b', lw=2),
                fontsize=14, color='#f59e0b', fontweight='bold')
    
    # コスト比較
    services = ['ChatGPT\nPlus', 'Wisbee']
    costs = [36000, 0]
    colors_cost = ['#ef4444', '#10b981']
    
    bars2 = ax2.bar(services, costs, color=colors_cost, alpha=0.8)
    ax2.set_title('年間コスト比較 (円)', fontsize=16, color='white', pad=20)
    ax2.set_ylabel('年間コスト (円)', fontsize=12, color='white')
    ax2.tick_params(colors='white')
    
    # 値をバーの上に表示
    for bar, cost in zip(bars2, costs):
        height = bar.get_height()
        if cost == 0:
            ax2.text(bar.get_x() + bar.get_width()/2., height + 1000,
                    '無料!', ha='center', va='bottom', color='white', fontweight='bold', fontsize=14)
        else:
            ax2.text(bar.get_x() + bar.get_width()/2., height + 1000,
                    f'¥{cost:,}', ha='center', va='bottom', color='white', fontweight='bold')
    
    # 節約効果を強調
    ax2.annotate('36,000円\n節約!', xy=(1, 0), xytext=(0.3, 20000),
                arrowprops=dict(arrowstyle='->', color='#f59e0b', lw=2),
                fontsize=14, color='#f59e0b', fontweight='bold', ha='center')
    
    plt.tight_layout()
    plt.savefig('assets/charts/performance_comparison.png', dpi=300, bbox_inches='tight', 
                facecolor='#0a0a0a', edgecolor='none')
    plt.savefig('assets/charts/performance_comparison_4k.png', dpi=600, bbox_inches='tight',
                facecolor='#0a0a0a', edgecolor='none')
    plt.close()

def create_feature_comparison():
    """機能比較表生成"""
    fig, ax = plt.subplots(figsize=(12, 8))
    fig.patch.set_facecolor('#0a0a0a')
    
    features = ['月額料金', '処理速度', 'プライバシー', '使用制限', 'オフライン', 'データ収集']
    wisbee_scores = [10, 9, 10, 10, 10, 10]  # 10点満点
    chatgpt_scores = [2, 6, 3, 4, 0, 2]
    
    x = np.arange(len(features))
    width = 0.35
    
    bars1 = ax.bar(x - width/2, wisbee_scores, width, label='Wisbee', 
                   color='#10b981', alpha=0.8)
    bars2 = ax.bar(x + width/2, chatgpt_scores, width, label='ChatGPT Plus', 
                   color='#ef4444', alpha=0.8)
    
    ax.set_title('機能比較 (10点満点)', fontsize=16, color='white', pad=20)
    ax.set_ylabel('スコア', fontsize=12, color='white')
    ax.set_xticks(x)
    ax.set_xticklabels(features, rotation=45, ha='right', color='white')
    ax.tick_params(colors='white')
    ax.legend()
    ax.set_ylim(0, 11)
    
    # スコアを表示
    for bar in bars1:
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height + 0.1,
                f'{int(height)}', ha='center', va='bottom', color='white', fontweight='bold')
    
    for bar in bars2:
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height + 0.1,
                f'{int(height)}', ha='center', va='bottom', color='white', fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('assets/charts/feature_comparison.png', dpi=300, bbox_inches='tight',
                facecolor='#0a0a0a', edgecolor='none')
    plt.close()

def create_logo_variations():
    """ロゴバリエーション生成"""
    sizes = [128, 256, 512, 1024]
    
    for size in sizes:
        # 基本ロゴ（蜂アイコン + Wisbeeテキスト）
        img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        
        # 背景円（グラデーション風）
        circle_size = int(size * 0.8)
        circle_pos = (size - circle_size) // 2
        
        # 蜂の絵文字は複雑なので、シンプルな幾何学的デザインで代替
        draw.ellipse([circle_pos, circle_pos, circle_pos + circle_size, circle_pos + circle_size],
                    fill='#f59e0b', outline='#dc8a0a', width=2)
        
        # 中央に 'W' または 'B' を描画
        try:
            font_size = int(size * 0.4)
            font = ImageFont.truetype("/System/Library/Fonts/Arial.ttf", font_size)
        except:
            font = ImageFont.load_default()
            
        text = "🐝"
        bbox = draw.textbbox((0, 0), text, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        text_x = (size - text_width) // 2
        text_y = (size - text_height) // 2
        
        draw.text((text_x, text_y), text, fill='white', font=font)
        
        img.save(f'assets/logos/wisbee_logo_{size}x{size}.png')
        
        # 角丸正方形版
        img_square = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        draw_square = ImageDraw.Draw(img_square)
        
        # 角丸長方形
        corner_radius = size // 8
        draw_square.rounded_rectangle([0, 0, size, size], 
                                    radius=corner_radius, 
                                    fill='#f59e0b', 
                                    outline='#dc8a0a', 
                                    width=2)
        
        draw_square.text((text_x, text_y), text, fill='white', font=font)
        img_square.save(f'assets/logos/wisbee_logo_square_{size}x{size}.png')

def create_infographic():
    """インフォグラフィック生成"""
    fig, ax = plt.subplots(figsize=(12, 16))
    fig.patch.set_facecolor('#0a0a0a')
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 20)
    ax.axis('off')
    
    # タイトル
    ax.text(5, 19, 'Wisbee vs ChatGPT', fontsize=24, color='white', 
            ha='center', fontweight='bold')
    ax.text(5, 18.5, '完全比較ガイド', fontsize=16, color='#f59e0b', ha='center')
    
    # セクション1: 速度
    ax.add_patch(mpatches.Rectangle((0.5, 15), 9, 2.5, 
                                   facecolor='#1a1a1a', edgecolor='#f59e0b', linewidth=2))
    ax.text(5, 16.8, '⚡ 処理速度', fontsize=18, color='#f59e0b', ha='center', fontweight='bold')
    ax.text(2.5, 16.2, 'Wisbee: 54.3 tok/s', fontsize=14, color='#10b981', ha='center')
    ax.text(7.5, 16.2, 'ChatGPT: 15 tok/s', fontsize=14, color='#ef4444', ha='center')
    ax.text(5, 15.6, '🏆 Wisbeeが3.6倍高速', fontsize=16, color='white', ha='center', fontweight='bold')
    
    # セクション2: コスト
    ax.add_patch(mpatches.Rectangle((0.5, 12), 9, 2.5, 
                                   facecolor='#1a1a1a', edgecolor='#f59e0b', linewidth=2))
    ax.text(5, 13.8, '💰 年間コスト', fontsize=18, color='#f59e0b', ha='center', fontweight='bold')
    ax.text(2.5, 13.2, 'Wisbee: ¥0', fontsize=14, color='#10b981', ha='center')
    ax.text(7.5, 13.2, 'ChatGPT: ¥36,000', fontsize=14, color='#ef4444', ha='center')
    ax.text(5, 12.6, '🏆 36,000円の節約効果', fontsize=16, color='white', ha='center', fontweight='bold')
    
    # セクション3: プライバシー
    ax.add_patch(mpatches.Rectangle((0.5, 9), 9, 2.5, 
                                   facecolor='#1a1a1a', edgecolor='#f59e0b', linewidth=2))
    ax.text(5, 10.8, '🔒 プライバシー', fontsize=18, color='#f59e0b', ha='center', fontweight='bold')
    ax.text(2.5, 10.2, 'Wisbee: 100%ローカル', fontsize=14, color='#10b981', ha='center')
    ax.text(7.5, 10.2, 'ChatGPT: クラウド送信', fontsize=14, color='#ef4444', ha='center')
    ax.text(5, 9.6, '🏆 データ漏洩リスクゼロ', fontsize=16, color='white', ha='center', fontweight='bold')
    
    # 結論
    ax.add_patch(mpatches.Rectangle((1, 6), 8, 2, 
                                   facecolor='#f59e0b', edgecolor='white', linewidth=2))
    ax.text(5, 7.5, '🐝 結論', fontsize=20, color='white', ha='center', fontweight='bold')
    ax.text(5, 6.8, 'Wisbeeが圧倒的優位', fontsize=16, color='white', ha='center')
    ax.text(5, 6.4, '高速・無料・プライベート', fontsize=16, color='white', ha='center')
    
    # ダウンロードCTA
    ax.text(5, 5, '今すぐダウンロード: wisbee.ai', fontsize=14, color='#f59e0b', 
            ha='center', fontweight='bold')
    
    plt.savefig('assets/press/wisbee_infographic.png', dpi=300, bbox_inches='tight',
                facecolor='#0a0a0a', edgecolor='none')
    plt.close()

def create_timeline():
    """開発タイムライン生成"""
    fig, ax = plt.subplots(figsize=(14, 8))
    fig.patch.set_facecolor('#0a0a0a')
    
    dates = ['2024年3月', '2024年8月', '2024年12月', '2025年6月']
    events = ['プロジェクト\n開始', 'プロトタイプ\n完成', 'ベータ版\nリリース', '正式版\n公開']
    
    # タイムライン描画
    ax.plot([0, 1, 2, 3], [0, 0, 0, 0], 'o-', color='#f59e0b', linewidth=3, markersize=12)
    
    for i, (date, event) in enumerate(zip(dates, events)):
        ax.text(i, 0.3, event, ha='center', fontsize=12, color='white', fontweight='bold')
        ax.text(i, -0.3, date, ha='center', fontsize=10, color='#f59e0b')
    
    ax.set_xlim(-0.5, 3.5)
    ax.set_ylim(-0.8, 0.8)
    ax.set_title('Wisbee 開発タイムライン', fontsize=18, color='white', pad=20)
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('assets/press/development_timeline.png', dpi=300, bbox_inches='tight',
                facecolor='#0a0a0a', edgecolor='none')
    plt.close()

def main():
    """メイン実行関数"""
    print("🎨 Wisbee メディア素材を生成中...")
    
    try:
        create_performance_comparison()
        print("✅ 性能比較チャート生成完了")
        
        create_feature_comparison()
        print("✅ 機能比較表生成完了")
        
        create_logo_variations()
        print("✅ ロゴバリエーション生成完了")
        
        create_infographic()
        print("✅ インフォグラフィック生成完了")
        
        create_timeline()
        print("✅ タイムライン生成完了")
        
        print("\n🎉 すべてのメディア素材の生成が完了しました!")
        print("📁 生成されたファイル:")
        print("   - assets/charts/ (比較チャート)")
        print("   - assets/logos/ (ロゴファイル)")
        print("   - assets/press/ (プレス用素材)")
        
    except Exception as e:
        print(f"❌ エラーが発生しました: {e}")
        print("必要なライブラリをインストールしてください:")
        print("pip install matplotlib seaborn pillow numpy")

if __name__ == "__main__":
    main()