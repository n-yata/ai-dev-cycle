# [機能名] フロントエンド結合テスト

| 項目 | 内容 |
|------|------|
| テスト対象 | [機能名]の主要ユーザーフロー |
| テストツール | Playwright / React Testing Library + MSW |
| 作成日 | YYYY-MM-DD |
| 作成者 | 氏名 |

---

## テスト計画

| # | テストシナリオ | 優先度 | ステータス |
|---|-------------|--------|---------|
| 1 | ゴールデンパス: 正常な操作フロー全体 | 高 | 未着手 |
| 2 | 認証フロー: ログイン〜機能利用〜ログアウト | 高 | 未着手 |
| 3 | エラーフロー: APIエラー時の画面遷移 | 高 | 未着手 |
| 4 | データ操作: 作成→表示→編集→削除 | 中 | 未着手 |
| 5 | 入力バリデーション: 不正入力時のエラー表示 | 中 | 未着手 |

---

## E2Eテストコード（Playwright）

```typescript
import { test, expect, Page } from '@playwright/test';

// --- テストデータ ---

const TEST_USER = {
  email: 'e2e-test@example.com',
  password: 'TestPassword123!',
  name: 'E2Eテストユーザー',
};

// --- ヘルパー関数 ---

async function loginAs(page: Page, email: string, password: string) {
  await page.goto('/login');
  await page.getByLabel('メールアドレス').fill(email);
  await page.getByLabel('パスワード').fill(password);
  await page.getByRole('button', { name: 'ログイン' }).click();
  await page.waitForURL('/dashboard');
}

// --- テストスイート ---

test.describe('[機能名]', () => {

  test.beforeEach(async ({ page }) => {
    // 必要に応じてテストデータのセットアップ
    await loginAs(page, TEST_USER.email, TEST_USER.password);
  });

  // ==========================================
  // ゴールデンパス
  // ==========================================

  test('ゴールデンパス: リソースの作成から削除まで', async ({ page }) => {
    // Step 1: リソース一覧ページへ移動
    await page.goto('/resources');
    await expect(page.getByRole('heading', { name: 'リソース一覧' })).toBeVisible();

    // Step 2: 新規作成ボタンをクリック
    await page.getByRole('button', { name: '新規作成' }).click();
    await expect(page.getByRole('dialog')).toBeVisible();

    // Step 3: フォームに入力
    await page.getByLabel('名前').fill('テストリソース');
    await page.getByLabel('説明').fill('テスト用の説明文');

    // Step 4: 保存
    await page.getByRole('button', { name: '保存' }).click();

    // Step 5: 一覧に反映されていることを確認
    await expect(page.getByText('テストリソース')).toBeVisible();
    await expect(page.getByText('保存しました')).toBeVisible(); // トースト通知

    // Step 6: 詳細ページへ遷移
    await page.getByText('テストリソース').click();
    await expect(page.getByRole('heading', { name: 'テストリソース' })).toBeVisible();
    await expect(page.getByText('テスト用の説明文')).toBeVisible();

    // Step 7: 編集
    await page.getByRole('button', { name: '編集' }).click();
    await page.getByLabel('名前').clear();
    await page.getByLabel('名前').fill('更新されたリソース');
    await page.getByRole('button', { name: '更新' }).click();
    await expect(page.getByRole('heading', { name: '更新されたリソース' })).toBeVisible();

    // Step 8: 削除
    await page.getByRole('button', { name: '削除' }).click();
    await page.getByRole('button', { name: '確認' }).click(); // 確認ダイアログ
    await page.waitForURL('/resources');
    await expect(page.getByText('更新されたリソース')).not.toBeVisible();
  });

  // ==========================================
  // エラーフロー
  // ==========================================

  test('APIエラー時にエラーメッセージが表示される', async ({ page }) => {
    // APIが失敗するシナリオをセットアップ（MSWなどでAPIをモック）
    await page.route('/api/v1/resources', route => {
      route.fulfill({ status: 500, json: { success: false, error: { message: 'サーバーエラー' } } });
    });

    await page.goto('/resources');

    // エラーメッセージが表示されることを確認
    await expect(page.getByRole('alert')).toBeVisible();
    await expect(page.getByText('データの取得に失敗しました')).toBeVisible();
  });

  // ==========================================
  // バリデーション
  // ==========================================

  test('フォームバリデーション: 必須フィールドが空の場合エラーが表示される', async ({ page }) => {
    await page.goto('/resources/new');

    // 空のまま送信
    await page.getByRole('button', { name: '保存' }).click();

    // バリデーションエラーの表示を確認
    await expect(page.getByText('名前は必須です')).toBeVisible();

    // 送信されていないことを確認（URLが変わらない）
    await expect(page).toHaveURL('/resources/new');
  });

  // ==========================================
  // 認証フロー
  // ==========================================

  test('未認証ユーザーは保護ページにアクセスできない', async ({ page }) => {
    // ログアウト状態でアクセス
    await page.context().clearCookies();
    await page.goto('/resources');

    // ログインページにリダイレクトされることを確認
    await expect(page).toHaveURL('/login');
  });

});
```

---

## React Testing Library + MSW による統合テンプレート

```typescript
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { setupServer } from 'msw/node';
import { http, HttpResponse } from 'msw';
import { FeaturePage } from './FeaturePage';
import { TestProviders } from '../test-helpers/TestProviders';

// --- MSWサーバーのセットアップ ---

const server = setupServer(
  http.get('/api/v1/resources', () => {
    return HttpResponse.json({
      success: true,
      data: [
        { id: '1', name: 'リソース1' },
        { id: '2', name: 'リソース2' },
      ],
    });
  }),
  http.post('/api/v1/resources', async ({ request }) => {
    const body = await request.json() as { name: string };
    return HttpResponse.json({
      success: true,
      data: { id: '3', name: body.name },
    }, { status: 201 });
  }),
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

// --- テスト ---

describe('FeaturePage (統合テスト)', () => {

  it('ページ表示時にAPIからデータを取得して一覧表示する', async () => {
    render(
      <TestProviders>
        <FeaturePage />
      </TestProviders>
    );

    // ローディング中はスケルトンが表示される
    expect(screen.getByTestId('loading-skeleton')).toBeInTheDocument();

    // データ取得後に一覧が表示される
    await waitFor(() => {
      expect(screen.getByText('リソース1')).toBeInTheDocument();
      expect(screen.getByText('リソース2')).toBeInTheDocument();
    });
  });

  it('新規作成フォームを送信するとリストに追加される', async () => {
    const user = userEvent.setup();
    render(
      <TestProviders>
        <FeaturePage />
      </TestProviders>
    );

    await waitFor(() => {
      expect(screen.getByText('リソース1')).toBeInTheDocument();
    });

    // フォームを開いて入力・送信
    await user.click(screen.getByRole('button', { name: '新規作成' }));
    await user.type(screen.getByLabelText('名前'), '新しいリソース');
    await user.click(screen.getByRole('button', { name: '保存' }));

    // リストに追加されることを確認
    await waitFor(() => {
      expect(screen.getByText('新しいリソース')).toBeInTheDocument();
    });
  });

  it('APIエラー時にエラーメッセージを表示する', async () => {
    server.use(
      http.get('/api/v1/resources', () => {
        return HttpResponse.json({ success: false }, { status: 500 });
      }),
    );

    render(
      <TestProviders>
        <FeaturePage />
      </TestProviders>
    );

    await waitFor(() => {
      expect(screen.getByRole('alert')).toBeInTheDocument();
    });
  });

});
```
