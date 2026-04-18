# TanStack Query の retry が Playwright エラーフロー E2E テストを誤動作させる — ナレッジ記録

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

> TanStack Query に `retry: 1`（または任意の正の値）が設定されている場合、Playwright の `page.route()` で 1回だけ 500 エラーを返しても自動リトライが成功してしまい、エラー画面の表示を検証するテストが通らない。インターセプトを「リトライ回数 + 1」回分返す必要がある。

---

## 背景・コンテキスト

**状況:** Playwright の E2E テスト（error-flow）で「GET /todos が 500 のときエラー画面が表示される」を検証しようとした。

**課題・問題:** `route.fulfill({status: 500})` を1回だけ設定したところ、TanStack Query が自動リトライして 2回目のリクエストは実際の BE に到達し成功。エラー画面が表示されずテストが失敗した。

---

## 事実（何が起きたか / 何を決めたか）

- フロントエンドで TanStack Query の `useQuery` に `retry: 1` が設定されていた
- Playwright で `page.route('**/api/v1/todos', route => route.fulfill({status: 500}))` を使うと、1回インターセプトした後は通常リクエストが流れる
- TanStack Query が初回エラー後に自動リトライ → 通常の BE に到達 → 成功レスポンス → エラー画面が出ない
- 修正: `times` オプション不使用で「常に500を返す」か、リトライ回数 + 1 回分インターセプトする

---

## 理由・分析

### 根本原因

```
直接原因: page.route() が1回だけインターセプトし、その後リクエストが素通りした
根本原因: TanStack Query の retry 設定を考慮せずにエラーシナリオのテストを設計した
```

---

## 具体例・コード

### ビフォー（問題のあるパターン）

```typescript
// retry: 1 の場合、初回は500が返るが2回目のリトライは通常BEに到達してしまう
await page.route('**/api/v1/todos', async (route) => {
  await route.fulfill({ status: 500 });
});
await page.goto('/');
await expect(page.getByText('サーバーエラーが発生しました')).toBeVisible(); // 失敗
```

### アフター（改善後のパターン）

```typescript
// 常に500を返すことで、何回リトライしても必ずエラーになる
await page.route('**/api/v1/todos', async (route) => {
  await route.fulfill({ status: 500 });
});
// ↑ unroute しない限り全リクエストが500になるのでリトライも失敗する

await page.goto('/');
await expect(page.getByText('サーバーエラーが発生しました')).toBeVisible(); // 成功
```

---

## 次回への示唆

### すべきこと（Do）

- [x] エラーフロー E2E テスト設計時に、フロントの TanStack Query / SWR 等のリトライ設定を確認する
- [x] `page.route()` でエラーを再現するとき、`unroute` を明示的に呼ぶまで全リクエストをインターセプトし続ける形にする
- [x] テストが「エラー後に正常復旧する」を検証する場合は、`page.unroute()` でインターセプトを解除してから再試行させる

### 避けること（Don't）

- TanStack Query の `retry` 設定を無視してエラーシナリオのテストを設計しない
- 「1回だけ 500 を返せば必ずエラー画面が出る」という前提でテストを書かない

### チェックリストへの追加提案

- [ ] `docs/rules/integration-test/frontend/INSTRUCTIONS.md` に追加: `page.route() でエラー再現するときは、TanStack Query 等のリトライ設定を確認し、リトライ分もインターセプトされるよう設計する`

---

## タグ

`tanstack-query`, `retry`, `playwright`, `page.route`, `e2e`, `error-flow`, `intercept`
