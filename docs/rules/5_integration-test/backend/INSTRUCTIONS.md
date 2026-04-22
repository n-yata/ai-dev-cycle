# バックエンド 結合テストガイド

---

## 使用ツール

| ツール | 用途 |
|--------|------|
| Jest / Vitest | テストランナー |
| Supertest | HTTPリクエストの送受信 |
| testcontainers | 本物のDBコンテナをテスト中に起動 |
| Prisma / Knex | DBマイグレーション・クリーンアップ |

---

## テストの種類と方針

### APIエンドポイント統合テスト

実際のDBを使い、HTTPリクエストからDBへの書き込み・読み取りまでの一連のフローを検証する。

**対象:**
- 全APIエンドポイントの正常系・異常系
- 認証・認可フロー
- データの永続化確認

### DBアクセス統合テスト

リポジトリ層のテスト。モックなしで実際のDBに対して操作を行い、クエリの正確性を検証する。

**対象:**
- 複雑なクエリ・JOIN・集計
- トランザクションの整合性
- インデックスの効果（クエリ計画の確認）

---

## テスト環境のセットアップ

```typescript
// jest.setup.ts
import { setupTestDB, teardownTestDB } from './test-helpers/db';

beforeAll(async () => {
  await setupTestDB(); // テスト用DB起動・マイグレーション
});

afterAll(async () => {
  await teardownTestDB(); // テスト用DB停止
});

afterEach(async () => {
  await cleanupTestData(); // 各テスト後にデータをリセット
});
```

---

## テストデータ管理

- **ファクトリ関数** を使ってテストデータを生成する
- テスト間のデータ干渉を防ぐため、各テストでユニークなデータを使用する
- テスト終了後は必ずデータをクリーンアップする

```typescript
// test-helpers/factories.ts
export const createTestUser = (overrides = {}) => ({
  email: `test-${Date.now()}@example.com`,
  name: 'テストユーザー',
  password: 'hashedPassword',
  ...overrides,
});
```

テストシナリオのテンプレートは [test-scenario.template.md](../test-scenario.template.md) を参照してください。
