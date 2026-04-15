#!/bin/bash
# =============================================================================
# knowledge-trigger.sh — UserPromptSubmit hook
# 会話ターンをカウントし、10ターンごとにナレッジ書き込みリマインドを注入する。
# /clear が検出された場合も書き込みリマインドを注入する。
# =============================================================================

COUNTER_FILE="${CLAUDE_PROJECT_DIR:-.}/.claude/.knowledge-counter"

# stdin から hook input を読み取る
INPUT=$(cat)

# /clear コマンドの検出（JSON内の prompt フィールドを簡易パース）
# jq がないため grep で検出
if echo "$INPUT" | grep -qE '"prompt"\s*:\s*"\s*/clear'; then
  cat <<'MSG'
[KNOWLEDGE_TRIGGER] /clear が実行されます。
会話で得られたナレッジがあれば docs/knowledge/ に書き込んでください。
- テンプレート: docs/rules/knowledge/template.md
- カテゴリ: design-decisions / review-findings / test-patterns / lessons-learned
- ファイル名: YYYYMMDD_短いタイトル.md
記録すべきナレッジがない場合はスキップして構いません。
MSG
  echo "0" > "$COUNTER_FILE"
  exit 0
fi

# カウンター読み取り・インクリメント
COUNT=0
if [ -f "$COUNTER_FILE" ]; then
  COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
  # 数値でない場合のフォールバック
  if ! [[ "$COUNT" =~ ^[0-9]+$ ]]; then
    COUNT=0
  fi
fi
COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE"

# 10ターンに達したらリマインド
if [ "$COUNT" -ge 10 ]; then
  cat <<'MSG'
[KNOWLEDGE_TRIGGER] 会話が10ターンに達しました。
この会話で得られたナレッジがあれば docs/knowledge/ に書き込んでください。
- テンプレート: docs/rules/knowledge/template.md
- カテゴリ: design-decisions / review-findings / test-patterns / lessons-learned
- ファイル名: YYYYMMDD_短いタイトル.md
記録すべきナレッジがない場合はスキップして構いません。
書き込み完了後（またはスキップ後）、通常の応答を続けてください。
MSG
  echo "0" > "$COUNTER_FILE"
fi

exit 0
