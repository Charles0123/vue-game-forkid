<template>
  <div class="sequence-game-screen">
    <!-- 遊戲頂部 -->
    <div class="game-header">
      <button class="back-btn" @click="emit('back')">◀ 返回菜單</button>
      <div class="game-info">
        <div class="info-item">
          <span class="label">難度:</span>
          <span class="difficulty" :class="difficulty">{{ difficultyText }}</span>
        </div>
        <div class="info-item">
          <span class="label">分數:</span>
          <span class="score">{{ score }}</span>
        </div>
      </div>
    </div>

    <!-- 難度選擇 -->
    <div v-if="!gameStarted" class="difficulty-selector">
      <h2>記憶序列遊戲</h2>
      <p class="subtitle">記住並重複顏色</p>
      <div class="difficulty-buttons">
        <button @click="startGame('easy')" class="difficulty-btn easy">
          🌟簡單 (3級)
        </button>
        <button @click="startGame('medium')" class="difficulty-btn medium">
          ⭐⭐ 中等 (5級)
        </button>
        <button @click="startGame('hard')" class="difficulty-btn hard">
          ⭐⭐⭐困難 (8級)
        </button>
      </div>
    </div>

    <!-- 遊戲操作-->
    <div v-else-if="!gameOver" class="game-area">
      <div class="sequence-display">
        <p class="instruction">{{ instruction }}</p>
        <button @click="playSequence" class="play-btn" :disabled="isPlaying">
          🔊播放序列
        </button>
      </div>

      <div class="color-grid">
        <div
          v-for="(color, index) in colors"
          :key="index"
          class="color-box"
          :style="{ backgroundColor: color }"
          @click="selectColor(index)"
          :class="{ active: activeColor === index }"
        >
          {{ colorNames[index] }}
        </div>
      </div>

      <div class="info-text">
        <p>已回應: {{ userSequence.length }}/{{ sequence.length }}</p>
      </div>
    </div>

    <!-- 遊戲結束 -->
    <div v-else class="game-over-screen">
      <div class="result-card">
        <div class="emoji">🎉</div>
        <h2>{{ resultMessage }}</h2>
        <p class="stats">
          完成級數: {{ level }} | 分數: {{ score }}
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

// State
const difficulty = ref(null)
const gameStarted = ref(false)
const gameOver = ref(false)
const sequence = ref([])
const userSequence = ref([])
const level = ref(1)
const maxLevel = ref(0)
const isPlaying = ref(false)
const activeColor = ref(-1)
const colors = ref(['#FF6B6B', '#4CAF50', '#2196F3', '#FFD700'])
const colorNames = ref(['紅', '綠', '藍', '金'])
const score = ref(0)
const instruction = ref('觀察顏色序列')

// Computed
const difficultyText = computed(() => {
  const map = { easy: '簡單', medium: '中等', hard: '困難' }
  return map[difficulty.value] || ''
})

const resultMessage = computed(() => {
  if (level.value >= 10) return '記憶超人！太厲害了！'
  if (level.value >= 6) return '很好的記憶力，表現相當不錯！'
  return '繼續加油！下次會更好！'
})

// Methods
const startGame = (lvl) => {
  difficulty.value = lvl
  gameStarted.value = true
  if (lvl === 'easy') {
    maxLevel.value = 5
  } else if (lvl === 'medium') {
    maxLevel.value = 7
  } else {
    maxLevel.value = 10
  }
  startRound()
}

const startRound = () => {
  const randomColor = Math.floor(Math.random() * colors.value.length)
  sequence.value.push(randomColor)
  userSequence.value = []
  instruction.value = '觀察顏色序列'
  setTimeout(() => {
    playSequence()
  }, 500)
}

const playSequence = () => {
  isPlaying.value = true
  instruction.value = '播放序列'
  let delay = 0
  const speed = 100 + (5 - difficulty.value.length) * 100

  sequence.value.forEach((colorIndex) => {
    setTimeout(() => {
      activeColor.value = colorIndex
      setTimeout(() => {
        activeColor.value = -1
      }, speed / 2)
    }, delay)
    delay += speed
  })

  setTimeout(() => {
    isPlaying.value = false
    instruction.value = '你的轉身！請點擊顏色'
  }, delay)
}

const selectColor = (index) => {
  if (isPlaying.value) return

  userSequence.value.push(index)
  activeColor.value = index
  setTimeout(() => {
    activeColor.value = -1
  }, 100)

  if (userSequence.value[userSequence.value.length - 1] !== sequence.value[userSequence.value.length - 1]) {
    gameOver.value = true
    return
  }

  if (userSequence.value.length === sequence.value.length) {
    level.value++
    score.value += 10 * level.value
    if (level.value > maxLevel.value) {
      gameOver.value = true
    } else {
      setTimeout(() => {
        startRound()
      }, 1000)
    }
  }
}

