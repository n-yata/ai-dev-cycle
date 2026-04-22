# 環境構築手順

| 項目 | 内容 |
|------|------|
| 作成日 | YYYY-MM-DD |
| 最終更新 | YYYY-MM-DD |
| 対象 OS |  |
| ステータス | 草稿 / 確認済み |

---

## 1. 前提ソフトウェア

| ソフトウェア | 必須バージョン | 確認コマンド | 備考 |
|------------|-------------|------------|------|
| Node.js |  | `node -v` |  |
| npm / pnpm |  | `npm -v` / `pnpm -v` |  |
| Git |  | `git -v` |  |
| Docker |  | `docker -v` | DB 等のローカル実行用 |

---

## 2. リポジトリのクローンと初期セットアップ

```bash
# リポジトリのクローン
git clone <repository-url>
cd <project-name>

# 依存パッケージのインストール
npm install
```

---

## 3. 環境変数の設定

```bash
# .env.example をコピーして .env を作成
cp .env.example .env
```

| 環境変数 | 説明 | 取得方法 |
|---------|------|---------|
| `DATABASE_URL` | DB 接続文字列 | ローカル DB を起動後に設定 |
| `API_BASE_URL` | API ベース URL | ローカル: `http://localhost:xxxx` |

> **注意**: `.env` ファイルは `.gitignore` に含まれている。実際の値をコミットしないこと。

---

## 4. ローカルサービスの起動

### データベース

```bash
# Docker Compose でローカル DB を起動
docker compose up -d db

# マイグレーションの実行
npm run db:migrate
```

### アプリケーション

```bash
# 開発サーバーの起動
npm run dev
```

| サービス | URL | 備考 |
|---------|-----|------|
| フロントエンド |  |  |
| バックエンド API |  |  |
| DB 管理ツール |  |  |

---

## 5. Dev Container（オプション）

Dev Container を使用する場合は `.devcontainer/` の設定を利用する。

```bash
# VS Code で Dev Container を開く
# コマンドパレット → "Dev Containers: Reopen in Container"
```

---

## 6. 動作確認

セットアップ完了後、以下を確認する。

- [ ] `npm run dev` でエラーなく起動する
- [ ] ブラウザでフロントエンドにアクセスできる
- [ ] API エンドポイントにリクエストが通る
- [ ] DB に接続できる

---

## 7. トラブルシューティング

| 症状 | 原因 | 対処法 |
|------|------|--------|
|  |  |  |
