# フェーズ② 実装（implementation）

詳細設計に基づいてコードを書くフェーズです。  
品質・一貫性・保守性を保つため、各ガイドラインに従って実装を進めます。

---

## このフェーズの目的

- 詳細設計の意図を正確にコードへ反映する
- チーム全体で一貫したコーディングスタイルを維持する
- レビュアーが理解しやすいコードを書く

---

## 成果物一覧

| # | 成果物 | テンプレート | 単位 | 説明 |
|---|--------|-----------|------|------|
| 1 | 実装計画 | [implementation-plan.template.md](implementation-plan.template.md) | 機能ごと | タスク分割・実装順序・ブランチ戦略 |
| 2 | 環境構築手順 | [setup-guide.template.md](setup-guide.template.md) | プロジェクトごと | ローカル開発環境のセットアップ手順 |

### ファイル命名規則

```
docs/artifacts/implementation/plans/{機能名}-plan.md   # 実装計画
docs/artifacts/implementation/setup-guide.md           # 環境構築手順（プロジェクト直下）
例: docs/artifacts/implementation/plans/todo-app-plan.md
例: docs/artifacts/implementation/plans/user-auth-plan.md
```

設計書は継続的に更新する。ファイル内の「最終更新」で履歴を管理する。

---

## ディレクトリ構成

```
rules/implementation/              # ルール・ガイドライン（ここ）
├── INSTRUCTIONS.md
├── implementation-plan.template.md
├── setup-guide.template.md
├── frontend/
│   ├── INSTRUCTIONS.md
│   └── guidelines.md
└── backend/
    ├── INSTRUCTIONS.md
    └── guidelines.md

artifacts/implementation/          # 成果物の出力先
├── plans/                         # 実装計画書（進行中）
└── done/                          # 実装計画書（完了済み・plans/ から移動）
```

---

## 実装開始前のチェックリスト

- [ ] 詳細設計ドキュメントが「承認済み」になっている
- [ ] 開発環境のセットアップが完了している
- [ ] 依存パッケージ・ライブラリのバージョンが確認済み
- [ ] ブランチ命名規則に従ったブランチを作成している（例: `feature/user-auth`）
- [ ] 実装計画が作成・レビュー済み

---

## 実装完了の定義（Definition of Done）

コードが以下を満たした状態を「実装完了」とする。

- [ ] 詳細設計の全スコープが実装されている
- [ ] 型エラー・Lintエラーがゼロ
- [ ] コードが自己説明的で、複雑なロジックにはコメントがある
- [ ] セキュリティ観点のセルフレビュー済み
- [ ] プルリクエストが作成され、レビュー依頼済み

---

## コードレビューの観点

1. **正確性**: 設計通りに動作するか
2. **セキュリティ**: OWASP Top 10 等の脆弱性がないか
3. **可読性**: 変数名・関数名が意図を正確に表しているか
4. **保守性**: 変更に対して適切な設計になっているか
5. **パフォーマンス**: 不必要な処理・N+1問題がないか
6. **ルール整合性**: CLAUDE.md・INSTRUCTIONS.md・artifacts のパスやルールが矛盾していないか

---

## コーディングガイドライン

- [フロントエンド実装ガイドライン](frontend/guidelines.md)
- [バックエンド実装ガイドライン](backend/guidelines.md)

---

## ナレッジからの追加ルール

<!-- このセクションは /reflect-knowledge コマンドにより自動追記されます -->

### ルール間の矛盾検出（2026-04-16）

> 出典: `docs/knowledge/reflected/review-findings/20260416_rule-inconsistency-detection.md`

**Do:**
- 新しいフェーズのルールを INSTRUCTIONS.md に追加するとき、CLAUDE.md との整合性を必ず確認する
- 成果物の格納先を変更するときは CLAUDE.md・INSTRUCTIONS.md・artifacts の3箇所を同時に更新する

**Don't:**
- CLAUDE.md だけ、または INSTRUCTIONS.md だけを更新してルール変更を完結させない

---

## 実装計画の完了時の運用

実装が完了した計画書は `plans/` から `done/` に移動する。

```bash
mv docs/artifacts/implementation/plans/{機能名}-plan.md docs/artifacts/implementation/done/
```
