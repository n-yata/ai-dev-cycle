#!/bin/bash
# =============================================================================
# pre-compact-knowledge.sh — PreCompact hook
# compact 実行前にナレッジ書き込みリマインドを注入する。
# =============================================================================

COUNTER_FILE="${CLAUDE_PROJECT_DIR:-.}/.claude/.knowledge-counter"

cat <<'MSG'
[KNOWLEDGE_TRIGGER] compact が実行されます。会話コンテキストが圧縮されます。
この会話で得られたナレッジがあれば docs/knowledge/ に書き込んでください。
- テンプレート: docs/rules/knowledge/template.md
- カテゴリ: design-decisions / review-findings / test-patterns / lessons-learned
- ファイル名: YYYYMMDD_短いタイトル.md
記録すべきナレッジがない場合はスキップして構いません。
MSG

# カウンターをリセット
echo "0" > "$COUNTER_FILE"

# フラグファイルを作成（次セッションの UserPromptSubmit でナレッジ書き込みをトリガーする）
FLAG_FILE="${CLAUDE_PROJECT_DIR:-.}/.claude/.post-compact-pending"
touch "$FLAG_FILE"

exit 0
