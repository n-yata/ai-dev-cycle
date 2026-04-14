# バックエンド コーディングガイドライン

---

## 1. API設計

### RESTfulなURL設計

```
# Good: リソース指向
GET    /api/v1/users          # 一覧
GET    /api/v1/users/:id      # 詳細
POST   /api/v1/users          # 作成
PUT    /api/v1/users/:id      # 更新（全体）
PATCH  /api/v1/users/:id      # 更新（部分）
DELETE /api/v1/users/:id      # 削除

# Bad: 動詞をURLに含める
GET    /api/v1/getUsers
POST   /api/v1/createUser
```

### レスポンス形式の統一

```typescript
// 成功レスポンス
{
  "success": true,
  "data": { ... }
}

// エラーレスポンス
{
  "success": false,
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "指定されたリソースが見つかりません"
  }
}

// リスト + ページネーション
{
  "success": true,
  "data": [...],
  "meta": {
    "total": 100,
    "page": 1,
    "perPage": 20
  }
}
```

---

## 2. レイヤー設計

### Handler（コントローラー）の責務

```typescript
// Good: ハンドラーはHTTP層のみ担当
const createUserHandler = async (req: Request, res: Response) => {
  const validatedBody = validateCreateUserInput(req.body); // バリデーション
  const user = await userService.createUser(validatedBody); // サービス呼び出し
  res.status(201).json({ success: true, data: user });     // レスポンス返却
};

// Bad: ハンドラーにビジネスロジックを書く
const createUserHandler = async (req: Request, res: Response) => {
  // ここに直接DBアクセスやビジネスルールを書かない
  const exists = await db.query('SELECT * FROM users WHERE email = $1', [req.body.email]);
  if (exists.rows.length > 0) { ... }
};
```

### Service層の責務

```typescript
// Good: サービスはビジネスロジックに集中
class UserService {
  constructor(private readonly userRepo: UserRepository) {}

  async createUser(input: CreateUserInput): Promise<User> {
    // ビジネスルールの実装
    const exists = await this.userRepo.findByEmail(input.email);
    if (exists) {
      throw new ConflictError('このメールアドレスは既に登録されています');
    }
    const hashedPassword = await hashPassword(input.password);
    return this.userRepo.create({ ...input, password: hashedPassword });
  }
}
```

### Repository層の責務

```typescript
// Good: リポジトリはDB操作のみ担当
class UserRepository {
  async findByEmail(email: string): Promise<User | null> {
    return db.user.findUnique({ where: { email } });
  }

  async create(data: CreateUserData): Promise<User> {
    return db.user.create({ data });
  }
}
```

---

## 3. エラーハンドリング

### カスタムエラークラスを使用する

```typescript
// エラークラスの定義
class AppError extends Error {
  constructor(
    public readonly code: string,
    message: string,
    public readonly statusCode: number = 500
  ) {
    super(message);
  }
}

class NotFoundError extends AppError {
  constructor(message = 'リソースが見つかりません') {
    super('RESOURCE_NOT_FOUND', message, 404);
  }
}

class ValidationError extends AppError {
  constructor(message: string) {
    super('VALIDATION_ERROR', message, 400);
  }
}
```

### グローバルエラーハンドラーで一元管理

```typescript
// Good: エラーハンドラーに集約
const errorHandler = (err: Error, req: Request, res: Response, next: NextFunction) => {
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      success: false,
      error: { code: err.code, message: err.message }
    });
  }
  // 予期しないエラー
  logger.error('Unexpected error', { error: err, requestId: req.id });
  res.status(500).json({ success: false, error: { code: 'INTERNAL_ERROR', message: 'サーバーエラーが発生しました' } });
};
```

---

## 4. 入力バリデーション

### スキーマバリデーションライブラリを使用する

```typescript
// Good: zod等でスキーマを定義
import { z } from 'zod';

const CreateUserSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
  password: z.string().min(8).max(128),
});

type CreateUserInput = z.infer<typeof CreateUserSchema>;

// バリデーションミドルウェアで使用
const validateBody = (schema: z.ZodSchema) => (req: Request, res: Response, next: NextFunction) => {
  const result = schema.safeParse(req.body);
  if (!result.success) {
    throw new ValidationError(result.error.message);
  }
  req.body = result.data;
  next();
};
```

---

## 5. セキュリティ

### SQLインジェクション対策

```typescript
// Good: プリペアドステートメント / ORM使用
const user = await db.user.findUnique({ where: { id: userId } });

// Bad: 文字列結合でSQLを構築
const user = await db.query(`SELECT * FROM users WHERE id = '${userId}'`);
```

### パスワードのハッシュ化

```typescript
// Good: bcrypt等でハッシュ化
import bcrypt from 'bcrypt';

const SALT_ROUNDS = 12;
const hashedPassword = await bcrypt.hash(plainPassword, SALT_ROUNDS);
const isValid = await bcrypt.compare(plainPassword, hashedPassword);
```

### 認証・認可の徹底

```typescript
// Good: ルートレベルで認証ミドルウェアを適用
router.use(authMiddleware);

// リソースオーナーのみアクセス可能
const ensureOwner = async (req: Request, res: Response, next: NextFunction) => {
  const resource = await resourceRepo.findById(req.params.id);
  if (resource.userId !== req.user.id) {
    throw new ForbiddenError();
  }
  next();
};
```

### 機密情報の管理

```typescript
// Good: 環境変数から取得
const jwtSecret = process.env.JWT_SECRET;
if (!jwtSecret) throw new Error('JWT_SECRET is not set');

// Bad: ハードコーディング
const jwtSecret = 'my-secret-key'; // 絶対禁止
```

---

## 6. ログ

### 構造化ログを出力する

```typescript
// Good: 構造化ログ
logger.info('User created', {
  userId: user.id,
  requestId: req.id,
  duration: Date.now() - startTime,
});

// Bad: 文字列のみ
console.log('User created: ' + userId);
```

### 機密情報をログに出さない

```typescript
// Bad
logger.info('Login request', { body: req.body }); // パスワードが含まれる

// Good
logger.info('Login request', { email: req.body.email }); // パスワードは除外
```

---

## 7. データベース

### トランザクションを適切に使用する

```typescript
// Good: 複数テーブルへの書き込みはトランザクション内で実施
const result = await db.$transaction(async (tx) => {
  const order = await tx.order.create({ data: orderData });
  await tx.inventory.update({ where: { id: itemId }, data: { stock: { decrement: 1 } } });
  return order;
});
```

### N+1問題を避ける

```typescript
// Bad: N+1問題
const users = await db.user.findMany();
for (const user of users) {
  user.posts = await db.post.findMany({ where: { userId: user.id } }); // N回クエリ発行
}

// Good: includeで一括取得
const users = await db.user.findMany({
  include: { posts: true },
});
```
