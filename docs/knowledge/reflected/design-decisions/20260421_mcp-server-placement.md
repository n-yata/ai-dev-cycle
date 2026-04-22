# MCP サーバー設定の置き場所判断 — ナレッジ記録

| 項目 | 内容 |
|------|------|
| 記録日 | 2026-04-21 |
| 最終更新 | 2026-04-21 |
| 記録者 | モドリッチ |
| フェーズ | 横断 |
| カテゴリ | design-decisions |
| 対象領域 | 両方 |
| 重要度 | 中（参考） |

---

## 概要

> `docs/rules/` を `.claude/rules/` に移すかどうか、および MCP サーバーの設定をどこに書くかを検討した。結論として `docs/rules/` は現状維持、MCP 設定は `.mcp.json` に書く方針を採用。

---

## 事実（何が起きたか / 何を決めたか）

- `docs/rules/` を Claude Code ネイティブの `.claude/rules/` に移行するか検討したが、分割による混乱を避けて現状維持とした
- MCP サーバーは `settings.json` ではなく `.mcp.json` に設定することを確認（`settings.json` の schema に `mcpServers` フィールドは存在しない）
- 採用した MCP サーバー: `sequential-thinking`, `fetch`, `github`

---

## 理由・分析（なぜそうなったか / なぜそう決めたか）

### 検討した選択肢

| 選択肢 | メリット | デメリット | 採用 |
|--------|---------|----------|------|
| `docs/rules/` を `.claude/rules/` に完全移行 | Claude Code ネイティブ機能を活用 | rules が2箇所に分散、template.md が rules に不向き | ❌ 却下 |
| INSTRUCTIONS.md のみ `.claude/rules/` に移行 | path-based auto-load が活きる | docs/rules と .claude/rules の2箇所管理になる | ❌ 却下 |
| `docs/rules/` 現状維持 | 単一の場所、hook で強制力あり、人間も読めるドキュメント | Claude Code ネイティブ機能を使わない | ✅ 採用 |

### `.claude/rules/` が有効なケース

- 実装コードが存在する段階で `src/**` への coding guidelines として使う
- 「常時適用したいルール」向き。フェーズゲート型のルールには不向き

---

## 次回への示唆

### すべきこと（Do）

- [ ] 実装フェーズ（フェーズ③）に入ったら `docs/rules/3_implementation/*/guidelines.md` の内容を `.claude/rules/` に複製することを検討する
- [ ] MCP 設定は `.mcp.json` に書く（`settings.json` には書けない）
- [ ] GitHub PAT などのシークレットは `.env` に書き、チャットには貼らない

### 避けること（Don't）

- `settings.json` に `mcpServers` を書こうとする（schema エラーになる）
- トークン・シークレットをチャットに貼る（会話ログに残る）

---

## タグ

`mcp`, `claude-rules`, `docs-rules`, `設定管理`, `シークレット管理`
