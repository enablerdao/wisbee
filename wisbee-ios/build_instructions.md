# Wisbee iOS App - ビルド手順

## 前提条件
- macOS 13.0以上
- Xcode 15.0以上
- iOS 16.0以上のデバイスまたはシミュレーター

## セットアップ手順

### 1. プロジェクトの作成

```bash
# 1. Xcodeを開く
# 2. Create New Project > iOS > App を選択
# 3. 以下の設定で作成:
#    - Product Name: Wisbee
#    - Team: Your Team
#    - Organization Identifier: com.enablerdao
#    - Interface: SwiftUI
#    - Language: Swift
#    - Use Core Data: No
#    - Include Tests: Yes
```

### 2. Swift Package Managerで依存関係を追加

Xcodeで:
1. File > Add Package Dependencies
2. 以下のURLを入力:
   ```
   https://github.com/StanfordSpezi/SpeziLLM
   ```
3. Version: Up to Next Major Version: 0.8.0
4. Add Package

### 3. ファイルの配置

作成したファイルを以下の構造で配置:
```
Wisbee/
├── WisbeeApp.swift
├── Views/
│   └── ContentView.swift
├── ViewModels/
│   └── ChatViewModel.swift
├── Models/
│   └── ChatMessage.swift
├── Services/
│   └── LLMRunner.swift
└── Info.plist
```

### 4. ビルド設定

1. プロジェクト設定を開く
2. Signing & Capabilities:
   - Team を選択
   - Bundle Identifier: com.enablerdao.wisbee
3. Deployment Info:
   - iOS 16.0+
   - iPhone, iPad にチェック

### 5. モデルファイルの準備（オプション）

ローカルでモデルを含める場合:
```bash
# モデルをダウンロード
curl -L -o qwen-0.6b.gguf \
  https://huggingface.co/TheBloke/Qwen1.5-0.5B-Chat-GGUF/resolve/main/qwen1_5-0_5b-chat-q4_k_m.gguf

# XcodeプロジェクトのResourcesフォルダに追加
```

### 6. ビルドと実行

```bash
# コマンドラインでビルド
xcodebuild -project Wisbee.xcodeproj \
           -scheme Wisbee \
           -sdk iphoneos \
           -configuration Release \
           clean build

# または Xcode で Cmd + R
```

## 既知の問題と解決策

### SpeziLLMがシミュレーターで動かない
- 実機でテストするか、別のLLMライブラリを使用

### Alternative: 直接llama.cppを使用

```bash
# llama.cppをクローン
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp

# iOS用にビルド
mkdir build-ios
cd build-ios
cmake .. -G Xcode \
  -DCMAKE_TOOLCHAIN_FILE=../cmake/ios.toolchain.cmake \
  -DPLATFORM=OS64 \
  -DLLAMA_METAL=ON
  
# Xcodeでビルド
open llama.cpp.xcodeproj
```

## デバッグ用の設定

1. Edit Scheme > Run > Arguments
2. Environment Variables に追加:
   ```
   LLAMA_DEBUG=1
   ```

## リリースビルド

1. Product > Archive
2. Distribute App > App Store Connect
3. Upload

詳細な手順は[Apple Developer Documentation](https://developer.apple.com/documentation/)を参照してください。