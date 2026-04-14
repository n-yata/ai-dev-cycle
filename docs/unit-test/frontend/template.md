# [コンポーネント/機能名] フロントエンド単体テスト

| 項目 | 内容 |
|------|------|
| テスト対象 | `src/features/.../ComponentName.tsx` |
| 作成日 | YYYY-MM-DD |
| 作成者 | 氏名 |

---

## テスト計画

| # | テストケース | 優先度 | ステータス |
|---|------------|--------|---------|
| 1 | 正常系: デフォルト状態でのレンダリング | 高 | 未着手 |
| 2 | 正常系: Propsに応じた表示変化 | 高 | 未着手 |
| 3 | 正常系: ユーザー操作（クリック・入力） | 高 | 未着手 |
| 4 | 異常系: エラー状態の表示 | 高 | 未着手 |
| 5 | 異常系: ローディング状態の表示 | 中 | 未着手 |
| 6 | 境界値: 空データ / 最大データ | 中 | 未着手 |

---

## テストコード

```typescript
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { vi, describe, it, expect, beforeEach } from 'vitest';
import { ComponentName } from './ComponentName';

// --- モックの設定 ---

// APIモック（MSW使用の場合はserver.useで上書き）
vi.mock('@/lib/api', () => ({
  fetchData: vi.fn(),
}));

const mockOnAction = vi.fn();

// --- テストスイート ---

describe('ComponentName', () => {

  beforeEach(() => {
    vi.clearAllMocks();
  });

  // ==========================================
  // 正常系
  // ==========================================

  describe('正常系', () => {

    it('デフォルトProps でコンポーネントが正しくレンダリングされる', () => {
      // Arrange
      const props = {
        title: 'テストタイトル',
        onAction: mockOnAction,
      };

      // Act
      render(<ComponentName {...props} />);

      // Assert
      expect(screen.getByText('テストタイトル')).toBeInTheDocument();
      expect(screen.getByRole('button', { name: '実行' })).toBeInTheDocument();
    });

    it('ボタンをクリックすると onAction が呼ばれる', async () => {
      // Arrange
      const user = userEvent.setup();
      render(<ComponentName title="テスト" onAction={mockOnAction} />);

      // Act
      await user.click(screen.getByRole('button', { name: '実行' }));

      // Assert
      expect(mockOnAction).toHaveBeenCalledOnce();
      expect(mockOnAction).toHaveBeenCalledWith(/* 期待する引数 */);
    });

    it('入力値を変更するとフォームの値が更新される', async () => {
      // Arrange
      const user = userEvent.setup();
      render(<ComponentName title="テスト" onAction={mockOnAction} />);

      // Act
      await user.type(screen.getByLabelText('名前'), '山田太郎');

      // Assert
      expect(screen.getByDisplayValue('山田太郎')).toBeInTheDocument();
    });

    it('データ取得中はローディング表示になる', () => {
      // Arrange
      // fetchData が pending 状態のモックを設定

      // Act
      render(<ComponentName title="テスト" onAction={mockOnAction} />);

      // Assert
      expect(screen.getByRole('progressbar')).toBeInTheDocument();
      expect(screen.queryByText('データ')).not.toBeInTheDocument();
    });

    it('データ取得後にリストが表示される', async () => {
      // Arrange
      const mockData = [
        { id: '1', name: 'アイテム1' },
        { id: '2', name: 'アイテム2' },
      ];
      // fetchData のモックを設定

      // Act
      render(<ComponentName title="テスト" onAction={mockOnAction} />);

      // Assert
      await waitFor(() => {
        expect(screen.getByText('アイテム1')).toBeInTheDocument();
        expect(screen.getByText('アイテム2')).toBeInTheDocument();
      });
    });

  });

  // ==========================================
  // 異常系
  // ==========================================

  describe('異常系', () => {

    it('API エラー時にエラーメッセージが表示される', async () => {
      // Arrange
      // fetchData がエラーを返すモックを設定

      // Act
      render(<ComponentName title="テスト" onAction={mockOnAction} />);

      // Assert
      await waitFor(() => {
        expect(screen.getByRole('alert')).toBeInTheDocument();
        expect(screen.getByText('データの取得に失敗しました')).toBeInTheDocument();
      });
    });

    it('必須フィールドが空の場合にバリデーションエラーが表示される', async () => {
      // Arrange
      const user = userEvent.setup();
      render(<ComponentName title="テスト" onAction={mockOnAction} />);

      // Act
      await user.click(screen.getByRole('button', { name: '送信' }));

      // Assert
      expect(screen.getByText('名前は必須です')).toBeInTheDocument();
      expect(mockOnAction).not.toHaveBeenCalled();
    });

  });

  // ==========================================
  // 境界値
  // ==========================================

  describe('境界値', () => {

    it('データが空の場合に空状態の表示になる', async () => {
      // Arrange
      // fetchData が空配列を返すモックを設定

      // Act
      render(<ComponentName title="テスト" onAction={mockOnAction} />);

      // Assert
      await waitFor(() => {
        expect(screen.getByText('データがありません')).toBeInTheDocument();
      });
    });

  });

});
```

---

## カスタムフックのテンプレート

```typescript
import { renderHook, act } from '@testing-library/react';
import { useHookName } from './useHookName';

describe('useHookName', () => {

  it('初期状態が正しい', () => {
    const { result } = renderHook(() => useHookName());
    expect(result.current.value).toBe(/* 期待する初期値 */);
  });

  it('action を呼ぶと状態が更新される', () => {
    const { result } = renderHook(() => useHookName());

    act(() => {
      result.current.action(/* 引数 */);
    });

    expect(result.current.value).toBe(/* 期待する更新後の値 */);
  });

});
```
