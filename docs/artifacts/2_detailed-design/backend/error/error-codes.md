# エラーコード一覧

| 項目 | 内容 |
|------|------|
| 作成日 | 2026-04-27 |
| 最終更新 | 2026-04-27 |
| ステータス | レビュー中 |

---

## 1. 概要

API Gateway 認証・認可基盤で使用するエラーコードの定義。
API レスポンスの `error.code` フィールドにこの一覧のコードを使用する。

本エラーコード体系は以下のレイヤで発生するエラーを網羅する:

- **API Gateway レイヤ**: SigV4 検証失敗（AWS マネージドレスポンス）
- **ビジネス Lambda 認可レイヤ**: ホワイトリスト確認、JWT 検証、ロール×API 認可
- **JWT 発行 Lambda**: トークン発行処理
- **共通**: バリデーション、システムエラー

---

## 2. エラーコード命名規則

```
{カテゴリ}_{詳細}
例: AUTH_JWT_EXPIRED, VALIDATION_REQUIRED_FIELD, SYSTEM_INTERNAL_ERROR
```

| カテゴリ | 用途 |
|---------|------|
| AUTH | 認証関連（SigV4、JWT 署名検証） |
| AUTHZ | 認可関連（ロール×API 権限、ホワイトリスト、呼び出し元 ARN） |
| TOKEN | JWT 発行関連 |
| VALIDATION | 入力バリデーション関連 |
| SYSTEM | システム内部エラー（DynamoDB、Secrets Manager、RDS 等） |

---

## 3. エラーコード一覧

### 認証 (AUTH)

| エラーコード | HTTP ステータス | メッセージ | 発生条件 | クライアント対応 |
|------------|---------------|----------|---------|---------------|
| AUTH_SIGV4_UNAUTHORIZED | 401 | SigV4 signature verification failed | SigV4 署名検証失敗。API Gateway が返却するマネージドレスポンス（Lambda 到達前に拒否） | 署名ロジック・タイムスタンプ・クレデンシャルを確認 |
| AUTH_JWT_MISSING | 401 | Authentication token is required | JWT が必要な API で `X-Auth-Token` ヘッダが未設定 | JWT を取得して `X-Auth-Token` ヘッダに設定 |
| AUTH_JWT_MALFORMED | 401 | Authentication token is malformed | JWT のフォーマットが不正（3 パート構成でない、Base64 デコード失敗等） | JWT の取得・設定処理を確認 |
| AUTH_JWT_EXPIRED | 401 | Authentication token has expired | JWT の `exp` クレームが現在時刻を超過 | `/auth/token` で新しい JWT を発行して再リクエスト |
| AUTH_JWT_NOT_YET_VALID | 401 | Authentication token is not yet valid | JWT の `nbf` クレームが現在時刻より未来 | トークン発行元の時刻同期を確認 |
| AUTH_JWT_INVALID_SIGNATURE | 401 | Authentication token signature is invalid | JWT の RS256 署名検証が失敗 | JWT の改ざんがないか確認。正規の発行エンドポイントから取得しているか確認 |
| AUTH_JWT_INVALID_ISSUER | 401 | Authentication token issuer is invalid | JWT の `iss` クレームが期待値と不一致 | 正規の JWT 発行エンドポイントを使用しているか確認 |
| AUTH_JWT_INVALID_AUDIENCE | 401 | Authentication token audience is invalid | JWT の `aud` クレームが期待値と不一致 | JWT 発行時の audience 設定を確認 |

### 認可 (AUTHZ)

| エラーコード | HTTP ステータス | メッセージ | 発生条件 | クライアント対応 |
|------------|---------------|----------|---------|---------------|
| AUTHZ_FORBIDDEN_ROLE | 403 | Access denied: insufficient role permissions | JWT 内のいずれのロールにも該当 API の許可エントリがない | 必要なロールの付与を管理者に依頼 |
| AUTHZ_FORBIDDEN_CALLER | 403 | Access denied: caller identity is not authorized | リクエスト元の IAM ARN が想定外（ServiceNow 用 IAM ユーザーでも内部 BE 用 IAM ロールでもない） | 正しい IAM クレデンシャルを使用しているか確認 |
| AUTHZ_ROLES_MISSING_IN_TOKEN | 403 | Access denied: no roles found in token | JWT の `roles` クレームが空配列または未定義 | ユーザーにロールが割り当てられているか確認 |

