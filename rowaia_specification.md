# リモート勤務オフィスワーカー向け汎用AIエージェント更新版仕様書

## 全体概要

Rowaia（ロワイア）は、リモート勤務オフィスワーカーの業務効率化を支援するAIエージェントシステムです。OODAループ（Observe-Orient-Decide-Act）の原則に基づき、情報収集から分析、意思決定、実行までを自動化します。Fluentdプラグインとローカルで動作するLLMを組み合わせ、プライバシーを保護しながら高度な情報処理を実現します。

本システムは4つのフェーズで構成され、2つの独立したFluentdプロセスとして実行されます：
1. Observe（観察）～Orient（状況判断）プロセス - 情報収集と状況把握
2. Decide（意思決定）～Act（実行）プロセス - 優先順位付けと行動喚起

システムの特徴：
- 完全オフライン処理によるプライバシー保護
- Fluentdプラグインによる拡張性の高さ
- OODAループに基づく効率的な業務サイクル
- 最小構成での迅速な実装と拡張性

---

## Observe（観察）〜Orient（状況判断）プロセス仕様書

### 1. 基本設計

Observe～Orientフェーズは、情報の収集と分析を担当します。このプロセスでは以下を実行します：
- Obsidianノートや各種情報源からデータを収集
- 収集した情報をバッファリングして整理
- LLMを使用して情報を要約・分析
- 分析結果を次のプロセスのために保存

### 2. アーキテクチャ

```
[情報源] → [in_exec] → [バッファリング] → [out_context/LLM処理] → [ファイル出力]
```

### 3. 使用プラグイン

#### 3.1 情報収集プラグイン
- **タイプ**: `exec`（Fluentd標準プラグイン）
- **役割**: 外部コマンドを実行して情報を取得
- **動作間隔**: 30分ごと

#### 3.2 情報処理プラグイン
- **タイプ**: `context`（カスタムプラグイン）
- **役割**: 収集情報のバッファリング、LLMによる要約処理
- **使用モデル**: Ollama経由のローカルLLM
- **出力形式**: タグ名をファイル名としたテキストファイル

### 4. データフロー

1. `in_exec`プラグインがObsidianノートを読み込み
2. 読み込まれた情報は`tag`で「観察」として識別
3. 情報は30分間バッファリングされ、累積
4. バッファ期間終了後にLLMが情報を要約処理
5. 要約結果は指定ディレクトリに保存（タグ名=ファイル名）

### 5. コンフィグレーション

```
# Observe & Orient Configuration

<source>
  @type exec
  command cat /Users/bash/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/ObsidianVault/2025/*
  format none
  tag observation
  run_interval 1800s  # 30分間隔
</source>

<match observation>
  @type context
  
  <buffer tag>
    @type memory
    timekey 1800  # 30分バッファリング
    timekey_wait 10s
    flush_at_shutdown true
  </buffer>
  
  output_path /tmp/fluentd/context
  model_name hf.co/elyza/Llama-3-ELYZA-JP-8B-GGUF:latest
  api_url http://localhost:11434/api
</match>
```

### 6. LLM処理

- **プロンプト**: 「以下のテキストを、文意を損ねぬよう情報量を保ったまま要約してください」
- **モデル**: Ollamaで動作するローカルLLM（ELYZA-japanese-Llama）
- **パラメータ**:
  - temperature: 0.6（低めに設定し一貫性を向上）
  - top_p: 0.88（文脈関連性の向上）
  - top_k: 40（語彙選択の制限）
  - その他最適化パラメータ

### 7. カスタマイズポイント

- 情報源の追加（Slack、メール、カレンダーなど）
- 分析プロンプトのカスタマイズ
- 処理間隔の変更（短縮・延長）
- 出力ファイルの保存形式・保存場所の変更

---

## Decide（意思決定）〜Act（実行）プロセス仕様書

### 1. 基本設計

Decide～Actフェーズは、分析された情報に基づく意思決定と実行を担当します。このプロセスでは以下を実行します：
- Orientフェーズで生成された分析結果を読み込み
- LLMを使用して情報のトリアージと優先順位付け
- 重要度に応じた対応策の決定
- ユーザーへの視覚的通知

### 2. アーキテクチャ

```
[分析ファイル] → [in_context] → [filter_llm_generate] → [out_sstp] → [デスクトップ通知]
```

