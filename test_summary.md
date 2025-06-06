# Ollama モデルテスト結果サマリー

## 実行日時: 2025年6月6日

### 🚀 クイック3問テスト (5秒で完了)

| モデル | Q1: 2+2=? | Q2: 日本の首都? | Q3: Hello=? | スコア |
|--------|-----------|----------------|-------------|--------|
| gemma3:4b | ❌ | ✅ 東京 | ❌ | 1/3 (33%) |
| jaahas/qwen3-abliterated:0.6b | ❌ | ❌ | ❌ | 0/3 (0%) |

**実行時間**: 5秒

### 📊 分析

1. **gemma3:4b**
   - 日本語の理解は良好（「日本の首都」に正解）
   - 単純な算数問題で不完全な応答
   - より多くのトークン数が必要な可能性

2. **jaahas/qwen3-abliterated:0.6b**
   - `<think>` タグを出力する問題
   - 0.6Bの小型モデルのため精度が低い
   - プロンプトの調整が必要

### 🔧 改善提案

1. **トークン数の調整**
   - 現在: 5-10トークン → 推奨: 20-30トークン

2. **プロンプトエンジニアリング**
   - システムプロンプトの追加
   - Few-shot例の提供

3. **モデル選択**
   - gemma3:4b が最も安定
   - 小型モデルは速度重視の場合のみ使用

### 📈 推奨設定

```bash
# 高精度設定
{
  "model": "gemma3:4b",
  "options": {
    "temperature": 0.1,
    "num_predict": 30,
    "top_p": 0.9
  }
}
```