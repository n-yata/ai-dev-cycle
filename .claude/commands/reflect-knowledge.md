# ナレッジ → ルール反映コマンド

docs/knowledge/ に蓄積されたナレッジを分析し、docs/rules/ 配下の該当ファイルに反映する。
反映済みナレッジは `docs/knowledge/reflected/` に移動し、次回以降の走査対象から除外する。

---

## 実行手順

### Step 1: ナレッジファイルの収集

`docs/knowledge/` 配下の **直下カテゴリディレクトリのみ** から `.md` ファイルを収集する（INSTRUCTIONS.md は除く、`reflected/` は走査しない）。

```
docs/knowledge/design-decisions/*.md
docs/knowledge/review-findings/*.md
docs/knowledge/test-patterns/*.md
docs/knowledge/lessons-learned/*.md
```

ナレッジファイルが1つも見つからない場合は「反映対象のナレッジがありません」と報告して終了する。

### Step 2: ナレッジの分析と反映先の特定

各ナレッジファイルから以下の情報を抽出する:

1. **メタデータ**: フェーズ、カテゴリ、対象領域
2. **「次回への示唆」セクション**: Do / Don't リスト
3. **「チェックリストへの追加提案」セクション**: 具体的な追加先と内容

反映先のマッピング:

| ナレッジのフェーズ | 対象領域 | 反映先 |
|------------------|---------|--------|
| 詳細設計 | フロントエンド | `docs/rules/detailed-design/frontend/INSTRUCTIONS.md` |
| 詳細設計 | バックエンド | `docs/rules/detailed-design/backend/INSTRUCTIONS.md` |
| 詳細設計 | 両方 | 上記の両方 |
| 実装 | フロントエンド | `docs/rules/implementation/frontend/guidelines.md` |
| 実装 | バックエンド | `docs/rules/implementation/backend/guidelines.md` |
| 実装 | 両方 | 上記の両方 |
| 単体テスト | フロントエンド | `docs/rules/unit-test/frontend/INSTRUCTIONS.md` |
| 単体テスト | バックエンド | `docs/rules/unit-test/backend/INSTRUCTIONS.md` |
| 単体テスト | 両方 | 上記の両方 |
| 結合テスト | フロントエンド | `docs/rules/integration-test/frontend/INSTRUCTIONS.md` |
| 結合テスト | バックエンド | `docs/rules/integration-test/backend/INSTRUCTIONS.md` |
| 結合テスト | 両方 | 上記の両方 |
| 横断 | — | フェーズ横断の場合、内容に応じて最も適切な反映先を判断する |

### Step 3: ルールファイルへの反映

反映先ファイルに以下の形式でセクションを追記する:

```markdown
## ナレッジからの追加ルール

<!-- このセクションは /reflect-knowledge コマンドにより自動追記されます -->

### [ナレッジタイトル]（YYYY-MM-DD）

> 出典: `docs/knowledge/reflected/カテゴリ/ファイル名.md`

**Do:**
- 具体的なアクション項目

**Don't:**
- 避けるべきパターン
```

反映のルール:
- 既に「ナレッジからの追加ルール」セクションがある場合は、そのセクション内に追記する
- セクションがない場合は、ファイル末尾に新規作成する
- 「チェックリストへの追加提案」に具体的なチェック項目がある場合は、該当ファイルのチェックリストセクションにも追記する
- 既存のルールと重複・矛盾する内容がないか確認し、矛盾がある場合はユーザーに確認を取る

### Step 4: 反映済みナレッジの移動

反映が完了したナレッジファイルを `docs/knowledge/reflected/` 配下の対応するカテゴリディレクトリに移動する。

```
移動元: docs/knowledge/design-decisions/20260416_example.md
移動先: docs/knowledge/reflected/design-decisions/20260416_example.md
```

移動先ディレクトリが存在しない場合は作成する。

### Step 5: 結果報告

以下の形式で反映結果をユーザーに報告する:

```
## ナレッジ → ルール反映結果

| ナレッジ | 反映先 | 反映内容 |
|---------|--------|---------|
| ファイル名 | 反映先パス | 追加した内容の要約 |

### スキップしたナレッジ
- ファイル名（理由: 反映先が特定できない等）
```

---

## 注意事項

- ルールファイルの既存内容は変更・削除しない。追記のみ行う。
- 反映内容はナレッジの「次回への示唆」セクションを中心に、具体的で行動可能な内容に絞る。
- 曖昧な表現（「気をつける」「注意する」等）は具体的なアクションに変換してから反映する。
- 1つのナレッジが複数のルールファイルに反映される場合がある（対象領域が「両方」の場合等）。
- `docs/knowledge/reflected/` 配下のファイルは参照用として残す。削除しない。
