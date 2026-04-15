# ルール・テンプレート（rules）

各開発フェーズのガイドライン、テンプレート、チェックリストを格納しています。  
成果物を作成する際は、ここのテンプレートをコピーして `docs/artifacts/` に配置してください。

---

## ディレクトリ構成

```
rules/
├── detailed-design/      # フェーズ①: 詳細設計のルール・テンプレート
│   ├── frontend/
│   └── backend/
├── implementation/       # フェーズ②: 実装ガイドライン
│   ├── frontend/
│   └── backend/
├── unit-test/            # フェーズ③: 単体テストのルール・テンプレート
│   ├── frontend/
│   └── backend/
├── integration-test/     # フェーズ④: 結合テストのルール・テンプレート
│   ├── frontend/
│   └── backend/
└── knowledge/            # ナレッジ記録テンプレート
    └── template.md
```

---

## 各フェーズのガイド

| フェーズ | ガイド | 概要 |
|---------|--------|------|
| 詳細設計 | [detailed-design/README.md](detailed-design/README.md) | 設計ドキュメントの作成手順・チェックリスト |
| 実装 | [implementation/README.md](implementation/README.md) | コーディングガイドライン・レビュー観点 |
| 単体テスト | [unit-test/README.md](unit-test/README.md) | テスト原則・カバレッジ目安 |
| 結合テスト | [integration-test/README.md](integration-test/README.md) | 結合テスト実行環境・チェックリスト |
| ナレッジ記録 | [knowledge/template.md](knowledge/template.md) | ナレッジ記録のテンプレート |