### 3. 使用プラグイン

#### 3.1 情報読み込みプラグイン
- **タイプ**: `context`（カスタムプラグイン）
- **役割**: Orientフェーズの出力ファイルを読み込み
- **動作間隔**: 30分ごと

#### 3.2 LLM処理プラグイン
- **タイプ**: `llm_generate`（GitHub: bash0C7/fluent-plugin-llm-generate）
- **役割**: 情報のトリアージと優先順位付け
- **使用モデル**: Ollama経由のローカルLLM

#### 3.3 通知プラグイン
- **タイプ**: `sstp`（GitHub: bash0C7/fluent-plugin-sstp）
- **役割**: SSTPプロトコルを使用したデスクトップ通知
- **表示方法**: SSP等のデスクトップアシスタント

### 4. データフロー

1. `in_context`プラグインがOrientフェーズの出力ファイルを読み込み
2. 読み込まれた情報は`tag`で「意思決定」として識別
3. `filter_llm_generate`によるLLM処理でトリアージ実行：
   - 重要度1（赤）：緊急対応が必要
   - 重要度2（黄）：重要だが時間的猶予あり
   - 重要度3（緑）：通常優先度
   - 重要度4（黒）：低優先度または情報のみ
4. トリアージ結果がレコードに追加
5. `out_sstp`プラグインによりSSTPプロトコルで通知
6. デスクトップアシスタントに視覚的に表示

### 5. コンフィグレーション

```
# Decide & Act Configuration

<source>
  @type context
  path /tmp/fluentd/context
  tag decision
  run_interval 1800s  # 30分間隔
</source>

<filter decision>
  @type llm_generate
  model_name hf.co/elyza/Llama-3-ELYZA-JP-8B-GGUF:latest
  api_url http://localhost:11434/api
  prompt |
    Below is information from various sources that needs to be triaged.
    
    <%= record["message"] %>
    
    Please categorize the priority as:
    1:red - Critical and requires immediate attention
    2:yellow - Important but not time-sensitive
    3:green - Normal priority, handle as scheduled
    4:black - Low priority or informational only
    
    Explain your reasoning for this categorization and provide specific next actions.
</filter>

<match decision>
  @type sstp
  sstp_server 127.0.0.1
  sstp_port 9801
  request_method NOTIFY
  request_version SSTP/1.1
  sender Rowaia
  option nodescript,notranslate
  script_template \h\s[8]<%= record["llm_output"] %> \uHow would you like to proceed?\e
  
  <buffer>
    @type memory
    flush_mode immediate
  </buffer>
</match>
```

### 6. LLM処理

- **プロンプト**: トリアージ用テンプレート（重要度判定と次のアクション提案）
- **モデル**: Ollamaで動作するローカルLLM（ELYZA-japanese-Llama）
- **出力フィールド**: `llm_output`（SSTPメッセージ作成に使用）

### 7. 通知システム

- **プロトコル**: SSTP（Sakura Script Transfer Protocol）
- **クライアント**: SSP等のSSTP対応デスクトップアシスタント
- **通知フォーマット**: サクラスクリプト形式
- **対話機能**: 「どのように進めますか？」等のフォローアップメッセージ

### 8. カスタマイズポイント

- トリアージ基準のカスタマイズ
- 通知テンプレートの変更
- アクション種別の追加（Slackメッセージ、メール送信など）
- デスクトップアシスタントのキャラクター変更

---

## 拡張案と今後の展望

### 1. 情報ソースの拡張
- Slack連携プラグインの実装
- メール取得プラグインの実装
- 会議議事録自動処理の追加
- ファイル変更監視の実装

### 2. 処理機能の拡張
- 自然言語クエリによる情報検索
- 特定キーワードの自動監視と優先通知
- 行動履歴の学習と改善提案
- タスク進捗の自動追跡

### 3. アクション機能の拡張
- Slack/Teams自動返信
- メール下書き作成
- カレンダー予定調整提案
- 議事録/報告書の自動生成

### 4. UI/UX改善
- Web管理インターフェース
- モバイル通知対応
- 設定可視化ツール
- 優先度設定の学習機能

このシステムは最小構成として設計されていますが、各コンポーネントはモジュール式で、必要に応じて機能拡張が可能です。Fluentdのプラグイン機構と外部ツール連携により、リモートワークにおける情報過多とタスク管理の課題を解決します。