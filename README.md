# 正念習慣知識庫（Mindfulness Habit Knowledge Hub）

> 對象：**自己、團隊成員** ｜ 架構：**麥肯錫結構化 10 分鐘簡報 ✕ 原創 SVG 圖解 ✕ 全域關鍵字檢索 ✕ 可擴充多書入口 ✕ Supabase BaaS (RLS) ✕ GitHub Pages**

🌐 **線上網址 (GitHub Pages)**：https://davidyeh51.github.io/mindfulness-knowledge-hub/

---

## 核心特色

1. **可持續擴充的多書門戶架構 (`data/library.json`)**：
   - 首頁直接連結各本書籍／專題的獨立簡報，已上架旗艦書目《正念習慣：日復一日構建內心的平靜》，並預留《用正念改寫你的人生劇本》《倦怠免疫力：用腦不走心》《「半憂鬱」大腦訊號與四階段修復》《正念禪修：在喧囂的世界中獲取安寧》等擴充席位。
   - 新增書籍僅需 3 個標準步驟（詳見 [`docs/EXPANSION.md`](docs/EXPANSION.md)），無須修改首頁主程式。
2. **全域關鍵字即時檢索 (`Ctrl + K`)**：
   - 由 `data/search-index.json` 驅動，支援跨書籍、跨頁碼多關鍵字即時篩選、熱門概念快選與關鍵字高亮，點擊結果卡片即精準跳轉至目標簡報指定頁碼（`#slide-N`）。
3. **麥肯錫 10 分鐘完整簡報 (`decks/the-mindfulness-habit.html`)**：
   - **MIND-01《正念習慣：日復一日構建內心的平靜》**（〔英〕麗莎·雷恩著／高小娟譯）：16 頁 16:9 投影片（涵蓋引言＋八章＋八課實作），嚴格忠於來源原文（未載明具體數據處明確標註「原文未載」）。
   - 內嵌 12+ 張原創 McKinsey 向量 SVG 圖表（重繪原書圖Ⅰ～圖Ⅲ、圖1-1～1-4、圖3-1～3-2、表3-2、圖4-1、表5-1、表6-1、圖6-1、圖7-1～7-2、圖8-1），並重新繪製書籍封面與首頁主視覺（儲存於 `assets/images/`）。
   - 內建三段式講者備忘稿抽屜（按 `N` 展開）、10 分鐘演講計時器（按 `T`）、投影片總覽與頁內搜尋（按 `G`）、全螢幕（按 `F`）與列印/PDF 匯出。
4. **「STOP 暫停 × 工作假設重塑器」✕ Supabase 雲端共學 (`supabase/schema.sql`)**：
   - 前端僅使用公開 `publishable key`（零私鑰外洩風險），後端採用 PostgreSQL **Row Level Security (RLS)** 保護 `mindfulness_team_notes` 與 `mindfulness_action_checkins`。
   - 未登入時亦自動無縫降級為瀏覽器本機 `localStorage` 暫存，個人與團隊成員皆可零阻礙使用。

---

## 專案目錄結構

```text
mindfulness-knowledge-hub/
├── index.html                        # 知識庫首頁門戶（搜尋、書庫、STOP 重塑器、團隊共學）
├── decks/
│   └── the-mindfulness-habit.html    # 《正念習慣》16 頁麥肯錫 10 分鐘完整簡報
├── assets/
│   ├── css/                          # portal.css, deck.css
│   ├── js/                           # portal.js, deck.js, supabase-sync.js
│   └── images/                       # 重新繪製之首頁主視覺與書籍封面插畫
├── data/
│   ├── library.json                  # 書目註冊檔與預留擴充槽位
│   └── search-index.json             # 跨書全域關鍵字搜尋索引
├── docs/
│   └── EXPANSION.md                  # 3 步驟擴充維護手冊
└── supabase/
    └── schema.sql                    # PostgreSQL 資料表與 RLS 安全策略
```

---

## Supabase 雲端同步啟用方式

1. 登入 Supabase 專案 Dashboard → **SQL Editor**（或於首頁右上角點擊「團隊登入 / Supabase」→「複製 schema.sql」）。
2. 貼上並執行 [`supabase/schema.sql`](supabase/schema.sql)，建立 `mindfulness_team_notes` 與 `mindfulness_action_checkins` 兩張資料表與完整 RLS 安全策略。
3. 於網頁右上角登入或註冊成員帳號，即可跨裝置同步習慣打卡與共學筆記。
