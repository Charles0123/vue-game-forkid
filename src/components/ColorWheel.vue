<template>
  <div class="color-wheel-screen">
    <!-- 難度選擇 -->
    <div v-if="!gameStarted" class="difficulty-selector">
      <div class="title-section">
        <h2>🎨 旋轉顏色</h2>
        <p class="subtitle">選擇難度開始遊戲</p>
      </div>
      <div class="difficulty-buttons">
        <button @click="startGame('easy')" class="difficulty-btn easy">
          ⭐ 簡單 (4種顏色)
        </button>
        <button @click="startGame('medium')" class="difficulty-btn medium">
          ⭐⭐ 中等 (6種顏色)
        </button>
        <button @click="startGame('hard')" class="difficulty-btn hard">
          ⭐⭐⭐ 困難 (8種顏色)
        </button>
      </div>
      <button class="back-btn" @click="emit('back')">← 返回菜單</button>
    </div>

    <!-- 遊戲頭部 -->
    <div v-else class="game-header">
      <button class="back-btn" @click="emit('back')">← 返回菜單</button>
      <div class="game-info">
        <div class="info-item">
          <span class="label">難度:</span>
          <span class="difficulty" :class="difficulty">{{ difficultyText }}</span>
        </div>
        <div class="info-item">
          <span class="label">等級:</span>
          <span class="level">{{ level }}</span>
        </div>
        <div class="info-item">
          <span class="label">分數:</span>
          <span class="score">{{ score }}</span>
        </div>
      </div>
    </div>

    <!-- 遊戲區域 -->
    <div v-if="gameStarted && !gameOver" class="game-area">
      <!-- 顏色輪盤 -->
      <div class="wheel-container">
        <div class="instructions">
          <p>點擊 <span class="target-color" :style="{ color: targetColor }">{{ targetColorName }}</span> 色</p>
        </div>

        <div class="color-wheel" :style="{ transform: `rotate(${rotation}deg)` }">
          <div
            v-for="(color, index) in colors"
            :key="index"
            class="color-slice"
            :style="{ backgroundColor: color }"
            @click="checkColor(color)"
          >
            <div class="color-label">{{ getColorName(color) }}</div>
          </div>
        </div>
      </div>

      <!-- 進度指示 -->
      <div class="progress">
        <p>完成: {{ correctCount }}/{{ roundsToWin }}</p>
        <div class="progress-bar">
          <div class="progress-fill" :style="{ width: (correctCount / roundsToWin) * 100 + '%' }"></div>
        </div>
      </div>
    </div>

    <!-- 遊戲結束 -->
    <div v-else-if="gameOver" class="game-over-screen">
      <div class="result-card">
        <div class="emoji">🎨</div>
        <h2>{{ resultMessage }}</h2>
        <p class="stats">
          <strong>{{ difficultyText }}</strong> 級 | <strong>{{ score }}</strong> 分
        </p>

        <button class="restart-btn" @click="resetGame">
          🔄 重新開始
        </button>
        <button class="menu-btn" @click="emit('back')">
          🏠 返回菜單
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

const emit = defineEmits(['back'])

// 狀態
const difficulty = ref(null)
const gameStarted = ref(false)
const colors = ref([])
const targetColor = ref(null)
const targetColorName = ref('')
const score = ref(0)
const level = ref(1)
const correctCount = ref(0)
const roundsToWin = ref(5)
const gameOver = ref(false)
const rotation = ref(0)

const allColors = {
  '#FF6B6B': '紅色',
  '#FFA500': '橙色',
  '#FFD700': '黃色',
  '#4CAF50': '綠色',
  '#4169E1': '藍色',
  '#9B59B6': '紫色',
  '#FF1493': '深粉色',
  '#00CED1': '深青色'
}

const colorNames = allColors

// 計算屬性
const resultMessage = computed(() => {
  if (level.value >= 6) {
    return '你是顏色大師！太厲害了！🌈'
  } else if (level.value >= 4) {
    return '很棒！繼續加油！💪'
  } else {
    return '不錯喔！下次會更好！💙'
  }
})

const difficultyText = computed(() => {
  if (difficulty.value === 'easy') return '簡單'
  if (difficulty.value === 'medium') return '中等'
  if (difficulty.value === 'hard') return '困難'
  return ''
})

// 方法
const getColorName = (color) => {
  return colorNames[color] || color
}

const selectTargetColor = () => {
  targetColor.value = colors.value[Math.floor(Math.random() * colors.value.length)]
  targetColorName.value = colorNames[targetColor.value]
  rotation.value = Math.random() * 360
}

const checkColor = (color) => {
  if (color === targetColor.value) {
    correctCount.value++
    score.value += 10

    if (correctCount.value >= roundsToWin.value) {
      levelUp()
    } else {
      selectTargetColor()
    }
  } else {
    shakeAnimation()
  }
}

const levelUp = () => {
  level.value++
  correctCount.value = 0
  score.value += 50

  if (level.value >= 8) {
    gameOver.value = true
  } else {
    selectTargetColor()
  }
}

const shakeAnimation = () => {
  const wheel = document.querySelector('.color-wheel')
  if (wheel) {
    wheel.style.animation = 'shake 0.3s ease-in-out'
    setTimeout(() => {
      wheel.style.animation = ''
    }, 300)
  }
}

