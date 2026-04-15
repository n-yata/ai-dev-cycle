# バックエンド 単体テストガイド

---

## 使用ツール

| ツール | 用途 |
|--------|------|
| Jest / Vitest | テストランナー |
| Supertest | HTTPリクエストのテスト |
| testcontainers | DBの本物環境でのテスト |
| ts-jest | TypeScriptサポート |

---

## テスト対象と方針

### サービス層テスト

ビジネスロジックに集中し、リポジトリ層はモック化する。

```typescript
describe('UserService', () => {
  let service: UserService;
  let mockUserRepo: jest.Mocked<UserRepository>;

  beforeEach(() => {
    mockUserRepo = {
      findByEmail: jest.fn(),
      create: jest.fn(),
    };
    service = new UserService(mockUserRepo);
  });

  it('既存メールアドレスで登録するとConflictErrorが発生する', async () => {
    // Arrange
    mockUserRepo.findByEmail.mockResolvedValue({ id: '1', email: 'test@example.com' });

    // Act & Assert
    await expect(
      service.createUser({ email: 'test@example.com', password: 'password123', name: 'テスト' })
    ).rejects.toThrow(ConflictError);
  });
});
```

### ユーティリティ関数テスト

```typescript
describe('validateEmail', () => {
  it.each([
    ['valid@example.com', true],
    ['invalid-email', false],
    ['', false],
    ['@no-local.com', false],
  ])('validateEmail(%s) => %s', (email, expected) => {
    expect(validateEmail(email)).toBe(expected);
  });
});
```

### ハンドラーテスト (Supertest)

```typescript
describe('POST /api/v1/users', () => {
  it('正常なリクエストで201とユーザーデータを返す', async () => {
    const response = await request(app)
      .post('/api/v1/users')
      .set('Authorization', `Bearer ${validToken}`)
      .send({ name: '山田太郎', email: 'yamada@example.com', password: 'password123' });

    expect(response.status).toBe(201);
    expect(response.body.success).toBe(true);
    expect(response.body.data.email).toBe('yamada@example.com');
    expect(response.body.data.password).toBeUndefined(); // パスワードは返さない
  });
});
```

---

## アンチパターン（避けるべきこと）

```typescript
// Bad: 意味のないテスト（ただのハードコーディング）
it('ユーザーIDが1を返す', () => {
  expect(getUserId()).toBe(1); // ロジックをテストしていない
});

// Bad: 本番コードにテスト用の条件分岐を入れる
if (process.env.NODE_ENV === 'test') {
  return hardcodedTestValue; // 絶対禁止
}
```

テンプレートは [template.md](template.md) を参照してください。
