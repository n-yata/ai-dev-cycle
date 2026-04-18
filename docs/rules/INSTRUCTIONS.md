# ルール・テンプレート（rules）

各開発フェーズのガイドライン、テンプレート、チェックリストを格納しています。  
成果物を作成する際は、ここのテンプレートをコピーして `docs/artifacts/` に配置してください。

---

## ディレクトリ構成

```
rules/
├── basic-design/         # フェーズ０: 基本設計のルール・テンプレート
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
| 基本設計 | [basic-design/INSTRUCTIONS.md](basic-design/INSTRUCTIONS.md) | 技術スタック・アーキテクチャ・構成の合意形成 |
| 詳細設計 | [detailed-design/INSTRUCTIONS.md](detailed-design/INSTRUCTIONS.md) | 設計ドキュメントの作成手順・チェックリスト |
| 実装 | [implementation/INSTRUCTIONS.md](implementation/INSTRUCTIONS.md) | コーディングガイドライン・レビュー観点 |
| 単体テスト | [unit-test/INSTRUCTIONS.md](unit-test/INSTRUCTIONS.md) | テスト原則・カバレッジ目安 |
| 結合テスト | [integration-test/INSTRUCTIONS.md](integration-test/INSTRUCTIONS.md) | 結合テスト実行環境・チェックリスト |
| ナレッジ記録 | [knowledge/template.md](knowledge/template.md) | ナレッジ記録のテンプレート |

---

## ナレッジからの追加ルール

<!-- このセクションは /reflect-knowledge コマンドにより自動追記されます -->

### ウォーターフォール フェーズゲート管理（2026-04-18）

> 出典: `docs/knowledge/reflected/design-decisions/20260418_waterfall-phase-gate-management.md`

**Do:**
- 次フェーズ開始依頼を受けたら、まず `docs/artifacts/PHASE_STATUS.md` を参照し、前フェーズのステータスが `COMPLETE` であることを確認してから着手する
- フェーズ開始時に PHASE_STATUS.md のステータスを `IN_PROGRESS` に、開始日を記入する
- フェーズ完了時は完了チェックリストを全項目消化し、シャビの承認を得てから `COMPLETE` に更新する
- 詳細な運用ルールは `CLAUDE.md` の「ウォーターフォール フェーズゲート管理」セクションに集約されているため、そちらを一次情報とする

**Don't:**
- 前フェーズのステータス確認を省略して次フェーズの作業を開始しない
- シャビの承認なしに自己判断でステータスを `COMPLETE` に更新しない
- シャビの明示的な指示がない限りフェーズをスキップしない

### ドキュメント整理時は構造ではなく中身で判断する（2026-04-18）

> 出典: `docs/knowledge/reflected/lessons-learned/20260418_doc-cleanup-read-before-delete.md`

**Do:**
- ドキュメントを削除・整理する前に、対象ファイルを Read ツールで開き「親ファイルや類似ファイルにない独自情報があるか」を確認する
- 同じ階層構造を持つ別ディレクトリ（例: `knowledge/` と `rules/`）でも、各ファイルの中身を個別に確認してから判断する

**Don't:**
- 「前に A を削除したから、同じ構造の B も削除でよい」という類推だけでドキュメントを削除しない
- ファイル名・ディレクトリ構造の類似性のみを根拠に、中身を読まずに整理作業を進めない