const startGame = (selectedDifficulty) => {
  difficulty.value = selectedDifficulty
  gameStarted.value = true
  gameOver.value = false
  score.value = 0
  level.value = 1
  correctCount.value = 0

  let colorCount = 0
  if (selectedDifficulty === 'easy') colorCount = 4
  else if (selectedDifficulty === 'medium') colorCount = 6
  else if (selectedDifficulty === 'hard') colorCount = 8

  const colorArray = Object.keys(colorNames)
  colors.value = colorArray.slice(0, colorCount)
  selectTargetColor()
}

const resetGame = () => {
  difficulty.value = null
  gameStarted.value = false
  gameOver.value = false
}
</script>

<style scoped>
.color-wheel-screen {
  width: 100%;
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 30px 20px;
  display: flex;
  flex-direction: column;
}

.difficulty-selector {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  gap: 30px;
}

.title-section {
  text-align: center;
  color: white;
}

.title-section h2 {
  font-size: 3rem;
  margin: 0 0 10px 0;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
}

.subtitle {
  font-size: 1.3rem;
  color: rgba(255, 255, 255, 0.9);
  margin: 0;
}

.difficulty-buttons {
  display: flex;
  flex-direction: column;
  gap: 20px;
  width: 100%;
  max-width: 400px;
}

.difficulty-btn {
  padding: 20px;
  font-size: 1.2rem;
  border: none;
  border-radius: 20px;
  cursor: pointer;
  font-weight: bold;
  color: white;
  transition: all 0.3s ease;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
}

.difficulty-btn.easy {
  background: linear-gradient(135deg, #84fab0 0%, #8fd3f4 100%);
}

.difficulty-btn.medium {
  background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
}

.difficulty-btn.hard {
  background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
}

.difficulty-btn:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.3);
}

.back-btn {
  padding: 12px 30px;
  font-size: 1.1rem;
  border: none;
  border-radius: 15px;
  cursor: pointer;
  background: rgba(255, 255, 255, 0.3);
  color: white;
  transition: all 0.3s ease;
  font-weight: bold;
  border: 2px solid white;
}

.back-btn:hover {
  background: white;
  color: #667eea;
}

.game-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 40px;
  flex-wrap: wrap;
  gap: 20px;
}

.game-info {
  display: flex;
  gap: 30px;
  align-items: center;
  flex-wrap: wrap;
  justify-content: center;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 10px;
  color: white;
  font-weight: bold;
  font-size: 1.1rem;
}

.label {
  color: rgba(255, 255, 255, 0.8);
}

.level {
  background: rgba(255, 255, 255, 0.2);
  padding: 5px 15px;
  border-radius: 20px;
}

.score {
  background: rgba(255, 255, 255, 0.2);
  padding: 5px 15px;
  border-radius: 20px;
}

.difficulty {
  padding: 5px 15px;
  border-radius: 20px;
  font-weight: bold;
}

.difficulty.easy {
  background: linear-gradient(135deg, #84fab0 0%, #8fd3f4 100%);
}

.difficulty.medium {
  background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
}

.difficulty.hard {
  background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
}

.game-area {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 40px;
}

.wheel-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
}

.instructions {
  color: white;
  font-size: 1.3rem;
  font-weight: bold;
  text-align: center;
  background: rgba(255, 255, 255, 0.1);
  padding: 15px 30px;
  border-radius: 15px;
}

.target-color {
  font-weight: bold;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
}

.color-wheel {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
  gap: 20px;
  max-width: 500px;
  margin: 20px auto;
}

.color-slice {
  width: 100px;
  height: 100px;
  border-radius: 15px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
  border: 3px solid white;
}

.color-slice:hover {
  transform: scale(1.1);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.3);
}

.color-label {
  color: white;
  font-weight: bold;
  font-size: 0.9rem;
  text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.3);
  text-align: center;
}

.progress {
  width: 100%;
  max-width: 400px;
  text-align: center;
}

.progress p {
  color: white;
  font-size: 1.2rem;
  font-weight: bold;
  margin-bottom: 10px;
}

.progress-bar {
  height: 20px;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 10px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #84fab0 0%, #8fd3f4 100%);
  transition: width 0.3s ease;
}

.game-over-screen {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
}

.result-card {
  background: white;
  padding: 40px;
  border-radius: 30px;
  text-align: center;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
  max-width: 500px;
}

.emoji {
  font-size: 4rem;
  margin-bottom: 20px;
}

.result-card h2 {
  font-size: 2rem;
  color: #667eea;
  margin: 20px 0;
}

.stats {
  font-size: 1.2rem;
  color: #764ba2;
  margin: 20px 0 30px 0;
}

.restart-btn,
.menu-btn {
  padding: 15px 30px;
  font-size: 1.1rem;
  border: none;
  border-radius: 15px;
  cursor: pointer;
  font-weight: bold;
  transition: all 0.3s ease;
  margin: 10px;
}

.restart-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.restart-btn:hover {
  transform: scale(1.05);
  box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
}

.menu-btn {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
}

.menu-btn:hover {
  transform: scale(1.05);
  box-shadow: 0 5px 15px rgba(245, 87, 108, 0.3);
}

@keyframes shake {
  0%, 100% {
    transform: translateX(0);
  }
  25% {
    transform: translateX(-10px);
  }
  75% {
    transform: translateX(10px);
  }
}
</style>
