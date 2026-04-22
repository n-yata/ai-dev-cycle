# 日記アプリ技術スタック選定 — ナレッジ記録

| 項目 | 内容 |
|------|------|
| 記録日 | 2026-04-21 |
| 最終更新 | 2026-04-21 |
| 記録者 | バルベルデ / モドリッチ |
| フェーズ | 基本設計 |
| カテゴリ | design-decisions |
| 対象領域 | フロントエンド |
| 重要度 | 高（必読） |

---

## 概要

フロントエンドのみ（バックエンドなし）の PWA 日記アプリにおける技術スタック選定。React 18 + Vite + TypeScript + Dexie.js + vite-plugin-pwa を採用。画像保存は IndexedDB への Blob 保存を選択。

---

## 背景・コンテキスト

**状況:** シングルユーザー向け PWA 日記アプリ。認証なし・バックエンドなし・データはブラウザローカル保存。

**課題・問題:** フレームワーク・IndexedDB ラッパー・画像保存方式の選定が必要。

---

## 事実（何を決めたか）

| 用途 | 採用 |
|------|------|
| UIフレームワーク | React 18 |
| ビルドツール | Vite |
| 言語 | TypeScript |
| ローカルDB | Dexie.js（IndexedDB ラッパー） |
| PWA | vite-plugin-pwa |
| ルーティング | React Router v6 |
| 状態管理 | React Context + useReducer |
| スタイリング | CSS Modules |
| カレンダーUI | react-day-picker |
| 画像保存方式 | IndexedDB に Blob として保存 |

---

## 理由・分析

### 検討した選択肢

| 選択肢 | メリット | デメリット | 採用 |
|--------|---------|----------|------|
| React 18 | エコシステム成熟、PWA+IndexedDB の実績豊富 | — | ✅ 採用 |
| Vue 3 | 学習コスト低、小規模アプリ向き | カレンダーUI等のライブラリが React より少ない | ❌ 却下 |
| Svelte | 高性能・軽量 | エコシステムの成熟度が低い | ❌ 却下 |
| Redux/Zustand | 大規模状態管理 | このアプリ規模では過剰 | ❌ 却下 |
| Tailwind CSS | 開発速度高 | HTML可読性低下、学習コスト | ❌ 却下 |
| idb | 軽量 | 低レベルAPIで記述量多い | ❌ 却下 |
| 画像: Base64 | img タグにそのまま渡せる | サイズ33%増大、ストレージ圧迫 | ❌ 却下 |
| 画像: Blob保存 | ストレージ効率良、Dexie.jsがネイティブ対応 | URL.createObjectURL()が必要 | ✅ 採用 |

---

## 次回への示唆

### すべきこと（Do）

- [ ] PWA + ローカルストレージ構成では Dexie.js を第一候補にする
- [ ] 画像を IndexedDB に保存する場合は Blob 保存を選ぶ
- [ ] 小〜中規模 SPA の状態管理は Context + useReducer から始める（複雑化したら Zustand へ移行）

### 避けること（Don't）

- 画像を Base64 に変換して IndexedDB に保存しない（33%サイズ増大）
- シングルユーザー・小規模アプリに Redux を導入しない

---

## タグ

`PWA`, `React`, `Vite`, `TypeScript`, `Dexie.js`, `IndexedDB`, `画像保存`, `Blob`, `フロントエンドのみ`
