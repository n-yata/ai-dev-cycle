# DynamoDB 認可テーブル データエンティティ定義

| 項目 | 内容 |
|------|------|
| 作成日 | 2026-04-27 |
| 最終更新 | 2026-04-27 |
| テーブル名 | 環境変数 `AUTH_TABLE_NAME` で指定（例: `apigw-auth-table`） |
| ステータス | レビュー中 |

---

## 1. 概要

API Gateway 認証・認可基盤の認可判定に必要なデータを一元管理する DynamoDB テーブル。シングルテーブルデザインを採用し、以下の 2 種類のアイテムコレクションを格納する。

- **ロール×API 認可エントリ**: ロール ID ごとに許可する API（メソッド + routeKey）を定義する
- **JWT スキップ ホワイトリストエントリ**: JWT 認可をスキップする API Gateway の API ID を登録する（内部 BE 用）

すべてのアクセスパターンは PK/SK 完全一致の GetItem で完結し、スキャンは不要。

---

## 2. テーブル定義

### テーブル設定

| 設定項目 | 値 | 備考 |
|---------|-----|------|
| パーティションキー（PK） | `PK` (String) | |
| ソートキー（SK） | `SK` (String) | |
| キャパシティモード | オンデマンド | 初期はオンデマンド。トラフィックパターンが安定したらプロビジョンドへの移行を検討 |
| 暗号化 | AWS 管理キー（SSE-S3） | |
| Point-in-time Recovery | 有効 | 誤削除・誤更新からの復旧用 |
| TTL | なし | 認可データは明示的に管理するため TTL 不要 |

### アイテムコレクション 1: ロール×API 認可

> PK=`ROLE#{roleId}`, SK=`API#{method}#{routeKey}` のパターン

| # | 属性名 | 型 | 必須 | デフォルト | 説明 |
|---|--------|-----|------|----------|------|
| 1 | PK | String | Yes | - | `ROLE#{roleId}`（例: `ROLE#admin`, `ROLE#viewer`） |
| 2 | SK | String | Yes | - | `API#{method}#{routeKey}`（例: `API#GET#/orders/{id}`, `API#POST#/orders`） |
| 3 | entity_type | String | Yes | `ROLE_API` | アイテムコレクションの識別子 |
| 4 | effect | String | Yes | `ALLOW` | 認可効果。現時点では `ALLOW` のみ。将来的に `DENY` を追加する拡張余地あり |
| 5 | description | String | No | - | この認可エントリの説明（運用・監査用） |
| 6 | created_at | String | Yes | - | 作成日時（ISO 8601 形式: `2026-04-27T00:00:00Z`） |
| 7 | updated_at | String | Yes | - | 更新日時（ISO 8601 形式） |

**アクセスパターン**:

| パターン | 操作 | キー条件 | 用途 |
|---------|------|---------|------|
| ロール×API 認可確認 | GetItem | PK=`ROLE#{roleId}`, SK=`API#{method}#{routeKey}` | ビジネス Lambda がロール認可判定を行う |
| ロールの全許可 API 一覧 | Query | PK=`ROLE#{roleId}`, SK begins_with `API#` | 運用・監査用途（通常のリクエスト処理では使用しない） |

**データ例**:

```json
{
  "PK": "ROLE#admin",
  "SK": "API#GET#/orders/{id}",
  "entity_type": "ROLE_API",
  "effect": "ALLOW",
  "description": "管理者は注文詳細を参照可能",
  "created_at": "2026-04-27T00:00:00Z",
  "updated_at": "2026-04-27T00:00:00Z"
}
```

### アイテムコレクション 2: JWT スキップ ホワイトリスト

> PK=`WHITELIST#API_ID`, SK=`#{apiId}` のパターン

| # | 属性名 | 型 | 必須 | デフォルト | 説明 |
|---|--------|-----|------|----------|------|
| 1 | PK | String | Yes | - | 固定値 `WHITELIST#API_ID` |
| 2 | SK | String | Yes | - | `#{apiId}`（例: `#abc123def4`）。API Gateway の API ID |
| 3 | entity_type | String | Yes | `WHITELIST` | アイテムコレクションの識別子 |
| 4 | description | String | No | - | このホワイトリストエントリの説明（例: 内部 BE 用 API Gateway B） |
| 5 | created_at | String | Yes | - | 作成日時（ISO 8601 形式） |
| 6 | updated_at | String | Yes | - | 更新日時（ISO 8601 形式） |

