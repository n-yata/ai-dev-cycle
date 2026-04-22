# フロントエンド 単体テストガイド

---

## 使用ツール

| ツール | 用途 |
|--------|------|
| Vitest / Jest | テストランナー |
| React Testing Library | コンポーネントのレンダリング・操作 |
| MSW (Mock Service Worker) | APIモック |
| @testing-library/user-event | ユーザー操作のシミュレーション |

---

## テスト対象と方針

### コンポーネントテスト

- レンダリングの確認（正しいUIが表示されるか）
- ユーザーインタラクション（クリック・入力に対する動作）
- Propsによる表示の変化
- 非同期処理（データ取得・送信）

```typescript
// Good: ユーザー視点でテストする
test('ログインボタンをクリックするとフォームが送信される', async () => {
  render(<LoginForm onSubmit={mockSubmit} />);
  
  await userEvent.type(screen.getByLabelText('メールアドレス'), 'user@example.com');
  await userEvent.type(screen.getByLabelText('パスワード'), 'password123');
  await userEvent.click(screen.getByRole('button', { name: 'ログイン' }));
  
  expect(mockSubmit).toHaveBeenCalledWith({
    email: 'user@example.com',
    password: 'password123',
  });
});
```

### カスタムフックテスト

```typescript
import { renderHook, act } from '@testing-library/react';

test('useCounter: インクリメントで値が増加する', () => {
  const { result } = renderHook(() => useCounter(0));
  
  act(() => {
    result.current.increment();
  });
  
  expect(result.current.count).toBe(1);
});
```

### ユーティリティ関数テスト

```typescript
test('formatDate: ISO8601文字列を日本語形式に変換する', () => {
  expect(formatDate('2026-04-14T09:00:00Z')).toBe('2026年4月14日');
});

test('formatDate: 無効な日付文字列はハイフンを返す', () => {
  expect(formatDate('invalid-date')).toBe('-');
});
```

---

## アンチパターン（避けるべきこと）

```typescript
// Bad: 実装の詳細をテストする
expect(component.state.isLoading).toBe(false); // 内部状態を直接確認

// Good: ユーザーが見える動作をテストする
expect(screen.queryByRole('progressbar')).not.toBeInTheDocument();
```

```typescript
// Bad: 意味のないアサーション
test('コンポーネントが存在する', () => {
  render(<MyComponent />);
  expect(true).toBe(true); // テストになっていない
});
```

テスト計画書のテンプレートは [test-plan.template.md](../test-plan.template.md) を参照してください。
