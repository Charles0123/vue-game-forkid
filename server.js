import express from "express";
import { fileURLToPath } from "url";
import { dirname } from "path";
import path from "path";
import fs from "fs";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3000;
const distPath = path.join(__dirname, "dist");

// 檢查 dist 文件夾是否存在
if (!fs.existsSync(distPath)) {
  console.error("❌ Error: dist folder not found!");
  console.error("Please run 'npm run build' first");
  process.exit(1);
}

// 提供靜態文件
app.use(express.static(distPath));

// 處理 SPA 路由 - 所有請求都指向 index.html
app.get("*", (req, res) => {
  const indexPath = path.join(distPath, "index.html");
  if (fs.existsSync(indexPath)) {
    res.sendFile(indexPath);
  } else {
    res.status(404).send("index.html not found");
  }
});

// 錯誤處理
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send("Something went wrong!");
});

// 啟動伺服器
app.listen(PORT, () => {
  console.log(`✅ Server is running on http://localhost:${PORT}`);
  console.log(`📁 Serving files from: ${distPath}`);
});