**アクセスパターン**:

| パターン | 操作 | キー条件 | 用途 |
|---------|------|---------|------|
| ホワイトリスト確認 | GetItem | PK=`WHITELIST#API_ID`, SK=`#{apiId}` | ビジネス Lambda が JWT スキップ判定を行う |

**データ例**:

```json
{
  "PK": "WHITELIST#API_ID",
  "SK": "#abc123def4",
  "entity_type": "WHITELIST",
  "description": "内部BEサーバー用 API Gateway B",
  "created_at": "2026-04-27T00:00:00Z",
  "updated_at": "2026-04-27T00:00:00Z"
}
```

---

## 3. インデックス

| インデックス名 | 対象属性 | 種別 | 理由 |
|-------------|---------|------|------|
| （テーブルキー） | PK + SK | PRIMARY | 全アクセスパターンが PK/SK 完全一致の GetItem で完結するため |
| GSI_SK_PK | SK（パーティションキー）+ PK（ソートキー） | GSI | 逆引き用途: 特定 API に対してどのロールが許可されているかを取得（運用・監査用）。不要と判断された場合は削除 |

### GSI 設計詳細

| 設定項目 | 値 |
|---------|-----|
| GSI パーティションキー | SK |
| GSI ソートキー | PK |
| 射影タイプ | KEYS_ONLY |
| キャパシティモード | テーブルと同一（オンデマンド） |

---

## 4. 制約

| 制約名 | 種別 | 対象属性 | 条件 | 備考 |
|--------|------|----------|------|------|
| PK_FORMAT_ROLE | アプリケーション制約 | PK | `ROLE#` で始まること（ロール×API エントリ） | DynamoDB には CHECK 制約がないため、IaC / アプリケーション側で担保 |
| SK_FORMAT_API | アプリケーション制約 | SK | `API#` で始まること（ロール×API エントリ） | 同上 |
| PK_FORMAT_WL | アプリケーション制約 | PK | `WHITELIST#API_ID` 固定値であること（ホワイトリストエントリ） | 同上 |
| SK_FORMAT_WL | アプリケーション制約 | SK | `#` で始まること（ホワイトリストエントリ） | 同上 |
| EFFECT_VALUES | アプリケーション制約 | effect | `ALLOW` のみ（現時点） | 将来的に `DENY` 追加の可能性あり |
| IaC_ONLY | 運用制約 | 全属性 | テーブルへの書き込みは IaC 経由のみ許可 | IAM ポリシーでコンソール/手動操作を禁止 |

---

## 5. ENUM・ステータス値

| 属性名 | 値 | 説明 |
|--------|-----|------|
| entity_type | `ROLE_API` | ロール×API 認可エントリ |
| entity_type | `WHITELIST` | JWT スキップ ホワイトリストエントリ |
| effect | `ALLOW` | API 呼び出しを許可 |

---

## 6. マイグレーション考慮事項

> 新規テーブルのため、既存データへの影響はなし。

- [ ] 既存データへの影響: なし（新規テーブル）
- [ ] ダウンタイムの要否: なし
- [ ] ロールバック手順: テーブル削除で完了。Point-in-time Recovery を有効化しているため、誤操作時はリストア可能

### 初期データ投入

IaC（CDK or Terraform）でテーブル作成と同時に初期データを投入する。

- ロール×API 認可エントリ: 業務要件に基づいて定義（API 一覧確定後）
- ホワイトリストエントリ: 内部 BE 用 API Gateway B の API ID を登録

---

## 7. 未解決事項

| # | 内容 | 担当 | 期限 |
|---|------|------|------|
| 1 | GSI（GSI_SK_PK）の要否確定。運用・監査で逆引きが必要かを判断する | バルベルデ | 実装前 |
| 2 | routeKey の記載形式の最終確定（パスパラメータの表記: `{id}` vs `:id`） | バルベルデ / ヴィニシウス | 実装前 |
| 3 | `effect` に `DENY` を追加する必要があるかの判断 | シャビ | 将来検討 |
