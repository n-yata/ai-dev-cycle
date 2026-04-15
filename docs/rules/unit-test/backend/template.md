# [サービス/モジュール名] バックエンド単体テスト

| 項目 | 内容 |
|------|------|
| テスト対象 | `src/services/ServiceName.ts` |
| 作成日 | YYYY-MM-DD |
| 作成者 | 氏名 |

---

## テスト計画

| # | テストケース | 優先度 | ステータス |
|---|------------|--------|---------|
| 1 | 正常系: 基本的な正常フロー | 高 | 未着手 |
| 2 | 正常系: 各種入力パターン | 高 | 未着手 |
| 3 | 異常系: バリデーションエラー | 高 | 未着手 |
| 4 | 異常系: リソース未存在 | 高 | 未着手 |
| 5 | 異常系: 認証・認可エラー | 高 | 未着手 |
| 6 | 境界値: 入力値の境界 | 中 | 未着手 |

---

## テストコード

### サービス層テンプレート

```typescript
import { describe, it, expect, beforeEach, jest } from '@jest/globals';
import { ServiceName } from './ServiceName';
import { DependencyRepository } from '../repositories/DependencyRepository';
import { NotFoundError, ValidationError, ConflictError } from '../errors';

// --- モックの設定 ---

jest.mock('../repositories/DependencyRepository');

describe('ServiceName', () => {
  let service: ServiceName;
  let mockRepo: jest.Mocked<DependencyRepository>;

  beforeEach(() => {
    jest.clearAllMocks();
    mockRepo = new DependencyRepository() as jest.Mocked<DependencyRepository>;
    service = new ServiceName(mockRepo);
  });

  // ==========================================
  // 正常系
  // ==========================================

  describe('methodName', () => {

    describe('正常系', () => {

      it('正常な入力でエンティティが作成される', async () => {
        // Arrange
        const input = {
          name: 'テストデータ',
          value: 100,
        };
        const expectedResult = {
          id: 'uuid-1',
          ...input,
          createdAt: new Date(),
        };
        mockRepo.create.mockResolvedValue(expectedResult);

        // Act
        const result = await service.methodName(input);

        // Assert
        expect(result).toEqual(expectedResult);
        expect(mockRepo.create).toHaveBeenCalledWith(input);
        expect(mockRepo.create).toHaveBeenCalledTimes(1);
      });

      it('既存データを取得できる', async () => {
        // Arrange
        const entityId = 'uuid-1';
        const existingEntity = { id: entityId, name: 'データ' };
        mockRepo.findById.mockResolvedValue(existingEntity);

        // Act
        const result = await service.getById(entityId);

        // Assert
        expect(result).toEqual(existingEntity);
      });

    });

    // ==========================================
    // 異常系
    // ==========================================

    describe('異常系', () => {

      it('存在しないIDを指定するとNotFoundErrorが発生する', async () => {
        // Arrange
        mockRepo.findById.mockResolvedValue(null);

        // Act & Assert
        await expect(
          service.getById('non-existent-id')
        ).rejects.toThrow(NotFoundError);
      });

      it('重複するデータを作成しようとするとConflictErrorが発生する', async () => {
        // Arrange
        const input = { email: 'existing@example.com' };
        mockRepo.findByEmail.mockResolvedValue({ id: '1', email: input.email });

        // Act & Assert
        await expect(
          service.create(input)
        ).rejects.toThrow(ConflictError);

        // リポジトリのcreateは呼ばれない
        expect(mockRepo.create).not.toHaveBeenCalled();
      });

      it('無効な入力でValidationErrorが発生する', async () => {
        // Arrange
        const invalidInput = { name: '' }; // 空文字は無効

        // Act & Assert
        await expect(
          service.methodName(invalidInput)
        ).rejects.toThrow(ValidationError);
      });

      it('リポジトリエラーが上位に伝播する', async () => {
        // Arrange
        const dbError = new Error('DB接続エラー');
        mockRepo.create.mockRejectedValue(dbError);

        // Act & Assert
        await expect(
          service.methodName({ name: '有効なデータ' })
        ).rejects.toThrow('DB接続エラー');
      });

    });

    // ==========================================
    // 境界値
    // ==========================================

    describe('境界値', () => {

      it.each([
        ['最小値', 1],
        ['最大値', 100],
      ])('%s: value=%d で正常に処理される', async (_, value) => {
        // Arrange
        mockRepo.create.mockResolvedValue({ id: '1', value });

        // Act
        const result = await service.methodName({ value });

        // Assert
        expect(result.value).toBe(value);
      });

      it('空リストの場合に空配列を返す', async () => {
        // Arrange
        mockRepo.findAll.mockResolvedValue([]);

        // Act
        const result = await service.getAll();

        // Assert
        expect(result).toEqual([]);
        expect(Array.isArray(result)).toBe(true);
      });

    });

  });

});
```

---

### ユーティリティ関数テンプレート

```typescript
import { describe, it, expect } from '@jest/globals';
import { utilityFunction } from './utils';

describe('utilityFunction', () => {

  it('正常な入力で期待する値を返す', () => {
    expect(utilityFunction('valid-input')).toBe('expected-output');
  });

  it.each([
    ['ケース1', 'input1', 'expected1'],
    ['ケース2', 'input2', 'expected2'],
    ['ケース3', 'input3', 'expected3'],
  ])('%s: utilityFunction(%s) === %s', (_, input, expected) => {
    expect(utilityFunction(input)).toBe(expected);
  });

  it('nullを渡すとエラーが発生する', () => {
    expect(() => utilityFunction(null as unknown as string)).toThrow(TypeError);
  });

});
```

---

### HTTPハンドラーテンプレート (Supertest)

```typescript
import request from 'supertest';
import { app } from '../app';
import { generateTestToken } from '../test-helpers/auth';

describe('POST /api/v1/resources', () => {
  let validToken: string;

  beforeAll(async () => {
    validToken = await generateTestToken({ userId: 'test-user-id' });
  });

  it('正常なリクエストで201を返す', async () => {
    const response = await request(app)
      .post('/api/v1/resources')
      .set('Authorization', `Bearer ${validToken}`)
      .send({ name: 'テストリソース' });

    expect(response.status).toBe(201);
    expect(response.body.success).toBe(true);
    expect(response.body.data.name).toBe('テストリソース');
    expect(response.body.data.id).toBeDefined();
  });

  it('認証なしで401を返す', async () => {
    const response = await request(app)
      .post('/api/v1/resources')
      .send({ name: 'テストリソース' });

    expect(response.status).toBe(401);
    expect(response.body.success).toBe(false);
  });

  it('バリデーションエラーで400を返す', async () => {
    const response = await request(app)
      .post('/api/v1/resources')
      .set('Authorization', `Bearer ${validToken}`)
      .send({ name: '' }); // 空文字は無効

    expect(response.status).toBe(400);
    expect(response.body.success).toBe(false);
    expect(response.body.error.code).toBe('VALIDATION_ERROR');
  });

});
```
