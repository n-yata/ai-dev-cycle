# ルール間の矛盾検出 — ナレッジ記録

| 項目 | 内容 |
|------|------|
| 記録日 | 2026-04-16 |
| 最終更新 | 2026-04-16 |
| 記録者 | モドリッチ |
| フェーズ | 実装 |
| カテゴリ | review-findings |
| 対象領域 | 両方 |
| 重要度 | 中（参考） |

---

## 概要

CLAUDE.md（プロジェクト共通ルール）と `docs/rules/implementation/INSTRUCTIONS.md` の間で、成果物の格納先に関する記述が矛盾していた。CLAUDE.md は「フェーズ別サブディレクトリ必須」と規定していたが、INSTRUCTIONS.md は `implementation/` 直下への配置例を示していた。

---

## 事実（何が起きたか）

- 実装計画書を `docs/artifacts/implementation/todo-app-plan.md`（直下）に作成した
- レビュー時にバルベルデがルール違反として指摘
- 調査すると CLAUDE.md と INSTRUCTIONS.md の記述が矛盾していた
- B案（`plans/` サブディレクトリを新設して移動）を採用し、両ルールを統一した

---

## 理由・分析

CLAUDE.md とフェーズ別 INSTRUCTIONS.md は異なるタイミングで作成されたため、記述が乖離しやすい。CLAUDE.md が「サブディレクトリ必須」と規定しているにもかかわらず、INSTRUCTIONS.md の命名規則例が直下配置になっていた。

---

## 次回への示唆

### すべきこと（Do）
- [ ] 新しいフェーズのルールを INSTRUCTIONS.md に追加するとき、CLAUDE.md との整合性を必ず確認する
- [ ] 成果物の格納先を変更するときは CLAUDE.md・INSTRUCTIONS.md・artifacts/INSTRUCTIONS.md の3箇所を同時に更新する
- [ ] レビュー観点に「プロジェクト共通ルールとの整合性」を常に含める

### 避けること（Don't）
- CLAUDE.md だけ、または INSTRUCTIONS.md だけを更新してルール変更を完結させない

---

## タグ

`rule-consistency`, `claude-md`, `instructions`, `implementation`, `review`
