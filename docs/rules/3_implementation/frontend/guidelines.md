# フロントエンド コーディングガイドライン

---

## 1. ファイル・命名規則

| 対象 | 規則 | 例 |
|------|------|-----|
| コンポーネントファイル | PascalCase | `UserCard.tsx` |
| フックファイル | camelCase (useで始める) | `useUserData.ts` |
| ユーティリティ | camelCase | `formatDate.ts` |
| 型定義ファイル | camelCase | `userTypes.ts` |
| テストファイル | 対象ファイル名 + `.test` | `UserCard.test.tsx` |

---

## 2. コンポーネント実装

### 関数コンポーネントを使用する

```typescript
// Good
const UserCard = ({ name, email }: UserCardProps) => {
  return <div>{name}</div>;
};

// Bad
class UserCard extends React.Component { ... }
```

### Props型は明示的に定義する

```typescript
// Good
type UserCardProps = {
  name: string;
  email: string;
  onEdit?: (id: string) => void;
};

const UserCard = ({ name, email, onEdit }: UserCardProps) => { ... };

// Bad
const UserCard = (props: any) => { ... };
```

### デフォルトexportより名前付きexportを優先する

```typescript
// Good
export const UserCard = (...) => { ... };

// Bad (デフォルトexportはリファクタリング時に名前が追跡しにくい)
export default UserCard;
```

---

## 3. 状態管理

### useState は単純な状態に使用する

```typescript
// Good: シンプルな状態
const [isOpen, setIsOpen] = useState(false);
const [count, setCount] = useState(0);
```

### 複数の関連する状態は useReducer で管理する

```typescript
// Good: 関連する状態をまとめる
type FormState = {
  name: string;
  email: string;
  isSubmitting: boolean;
  error: string | null;
};

const [state, dispatch] = useReducer(formReducer, initialState);
```

### サーバーデータは React Query / SWR で管理する

```typescript
// Good: サーバー状態の管理
const { data, isLoading, error } = useQuery({
  queryKey: ['users', userId],
  queryFn: () => fetchUser(userId),
});
```

---

## 4. カスタムフック

### ビジネスロジックはカスタムフックに切り出す

```typescript
// Good: ロジックをフックに分離
const useUserForm = (userId: string) => {
  const [formData, setFormData] = useState<UserFormData>(initialData);
  const { mutate, isLoading } = useUpdateUser();

  const handleSubmit = async (data: UserFormData) => {
    await mutate({ userId, ...data });
  };

  return { formData, setFormData, handleSubmit, isLoading };
};

// コンポーネントはフックを呼ぶだけ
const UserForm = ({ userId }: { userId: string }) => {
  const { formData, handleSubmit, isLoading } = useUserForm(userId);
  return <form onSubmit={handleSubmit}>...</form>;
};
```

---

## 5. エラーハンドリング

### try-catch は必要最小限にとどめる

```typescript
// Good: React Query のエラーハンドリング活用
const { data, error } = useQuery({ ... });

if (error) return <ErrorMessage message={error.message} />;
```

### ユーザーへのフィードバックを忘れずに

```typescript
// Good: エラー時にユーザーへ通知
const handleSubmit = async () => {
  try {
    await submitData();
    toast.success('保存しました');
  } catch (err) {
    toast.error('保存に失敗しました。もう一度お試しください。');
  }
};
```

---

## 6. パフォーマンス

### 不必要なレンダリングを避ける

```typescript
// Good: 純粋なコンポーネントはmemoで最適化
const UserList = memo(({ users }: { users: User[] }) => {
  return <ul>{users.map(u => <li key={u.id}>{u.name}</li>)}</ul>;
});

// Good: コールバックはuseCallbackで安定化
const handleDelete = useCallback((id: string) => {
  deleteUser(id);
}, [deleteUser]);
```

### 重い計算はuseMemoで最適化する

```typescript
const filteredUsers = useMemo(
  () => users.filter(u => u.role === selectedRole),
  [users, selectedRole]
);
```

---

## 7. セキュリティ

### dangerouslySetInnerHTML を使わない

```typescript
// Bad: XSS脆弱性
<div dangerouslySetInnerHTML={{ __html: userInput }} />

// Good: テキストとして表示
<div>{userInput}</div>
```

### URLパラメータはバリデーションする

```typescript
// Good: パスパラメータを検証
const { id } = useParams<{ id: string }>();
if (!isValidUUID(id)) {
  return <Navigate to="/404" />;
}
```

### 機密情報をログに出力しない

```typescript
// Bad
console.log('Login response:', response); // トークンが含まれる可能性

// Good
console.log('Login successful for user:', response.data.userId);
```

---

## 8. アクセシビリティ

- インタラクティブ要素には適切な `aria-label` を付ける
- フォームラベルと入力を `htmlFor` で関連付ける
- アイコンのみのボタンには `aria-label` を必ず付ける
- フォーカスの視覚的フィードバックを削除しない（`outline: none` を避ける）
