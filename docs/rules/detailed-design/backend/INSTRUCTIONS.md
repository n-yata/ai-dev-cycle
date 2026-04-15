# バックエンド 詳細設計ガイド

バックエンドの詳細設計で記録・検討すべき内容のガイドラインです。

---

## 成果物

| 成果物 | テンプレート | 単位 |
|--------|-----------|------|
| データエンティティ関連図 | [entity-relationship.template.md](entity-relationship.template.md) | システム/機能群ごと |
| データエンティティ定義 | [entity-definition.template.md](entity-definition.template.md) | エンティティごと |
| API 一覧 | [api-list.template.md](api-list.template.md) | システム/機能群ごと |
| API 処理設計書 | [api-design.template.md](api-design.template.md) | API ごと |
| エラーコード一覧 | [error-codes.template.md](error-codes.template.md) | システム全体 |
| 外部連携 IF 定義 | [external-interface.template.md](external-interface.template.md) | 外部サービスごと |

---

## 設計の観点

### 1. API 設計

| 観点 | 内容 |
|------|------|
| RESTful 設計 | リソース指向の URL 設計、HTTP メソッドの適切な使用 |
| バージョニング | `/api/v1/` 等のバージョン管理方針 |
| レスポンス形式 | 成功・エラー時の JSON スキーマ統一 |
| 認証・認可 | JWT / Session / OAuth の方式と適用範囲 |

### 2. データモデル設計

| 観点 | 内容 |
|------|------|
| テーブル/コレクション設計 | エンティティ定義、正規化レベル |
| リレーション | 外部キー制約、インデックス設計 |
| マイグレーション | スキーマ変更の管理方法 |
| データ型 | 各フィールドの型・制約・デフォルト値 |

### 3. ビジネスロジック設計

| 観点 | 内容 |
|------|------|
| ユースケース | ビジネスルールの文書化 |
| バリデーション | 入力値の検証ルール |
| トランザクション | データ整合性が必要な処理の特定 |
| 非同期処理 | キュー、バッチ処理の設計 |

### 4. セキュリティ設計

| 観点 | 内容 |
|------|------|
| 認証フロー | ログイン・トークン更新・ログアウトのフロー |
| 認可ポリシー | ロールベースアクセス制御（RBAC）の設計 |
| 入力検証 | SQL インジェクション・XSS 対策 |
| 機密情報管理 | 環境変数・シークレット管理の方針 |

### 5. エラー設計

| 観点 | 内容 |
|------|------|
| エラーコード体系 | カテゴリ別の命名規則を統一する |
| エラーレスポンス形式 | JSON スキーマの統一 |
| クライアント連携 | フロントエンドがエラーコードで分岐できるよう設計する |

### 6. 外部連携設計

| 観点 | 内容 |
|------|------|
| IF 定義 | リクエスト/レスポンスのデータマッピング |
| 障害対策 | タイムアウト・リトライ・サーキットブレーカー |
| テスト方針 | モック/サンドボックス環境の利用方法 |

---

## 設計ドキュメントの保存場所

```
docs/artifacts/detailed-design/backend/{成果物名}.md
例: docs/artifacts/detailed-design/backend/entity-relationship.md
例: docs/artifacts/detailed-design/backend/users.md
例: docs/artifacts/detailed-design/backend/api-list.md
例: docs/artifacts/detailed-design/backend/create-user.md
例: docs/artifacts/detailed-design/backend/error-codes.md
例: docs/artifacts/detailed-design/backend/stripe.md
```

設計書は継続的に更新する。ファイル内の「最終更新」で履歴を管理する。