const resetGame = () => {
  difficulty.value = null
  gameStarted.value = false
  gameOver.value = false
  sequence.value = []
  userSequence.value = []
  level.value = 1
  score.value = 0
  maxLevel.value = 0
}
</script>

<style scoped>
.sequence-game-screen {
  width: 100%;
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 30px 20px;
}

.game-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 40px;
  flex-wrap: wrap;
  gap: 20px;
}

.back-btn {
  padding: 12px 24px;
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
}

.game-info {
  display: flex;
  gap: 30px;
  background: rgba(255, 255, 255, 0.95);
  padding: 15px 30px;
  border-radius: 15px;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

.info-item {
  display: flex;
  align-items: center;
  gap: 10px;
}

.label {
  font-weight: bold;
  color: #667eea;
  font-size: 1.1rem;
}

.difficulty {
  font-size: 1.3rem;
  font-weight: bold;
  padding: 5px 15px;
  border-radius: 10px;
}

.difficulty.easy {
  background: #90EE90;
  color: #333;
}

.difficulty.medium {
  background: #FFD700;
  color: #333;
}

.difficulty.hard {
  background: #FF6B6B;
  color: white;
}

.score {
  font-size: 1.5rem;
  font-weight: bold;
  color: #f5576c;
}

.difficulty-selector {
  max-width: 600px;
  margin: 50px auto;
  background: rgba(255, 255, 255, 0.95);
  border-radius: 25px;
  padding: 40px;
  text-align: center;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
  animation: slideUp 0.5s ease-out;
}

.difficulty-selector h2 {
  font-size: 2rem;
  color: #667eea;
  margin-bottom: 10px;
}

.subtitle {
  font-size: 1.1rem;
  color: #666;
  margin-bottom: 30px;
}

.difficulty-buttons {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 20px;
}

.difficulty-btn {
  padding: 30px;
  font-size: 1.2rem;
  border: none;
  border-radius: 15px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: bold;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
  color: white;
}

.difficulty-btn.easy {
  background: linear-gradient(135deg, #90EE90 0%, #7CCD7C 100%);
}

.difficulty-btn.medium {
  background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
}

.difficulty-btn.hard {
  background: linear-gradient(135deg, #FF6B6B 0%, #FF4444 100%);
}

.difficulty-btn:hover {
  transform: scale(1.1);
}

.game-area {
  max-width: 600px;
  margin: 0 auto;
}

.sequence-display {
  background: rgba(255, 255, 255, 0.95);
  padding: 30px;
  border-radius: 20px;
  margin-bottom: 30px;
  text-align: center;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
  animation: slideDown 0.5s ease-out;
}

.instruction {
  font-size: 1.5rem;
  color: #667eea;
  font-weight: bold;
  margin-bottom: 20px;
}

.play-btn {
  padding: 15px 40px;
  font-size: 1.3rem;
  border: none;
  border-radius: 15px;
  cursor: pointer;
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  color: white;
  transition: all 0.3s ease;
  font-weight: bold;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
}

.play-btn:hover:not(:disabled) {
  transform: scale(1.05);
}

.play-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.color-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
  margin-bottom: 30px;
}

.color-box {
  aspect-ratio: 1;
  border-radius: 20px;
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: bold;
  font-size: 1.3rem;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
  border: 3px solid white;
}

.color-box:hover {
  transform: scale(1.05);
}

.color-box.active {
  transform: scale(0.95);
  box-shadow: 0 0 30px rgba(255, 255, 255, 0.8);
}

.info-text {
  background: rgba(255, 255, 255, 0.95);
  padding: 15px;
  border-radius: 15px;
  text-align: center;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

.info-text p {
  font-size: 1.2rem;
  color: #667eea;
  font-weight: bold;
  margin: 0;
}

.game-over-screen {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  padding: 20px;
}

.result-card {
  background: white;
  border-radius: 30px;
  padding: 50px 40px;
  text-align: center;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  animation: popIn 0.5s ease-out;
}

.emoji {
  font-size: 4rem;
  margin-bottom: 20px;
  animation: bounce 0.8s ease infinite;
}

.result-card h2 {
  font-size: 2rem;
  color: #667eea;
  margin-bottom: 20px;
}

.stats {
  font-size: 1.2rem;
  color: #555;
  margin-bottom: 30px;
}

.restart-btn,
.menu-btn {
  padding: 15px 40px;
  font-size: 1.1rem;
  border: none;
  border-radius: 15px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: bold;
  margin: 10px;
}

.restart-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.menu-btn {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
}

.restart-btn:hover,
.menu-btn:hover {
  transform: scale(1.05);
}

@keyframes slideUp {
  from {
    transform: translateY(30px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

@keyframes slideDown {
  from {
    transform: translateY(-30px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

@keyframes popIn {
  from {
    transform: scale(0.5);
    opacity: 0;
  }
  to {
    transform: scale(1);
    opacity: 1;
  }
}

@keyframes bounce {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.2);
  }
}
</style>
