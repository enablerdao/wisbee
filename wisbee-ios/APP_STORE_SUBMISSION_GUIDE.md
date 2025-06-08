# Wisbee iOS App Store Submission Guide

## 📋 Pre-Submission Checklist

### ✅ Required Items
- [ ] Apple Developer Account ($99/year)
- [ ] Valid App ID (Bundle Identifier)
- [ ] Code Signing Certificates
- [ ] Provisioning Profiles
- [ ] App Icons (all required sizes)
- [ ] Launch Screen
- [ ] Screenshots for all supported devices
- [ ] App Store Connect account

### ✅ Technical Requirements
- [ ] iOS 16.0 minimum deployment target
- [ ] arm64 architecture support
- [ ] No private APIs usage
- [ ] Crash-free on all supported devices
- [ ] Network permissions properly configured

## 🎯 App Store Connect Metadata

### Basic Information
- **App Name**: Wisbee
- **Subtitle**: Local AI Chat Assistant
- **Primary Category**: Productivity
- **Secondary Category**: Utilities

### Pricing
- **Price**: Free
- **In-App Purchases**: None

### Age Rating
- **Age Rating**: 4+
- **Content Descriptions**: None applicable

### App Description (English)
```
Wisbee is a beautiful AI chat assistant that runs entirely on your iPhone. Chat with AI privately without internet connection, powered by advanced local language models.

Features:
• Beautiful dark UI with gradient animations
• Complete privacy - runs entirely offline
• Fast responses using optimized inference
• Connect to Mac for more powerful models
• Japanese language support

Perfect for:
- Private conversations with AI
- Learning and exploration
- Creative writing assistance
- Code generation help
- General Q&A

No subscription required. No data collection. Your conversations stay on your device.
```

### App Description (Japanese)
```
Wisbeeは、iPhone上で完全に動作する美しいAIチャットアシスタントです。インターネット接続なしで、プライベートにAIとチャットできます。

特徴：
• グラデーションアニメーションを使用した美しいダークUI
• 完全なプライバシー - オフラインで動作
• 最適化された推論による高速レスポンス
• Macに接続してより強力なモデルを使用
• 日本語完全対応

最適な用途：
- AIとのプライベートな会話
- 学習と探索
- 創造的な文章作成支援
- コード生成のヘルプ
- 一般的なQ&A

サブスクリプション不要。データ収集なし。会話はデバイス上に保存されます。
```

### Keywords
```
AI, Chat, Local, LLM, Private, Offline, Assistant, Japanese, 日本語, チャット, ローカル, プライベート, アシスタント
```

### Support Information
- **Support URL**: https://github.com/enablerdao/wisbee-ios/issues
- **Marketing URL**: https://github.com/enablerdao/wisbee-ios
- **Privacy Policy URL**: https://enablerdao.github.io/wisbee-privacy

### App Review Information
- **Demo Account**: Not required (local app)
- **Notes**: This app runs AI models locally on device. No server connection required except for optional Mac connectivity feature.

## 📸 Required Screenshots

### iPhone Screenshots (Required Sizes)
1. **6.9" Display** (1320 x 2868 px) - iPhone 16 Pro Max
2. **6.7" Display** (1290 x 2796 px) - iPhone 15 Pro Max  
3. **6.5" Display** (1284 x 2778 px) - iPhone 14 Plus
4. **6.1" Display** (1179 x 2556 px) - iPhone 15
5. **5.5" Display** (1242 x 2208 px) - iPhone 8 Plus

### iPad Screenshots (If Universal)
1. **12.9" Display** (2048 x 2732 px) - iPad Pro
2. **11" Display** (1668 x 2388 px) - iPad Pro

### Screenshot Content Suggestions
1. Main chat interface with conversation
2. Model selection/settings screen
3. Dark theme showcase
4. Japanese conversation example
5. Loading/initialization screen

## 🎨 App Icons Required

Create these icon sizes:
- 1024x1024 (App Store)
- 180x180 (iPhone @3x)
- 120x120 (iPhone @2x)
- 152x152 (iPad @2x)
- 167x167 (iPad Pro)
- 76x76 (iPad @1x)

## 🚀 Build Configuration

### Xcode Settings
```
Product Name: Wisbee
Bundle Identifier: com.enablerdao.wisbee
Version: 1.0.0
Build: 1
Deployment Target: iOS 16.0
Devices: iPhone, iPad
```

### Capabilities
- Background Modes (fetch, processing)
- Network (for Mac connectivity)

## 📝 Privacy & Compliance

### Privacy Policy Must Include
- No data collection statement
- Local processing only
- Optional network usage for Mac connectivity
- No third-party analytics
- No user tracking

### Export Compliance
- Uses standard encryption (HTTPS)
- Exempt from export requirements (ITSAppUsesNonExemptEncryption = NO)

## 🔧 Common Rejection Reasons to Avoid

1. **Incomplete functionality** - Ensure all features work
2. **Crashes** - Test on multiple devices
3. **Privacy issues** - Clear privacy policy required
4. **Performance** - App must be responsive
5. **Content** - Ensure AI responses are appropriate

## 📤 Submission Process

1. **Archive in Xcode**
   ```bash
   Product > Archive
   ```

2. **Validate Archive**
   - Window > Organizer
   - Select archive > Validate App

3. **Upload to App Store Connect**
   - Select archive > Distribute App
   - Choose "App Store Connect"

4. **Complete App Store Connect**
   - Add all metadata
   - Upload screenshots
   - Submit for review

## ⏱️ Timeline

- **Review Time**: 24-48 hours typically
- **First Submission**: May take longer
- **Expedited Review**: Available for critical issues

## 📞 Support Resources

- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)

---

Last Updated: June 2025