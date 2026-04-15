# [機能名] バックエンド結合テスト

| 項目 | 内容 |
|------|------|
| テスト対象 | [機能名]のAPIエンドポイント / リポジトリ |
| テストツール | Jest + Supertest + TestDB |
| 作成日 | YYYY-MM-DD |
| 作成者 | 氏名 |

---

## テスト計画

| # | テストシナリオ | 優先度 | ステータス |
|---|-------------|--------|---------|
| 1 | 正常系: リソースの CRUD 操作全体 | 高 | 未着手 |
| 2 | 認証: JWTなしで401が返る | 高 | 未着手 |
| 3 | 認可: 他ユーザーのリソース操作で403が返る | 高 | 未着手 |
| 4 | バリデーション: 不正入力で400が返る | 高 | 未着手 |
| 5 | 冪等性: 同一リクエストを複数回送っても安全 | 中 | 未着手 |
| 6 | トランザクション: エラー時にロールバックされる | 中 | 未着手 |

---

## APIエンドポイント結合テストコード

```typescript
import request from 'supertest';
import { app } from '../app';
import { db } from '../lib/db';
import { createTestUser, createTestResource } from '../test-helpers/factories';
import { generateToken } from '../test-helpers/auth';

// --- テスト全体のセットアップ ---

beforeAll(async () => {
  await db.$connect();
});

afterAll(async () => {
  await db.$disconnect();
});

afterEach(async () => {
  // テストデータをクリーンアップ（テーブルのtruncate等）
  await db.resource.deleteMany();
  await db.user.deleteMany();
});

// --- ヘルパー ---

async function setupUser() {
  const user = await db.user.create({ data: createTestUser() });
  const token = generateToken({ userId: user.id });
  return { user, token };
}

// --- テストスイート ---

describe('Resources API', () => {

  // ==========================================
  // GET /api/v1/resources
  // ==========================================

  describe('GET /api/v1/resources', () => {

    it('認証済みユーザーが自分のリソース一覧を取得できる', async () => {
      // Arrange
      const { user, token } = await setupUser();
      await db.resource.createMany({
        data: [
          { userId: user.id, name: 'リソース1' },
          { userId: user.id, name: 'リソース2' },
        ],
      });

      // 他のユーザーのリソース（取得されないこと）
      const otherUser = await db.user.create({ data: createTestUser() });
      await db.resource.create({ data: { userId: otherUser.id, name: '他のリソース' } });

      // Act
      const response = await request(app)
        .get('/api/v1/resources')
        .set('Authorization', `Bearer ${token}`);

      // Assert
      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveLength(2);
      expect(response.body.data.map((r: any) => r.name)).toEqual(
        expect.arrayContaining(['リソース1', 'リソース2'])
      );
      // 他のユーザーのリソースは含まれない
      expect(response.body.data.map((r: any) => r.name)).not.toContain('他のリソース');
    });

    it('認証なしで401を返す', async () => {
      const response = await request(app).get('/api/v1/resources');
      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
    });

    it('リソースが0件の場合に空配列を返す', async () => {
      const { token } = await setupUser();

      const response = await request(app)
        .get('/api/v1/resources')
        .set('Authorization', `Bearer ${token}`);

      expect(response.status).toBe(200);
      expect(response.body.data).toEqual([]);
    });

  });

  // ==========================================
  // POST /api/v1/resources
  // ==========================================

  describe('POST /api/v1/resources', () => {

    it('正常なリクエストでリソースが作成され201を返す', async () => {
      const { user, token } = await setupUser();

      const response = await request(app)
        .post('/api/v1/resources')
        .set('Authorization', `Bearer ${token}`)
        .send({ name: '新しいリソース', description: '説明文' });

      // レスポンス検証
      expect(response.status).toBe(201);
      expect(response.body.success).toBe(true);
      expect(response.body.data.name).toBe('新しいリソース');
      expect(response.body.data.id).toBeDefined();

      // DBに実際に保存されていることを確認
      const saved = await db.resource.findFirst({ where: { userId: user.id } });
      expect(saved).not.toBeNull();
      expect(saved?.name).toBe('新しいリソース');
    });

    it('nameが空文字の場合に400を返す', async () => {
      const { token } = await setupUser();

      const response = await request(app)
        .post('/api/v1/resources')
        .set('Authorization', `Bearer ${token}`)
        .send({ name: '' });

      expect(response.status).toBe(400);
      expect(response.body.error.code).toBe('VALIDATION_ERROR');

      // DBに保存されていないことを確認
      const count = await db.resource.count();
      expect(count).toBe(0);
    });

    it('nameが100文字を超える場合に400を返す', async () => {
      const { token } = await setupUser();
      const tooLongName = 'a'.repeat(101);

      const response = await request(app)
        .post('/api/v1/resources')
        .set('Authorization', `Bearer ${token}`)
        .send({ name: tooLongName });

      expect(response.status).toBe(400);
    });

  });

  // ==========================================
  // PUT /api/v1/resources/:id
  // ==========================================

  describe('PUT /api/v1/resources/:id', () => {

    it('オーナーがリソースを更新できる', async () => {
      const { user, token } = await setupUser();
      const resource = await db.resource.create({
        data: { userId: user.id, name: '元の名前' },
      });

      const response = await request(app)
        .put(`/api/v1/resources/${resource.id}`)
        .set('Authorization', `Bearer ${token}`)
        .send({ name: '更新された名前' });

      expect(response.status).toBe(200);
      expect(response.body.data.name).toBe('更新された名前');

      // DBが更新されていることを確認
      const updated = await db.resource.findUnique({ where: { id: resource.id } });
      expect(updated?.name).toBe('更新された名前');
    });

    it('他のユーザーのリソースを更新しようとすると403を返す', async () => {
      // 別のユーザーのリソースを作成
      const otherUser = await db.user.create({ data: createTestUser() });
      const resource = await db.resource.create({
        data: { userId: otherUser.id, name: '他のリソース' },
      });

      // 自分のトークンで他ユーザーのリソースを更新しようとする
      const { token } = await setupUser();
      const response = await request(app)
        .put(`/api/v1/resources/${resource.id}`)
        .set('Authorization', `Bearer ${token}`)
        .send({ name: '書き換え試行' });

      expect(response.status).toBe(403);

      // DBが変更されていないことを確認
      const unchanged = await db.resource.findUnique({ where: { id: resource.id } });
      expect(unchanged?.name).toBe('他のリソース');
    });

    it('存在しないIDを指定すると404を返す', async () => {
      const { token } = await setupUser();

      const response = await request(app)
        .put('/api/v1/resources/non-existent-id')
        .set('Authorization', `Bearer ${token}`)
        .send({ name: '更新' });

      expect(response.status).toBe(404);
    });

  });

  // ==========================================
  // DELETE /api/v1/resources/:id
  // ==========================================

  describe('DELETE /api/v1/resources/:id', () => {

    it('オーナーがリソースを削除できる', async () => {
      const { user, token } = await setupUser();
      const resource = await db.resource.create({
        data: { userId: user.id, name: '削除対象' },
      });

      const response = await request(app)
        .delete(`/api/v1/resources/${resource.id}`)
        .set('Authorization', `Bearer ${token}`);

      expect(response.status).toBe(204);

      // DBから削除されていることを確認
      const deleted = await db.resource.findUnique({ where: { id: resource.id } });
      expect(deleted).toBeNull();
    });

  });

});
```

