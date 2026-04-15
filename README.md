# ai-dev-cycle

AI開発サイクルのドキュメント基盤プロジェクト。  
詳細設計から結合テストまでの各フェーズを体系的に管理するためのテンプレートとガイドラインを提供します。

---

## 開発サイクル概要

```
┌─────────────────────────────────────────────────────┐
│              AI開発サイクル                          │
│                                                     │
│  ① 詳細設計  →  ② 実装  →  ③ 単体テスト  →  ④ 結合テスト │
│                                                     │
│  フロントエンド / バックエンド 両方を対象            │
└─────────────────────────────────────────────────────┘
```

各フェーズは **フロントエンド（FE）** と **バックエンド（BE）** の両観点をカバーしています。

---

## ディレクトリ構成

```
ai-dev-cycle/
├── src/                          # 実装ソースコード（別途配置）
└── docs/
    ├── artifacts/                # 成果物の出力先
    │   ├── detailed-design/     #   詳細設計ドキュメント
    │   │   ├── frontend/
    │   │   └── backend/
    │   ├── implementation/      #   実装記録
    │   │   ├── frontend/
    │   │   └── backend/
    │   ├── unit-test/           #   単体テスト仕様書
    │   │   ├── frontend/
    │   │   └── backend/
    │   └── integration-test/    #   結合テスト仕様書
    │       ├── frontend/
    │       └── backend/
    │
    ├── rules/                   # ルール・テンプレート
    │   ├── detailed-design/     #   詳細設計のルール・テンプレート
    │   │   ├── frontend/
    │   │   └── backend/
    │   ├── implementation/      #   実装ガイドライン
    │   │   ├── frontend/
    │   │   └── backend/
    │   ├── unit-test/           #   単体テストのルール・テンプレート
    │   │   ├── frontend/
    │   │   └── backend/
    │   ├── integration-test/    #   結合テストのルール・テンプレート
    │   │   ├── frontend/
    │   │   └── backend/
    │   └── knowledge/           #   ナレッジ記録テンプレート
    │
    └── knowledge/               # ナレッジベース（サイクルを回すたびに成長）
        ├── design-decisions/    #   設計判断とその理由
        ├── review-findings/     #   レビュー指摘パターン
        ├── test-patterns/       #   バグパターン・テスト手法
        └── lessons-learned/     #   各フェーズの教訓
```

### 3つの柱

| ディレクトリ | 役割 | 説明 |
|------------|------|------|
| `docs/artifacts/` | 成果物 | 各フェーズで生成されるドキュメント成果物の出力先 |
| `docs/rules/` | ルール | テンプレート、ガイドライン、チェックリスト。成果物を作る際の「型」 |
| `docs/knowledge/` | ナレッジ | 開発サイクルで得た知見・教訓の蓄積 |

---

## 各フェーズの概要

### フェーズ① 詳細設計（detailed-design）

実装前に設計を文書化するフェーズ。  
- UI/UXコンポーネント設計、状態管理設計（FE）
- API仕様、データモデル、シーケンス図（BE）

ルール → [docs/rules/detailed-design/INSTRUCTIONS.md](docs/rules/detailed-design/INSTRUCTIONS.md)

---

### フェーズ② 実装（implementation）

詳細設計をもとにコードを書くフェーズ。  
コーディング規約・実装ガイドラインを参照しながら進める。

ルール → [docs/rules/implementation/INSTRUCTIONS.md](docs/rules/implementation/INSTRUCTIONS.md)

---

### フェーズ③ 単体テスト（unit-test）

個々のコンポーネント・関数・モジュール単位での品質確認フェーズ。  
- コンポーネントテスト、カスタムフックテスト（FE）
- ユニットテスト、サービス層テスト（BE）

ルール → [docs/rules/unit-test/INSTRUCTIONS.md](docs/rules/unit-test/INSTRUCTIONS.md)

---

### フェーズ④ 結合テスト（integration-test）

複数のモジュールやシステム間の連携を検証するフェーズ。  
- E2Eテスト、API通信テスト（FE）
- APIエンドポイントテスト、DBアクセステスト（BE）

ルール → [docs/rules/integration-test/INSTRUCTIONS.md](docs/rules/integration-test/INSTRUCTIONS.md)

---

## 開発フロー

1. **ルールを確認** → `docs/rules/` でテンプレート・ガイドラインを参照
2. **成果物を作成** → テンプレートをコピーし `docs/artifacts/` に配置
3. **各フェーズを実施** → 詳細設計 → 実装 → 単体テスト → 結合テスト
4. **ナレッジを記録** → `docs/knowledge/` に学びを蓄積

---

## ナレッジベース

開発サイクルを回すたびに得られた知識・経験を蓄積し、次のサイクルへ活かす仕組みです。

```
┌─────────────────────────────────────────────────────────────┐
│  設計判断         レビュー指摘       テストパターン    教訓  │
│  を残す     →     を共有する   →     を蓄積する   →  を活かす│
│                                                             │
│              次のサイクルへフィードバック                    │
└─────────────────────────────────────────────────────────────┘
```

### 記録タイミング

| フェーズ完了後 | 記録するナレッジ |
|-------------|---------------|
| 詳細設計レビュー後 | 設計判断の理由・却下した選択肢 → `knowledge/design-decisions/` |
| コードレビュー後 | 繰り返し出た指摘パターン → `knowledge/review-findings/` |
| テスト実施後 | 発見したバグのパターン・効果的な手法 → `knowledge/test-patterns/` |
| フェーズ完了後 | フェーズ全体の振り返り・教訓 → `knowledge/lessons-learned/` |

詳細 → [docs/knowledge/INSTRUCTIONS.md](docs/knowledge/INSTRUCTIONS.md)

---

## 関連リンク

- [成果物（artifacts）](docs/artifacts/INSTRUCTIONS.md)
- [ルール・テンプレート（rules）](docs/rules/INSTRUCTIONS.md)
- [ナレッジベース（knowledge）](docs/knowledge/INSTRUCTIONS.md)
