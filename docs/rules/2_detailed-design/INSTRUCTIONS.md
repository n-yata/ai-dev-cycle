# フェーズ① 詳細設計（detailed-design）

実装を開始する前に、コンポーネント・API・データ構造を文書化するフェーズです。  
設計の曖昧さを解消し、チーム全員が共通認識を持った状態で実装に入ることを目的とします。

---

## このフェーズの目的

- 実装方針の合意形成
- 仕様の抜け漏れ・矛盾の早期発見
- レビュー・引き継ぎのための記録作成

---

## 成果物一覧

### フロントエンド

| # | 成果物 | テンプレート | 単位 | 説明 |
|---|--------|-----------|------|------|
| 1 | 画面遷移図 | [screen-flow.template.md](frontend/screen-flow.template.md) | アプリ/機能群ごと | 画面間の遷移とルーティングの全体像 |
| 2 | 画面設計書 | [screen-design.template.md](frontend/screen-design.template.md) | 画面ごと | 各画面のレイアウト・コンポーネント・状態管理 |

### バックエンド

| # | 成果物 | テンプレート | 単位 | 説明 |
|---|--------|-----------|------|------|
| 3 | データエンティティ関連図 | [entity-relationship.template.md](backend/entity-relationship.template.md) | システム/機能群ごと | エンティティ間のリレーション全体像 |
| 4 | データエンティティ定義 | [entity-definition.template.md](backend/entity-definition.template.md) | エンティティごと | テーブル定義・カラム・制約・インデックス |
| 5 | API 一覧 | [api-list.template.md](backend/api-list.template.md) | システム/機能群ごと | 全エンドポイントの一覧と共通仕様 |
| 6 | API 処理設計書 | [api-design.template.md](backend/api-design.template.md) | API ごと | 各 API の詳細な処理フロー・IF 定義 |
| 7 | エラーコード一覧 | [error-codes.template.md](backend/error-codes.template.md) | システム全体 | エラーコードの命名規則と定義 |
| 8 | 外部連携 IF 定義 | [external-interface.template.md](backend/external-interface.template.md) | 外部サービスごと | 外部 API との接続・データマッピング |

---

## ディレクトリ構成

```
rules/detailed-design/        # ルール・テンプレート（ここ）
├── INSTRUCTIONS.md
├── frontend/
│   ├── INSTRUCTIONS.md
│   ├── screen-flow.template.md
│   └── screen-design.template.md
└── backend/
    ├── INSTRUCTIONS.md
    ├── entity-relationship.template.md
    ├── entity-definition.template.md
    ├── api-list.template.md
    ├── api-design.template.md
    ├── error-codes.template.md
    └── external-interface.template.md

artifacts/detailed-design/    # 成果物の出力先
├── frontend/
│   └── screen/
│       ├── screen-flow.md        # 画面遷移図（一覧）
│       └── screens/              # 個別画面設計書
│           ├── {画面名}.md
│           └── ...
└── backend/
    ├── entity/
    │   ├── entity-relationship.md  # エンティティ関連図（一覧）
    │   └── entities/               # 個別エンティティ定義
    │       ├── {エンティティ名}.md
    │       └── ...
    ├── api/
    │   ├── api-list.md             # API一覧
    │   └── designs/                # 個別API処理設計書
    │       ├── {api名}.md
    │       └── ...
    ├── error/                      # エラーコード一覧
    └── external/                   # 外部連携IF定義
```

---

## 詳細設計ドキュメントの作成手順

1. 対象の成果物に応じたテンプレートをコピーする
2. `docs/artifacts/detailed-design/` 配下に保存する（命名規則は下記参照）
3. テンプレートの各セクションを埋める
4. チームレビューを実施する
5. 承認後、実装フェーズへ移行する
6. 仕様変更があれば既存ファイルを直接更新する（ファイル内の「最終更新」を変更する）

### ファイル命名規則

設計書は継続的に更新するため、ファイル名に日付は付けない。

| 成果物 | ファイル名 | 例 |
|--------|----------|-----|
| 画面遷移図 | `screen-flow.md` | 1ファイル/機能群 |
| 画面設計書 | `{画面名}.md` | `login.md`, `dashboard.md` |
| エンティティ関連図 | `entity-relationship.md` | 1ファイル/機能群 |
| エンティティ定義 | `{エンティティ名}.md` | `users.md`, `orders.md` |
| API 一覧 | `api-list.md` | 1ファイル/機能群 |
| API 処理設計書 | `{API名}.md` | `create-user.md`, `get-orders.md` |
| エラーコード一覧 | `error-codes.md` | 1ファイル/システム |
| 外部連携 IF 定義 | `{サービス名}.md` | `stripe.md`, `sendgrid.md` |

---

## チェックリスト

設計ドキュメントが以下の観点を満たしているか確認してください。

- [ ] 機能の目的・背景が明記されている
- [ ] 対象スコープが明確に定義されている
- [ ] フロントエンド・バックエンド間のインターフェース（API仕様）が合意されている
- [ ] エラーケース・例外処理が検討されている
- [ ] セキュリティ要件が考慮されている
- [ ] エラーコードが一覧に定義されている
- [ ] 外部連携がある場合、IF 定義が作成されている
- [ ] レビュアーの承認を得ている

---

## 各観点の詳細

- [フロントエンド詳細設計](frontend/INSTRUCTIONS.md)
- [バックエンド詳細設計](backend/INSTRUCTIONS.md)

---

## 利用可能な MCP ツール

| ツール | 用途 | 使うタイミング |
|--------|------|--------------|
| `sequential-thinking` | 複雑な設計判断の構造化推論 | API 設計・データモデル・コンポーネント構成で複数案を比較検討するとき |
| `fetch` | ライブラリ仕様・外部 API ドキュメントの参照 | 外部サービスとの連携仕様や、使用ライブラリの最新 API を確認するとき |

---

## ナレッジからの追加ルール

<!-- このセクションは /reflect-knowledge コマンドにより自動追記されます -->

### サブエージェント委譲時のテンプレート規約遵守（2026-04-16）

> 出典: `docs/knowledge/reflected/lessons-learned/20260416_subagent-delegation-template-compliance.md`

**Do:**
- サブエージェントへのドキュメント作成指示には、使用するテンプレートのパスを必ず明記する
- 「テンプレートの構造（セクション・表形式・図）を必ず維持すること」と明示する
- 作成ファイルと対応テンプレートの対応表を指示に含める
- 委譲前に `docs/rules/` の該当 INSTRUCTIONS を自分で確認してから指示を書く

**Don't:**
- 「設計書を作って」「詳細設計を作って」だけの曖昧な指示でサブエージェントに委譲しない
- CLAUDE.md にルールを追記する際、既存の `docs/rules/` との整合性を確認せずに書かない