---

## リポジトリ層 結合テストコード

```typescript
import { db } from '../lib/db';
import { UserRepository } from './UserRepository';
import { createTestUser } from '../test-helpers/factories';

describe('UserRepository (DB Integration)', () => {
  let repo: UserRepository;

  beforeEach(() => {
    repo = new UserRepository(db);
  });

  afterEach(async () => {
    await db.user.deleteMany();
  });

  it('ユーザーをメールアドレスで検索できる', async () => {
    // Arrange
    const userData = createTestUser({ email: 'find-me@example.com' });
    await db.user.create({ data: userData });

    // Act
    const found = await repo.findByEmail('find-me@example.com');

    // Assert
    expect(found).not.toBeNull();
    expect(found?.email).toBe('find-me@example.com');
  });

  it('存在しないメールアドレスではnullを返す', async () => {
    const found = await repo.findByEmail('nobody@example.com');
    expect(found).toBeNull();
  });

  it('トランザクション失敗時にロールバックされる', async () => {
    const initialCount = await db.user.count();

    await expect(
      db.$transaction(async (tx) => {
        await tx.user.create({ data: createTestUser() });
        throw new Error('意図的なエラー'); // トランザクションを失敗させる
      })
    ).rejects.toThrow('意図的なエラー');

    // カウントが変わっていないことを確認（ロールバック確認）
    const finalCount = await db.user.count();
    expect(finalCount).toBe(initialCount);
  });

});
```
