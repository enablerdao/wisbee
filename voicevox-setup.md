# VOICEVOX セットアップガイド

## VOICEVOXとは
VOICEVOXは無料で使える高品質な音声合成ソフトウェアで、アニメ風のキャラクターボイスを生成できます。

## インストール方法

### 1. VOICEVOXエンジンのダウンロード
[VOICEVOX公式サイト](https://voicevox.hiroshiba.jp/)から、お使いのOSに対応したバージョンをダウンロードしてください。

### 2. VOICEVOXの起動
- ダウンロードしたファイルを実行してインストール
- VOICEVOXを起動（デフォルトでポート50021で起動します）

### 3. 動作確認
```bash
# VOICEVOXが起動しているか確認
curl http://localhost:50021/version
```

## Enhanced Voice Serverでの使用方法

1. VOICEVOXを起動した状態で、enhanced-voice-server.pyを実行
```bash
python3 enhanced-voice-server.py
```

2. ブラウザでenhanced-voice-chat.htmlを開く

3. 音声選択で「アニメ音声 (VOICEVOX)」カテゴリから好きなキャラクターを選択

## 利用可能なキャラクター音声

- **ずんだもん**: 明るくかわいい声
- **春日部つむぎ**: 落ち着いた女性の声
- **九州そら**: 元気な女の子の声
- **四国めたん**: クールな女性の声
- **波音リツ**: ロボット風の声

## トラブルシューティング

### VOICEVOXに接続できない場合
1. VOICEVOXが起動しているか確認
2. ポート50021が使用されていないか確認
3. ファイアウォールの設定を確認

### 音声が再生されない場合
1. ブラウザの音声再生許可を確認
2. 音量設定を確認
3. 他のアプリケーションで音声が占有されていないか確認