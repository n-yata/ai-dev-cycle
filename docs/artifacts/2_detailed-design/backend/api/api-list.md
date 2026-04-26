# API Gateway 認証・認可基盤 API 一覧

| 項目 | 内容 |
|------|------|
| 作成日 | 2026-04-27 |
| 最終更新 | 2026-04-27 |
| API バージョン | v1 |
| ベース URL | `https://{cloudfront-domain}/`（API Gateway A / B はそれぞれ別ドメインまたは別パスで分離） |
| ステータス | レビュー中 |

---

## 1. 概要

本 API 一覧は、API Gateway 認証・認可基盤に関わるエンドポイントを定義する。

### 設計原則

- すべての API は **IAM 認証（SigV4）** を必須とし、API Gateway が Lambda 到達前に署名検証を完了する
- ServiceNow 用 API（API Gateway A 経由）は SigV4 に加え **JWT（`X-Auth-Token` ヘッダ）** による認可を必須とする
- 内部 BE 用 API（API Gateway B 経由）は **ホワイトリスト** に基づき JWT 認可をスキップする
- JWT は `Authorization` ヘッダと競合しないよう、**`X-Auth-Token` ヘッダ** で送信する
- API Gateway A（ServiceNow 用）と API Gateway B（内部 BE 用）の 2 系統でリソースを分離する

### API Gateway 系統

| 系統 | 用途 | 呼び出し元 | 認証 | JWT |
|------|------|-----------|------|-----|
| API Gateway A | ServiceNow 用業務 API | ServiceNow（外部 SaaS） | IAM 認証（SigV4） | 必須（`X-Auth-Token`） |
| API Gateway B | 内部 BE 用業務 API | 内部バックエンドサーバー | IAM 認証（SigV4） | 不要（ホワイトリスト対象） |
| API Gateway A | JWT 発行 API | ServiceNow（外部 SaaS） | IAM 認証（SigV4） | 不要（トークン発行のため） |

---

## 2. 共通仕様

### 認証方式

| 方式 | ヘッダー | 備考 |
|------|---------|------|
| IAM 認証（SigV4） | `Authorization: AWS4-HMAC-SHA256 ...` | 全 API 必須。AWS SDK が自動付与。API Gateway が検証 |
| JWT Bearer トークン | `X-Auth-Token: {JWT}` | ServiceNow 用 API のみ必須。`Authorization` ヘッダとの競合を回避するため独立ヘッダを使用 |

### レスポンス形式

**成功:**
```json
{
  "success": true,
  "data": { ... }
}
```

**エラー:**
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "エラーメッセージ"
  }
}
```

---

## 3. エンドポイント一覧

### 認証・認可

| # | メソッド | パス | 説明 | API Gateway | 認証 | JWT | 処理設計書 |
|---|---------|------|------|-------------|------|-----|----------|
| 1 | POST | `/auth/token` | JWT トークン発行。ユーザー ID を受け取り、RS256 署名付き JWT を返却 | A | IAM（SigV4） | 不要 | [issue-token.md](designs/issue-token.md) |

### 業務 API（ServiceNow 用 - API Gateway A）

| # | メソッド | パス | 説明 | API Gateway | 認証 | JWT | 処理設計書 |
|---|---------|------|------|-------------|------|-----|----------|
| 2 | 各種 | `/api/...` | ServiceNow 向け業務 API（個別の業務 API 設計は対象外） | A | IAM（SigV4） | 必須 | 業務 API ごとに別途作成 |

### 業務 API（内部 BE 用 - API Gateway B）

| # | メソッド | パス | 説明 | API Gateway | 認証 | JWT | 処理設計書 |
|---|---------|------|------|-------------|------|-----|----------|
| 3 | 各種 | `/api/...` | 内部 BE 向け業務 API（個別の業務 API 設計は対象外） | B | IAM（SigV4） | 不要 | 業務 API ごとに別途作成 |

### 共通認可ミドルウェア

| # | 対象 | 説明 | 処理設計書 |
|---|------|------|----------|
| 4 | 全業務 API | ビジネス Lambda 内の認可処理フロー（ホワイトリスト確認 → JWT 検証 → ロール認可） | [authorize-request.md](designs/authorize-request.md) |

---

## 4. ステータスコード方針

| コード | 意味 | 使用場面 |
|--------|------|---------|
| 200 | OK | 正常処理完了（JWT 発行、業務 API の GET/PUT 等） |
| 201 | Created | リソース作成成功 |
| 204 | No Content | DELETE 成功 |
| 400 | Bad Request | リクエストボディのバリデーションエラー |
| 401 | Unauthorized | SigV4 検証失敗（API Gateway が返却） / JWT 署名不正・期限切れ |
| 403 | Forbidden | ロールに該当 API の許可なし / 呼び出し元 ARN が想定外 |
| 404 | Not Found | リソース未存在 |
| 429 | Too Many Requests | WAF レートリミット超過（CloudFront/WAF が返却） |
| 500 | Internal Server Error | Lambda 内部エラー（Secrets Manager 接続失敗、DynamoDB 障害等） |

### エラーコード一覧（認証・認可関連）

| HTTP ステータス | エラーコード | 発生条件 | エラーメッセージ |
|----------------|------------|---------|--------------|
| 401 | `UNAUTHORIZED_SIGV4` | SigV4 検証失敗（API Gateway が返却） | Signature verification failed |
| 401 | `UNAUTHORIZED_JWT_MISSING` | `X-Auth-Token` ヘッダ未設定（JWT 必須 API） | Authentication token is required |
| 401 | `UNAUTHORIZED_JWT_INVALID` | JWT 署名検証失敗 | Invalid authentication token |
| 401 | `UNAUTHORIZED_JWT_EXPIRED` | JWT 有効期限切れ | Authentication token has expired |
| 403 | `FORBIDDEN_ROLE` | ロールに該当 API の許可なし | Access denied: insufficient permissions |
| 403 | `FORBIDDEN_CALLER` | 呼び出し元 ARN が想定外 | Access denied: unrecognized caller |
| 400 | `INVALID_REQUEST_BODY` | リクエストボディのバリデーション失敗 | Invalid request body |
| 400 | `INVALID_USER_ID` | userId が空または不正形式 | Invalid or missing userId |
| 404 | `USER_NOT_FOUND` | 指定された userId が RDS に存在しない | User not found |
| 500 | `INTERNAL_ERROR` | Lambda 内部のシステムエラー | Internal server error |

---

## 5. レートリミット

| 対象 | 制限 | 単位 | 備考 |
|------|------|------|------|
| API Gateway A（ServiceNow 用） | WAF ルールで設定 | リクエスト/分 | カウントモードで事前検証後に Block へ切替 |
| API Gateway B（内部 BE 用） | WAF ルールで設定 | リクエスト/分 | 内部通信のため緩めに設定 |
| POST `/auth/token` | WAF ルールで設定 | リクエスト/分 | トークン発行の濫用を防止 |

---

## 6. 未解決事項

| # | 内容 | 担当 | 期限 |
|---|------|------|------|
| 1 | 業務 API の具体的なエンドポイント一覧（本設計は認可基盤のスコープのため、業務 API 個別の設計は対象外） | シャビ | 業務 API 設計時 |
| 2 | WAF レートリミットの具体的な閾値 | ベリンガム | インフラ構築時 |
