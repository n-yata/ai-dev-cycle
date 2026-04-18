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

### Step 3: 反映前の事前確認（必須）

**反映先ファイルへの書き込み前に、以下を必ず実施すること。**

#### 3-1: 反映先ルールファイルの全文読み込み

反映先として特定された全ルールファイルを Read ツールで読み込む。
さらに、関連する可能性がある隣接ファイル（同フェーズの別INSTRUCTIONS、親フェーズのINSTRUCTIONS等）も合わせて読む。

```
対象例（詳細設計バックエンドの場合）:
- docs/rules/detailed-design/backend/INSTRUCTIONS.md    ← 反映先
- docs/rules/detailed-design/INSTRUCTIONS.md            ← 親フェーズ
- docs/rules/detailed-design/frontend/INSTRUCTIONS.md   ← 隣接
- docs/rules/basic-design/INSTRUCTIONS.md               ← 上流フェーズ
```

#### 3-2: 重複チェック

既存ルールと照合し、以下に該当する場合は**反映をスキップ**する（スキップ理由を結果報告に記載）:

- 同一または実質的に同じ内容がすでに記載されている
- 表現は異なるが、指示している行動が同一である
- 既存チェックリストに同等の項目が存在する

#### 3-3: 整合性チェック

既存ルールとの整合性を確認し、以下の場合は**ユーザーに確認を取ってから**反映する:

- 既存ルールと矛盾・競合する内容がある
- 既存ルールの前提を崩す可能性がある変更

#### 3-4: 有用性フィルター

以下の基準を**すべて満たす場合のみ**反映する:

| 基準 | 説明 |
|------|------|
| 再現性 | 次回また同じ状況で役立つ内容か |
| 具体性 | 「気をつける」ではなく、具体的な行動・判断基準か |
| 非自明性 | コードや既存ドキュメントを読めば自明な内容でないか |
| 普遍性 | 特定のタスクに閉じた一時的な内容でないか |

上記を1つでも満たさない場合は反映をスキップする。

### Step 4: ルールファイルへの反映

Step 3の事前確認を通過したナレッジのみ、反映先ファイルに以下の形式でセクションを追記する:

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

### Step 5: 反映済みナレッジの移動

反映が完了したナレッジファイルを `docs/knowledge/reflected/` 配下の対応するカテゴリディレクトリに移動する。

```
移動元: docs/knowledge/design-decisions/20260416_example.md
移動先: docs/knowledge/reflected/design-decisions/20260416_example.md
```

移動先ディレクトリが存在しない場合は作成する。

### Step 6: 結果報告

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
