#!/bin/bash
# Vue 3 Composition API 轉換腳本

# 這個腳本將幫助完成剩下的 6 個組件轉換：
# 1. PatternGame.vue  
# 2. SequenceGame.vue 
# 3. ShadowGame.vue   
# 4. MatchGame.vue    
# 5. SortGame.vue     
# 6. ReactionGame.vue 

# 每個組件的轉換步驟：
# 1. 將 export default { ... } 改為 <script setup>
# 2. 使用 defineEmits() 定義發送事件
# 3. 使用 ref() 替代 data()
# 4. 使用 computed() 替代 computed
# 5. 直接定義方法（無需 methods: 包裝）
# 6. 導入必要的生命週期鉤子（onMounted, onBeforeUnmount 等）

# 命令範例：
# cp src/components/PatternGame.vue src/components/PatternGame_old.vue
# # 編輯 PatternGame.vue 使用上述轉換步驟
# npm run build
# git add -A && git commit -m "refactor: convert remaining 6 components to Composition API"