### JWT 発行 (TOKEN)

| エラーコード | HTTP ステータス | メッセージ | 発生条件 | クライアント対応 |
|------------|---------------|----------|---------|---------------|
| TOKEN_USER_NOT_FOUND | 404 | User not found | リクエストされた `userId` が RDS の `user_roles` テーブルに存在しない | ユーザー ID が正しいか確認 |
| TOKEN_NO_ROLES_ASSIGNED | 400 | No roles assigned to user | ユーザーは存在するがロールが 1 つも割り当てられていない | 管理者にロール割り当てを依頼 |
| TOKEN_SIGNING_FAILED | 500 | Token generation failed | RSA 秘密鍵の取得失敗、または署名処理中のエラー | 時間をおいてリトライ。繰り返す場合はシステム管理者に連絡 |

### バリデーション (VALIDATION)

| エラーコード | HTTP ステータス | メッセージ | 発生条件 | クライアント対応 |
|------------|---------------|----------|---------|---------------|
| VALIDATION_REQUIRED_FIELD | 400 | Required field is missing: {fieldName} | 必須フィールドが未入力 | 該当フィールドを設定してリクエスト |
| VALIDATION_INVALID_FORMAT | 400 | Invalid format: {fieldName} | フィールドの形式が不正（例: userId の形式不正） | 入力値の形式を確認 |
| VALIDATION_INVALID_JSON | 400 | Request body is not valid JSON | リクエストボディが JSON としてパースできない | リクエストボディの JSON 形式を確認 |

### システム (SYSTEM)

| エラーコード | HTTP ステータス | メッセージ | 発生条件 | クライアント対応 |
|------------|---------------|----------|---------|---------------|
| SYSTEM_INTERNAL_ERROR | 500 | Internal server error | 予期しないエラー（未分類の例外） | 時間をおいてリトライ。繰り返す場合はシステム管理者に連絡 |
| SYSTEM_DYNAMODB_ERROR | 500 | Internal server error | DynamoDB へのアクセスでエラー発生（スロットリング、接続エラー等） | 時間をおいてリトライ |
| SYSTEM_SECRETS_MANAGER_ERROR | 500 | Internal server error | Secrets Manager へのアクセスでエラー発生 | 時間をおいてリトライ |
| SYSTEM_RDS_ERROR | 500 | Internal server error | RDS への接続・クエリでエラー発生 | 時間をおいてリトライ |
| SYSTEM_RATE_LIMITED | 429 | Too many requests | API Gateway / Lambda のスロットリング | 時間をおいてリトライ（`Retry-After` ヘッダを参照） |

---

## 4. エラーレスポンス形式

### 基本形式

```json
{
  "error": {
    "code": "AUTH_JWT_EXPIRED",
    "message": "Authentication token has expired"
  }
}
```

### バリデーションエラー（複数フィールド）

```json
{
  "error": {
    "code": "VALIDATION_REQUIRED_FIELD",
    "message": "Required fields are missing",
    "details": [
      { "field": "userId", "message": "userId is required" }
    ]
  }
}
```

### セキュリティ上の注意

- **SYSTEM カテゴリのエラー**: クライアントには一律 `Internal server error` を返却し、詳細情報（スタックトレース、内部サービス名、エンドポイント等）はレスポンスに含めない。詳細は CloudWatch Logs にのみ記録する。
- **AUTH / AUTHZ カテゴリのエラー**: 攻撃者にヒントを与えない範囲で、クライアントが自己解決可能な程度のメッセージとする。
- **エラーレスポンスに含めてはいけない情報**: AWS アカウント ID、Lambda 関数名、DynamoDB テーブル名、Secrets Manager シークレット名、スタックトレース。

---

## 5. 未解決事項

| # | 内容 | 担当 | 期限 |
|---|------|------|------|
| 1 | JWT ヘッダ名の最終確定（`X-Auth-Token` vs `Authorization: Bearer`）。SigV4 と `Authorization` ヘッダの競合回避方針 | バルベルデ | API 設計確定時 |
| 2 | `Retry-After` ヘッダの付与方針（429 レスポンス時） | ヴィニシウス | 実装時 |
| 3 | API Gateway が返却する SigV4 エラーレスポンスの形式カスタマイズ可否 | ベリンガム | インフラ構築時 |
| 4 | エラーコードのローカライゼーション方針（日本語メッセージの要否） | シャビ | 実装前 |
