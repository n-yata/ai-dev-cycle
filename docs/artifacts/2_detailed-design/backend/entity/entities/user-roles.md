# user_roles データエンティティ定義

| 項目 | 内容 |
|------|------|
| 作成日 | 2026-04-27 |
| 最終更新 | 2026-04-27 |
| テーブル名 | user_roles |
| ステータス | レビュー中 |

---

## 1. 概要

ユーザー ID に紐づくロール ID の一覧を管理する RDS（PostgreSQL）テーブル。JWT 発行 Lambda がユーザー ID を受け取った際にこのテーブルを参照し、該当ユーザーに割り当てられたロール ID リストを取得して JWT の `roles` クレームに含める。

1 ユーザーに複数のロールを割り当て可能（多対多）。ユーザーマスタ・ロールマスタ自体は本システムのスコープ外であり、外部で管理される前提。

---

## 2. テーブル定義

| # | カラム名 | 型 | NULL | デフォルト | 制約 | 説明 |
|---|---------|-----|------|----------|------|------|
| 1 | id | UUID | NOT NULL | gen_random_uuid() | PK | サロゲートキー |
| 2 | user_id | VARCHAR(255) | NOT NULL | - | - | ユーザー ID（外部システムのユーザー識別子） |
| 3 | role_id | VARCHAR(100) | NOT NULL | - | - | ロール ID（例: `admin`, `viewer`, `editor`） |
| 4 | created_at | TIMESTAMP WITH TIME ZONE | NOT NULL | CURRENT_TIMESTAMP | - | レコード作成日時 |
| 5 | updated_at | TIMESTAMP WITH TIME ZONE | NOT NULL | CURRENT_TIMESTAMP | - | レコード更新日時 |

### DDL

```sql
CREATE TABLE user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(255) NOT NULL,
    role_id VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_user_roles_user_id_role_id UNIQUE (user_id, role_id)
);

-- user_id での検索用インデックス（JWT 発行時のアクセスパターン）
CREATE INDEX idx_user_roles_user_id ON user_roles (user_id);

-- updated_at 自動更新トリガー
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_user_roles_updated_at
    BEFORE UPDATE ON user_roles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

## 3. インデックス

| インデックス名 | 対象カラム | 種別 | 理由 |
|-------------|----------|------|------|
| user_roles_pkey | id | PRIMARY | 主キー |
| uq_user_roles_user_id_role_id | (user_id, role_id) | UNIQUE | 同一ユーザーに同一ロールの重複割り当てを防止 |
| idx_user_roles_user_id | user_id | INDEX | JWT 発行時に user_id で WHERE 検索するため。主要なアクセスパターン |

---

## 4. 制約

| 制約名 | 種別 | 対象カラム | 条件 | 備考 |
|--------|------|----------|------|------|
| user_roles_pkey | PRIMARY KEY | id | - | |
| uq_user_roles_user_id_role_id | UNIQUE | (user_id, role_id) | ユーザー×ロールの組み合わせが一意 | 重複登録を DB レベルで防止 |

---

## 5. ENUM・ステータス値

> 現時点では ENUM 型は使用しない。`role_id` は自由文字列とし、ロールマスタ側（スコープ外）で管理する。

| カラム名 | 想定される値（例） | 説明 |
|---------|-----------------|------|
| role_id | `admin` | 管理者ロール |
| role_id | `editor` | 編集者ロール |
| role_id | `viewer` | 閲覧者ロール |

> 上記は例示であり、実際のロール体系は業務要件に基づいて決定する。

---

## 6. マイグレーション考慮事項

> 既存 RDS 環境にテーブルを新規追加する。

- [ ] 既存データへの影響: なし（新規テーブル追加のため既存テーブルに影響しない）
- [ ] ダウンタイムの要否: なし（CREATE TABLE は非破壊的操作）
- [ ] ロールバック手順: `DROP TABLE user_roles;` で完了

### RDS 接続設定

- ホスト: 環境変数 `RDS_HOST` で指定
- ポート: 環境変数 `RDS_PORT` で指定（デフォルト: `5432`）
- データベース名: 環境変数 `RDS_DATABASE` で指定
- 認証情報: Secrets Manager（シークレット ID: 環境変数 `RDS_SECRET_ID` で指定）から取得

---

## 7. 未解決事項

| # | 内容 | 担当 | 期限 |
|---|------|------|------|
| 1 | user_id の形式確定（UUID / メールアドレス / 外部 ID 等） | シャビ | 実装前 |
| 2 | role_id の命名規約確定（ケバブケース / スネークケース / 自由文字列） | バルベルデ | 実装前 |
| 3 | ユーザー×ロールの初期データ投入方法（マイグレーションスクリプト / 管理画面） | ベリンガム | インフラ構築時 |
| 4 | role_id に外部キー制約を付けるか（ロールマスタテーブルの存在次第） | バルベルデ | ロールマスタ方針確定後 |
