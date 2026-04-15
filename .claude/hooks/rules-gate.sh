#!/bin/bash
# =============================================================================
# rules-gate.sh — PreToolUse hook (Write / Edit)
# docs/artifacts/PHASE/ への書き込みを検知し、対応する docs/rules/PHASE/ の
# ルールを事前に読むよう強制する。
# セッション内で一度ルールを読了したフェーズは再ブロックしない。
# =============================================================================

STATE_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/.rules-gate-state"
mkdir -p "$STATE_DIR" 2>/dev/null

# stdin から hook input を読み取る
INPUT=$(cat)

# tool_input.file_path を抽出（jq なし簡易パース）
FILE_PATH=$(echo "$INPUT" | grep -oP '"file_path"\s*:\s*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')

# docs/artifacts/ 配下でなければ何もしない
if ! echo "$FILE_PATH" | grep -q 'docs/artifacts/'; then
  exit 0
fi

# フェーズを抽出: docs/artifacts/PHASE/... → PHASE
PHASE=$(echo "$FILE_PATH" | grep -oP 'docs/artifacts/\K[^/]+')

if [ -z "$PHASE" ]; then
  exit 0
fi

# フェーズ → ルールディレクトリのマッピング確認
case "$PHASE" in
  detailed-design|implementation|unit-test|integration-test)
    RULES_DIR="docs/rules/$PHASE"
    ;;
  *)
    # 未知のフェーズは通過させる
    exit 0
    ;;
esac

# 対象領域（frontend/backend）を抽出
DOMAIN=$(echo "$FILE_PATH" | grep -oP "docs/artifacts/$PHASE/\K[^/]+")

# セッション内で既にルール読了済みかチェック
STATE_KEY="${PHASE}"
if [ -n "$DOMAIN" ] && ([ "$DOMAIN" = "frontend" ] || [ "$DOMAIN" = "backend" ]); then
  STATE_KEY="${PHASE}_${DOMAIN}"
fi

STATE_FILE="$STATE_DIR/$STATE_KEY"

if [ -f "$STATE_FILE" ]; then
  # 読了済み → 通過
  exit 0
fi

# ルール参照を要求してブロック
if [ -n "$DOMAIN" ] && ([ "$DOMAIN" = "frontend" ] || [ "$DOMAIN" = "backend" ]); then
  RULES_PATH="$RULES_DIR/$DOMAIN/"
  cat <<MSG
[RULES_GATE] docs/artifacts/$PHASE/$DOMAIN/ への書き込みを検知しました。

この成果物を作成する前に、以下のルール・テンプレートを必ず読んでください:
- docs/rules/$PHASE/INSTRUCTIONS.md（フェーズ全体のルール）
- ${RULES_PATH}INSTRUCTIONS.md（${DOMAIN} 固有のルール）
- ${RULES_PATH} 配下の template.md または guidelines.md（テンプレート・ガイドライン）

ルールを読んだ後、以下のコマンドを Bash で実行してから再度書き込んでください:
  mkdir -p "$CLAUDE_PROJECT_DIR/.claude/.rules-gate-state" && touch "$CLAUDE_PROJECT_DIR/.claude/.rules-gate-state/${STATE_KEY}"
MSG
else
  cat <<MSG
[RULES_GATE] docs/artifacts/$PHASE/ への書き込みを検知しました。

この成果物を作成する前に、以下のルール・テンプレートを必ず読んでください:
- docs/rules/$PHASE/INSTRUCTIONS.md（フェーズ全体のルール）
- docs/rules/$PHASE/ 配下のサブディレクトリにある INSTRUCTIONS.md, template.md, guidelines.md

ルールを読んだ後、以下のコマンドを Bash で実行してから再度書き込んでください:
  mkdir -p "$CLAUDE_PROJECT_DIR/.claude/.rules-gate-state" && touch "$CLAUDE_PROJECT_DIR/.claude/.rules-gate-state/${STATE_KEY}"
MSG
fi

exit 2
