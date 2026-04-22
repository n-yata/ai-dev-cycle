# プロジェクト共通ルール

## ドキュメント管理

### 設計書・実装計画の格納先

**設計書・実装計画は必ず `docs/artifacts/` のフェーズ別サブディレクトリに格納すること。`docs/artifacts/` 直下には絶対に置かない。**

- **各フェーズの規約・テンプレートは必ず `docs/rules/` を参照してから作成すること**
- 形式: Markdown（`.md`）
- タイミング: 設計・計画が固まった段階で即格納する（会話内だけに留めない）

| フェーズ | 格納先 | ルール参照先 |
|---------|--------|------------|
| 要件定義 | `docs/artifacts/0_requirements/` | `docs/rules/0_requirements/INSTRUCTIONS.md` |
| 基本設計 | `docs/artifacts/1_basic-design/` | `docs/rules/1_basic-design/INSTRUCTIONS.md` |
| 詳細設計 | `docs/artifacts/2_detailed-design/frontend/` or `backend/` | `docs/rules/2_detailed-design/INSTRUCTIONS.md` |
| 実装計画（進行中） | `docs/artifacts/3_implementation/plans/` | `docs/rules/3_implementation/INSTRUCTIONS.md` |
| 実装計画（完了済み） | `docs/artifacts/3_implementation/done/` | 実装完了後に `plans/` から移動する |
| 単体テスト | `docs/artifacts/4_unit-test/frontend/` or `backend/` | `docs/rules/4_unit-test/` |
| 結合テスト | `docs/artifacts/5_integration-test/frontend/` or `backend/` | `docs/rules/5_integration-test/` |

### 要件定義の成果物ルール（抜粋）

- ファイル名に日付は付けない（`todo-app.md`, `user-auth.md` 等）
- テンプレート: `docs/rules/0_requirements/template.md` を使用
- 詳細は `docs/rules/0_requirements/INSTRUCTIONS.md` を参照

### 基本設計の成果物ルール（抜粋）

- ファイル名に日付は付けない（`todo-app.md`, `user-auth.md` 等）
- テンプレート: `docs/rules/1_basic-design/template.md` を使用
- 詳細は `docs/rules/1_basic-design/INSTRUCTIONS.md` を参照

### 詳細設計の成果物ルール（抜粋）

- 成果物は**1ドキュメント1ファイル**（まとめて1ファイルにしない）
- ファイル名に日付は付けない（`api-list.md`, `entity-relationship.md` 等）
- テンプレート: `docs/rules/2_detailed-design/{frontend or backend}/*.template.md` を使用
- **カテゴリ別サブディレクトリに格納する**:

  | 対象 | 成果物 | 格納先 |
  |------|--------|--------|
  | FE | 画面遷移図（一覧） | `frontend/screen/` |
  | FE | 個別画面設計書 | `frontend/screen/screens/` |
  | BE | エンティティ関連図（一覧） | `backend/entity/` |
  | BE | 個別エンティティ定義 | `backend/entity/entities/` |
  | BE | API一覧 | `backend/api/` |
  | BE | 個別API処理設計書 | `backend/api/designs/` |
  | BE | エラーコード一覧 | `backend/error/` |
  | BE | 外部連携IF定義 | `backend/external/` |

- 詳細は `docs/rules/2_detailed-design/INSTRUCTIONS.md` を参照

## ウォーターフォール フェーズゲート管理

### 絶対に守ってください！

このプロジェクトはウォーターフォール開発を採用しています。  
**前工程が完了していない限り、次工程を開始してはいけません。**

### フェーズ進行の基本ルール

1. **フェーズ開始前に必ず `docs/artifacts/PHASE_STATUS.md` を確認すること**
   - 前フェーズのステータスが `COMPLETE` であることを確認する
   - `COMPLETE` でない場合は次フェーズを開始せず、シャビに報告する
2. **フェーズ開始時**: PHASE_STATUS.md のステータスを `IN_PROGRESS`、開始日を記入する
3. **フェーズ完了時**:
   - 完了チェックリストを全項目チェックする
   - シャビに完了報告し、承認を得る
   - 承認後、ステータスを `COMPLETE`、完了日を記入する
   - **ステータスを `COMPLETE` に更新したら、必ずコミットを実行する**
4. **フェーズ完了はシャビが承認して初めて確定する**（自己判断で `COMPLETE` にしない）

### フェーズ順序

```
フェーズ０: 要件定義  →  フェーズ①: 基本設計  →  フェーズ②: 詳細設計  →  フェーズ③: 実装  →  フェーズ④: 単体テスト  →  フェーズ⑤: 結合テスト
```

各フェーズの開始条件・完了チェックリストは `docs/artifacts/PHASE_STATUS.md` に定義されている。

### 前工程未完了時の対応

- 次フェーズの作業依頼があった場合、先に前フェーズの未完了項目をシャビに提示する
- シャビの明示的な指示がない限り、フェーズをスキップしない
- 例外（緊急対応など）はシャビの明示的な承認を得てから進める

---

## ナレッジ自動蓄積

### トリガーと動作

フックシステムにより `[KNOWLEDGE_TRIGGER]` メッセージが注入される。以下のタイミングで発火する:

| トリガー | 仕組み | タイミング |
|---------|--------|-----------|
| 10ターンごと | `UserPromptSubmit` フック | 会話が10往復に達した時点 |
| `/compact` 実行時 | `PreCompact` フック | compact 処理の直前 |
| `/clear` 実行時 | `UserPromptSubmit` フック | /clear コマンド検出時 |

### `[KNOWLEDGE_TRIGGER]` を受け取ったときの動作

1. **この会話で記録すべきナレッジがあるか判断する**
   - 設計判断・トレードオフの議論があった → `design-decisions/`
   - コードレビューで指摘パターンがあった → `review-findings/`
   - テストで発見したバグ・有効な手法があった → `test-patterns/`
   - フェーズの振り返り・教訓があった → `lessons-learned/`
2. **記録すべきものがあれば** カテゴリに応じたサブディレクトリに書き込む
   - テンプレート: `docs/rules/knowledge/template.md` を使用
   - ファイル名: `YYYYMMDD_短いタイトル.md`（例: `20260416_hook-system-design.md`）
   - 不要なセクションは省略してよい（概要・事実・理由・次回への示唆は必須）
   - **格納先（カテゴリ別）**:
     | カテゴリ | 格納先 | 対象 |
     |---------|--------|------|
     | design-decisions | `docs/knowledge/design-decisions/` | 設計判断・技術スタック選定・却下した選択肢 |
     | review-findings | `docs/knowledge/review-findings/` | コードレビューの指摘パターン |
     | test-patterns | `docs/knowledge/test-patterns/` | バグパターン・効果的なテスト手法 |
     | lessons-learned | `docs/knowledge/lessons-learned/` | フェーズ振り返り・教訓 |
   - **`docs/knowledge/` 直下には絶対に置かない**
3. **記録すべきものがなければスキップ**して通常の応答を続ける

### 記録すべきかの判断基準

以下のいずれかに該当すれば記録する:

- 次回また同じことで迷いそうな判断
- 気づきにくいバグや指摘
- 効果的だったテスト・設計手法
- チーム内で議論になった決定事項
- 公式ドキュメントに書かれていない実践的な知見

以下は記録しない:

- 公式ドキュメントに書いてあること
- コードを読めば自明な内容
- 一時的な作業メモ

### /clear 前の注意

`/clear` はローカルコマンドのため、フックで確実に捕捉できない場合がある。
ユーザーが `/clear` を実行する意思を示した場合、**ナレッジ書き込みを先に実行してから** `/clear` を案内すること。
