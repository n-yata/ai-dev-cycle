# Secrets Manager シークレット データエンティティ定義

| 項目 | 内容 |
|------|------|
| 作成日 | 2026-04-27 |
| 最終更新 | 2026-04-27 |
| テーブル名 | N/A（AWS Secrets Manager） |
| ステータス | レビュー中 |

---

## 1. 概要

API Gateway 認証・認可基盤で使用するシークレット（RSA 鍵ペア、RDS 接続情報）を AWS Secrets Manager で管理する。Lambda からは Secrets Manager API（`GetSecretValue`）経由で取得し、ソースコードやIaC テンプレートに秘密情報を含めない。

本ドキュメントでは各シークレットの構造・利用者・アクセス制御方針を定義する。

---

## 2. テーブル定義

> Secrets Manager はテーブルではないため、シークレット単位で構造を定義する。

### シークレット 1: JWT 秘密鍵

| # | 属性名 | 型 | 必須 | デフォルト | 制約 | 説明 |
|---|--------|-----|------|----------|------|------|
| 1 | シークレット名 | String | Yes | - | 環境変数 `JWT_PRIVATE_KEY_SECRET_ID` で参照 | 例: `apigw-auth/jwt/private-key` |
| 2 | シークレット値 | PlainText | Yes | - | RSA 秘密鍵 PEM 形式 | RS256 署名に使用する RSA 秘密鍵 |

| 設定項目 | 値 |
|---------|-----|
| シークレット名（例） | `apigw-auth/jwt/private-key` |
| シークレットタイプ | プレーンテキスト（PEM 形式の秘密鍵） |
| 暗号化 | AWS 管理キー（`aws/secretsmanager`） |
| 自動ローテーション | 無効（初期。将来的に `kid` ヘッダ方式で対応予定） |
| 利用者 | JWT 発行 Lambda のみ |
| IAM アクセス制御 | JWT 発行 Lambda の実行ロールに `secretsmanager:GetSecretValue` を許可。他のすべての Lambda・ユーザーからのアクセスを拒否 |

**シークレット値の形式**:

```
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA...
...
-----END RSA PRIVATE KEY-----
```

### シークレット 2: JWT 公開鍵

| # | 属性名 | 型 | 必須 | デフォルト | 制約 | 説明 |
|---|--------|-----|------|----------|------|------|
| 1 | シークレット名 | String | Yes | - | 環境変数 `JWT_PUBLIC_KEY_SECRET_ID` で参照 | 例: `apigw-auth/jwt/public-key` |
| 2 | シークレット値 | PlainText | Yes | - | RSA 公開鍵 PEM 形式 | RS256 検証に使用する RSA 公開鍵 |

| 設定項目 | 値 |
|---------|-----|
| シークレット名（例） | `apigw-auth/jwt/public-key` |
| シークレットタイプ | プレーンテキスト（PEM 形式の公開鍵） |
| 暗号化 | AWS 管理キー（`aws/secretsmanager`） |
| 自動ローテーション | 無効（秘密鍵と同時にローテーション） |
| 利用者 | ビジネス Lambda のみ |
| IAM アクセス制御 | ビジネス Lambda の実行ロールに `secretsmanager:GetSecretValue` を許可 |

**シークレット値の形式**:

```
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A...
...
-----END PUBLIC KEY-----
```

### シークレット 3: RDS 接続情報

| # | 属性名 | 型 | 必須 | デフォルト | 制約 | 説明 |
|---|--------|-----|------|----------|------|------|
| 1 | シークレット名 | String | Yes | - | 環境変数 `RDS_SECRET_ID` で参照 | 例: `apigw-auth/rds/credentials` |
| 2 | username | String | Yes | - | RDS 接続ユーザー名 | PostgreSQL のログインユーザー |
| 3 | password | String | Yes | - | RDS 接続パスワード | PostgreSQL のログインパスワード |
| 4 | host | String | Yes | - | RDS エンドポイント | クラスターエンドポイント |
| 5 | port | Number | Yes | 5432 | RDS ポート番号 | |
| 6 | dbname | String | Yes | - | データベース名 | |

| 設定項目 | 値 |
|---------|-----|
| シークレット名（例） | `apigw-auth/rds/credentials` |
| シークレットタイプ | JSON（キー/値ペア） |
| 暗号化 | AWS 管理キー（`aws/secretsmanager`） |
| 自動ローテーション | 有効を推奨（Secrets Manager の RDS ローテーション Lambda を利用） |
| 利用者 | JWT 発行 Lambda のみ |
| IAM アクセス制御 | JWT 発行 Lambda の実行ロールに `secretsmanager:GetSecretValue` を許可 |

