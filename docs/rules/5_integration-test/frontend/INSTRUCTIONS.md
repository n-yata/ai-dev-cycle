# フロントエンド 結合テストガイド

---

## 使用ツール

| ツール | 用途 |
|--------|------|
| Playwright | E2Eテスト・ブラウザ操作 |
| MSW (Mock Service Worker) | APIモック（ブラウザ環境）|
| React Testing Library | コンポーネント統合テスト |

---

## テストの種類と方針

### E2Eテスト（Playwright）

実際のブラウザを使用して、ユーザーの操作フローをエンドツーエンドで検証する。

**対象: ゴールデンパス（最も重要なユーザーフロー）**
- ユーザー登録 → ログイン → 主要機能の利用
- データ作成 → 一覧表示 → 詳細表示 → 編集 → 削除

### API通信統合テスト

MSWを使用してAPIレスポンスをモック化し、フロントエンドのAPI通信ロジックを検証する。

**対象:**
- データ取得からUI反映までの一連のフロー
- エラーレスポンス時のエラーハンドリング
- ページネーション・フィルタリング

---

## テスト実行方法

```bash
# E2Eテスト（Playwright）
npx playwright test

# 特定のテストファイルのみ実行
npx playwright test tests/auth.spec.ts

# UIモードで実行（デバッグ用）
npx playwright test --ui

# ヘッドフルモードで実行（ブラウザが見える状態）
npx playwright test --headed
```

---

## テストデータ管理

- テストデータはテスト開始前に `beforeAll` / `beforeEach` でセットアップする
- テスト終了後は `afterAll` / `afterEach` でクリーンアップする
- 本番環境のデータに依存しないテストデータを使用する

テストシナリオのテンプレートは [test-scenario.template.md](../test-scenario.template.md) を参照してください。

---

## ナレッジからの追加ルール

<!-- このセクションは /reflect-knowledge コマンドにより自動追記されます -->

### Playwright webServer 設定: dev container vs ローカル環境（2026-04-19）

> 出典: `docs/knowledge/reflected/test-patterns/20260419_playwright-config-local-vs-devcontainer.md`

**Do:**
- `webServer.command` はクロスプラットフォームなコマンド（`go run`、`npm run` 等）を使う
- `cwd` は `playwright.config.ts` からの相対パスで指定する
- 環境変数は `env` プロパティで渡す（コマンド文字列に埋め込まない）
- `go run` を使う場合は `timeout` を 30000ms 以上に設定する（コンパイル時間を考慮）
- 共有 DB を使う場合は `workers: 1` を設定して並列アクセスを防ぐ

**Don't:**
- Linux 絶対パスを `webServer.command` や `cwd` にハードコードしない（dev container 専用になる）
- コンパイル済みバイナリのパスを直接指定しない（環境依存になる）
- バックエンド用コンテナ・バイナリが `PATH` に存在することを前提にしない

---

### TanStack Query の retry が Playwright エラーフロー E2E テストを誤動作させる（2026-04-19）

> 出典: `docs/knowledge/reflected/test-patterns/20260419_tanstack-query-retry-e2e-intercept.md`

**Do:**
- エラーフロー E2E テスト設計時に、TanStack Query / SWR 等のリトライ設定（`retry` の値）を事前に確認する
- `page.route()` でエラーを再現するとき、`page.unroute()` を呼ぶまで全リクエストをインターセプトし続ける形にする（1回だけ返すのではなく常に返す）
- 「エラー後に正常復旧する」を検証する場合は `page.unroute()` でインターセプトを解除してから再試行させる

**Don't:**
- TanStack Query の `retry` 設定を無視してエラーシナリオのテストを設計しない
- 「1回だけ 500 を返せば必ずエラー画面が出る」という前提でテストを書かない（リトライにより成功してしまう）
