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
└── docs/
    ├── detailed-design/      # フェーズ①: 詳細設計
    │   ├── frontend/         # FE詳細設計
    │   └── backend/          # BE詳細設計
    ├── implementation/       # フェーズ②: 実装
    │   ├── frontend/         # FE実装ガイドライン
    │   └── backend/          # BE実装ガイドライン
    ├── unit-test/            # フェーズ③: 単体テスト
    │   ├── frontend/         # FE単体テスト
    │   └── backend/          # BE単体テスト
    ├── integration-test/     # フェーズ④: 結合テスト
    │   ├── frontend/         # FE結合テスト
    │   └── backend/          # BE結合テスト
    └── knowledge-base/       # ナレッジベース（サイクルを回すたびに成長）
        ├── design-decisions/ # 設計判断とその理由
        ├── review-findings/  # レビュー指摘パターン
        ├── test-patterns/    # バグパターン・テスト手法
        └── lessons-learned/  # 各フェーズの教訓
```

---

## 各フェーズの概要

### フェーズ① 詳細設計（detailed-design）

実装前に設計を文書化するフェーズ。  
- UI/UXコンポーネント設計、状態管理設計（FE）
- API仕様、データモデル、シーケンス図（BE）

詳細 → [docs/detailed-design/README.md](docs/detailed-design/README.md)

---

### フェーズ② 実装（implementation）

詳細設計をもとにコードを書くフェーズ。  
コーディング規約・実装ガイドラインを参照しながら進める。

詳細 → [docs/implementation/README.md](docs/implementation/README.md)

---

### フェーズ③ 単体テスト（unit-test）

個々のコンポーネント・関数・モジュール単位での品質確認フェーズ。  
- コンポーネントテスト、カスタムフックテスト（FE）
- ユニットテスト、サービス層テスト（BE）

詳細 → [docs/unit-test/README.md](docs/unit-test/README.md)

---

### フェーズ④ 結合テスト（integration-test）

複数のモジュールやシステム間の連携を検証するフェーズ。  
- E2Eテスト、API通信テスト（FE）
- APIエンドポイントテスト、DBアクセステスト（BE）

詳細 → [docs/integration-test/README.md](docs/integration-test/README.md)

---

## 開発フロー

1. **詳細設計ドキュメントを作成** → `docs/detailed-design/` のテンプレートを使用
2. **実装ガイドラインを確認** → `docs/implementation/` のガイドラインに従って実装
3. **単体テストを作成・実行** → `docs/unit-test/` のテンプレートを使用
4. **結合テストを作成・実行** → `docs/integration-test/` のテンプレートを使用
5. **ナレッジを記録する** → `docs/knowledge-base/` に学びを蓄積

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
| 詳細設計レビュー後 | 設計判断の理由・却下した選択肢 → `design-decisions/` |
| コードレビュー後 | 繰り返し出た指摘パターン → `review-findings/` |
| テスト実施後 | 発見したバグのパターン・効果的な手法 → `test-patterns/` |
| フェーズ完了後 | フェーズ全体の振り返り・教訓 → `lessons-learned/` |

詳細 → [docs/knowledge-base/README.md](docs/knowledge-base/README.md)

---

## 関連リンク

- [詳細設計ガイド](docs/detailed-design/README.md)
- [実装ガイドライン](docs/implementation/README.md)
- [単体テストガイド](docs/unit-test/README.md)
- [結合テストガイド](docs/integration-test/README.md)
- [ナレッジベース](docs/knowledge-base/README.md)
