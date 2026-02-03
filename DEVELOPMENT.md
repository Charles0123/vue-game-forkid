# 📖 開發和部署指南

## 🎮 本地開發

### 方式 1：開發模式（推薦用於開發）
```powershell
npm run dev
```
- 使用 Vite 快速開發服務器
- 訪問 http://localhost:5173
- 支持熱重載（Hot Reload）
- 代碼改變時自動重新整理

### 方式 2：生產模式測試（測試生成的版本）
```powershell
# 先建造
npm run build

# 再啟動伺服器
npm run serve
```
- 訪問 http://localhost:3000
- 測試實際部署到 Heroku 後的效果
- 靜態文件由 Express 提供

### 方式 3：完整啟動（包含構建）
```powershell
npm run start
```
- 先執行 `npm run build` 編譯 Vue
- 再執行 `npm run serve` 啟動伺服器
- 訪問 http://localhost:3000
- 這是 Heroku 使用的命令

## 📊 npm 腳本說明

| 命令 | 用途 | 訪問端口 |
|------|------|--------|
| `npm run dev` | 快速開發 | http://localhost:5173 |
| `npm run build` | 編譯 Vue 生成 dist | - |
| `npm run preview` | 本地預覽編譯結果 | http://localhost:5174 |
| `npm run serve` | 啟動 Express 伺服器 | http://localhost:3000 |
| `npm run start` | 編譯 + 啟動伺服器（Heroku 用） | http://localhost:3000 |

## 🚀 部署到 Heroku

### 步驟 1：確保代碼已提交
```powershell
git add .
git commit -m "Update: Add server and deployment config"
```

### 步驟 2：登錄 Heroku
```powershell
heroku login
```

### 步驟 3：建立應用（第一次）
```powershell
heroku create your-app-name
```

### 步驟 4：部署
```powershell
git push heroku main
```

### 步驟 5：打開應用
```powershell
heroku open
```

## 🔧 故障排除

### 問題：localhost 拒絕連線
```powershell
# 檢查 dist 文件夾是否存在
npm run build

# 再執行
npm run serve
```

### 問題：連接超時
- 檢查防火牆設置
- 確保沒有其他應用佔用端口 3000 或 5173
- 嘗試重啟終端

### 問題：Heroku 應用崩潰
```powershell
heroku logs --tail
```
查看詳細錯誤信息

## 📁 文件夾結構

```
vue-game/
├── src/                    # Vue 源代碼
│   ├── components/        # Vue 元件
│   ├── App.vue           # 主應用
│   └── main.js           # 入口
├── dist/                 # 編譯後的靜態文件（npm run build 生成）
├── server.js             # Express 伺服器
├── package.json          # 依賴配置
├── vite.config.js        # Vite 配置
├── Procfile              # Heroku 啟動指令
└── index.html            # HTML 模板
```

## 💡 最佳實踐

1. **開發時**：使用 `npm run dev` 快速迭代
2. **部署前**：執行 `npm run build` 確保編譯成功
3. **測試前**：執行 `npm run serve` 測試最終版本
4. **部署時**：確保所有文件已提交到 Git

---

祝您開發順利！ 🎉
