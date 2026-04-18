# Playwright webServer 設定: dev container vs ローカル環境 — ナレッジ記録

| 項目 | 内容 |
|------|------|
| 記録日 | 2026-04-19 |
| 最終更新 | 2026-04-19 |
| 記録者 | モドリッチ |
| フェーズ | 結合テスト |
| カテゴリ | test-patterns |
| 対象領域 | フロントエンド |
| 重要度 | 高（必読） |

---

## 概要

> Playwright の `webServer` 設定に絶対パス（Linux パス）やコンパイル済みバイナリを指定すると、dev container 以外の環境（ローカル Windows 等）で E2E テストが起動できない。`go run` + 相対 `cwd` + `env` プロパティの組み合わせにすることで環境非依存になる。

---

## 背景・コンテキスト

**状況:** dev container で開発した E2E テストをローカル Windows 環境で実行しようとした。

**課題・問題:** `playwright.config.ts` の `webServer` に Linux 絶対パスとコンパイル済みバイナリパスがハードコードされており、ローカル環境では起動できなかった。

---

## 事実（何が起きたか / 何を決めたか）

- `webServer.command` に `/workspace/...` の Linux 絶対パスとバイナリパス（`bin/server`）を指定していた
- ローカル Windows では当然このパスが存在しないため、Playwright がバックエンドサーバーを起動できず E2E テストが全件失敗
- `go run ./cmd/server/main.go` + `env` プロパティ + 相対 `cwd` に変更することで解決

---

## 理由・分析

### 検討した選択肢

| 選択肢 | メリット | デメリット | 採用 |
|--------|---------|----------|------|
| `go run ./cmd/server/main.go` + `env` プロパティ | クロスプラットフォーム。バイナリビルド不要 | コンパイル時間がかかる（timeout 延長が必要） | ✅ 採用 |
| Windows 向けバイナリをビルドして参照 | 起動が速い | 環境ごとにビルドが必要。CI/CD との乖離が起きやすい | ❌ 却下 |
| 環境変数でパスを切り替える | 柔軟性がある | 設定が複雑になる | ❌ 却下 |

### 根本原因

```
直接原因: dev container 前提の絶対パスをそのまま使用した
根本原因: Playwright config を作成した時点でローカル実行を考慮しなかった
```

---

## 具体例・コード

### ビフォー（問題のあるパターン）

```typescript
webServer: [
  {
    command: 'PORT=8080 DB_PATH=./todo_test.db CORS_ORIGIN=http://localhost:4173 /workspace/workspace-claude/ai-dev-cycle/backend/bin/server',
    cwd: '/workspace/workspace-claude/ai-dev-cycle/backend',
    port: 8080,
    reuseExistingServer: false,
    timeout: 10000,
  },
  {
    command: 'npm run preview',
    cwd: '/workspace/workspace-claude/ai-dev-cycle/frontend',
    port: 4173,
    reuseExistingServer: false,
    timeout: 10000,
  },
],
```

### アフター（改善後のパターン）

```typescript
webServer: [
  {
    command: 'go run ./cmd/server/main.go',
    cwd: '../backend',           // playwright.config.ts からの相対パス
    port: 8080,
    reuseExistingServer: false,
    timeout: 30000,              // go run のコンパイル時間を考慮して延長
    env: {
      PORT: '8080',
      DB_PATH: './todo_test.db',
      CORS_ORIGIN: 'http://localhost:4173',
    },
  },
  {
    command: 'npm run preview',
    port: 4173,
    reuseExistingServer: false,
    timeout: 15000,
  },
],
```

---

## 次回への示唆

### すべきこと（Do）

- [x] `webServer.command` はクロスプラットフォームなコマンド（`go run`、`npm run` 等）を使う
- [x] `cwd` は config ファイルからの相対パスで指定する
- [x] 環境変数は `env` プロパティで渡す（コマンド文字列に埋め込まない）
- [x] `go run` を使う場合は `timeout` を 30000ms 以上に設定する
- [x] `workers: 1` を設定して、共有 DB への並列アクセスを防ぐ

### 避けること（Don't）

- Linux 絶対パスを `webServer.command` や `cwd` にハードコードしない
- コンパイル済みバイナリのパスを直接指定しない（環境依存になる）
- バックエンド用コンテナ・バイナリが `PATH` に存在することを前提にしない

### チェックリストへの追加提案

- [ ] `docs/rules/integration-test/frontend/INSTRUCTIONS.md` に追加: `playwright.config.ts の webServer は go run + 相対 cwd + env プロパティを使用し、絶対パスやバイナリパスを含めない`

---

## タグ

`playwright`, `webServer`, `devcontainer`, `cross-platform`, `go-run`, `e2e`
