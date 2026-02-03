#!/bin/pwsh
# Vue 3 Composition API 批量轉換腳本

$components = @('PatternGame', 'SequenceGame', 'ShadowGame', 'MatchGame', 'SortGame', 'ReactionGame')
$srcPath = 'c:\00.Charles\Front-End\Vue\vue開發者快速復建計畫\vue-game\src\components'

# 轉換說明文檔
Write-Host @"
╔════════════════════════════════════════════════════════════════╗
║  Vue 3 Composition API 轉換指南                               ║
╚════════════════════════════════════════════════════════════════╝

待轉換組件：
1. PatternGame.vue      - 規律尋找遊戲
2. SequenceGame.vue     - 記憶序列遊戲
3. ShadowGame.vue       - 影子配對遊戲
4. MatchGame.vue        - 配對大師遊戲
5. SortGame.vue         - 數字排序遊戲
6. ReactionGame.vue     - 反應測驗遊戲

轉換步驟概述：
───────────────────────────────────────────────────────────────

1. 腳本標籤：
   FROM: <script>
         export default {
           name: 'ComponentName',
           emits: ['back'],
           data() { return {...} },
           computed: {...},
           methods: {...}
         }
         </script>
   
   TO: <script setup>
       import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
       const emit = defineEmits(['back'])
       // state, computed, methods 都在这里定义
       </script>

2. 狀態轉換：
   FROM: data() { return { count: 0 } }
   TO:   const count = ref(0)

3. 計算屬性：
   FROM: computed: { messageFROM() { return 'text' } }
   TO:   const message = computed(() => 'text')

4. 方法轉換：
   FROM: methods: { doSomething() { ... } }
   TO:   const doSomething = () => { ... }

5. 事件發送：
   FROM: this.$emit('back')
   TO:   emit('back')

6. 模板更新：
   FROM: @click="$emit('back')"
   TO:   @click="emit('back')"

7. 生命週期：
   FROM: mounted() { ... }
   TO:   onMounted(() => { ... })

準備工作：
───────────────────────────────────────────────────────────────

// 為每個組件備份原始版本
$components | ForEach-Object {
    Copy-Item "$srcPath/$_.vue" "$srcPath/$_`_backup.vue" -Force
}

推薦轉換順序（由簡到難）：
───────────────────────────────────────────────────────────────

1️⃣  ShadowGame.vue       - 相對簡單（基於卡牌匹配）
2️⃣  PatternGame.vue      - 中等複雜性
3️⃣  SequenceGame.vue     - 中等複雜性
4️⃣  MatchGame.vue        - 中等複雜性
5️⃣  SortGame.vue         - 相對複雜（邏輯遊戲）
6️⃣  ReactionGame.vue     - 最複雜（計時器管理）

已有的 Composition API 模板可參考：
───────────────────────────────────────────────────────────────
- MemoryGame.vue (已轉換)
- NumberBomb.vue (已轉換)
- ColorWheel.vue (已轉換)
- MathGame.vue (已轉換)

快速轉換檢查清單：
───────────────────────────────────────────────────────────────
☐ 更換 <script> 標籤為 <script setup>
☐ 添加正確的 import 語句
☐ 定義 emit = defineEmits(['back'])
☐ 轉換所有 data() 為 ref() 或 reactive()
☐ 轉換所有 computed 為 computed()
☐ 轉換所有 methods 為函數定義
☐ 轉換所有 $emit() 為 emit()
☐ 轉換生命週期鉤子
☐ 刪除 name: 'ComponentName' (在 <script setup> 不需要)
☐ 測試組件功能是否正常

編譯和測試：
───────────────────────────────────────────────────────────────
npm run build          # 檢查是否有編譯錯誤
npm run dev            # 本地測試
# 在瀏覽器中測試各遊戲功能

提交到 Git：
───────────────────────────────────────────────────────────────
git add src/components/*.vue
git commit -m "refactor: convert all remaining components to Composition API"
git push heroku master  # 部署到 Heroku

預計時間：
───────────────────────────────────────────────────────────────
每個組件: 15-25 分鐘
全部完成: 2-3 小時
"@
