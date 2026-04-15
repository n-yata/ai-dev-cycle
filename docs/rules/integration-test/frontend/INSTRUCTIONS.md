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
