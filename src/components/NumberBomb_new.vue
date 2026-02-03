<template>
  <div class="bomb-game-screen">
    <!-- 難度選擇 -->
    <div v-if="!gameStarted" class="difficulty-selector">
      <div class="title-section">
        <h2>💣 數字炸彈</h2>
        <p class="subtitle">選擇難度開始遊戲</p>
      </div>
      <div class="difficulty-buttons">
        <button @click="startGame('easy')" class="difficulty-btn easy">
          ⭐ 簡單 (寬鬆時間)
        </button>
        <button @click="startGame('medium')" class="difficulty-btn medium">
          ⭐⭐ 中等 (正常時間)
        </button>
        <button @click="startGame('hard')" class="difficulty-btn hard">
          ⭐⭐⭐ 困難 (時間緊張)
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
          <span class="label">生命值:</span>
          <div class="hearts">
            <span v-for="i in 3" :key="i" class="heart" :class="{ lost: i > lives }">
              ❤️
            </span>
          </div>
        </div>
        <div class="info-item">
          <span class="label">分數:</span>
          <span class="score">{{ score }}</span>
        </div>
      </div>
    </div>

    <!-- 遊戲區域 -->
    <div v-if="gameStarted && !gameOver" class="bomb-game-area">
      <div class="instructions">
        <p>🎯 找到: <strong>{{ targetNumber }}</strong></p>
      </div>

      <div class="time-display">
        <div class="time-bar">
          <div class="time-fill" :style="{ width: timePercentage + '%' }"></div>
        </div>
        <span class="time-text">{{ timeLeft.toFixed(1) }}s</span>
      </div>

      <div class="numbers-container">
        <button
          v-for="num in currentNumbers"
          :key="num"
          class="number-btn"
          @click="checkNumber(num)"
          :class="{ selected: selectedIndex === currentNumbers.indexOf(num) }"
        >
          {{ num }}
        </button>
      </div>

      <div class="stats">
        <p>連續命中: {{ wins }}</p>
      </div>
    </div>

    <!-- 遊戲結束 -->
    <div v-else-if="gameOver" class="game-over-screen">
      <div class="result-card">
        <div class="emoji">💣</div>
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
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'

const emit = defineEmits(['back'])

// 狀態
const difficulty = ref(null)
const gameStarted = ref(false)
const currentNumbers = ref([])
const targetNumber = ref(null)
const score = ref(0)
const lives = ref(3)
const gameOver = ref(false)
const wins = ref(0)
const timeLeft = ref(3)
const timeTotal = ref(3)
const gameTimer = ref(null)
const difficultyLevel = ref(1)
const selectedIndex = ref(-1)
const isCorrect = ref(false)

// 計算屬性
const timePercentage = computed(() => {
  return (timeLeft.value / timeTotal.value) * 100
})

const resultMessage = computed(() => {
  if (wins.value >= 5) {
    return '太棒了！你是數字高手！🌟'
  } else if (wins.value >= 3) {
    return '很不錯！再加油！💪'
  } else {
    return '繼續練習喔！下次會更好！💙'
  }
})

const difficultyText = computed(() => {
  if (difficulty.value === 'easy') return '簡單'
  if (difficulty.value === 'medium') return '中等'
  if (difficulty.value === 'hard') return '困難'
  return ''
})

// 方法
const generateRound = () => {
  const count = 3 + Math.floor(difficultyLevel.value / 2)
  const range = 10 + difficultyLevel.value * 5
  const numbers = new Set()

  while (numbers.size < count) {
    numbers.add(Math.floor(Math.random() * range) + 1)
  }

  currentNumbers.value = Array.from(numbers).sort(() => Math.random() - 0.5)
  targetNumber.value = currentNumbers.value[Math.floor(Math.random() * currentNumbers.value.length)]
  timeLeft.value = timeTotal.value
  selectedIndex.value = -1
  isCorrect.value = false
}

const startTimer = () => {
  if (gameTimer.value) clearInterval(gameTimer.value)

  gameTimer.value = setInterval(() => {
    timeLeft.value -= 0.05

    if (timeLeft.value <= 0) {
      clearInterval(gameTimer.value)
      loseLife()
    }
  }, 50)
}

const checkNumber = (num) => {
  clearInterval(gameTimer.value)

  selectedIndex.value = currentNumbers.value.indexOf(num)

  if (num === targetNumber.value) {
    isCorrect.value = true
    score.value += Math.max(Math.floor(timeLeft.value * 10), 5)
    wins.value++
    difficultyLevel.value += 0.5

    setTimeout(() => {
      if (lives.value > 0) {
        generateRound()
        startTimer()
      }
    }, 500)
  } else {
    loseLife()
  }
}

const loseLife = () => {
  clearInterval(gameTimer.value)
  lives.value--

  if (lives.value <= 0) {
    gameOver.value = true
  } else {
    setTimeout(() => {
      generateRound()
      startTimer()
    }, 800)
  }
}

const startGame = (level) => {
  difficulty.value = level
  difficultyLevel.value = level === 'easy' ? 1 : level === 'medium' ? 2 : 3
  timeTotal.value = level === 'easy' ? 5 : level === 'medium' ? 3.5 : 2.5
  score.value = 0
  lives.value = 3
  wins.value = 0
  gameOver.value = false
  gameStarted.value = true
  generateRound()
  startTimer()
}

const resetGame = () => {
  difficulty.value = null
  gameStarted.value = false
  gameOver.value = false
  score.value = 0
  lives.value = 3
  wins.value = 0
  currentNumbers.value = []
  timeLeft.value = 3
  timeTotal.value = 3
  if (gameTimer.value) clearInterval(gameTimer.value)
}

onBeforeUnmount(() => {
  if (gameTimer.value) clearInterval(gameTimer.value)
})
</script>

<style scoped>
.bomb-game-screen {
  width: 100%;
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 30px 20px;
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
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
  transition: all 0.3s ease;
  font-weight: bold;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
}

.back-btn:hover {
  transform: scale(1.05);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.3);
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

.hearts {
  display: flex;
  gap: 5px;
}

.heart {
  font-size: 1.5rem;
  transition: all 0.2s ease;
}

.heart.lost {
  opacity: 0.3;
}

.bomb-game-area {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 30px;
}

.instructions {
  color: white;
  font-size: 1.5rem;
  font-weight: bold;
  text-align: center;
  background: rgba(255, 255, 255, 0.1);
  padding: 20px 40px;
  border-radius: 15px;
}

.time-display {
  width: 100%;
  max-width: 400px;
  text-align: center;
}

.time-bar {
  height: 20px;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 10px;
  overflow: hidden;
  margin-bottom: 10px;
}

.time-fill {
  height: 100%;
  background: linear-gradient(90deg, #84fab0 0%, #8fd3f4 100%);
  transition: width 0.05s linear;
}

.time-text {
  color: white;
  font-weight: bold;
  font-size: 1.3rem;
}

.numbers-container {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(80px, 1fr));
  gap: 15px;
  width: 100%;
  max-width: 400px;
}

.number-btn {
  padding: 20px;
  font-size: 1.8rem;
  background: white;
  border: 3px solid rgba(255, 255, 255, 0.5);
  border-radius: 15px;
  cursor: pointer;
  font-weight: bold;
  color: #667eea;
  transition: all 0.2s ease;
}

.number-btn:hover {
  transform: scale(1.1);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2);
}

.number-btn.selected {
  background: #667eea;
  color: white;
  border-color: #667eea;
}

.stats {
  color: white;
  font-size: 1.3rem;
  font-weight: bold;
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
  color: #f5576c;
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
</style>
