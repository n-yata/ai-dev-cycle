# 成果物（artifacts）

各開発フェーズで作成されるドキュメント成果物の出力先です。  
テンプレートやガイドラインは `docs/rules/` を参照してください。

---

## ディレクトリ構成

```
artifacts/
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

```
YYYYMMDD_機能名.md
例: 20260416_user-auth.md
```

---

## 成果物の作成手順

1. `docs/rules/` から対象フェーズのテンプレートをコピーする
2. 上記の命名規則に従ってファイル名を付ける
3. 対応するサブディレクトリ（frontend / backend）に配置する
4. テンプレートの各セクションを埋める
5. レビューを実施し、承認を得る

---

## 各フェーズの成果物

| フェーズ | 保存先 | テンプレート |
|---------|--------|------------|
| 詳細設計 | `detailed-design/frontend/` or `backend/` | [FEテンプレート](../rules/detailed-design/frontend/template.md) / [BEテンプレート](../rules/detailed-design/backend/template.md) |
| 実装 | `implementation/frontend/` or `backend/` | [FEガイドライン](../rules/implementation/frontend/guidelines.md) / [BEガイドライン](../rules/implementation/backend/guidelines.md) |
| 単体テスト | `unit-test/frontend/` or `backend/` | [FEテンプレート](../rules/unit-test/frontend/template.md) / [BEテンプレート](../rules/unit-test/backend/template.md) |
| 結合テスト | `integration-test/frontend/` or `backend/` | [FEテンプレート](../rules/integration-test/frontend/template.md) / [BEテンプレート](../rules/integration-test/backend/template.md) |
