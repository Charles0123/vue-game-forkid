# Heroku 部署指南 🚀

## 前提條件
確保已安裝：
- Node.js 18+
- npm 9+
- Heroku CLI

## 部署步驟

### 1. 本地測試
```bash
npm install
npm run start
```
訪問 http://localhost:3000 確保應用正常運行

### 2. 初始化 Git（如果還沒有）
```bash
git init
git add .
git commit -m "Initial commit: Vue Kids Game"
```

### 3. 登錄 Heroku
```bash
heroku login
```

### 4. 建立 Heroku App
```bash
heroku create your-app-name
```
將 `your-app-name` 替換為您想要的應用名稱

### 5. 部署到 Heroku
```bash
git push heroku main
```
或如果您使用 master 分支：
```bash
git push heroku master
```

### 6. 查看應用
```bash
heroku open
```

## 檔案說明

- **server.js** - Express 伺服器，用於在 Heroku 上運行應用
- **Procfile** - 告訴 Heroku 如何啟動應用
- **package.json** - 更新了 npm scripts 和依賴
  - `npm start` - 在 Heroku 上運行：先編譯 Vue，再啟動 Express 伺服器

## 常用 Heroku 命令

```bash
# 查看日誌
heroku logs --tail

# 查看應用信息
heroku info

# 設置環境變數
heroku config:set KEY=value

# 查看環境變數
heroku config

# 重啟應用
heroku restart

# 刪除應用
heroku apps:destroy --app your-app-name
```

## 環境變數

如果需要設置特定環境變數，使用：
```bash
heroku config:set NODE_ENV=production
```

## 故障排除

### 1. 應用崩潰
```bash
heroku logs --tail
```
查看詳細的錯誤信息

### 2. 構建失敗
- 確保 package.json 中的依賴版本正確
- 檢查是否有語法錯誤

### 3. 靜態文件未加載
- 確保 `npm run build` 正確生成了 dist 文件夾
- 檢查 server.js 中的靜態文件路徑

## 自動部署（GitHub 集成）

1. 在 Heroku Dashboard 中查看您的應用
2. 進入 "Deploy" 標籤
3. 連接 GitHub 帳戶
4. 選擇您的倉庫
5. 啟用「自動部署」

---

祝部署順利！ 🎉