**シークレット値の形式（JSON）**:

```json
{
  "username": "<DB_USERNAME>",
  "password": "<DB_PASSWORD>",
  "host": "<RDS_ENDPOINT>",
  "port": 5432,
  "dbname": "<DB_NAME>"
}
```

---

## 3. インデックス

> Secrets Manager にはインデックスの概念は存在しない。シークレット名がルックアップキーとなる。

| シークレット名パターン | 利用者 | ルックアップ方法 |
|-------------------|--------|---------------|
| `apigw-auth/jwt/private-key` | JWT 発行 Lambda | 環境変数 `JWT_PRIVATE_KEY_SECRET_ID` で名前を取得し `GetSecretValue` |
| `apigw-auth/jwt/public-key` | ビジネス Lambda | 環境変数 `JWT_PUBLIC_KEY_SECRET_ID` で名前を取得し `GetSecretValue` |
| `apigw-auth/rds/credentials` | JWT 発行 Lambda | 環境変数 `RDS_SECRET_ID` で名前を取得し `GetSecretValue` |

---

## 4. 制約

| 制約名 | 種別 | 対象 | 条件 | 備考 |
|--------|------|------|------|------|
| IAM_PRIVATE_KEY | IAM ポリシー | JWT 秘密鍵 | JWT 発行 Lambda の実行ロールのみ `GetSecretValue` 可能 | 他の Lambda・ユーザーからのアクセスを Resource Policy で明示的に Deny |
| IAM_PUBLIC_KEY | IAM ポリシー | JWT 公開鍵 | ビジネス Lambda の実行ロールのみ `GetSecretValue` 可能 | |
| IAM_RDS_CREDS | IAM ポリシー | RDS 接続情報 | JWT 発行 Lambda の実行ロールのみ `GetSecretValue` 可能 | |
| NO_HARDCODE | 運用制約 | 全シークレット | シークレット名・値をソースコードに直接記載しない | 環境変数経由で参照する |
| CLOUDTRAIL_AUDIT | 監査制約 | 全シークレット | `GetSecretValue` の呼び出しを CloudTrail で記録する | 不正アクセスの検知・監査用 |

---

## 5. ENUM・ステータス値

> Secrets Manager にはステータス値の概念は存在しない。以下はシークレットのバージョンステージを示す。

| ステージ | 説明 |
|---------|------|
| `AWSCURRENT` | 現在有効なシークレットバージョン |
| `AWSPREVIOUS` | 直前のバージョン（ローテーション時に自動設定） |
| `AWSPENDING` | ローテーション中の新しいバージョン |

---

## 6. マイグレーション考慮事項

> 新規シークレット作成のため、既存データへの影響はなし。

- [ ] 既存データへの影響: なし（新規シークレット）
- [ ] ダウンタイムの要否: なし
- [ ] ロールバック手順: シークレットの削除（復旧期間あり: デフォルト 30 日）

### 初期セットアップ手順

1. RSA 鍵ペアを生成する（2048 ビット以上）
2. IaC で Secrets Manager にシークレットを作成し、鍵を登録する
3. RDS 接続情報を IaC で Secrets Manager に登録する
4. Lambda の実行ロールに適切な IAM ポリシーをアタッチする

### キャッシュ戦略

Lambda 内で Secrets Manager への API 呼び出しを削減するため、以下のキャッシュ戦略を採用する。

| シークレット | キャッシュ方式 | TTL | 理由 |
|------------|-------------|------|------|
| JWT 秘密鍵 | Lambda 実行環境のメモリ内キャッシュ | Lambda 実行環境のライフサイクル | 頻繁に変更されないため、コールドスタート時に 1 回取得すれば十分 |
| JWT 公開鍵 | Lambda 実行環境のメモリ内キャッシュ | Lambda 実行環境のライフサイクル | 同上 |
| RDS 接続情報 | Lambda 実行環境のメモリ内キャッシュ | Lambda 実行環境のライフサイクル | 同上。ローテーション時はコネクションエラーを検知して再取得 |

---

## 7. 未解決事項

| # | 内容 | 担当 | 期限 |
|---|------|------|------|
| 1 | RSA 鍵のビット長確定（2048 / 4096） | クルトワ | セキュリティレビュー時 |
| 2 | 鍵ローテーション運用手順の策定（`kid` ヘッダによる新旧鍵並行期間等） | バルベルデ / ベリンガム | 将来対応 |
| 3 | RDS 接続情報の自動ローテーション設定の有無 | ベリンガム | インフラ構築時 |
| 4 | Secrets Manager の暗号化キーを CMK（カスタマー管理キー）に変更するか | クルトワ | セキュリティレビュー時 |
