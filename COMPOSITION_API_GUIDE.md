# Vue 3 Composition API 完整轉換指南

## 已完成轉換（4 個組件）
✅ MemoryGame.vue
✅ NumberBomb.vue
✅ ColorWheel.vue
✅ MathGame.vue

## 待轉換（6 個組件）
⏳ PatternGame.vue
⏳ SequenceGame.vue
⏳ ShadowGame.vue
⏳ MatchGame.vue
⏳ SortGame.vue
⏳ ReactionGame.vue

---

## 轉換模板（以 MemoryGame.vue 為例）

### 步驟 1: 改變腳本標籤和導入

```vue
<!-- 舊的 -->
<script>
export default {
  name: 'MemoryGame',
  emits: ['back'],
  data() { ... },
  computed: { ... },
  methods: { ... },
  beforeUnmount() { ... }
}
</script>

<!-- 新的 -->
<script setup>
import { ref, computed, onBeforeUnmount } from 'vue'

const emit = defineEmits(['back'])
// 所有狀態、計算屬性、方法在此定義
</script>
```

### 步驟 2: 轉換 data() → ref()

```javascript
// 舊
data() {
  return {
    gameStarted: false,
    score: 0,
    cards: [],
    flippedCards: []
  }
}

// 新
const gameStarted = ref(false)
const score = ref(0)
const cards = ref([])
const flippedCards = ref([])
```

### 步驟 3: 轉換 computed

```javascript
// 舊
computed: {
  difficultyText() {
    if (this.difficulty === 'easy') return '簡單'
    return ''
  }
}

// 新
const difficultyText = computed(() => {
  if (difficulty.value === 'easy') return '簡單'
  return ''
})
```

⚠️ 注意：在 Composition API 中訪問 ref 需要添加 `.value`

### 步驟 4: 轉換 methods → 函數

```javascript
// 舊
methods: {
  startGame(level) {
    this.difficulty = level
    this.gameStarted = true
  }
}

// 新
const startGame = (level) => {
  difficulty.value = level
  gameStarted.value = true
}
```

### 步驟 5: 轉換事件發送

```vue
<!-- 舊 -->
<button @click="$emit('back')">返回</button>
<method> this.$emit('back') </method>

<!-- 新 -->
<button @click="emit('back')">返回</button>
<method> emit('back') </method>
```

### 步驟 6: 轉換生命週期

```javascript
// 舊
mounted() {
  this.initData()
}
beforeUnmount() {
  clearInterval(this.timer)
}

// 新
import { onMounted, onBeforeUnmount } from 'vue'

onMounted(() => {
  initData()
})
onBeforeUnmount(() => {
  clearInterval(timer.value)
})
```

---

## 各組件特定的轉換提示

### PatternGame.vue
- 轉換 `this.pattern` → `pattern.value`
- 轉換 `this.correctAnswer` → `correctAnswer.value`
- computed 中的 `this.totalQuestions` → `totalQuestions.value`

### SequenceGame.vue
- 轉換計時器邏輯（類似 MathGame）
- 轉換序列數組操作

### ShadowGame.vue
- 轉換卡牌匹配邏輯（參考 MemoryGame）
- 轉換配對檢查方法

### MatchGame.vue
- 轉換網格狀態管理
- 轉換匹配檢測邏輯

### SortGame.vue
- 轉換點擊追蹤
- 轉換進度管理

### ReactionGame.vue
- ⚠️ 複雜的計時器邏輯 - 參考現有實現
- 已在 ReactionGame_new.vue 中完成轉換

---

## 快速檢查清單

每個組件轉換後都需檢查：

```
☐ <script setup> 標籤正確
☐ 正確導入 ref, computed, 生命週期
☐ defineEmits 正確定義
☐ 所有 this.xxx 改為 xxx.value
☐ 所有 $emit() 改為 emit()
☐ 所有 computed 使用 computed()
☐ 所有 methods 轉為函數
☐ 刪除了 export default
☐ 刪除了 emits 對象（已用 defineEmits()）
☐ 刪除了 name 屬性
```

---

## 命令行快速轉換

如果您想用我提供的預構建版本直接替換：

```powershell
# 進入組件目錄
cd "c:\00.Charles\Front-End\Vue\vue開發者快速復建計畫\vue-game\src\components"

# 將新版本複製到原位置（當新版本準備好時）
Copy-Item PatternGame_new.vue PatternGame.vue
Copy-Item SequenceGame_new.vue SequenceGame.vue
Copy-Item ShadowGame_new.vue ShadowGame.vue
Copy-Item MatchGame_new.vue MatchGame.vue
Copy-Item SortGame_new.vue SortGame.vue
Copy-Item ReactionGame_new.vue ReactionGame.vue

# 測試編譯
npm run build

# 部署
git add -A
git commit -m "refactor: convert all components to Composition API"
git push heroku master
```

---

## 常見問題

### Q: 為什麼需要 `.value`？
A: 在 Composition API 中，`ref()` 返回一個響應式引用對象，需要 `.value` 訪問實際值。在模板中不需要。

### Q: computed 中怎麼訪問其他 ref？
A: 使用 `.value`：
```javascript
const total = computed(() => {
  return score.value + bonus.value
})
```

### Q: 如何處理複雜的 watch 邏輯？
A: 使用 `watch()` 函數（如需要）：
```javascript
import { watch } from 'vue'
watch(() => count.value, (newVal) => {
  console.log(newVal)
})
```

---

## 測試步驟

轉換後務必測試：

1. npm run dev 啟動開發服務器
2. 打開 http://localhost:5173
3. 進入每個遊戲測試功能
4. 檢查控制台是否有錯誤
5. npm run build 檢查生產構建

---

## 成功標誌

當所有 10 個組件都轉換完成時：
✨ 所有組件使用 Composition API
✨ 所有功能正常工作
✨ 代碼更加清晰易維護
✨ 性能無變化（Composition API 性能相同）
✨ 代碼行數可能減少
