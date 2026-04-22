# 成果物（artifacts）

各開発フェーズで作成されるドキュメント成果物の出力先です。  
テンプレートやガイドラインは `docs/rules/` を参照してください。

---

## ディレクトリ構成

```
artifacts/
├── 0_requirements/       # フェーズ０: 要件定義書
├── 1_basic-design/       # フェーズ①: 基本設計書
├── 2_detailed-design/    # フェーズ②: 詳細設計ドキュメント
│   ├── frontend/
│   └── backend/
├── 3_implementation/     # フェーズ③: 実装計画・記録
│   ├── frontend/
│   ├── backend/
│   ├── plans/            # 実装計画（進行中）
│   └── done/             # 実装計画（完了済み）
├── 4_unit-test/          # フェーズ④: 単体テスト仕様書
│   ├── frontend/
│   └── backend/
└── 5_integration-test/   # フェーズ⑤: 結合テスト仕様書
    ├── frontend/
    └── backend/
```

---

## ファイル命名規則

ファイル名に日付は付けない。成果物の種類・機能名で命名する。

```
{成果物名またはエンティティ名・機能名}.md
例: todo-app.md, api-list.md, entity-relationship.md, setup-guide.md
```

詳細な命名規則は各フェーズの INSTRUCTIONS.md を参照すること。

---

## 成果物の作成手順

1. `docs/rules/` から対象フェーズの INSTRUCTIONS.md を読む
2. 対応するテンプレートをコピーする
3. 命名規則に従ってファイル名を付ける
4. 対応するサブディレクトリに配置する
5. テンプレートの各セクションを埋める
6. レビューを実施し、承認を得る

---

## 各フェーズの成果物

| フェーズ | 保存先 | ルール参照先 |
|---------|--------|------------|
| 要件定義 | `0_requirements/` | [0_requirements/INSTRUCTIONS.md](../rules/0_requirements/INSTRUCTIONS.md) |
| 基本設計 | `1_basic-design/` | [1_basic-design/INSTRUCTIONS.md](../rules/1_basic-design/INSTRUCTIONS.md) |
| 詳細設計 | `2_detailed-design/frontend/` or `backend/` | [2_detailed-design/INSTRUCTIONS.md](../rules/2_detailed-design/INSTRUCTIONS.md) |
| 実装計画 | `3_implementation/plans/` | [3_implementation/INSTRUCTIONS.md](../rules/3_implementation/INSTRUCTIONS.md) |
| 実装 | `3_implementation/frontend/` or `backend/` | [3_implementation/INSTRUCTIONS.md](../rules/3_implementation/INSTRUCTIONS.md) |
| 単体テスト | `4_unit-test/frontend/` or `backend/` | [4_unit-test/INSTRUCTIONS.md](../rules/4_unit-test/INSTRUCTIONS.md) |
| 結合テスト | `5_integration-test/frontend/` or `backend/` | [5_integration-test/INSTRUCTIONS.md](../rules/5_integration-test/INSTRUCTIONS.md) |
