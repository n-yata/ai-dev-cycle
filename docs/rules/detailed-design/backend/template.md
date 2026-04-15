# [機能名] バックエンド詳細設計

| 項目 | 内容 |
|------|------|
| 作成日 | YYYY-MM-DD |
| 作成者 | 氏名 |
| 最終更新 | YYYY-MM-DD |
| ステータス | 草稿 / レビュー中 / 承認済み |

---

## 1. 概要

### 1.1 目的・背景

> この機能を実装する目的と、なぜ今必要なのかを記述する。

### 1.2 スコープ

**対象:**
- 

**対象外:**
- 

---

## 2. API設計

### 2.1 エンドポイント一覧

| メソッド | パス | 説明 | 認証 |
|---------|------|------|------|
| GET | `/api/v1/resources` | リソース一覧取得 | Bearer Token |
| GET | `/api/v1/resources/:id` | リソース詳細取得 | Bearer Token |
| POST | `/api/v1/resources` | リソース作成 | Bearer Token |
| PUT | `/api/v1/resources/:id` | リソース更新 | Bearer Token |
| DELETE | `/api/v1/resources/:id` | リソース削除 | Bearer Token |

### 2.2 リクエスト仕様

#### `POST /api/v1/resources`

**Headers:**
```
Content-Type: application/json
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "name": "string",       // 必須: リソース名 (1-100文字)
  "description": "string" // 任意: 説明
}
```

### 2.3 レスポンス仕様

**成功レスポンス (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "string",
    "description": "string",
    "createdAt": "ISO8601",
    "updatedAt": "ISO8601"
  }
}
```

**エラーレスポンス:**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "入力値が不正です",
    "details": [
      { "field": "name", "message": "nameは必須です" }
    ]
  }
}
```

### 2.4 ステータスコード一覧

| コード | 意味 | 使用場面 |
|--------|------|---------|
| 200 | OK | GET成功 |
| 201 | Created | POST成功 |
| 204 | No Content | DELETE成功 |
| 400 | Bad Request | バリデーションエラー |
| 401 | Unauthorized | 認証失敗 |
| 403 | Forbidden | 認可失敗 |
| 404 | Not Found | リソース未存在 |
| 500 | Internal Server Error | サーバーエラー |

---

## 3. データモデル設計

### 3.1 ER図

```
[users]
  id (PK)
  email
  created_at

[resources]
  id (PK)
  user_id (FK -> users.id)
  name
  description
  created_at
  updated_at
```

### 3.2 テーブル定義

#### `resources` テーブル

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|----------|------|
| id | UUID | NOT NULL | gen_random_uuid() | 主キー |
| user_id | UUID | NOT NULL | - | ユーザーID（外部キー）|
| name | VARCHAR(100) | NOT NULL | - | リソース名 |
| description | TEXT | NULL | - | 説明 |
| created_at | TIMESTAMPTZ | NOT NULL | NOW() | 作成日時 |
| updated_at | TIMESTAMPTZ | NOT NULL | NOW() | 更新日時 |

**インデックス:**
- PRIMARY KEY: `id`
- INDEX: `user_id`（検索頻度が高いため）

---

## 4. ビジネスロジック設計

### 4.1 ユースケース

```
ユーザーがリソースを作成する:
1. リクエストのJWTを検証する
2. リクエストボディをバリデーションする
3. DBにリソースを保存する
4. 作成したリソースをレスポンスとして返す
```

### 4.2 バリデーションルール

| フィールド | ルール | エラーコード |
|-----------|--------|------------|
| name | 必須、1〜100文字 | REQUIRED, MAX_LENGTH |
| description | 任意、最大500文字 | MAX_LENGTH |

### 4.3 トランザクション

> トランザクションが必要な処理を記述する。

| 処理名 | トランザクション範囲 | 理由 |
|--------|------------------|------|
|  |  |  |

---

## 5. シーケンス図

### 5.1 リソース作成フロー

```
Client          API             Service         Repository       DB
  |              |                |                  |             |
  |--POST /api-->|                |                  |             |
  |              |--validateJWT-->|                  |             |
  |              |                |--validate()----> |             |
  |              |                |--create()------> |             |
  |              |                |                  |--INSERT----> |
  |              |                |                  |<--result----|
  |              |                |<--resource-------|             |
  |              |<--201 Created--|                  |             |
  |<--response---|                |                  |             |
```

---

## 6. セキュリティ設計

### 6.1 認証・認可

| 観点 | 実装方針 |
|------|---------|
| 認証方式 | JWT (HS256 / RS256) |
| トークン有効期限 | アクセス: 15分 / リフレッシュ: 7日 |
| 認可 | リソースオーナーのみ更新・削除可能 |

### 6.2 セキュリティチェックリスト

- [ ] SQLインジェクション対策（プリペアドステートメント使用）
- [ ] 入力値サニタイズ
- [ ] レートリミット設定
- [ ] センシティブ情報のログ出力禁止
- [ ] HTTPSのみ許可
- [ ] CORS設定

---

## 7. 非機能要件

### 7.1 パフォーマンス

- [ ] APIレスポンスタイム: 〇ミリ秒以内（95パーセンタイル）
- [ ] 想定同時接続数: 〇リクエスト/秒
- [ ] N+1問題への対策: 

### 7.2 ログ・監視

| ログ種別 | 出力内容 | 保存期間 |
|---------|---------|---------|
| アクセスログ | メソッド、パス、ステータス、レスポンスタイム | 90日 |
| エラーログ | スタックトレース、リクエストID | 180日 |

---

## 8. 未解決事項・懸念点

| # | 内容 | 担当 | 期限 |
|---|------|------|------|
| 1 |  |  |  |

---

## 9. レビュー記録

| 日付 | レビュアー | コメント | 対応状況 |
|------|----------|---------|---------|
|  |  |  | 対応済み / 対応中 / 保留 |
