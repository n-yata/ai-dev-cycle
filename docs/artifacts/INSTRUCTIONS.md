# 成果物（artifacts）

各開発フェーズで作成されるドキュメント成果物の出力先です。  
テンプレートやガイドラインは `docs/rules/` を参照してください。

---

## ディレクトリ構成

```
artifacts/
├── basic-design/         # フェーズ０: 基本設計ドキュメント
├── detailed-design/      # フェーズ①: 詳細設計ドキュメント
│   ├── frontend/
│   └── backend/
├── implementation/       # フェーズ②: 実装記録
│   ├── frontend/
│   └── backend/
├── unit-test/            # フェーズ③: 単体テスト仕様書
│   ├── frontend/
│   └── backend/
└── integration-test/     # フェーズ④: 結合テスト仕様書
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
| 基本設計 | `basic-design/` | [basic-design/INSTRUCTIONS.md](../rules/basic-design/INSTRUCTIONS.md) |
| 詳細設計 | `detailed-design/frontend/` or `backend/` | [detailed-design/INSTRUCTIONS.md](../rules/detailed-design/INSTRUCTIONS.md) |
| 実装計画 | `implementation/plans/` | [implementation/INSTRUCTIONS.md](../rules/implementation/INSTRUCTIONS.md) |
| 実装 | `implementation/frontend/` or `backend/` | [implementation/INSTRUCTIONS.md](../rules/implementation/INSTRUCTIONS.md) |
| 単体テスト | `unit-test/frontend/` or `backend/` | [unit-test/INSTRUCTIONS.md](../rules/unit-test/INSTRUCTIONS.md) |
| 結合テスト | `integration-test/frontend/` or `backend/` | [integration-test/INSTRUCTIONS.md](../rules/integration-test/INSTRUCTIONS.md) |
