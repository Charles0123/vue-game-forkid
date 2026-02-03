<template>
  <div class="memory-game-screen">
    <!-- 難度選擇 -->
    <div v-if="!gameStarted" class="difficulty-selector">
      <div class="title-section">
        <h2>🧠 記憶大師</h2>
        <p class="subtitle">選擇難度開始遊戲</p>
      </div>
      <div class="difficulty-buttons">
        <button @click="startGame('easy')" class="difficulty-btn easy">
          ⭐ 簡單 (6對卡牌)
        </button>
        <button @click="startGame('medium')" class="difficulty-btn medium">
          ⭐⭐ 中等 (12對卡牌)
        </button>
        <button @click="startGame('hard')" class="difficulty-btn hard">
          ⭐⭐⭐ 困難 (18對卡牌)
        </button>
      </div>
      <button class="back-btn" @click="emit('back')">← 返回菜單</button>
    </div>

    <!-- 遊戲頭部 -->
    <div v-else class="game-header">
      <button class="back-btn" @click="emit('back')">← 返回菜單</button>
      <div class="score-info">
        <div class="score-item">
          <span class="label">難度:</span>
          <span class="difficulty" :class="difficulty">{{ difficultyText }}</span>
        </div>
        <div class="score-item">
          <span class="label">配對:</span>
          <span class="value">{{ matchCount }}/{{ totalPairs }}</span>
        </div>
        <div class="score-item">
          <span class="label">點擊:</span>
          <span class="value">{{ clickCount }}</span>
        </div>
      </div>
      <button v-if="isGameOver" class="restart-btn" @click="resetGame">
        🔄 重新開始
      </button>
    </div>

    <!-- 遊戲網格 -->
    <div class="memory-grid" v-if="gameStarted && !isGameOver">
      <div
        v-for="(card, index) in cards"
        :key="index"
        class="card"
        :class="{ flipped: card.flipped, matched: card.matched }"
        @click="flipCard(index)"
      >
        <div class="card-inner">
          <div class="card-front">?</div>
          <div class="card-back">{{ card.emoji }}</div>
        </div>
      </div>
    </div>

    <!-- 遊戲結束畫面 -->
    <div v-else-if="isGameOver" class="game-over-screen">
      <div class="congratulations">
        <div class="trophy">🏆</div>
        <h2>太棒了！</h2>
        <p class="stats">
          用 {{ clickCount }} 次點擊<br>
          在 {{ timeElapsed }} 秒內完成！
        </p>
        <p class="message">
          {{ getMessageByClicks() }}
        </p>
        <button class="play-again-btn" @click="resetGame">
          🎮 再玩一次
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
const cards = ref([])
const flippedCards = ref([])
const matchCount = ref(0)
const clickCount = ref(0)
const totalPairs = ref(6)
const isGameOver = ref(false)
const startTime = ref(null)
const timeElapsed = ref(0)
const timerInterval = ref(null)

const emojis = ['🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯']

// 計算屬性
const difficultyText = computed(() => {
  if (difficulty.value === 'easy') return '簡單'
  if (difficulty.value === 'medium') return '中等'
  if (difficulty.value === 'hard') return '困難'
  return ''
})

// 方法
const initializeCards = () => {
  const selectedEmojis = emojis.slice(0, totalPairs.value)
  const pairs = [...selectedEmojis, ...selectedEmojis]
  
  // 打亂
  for (let i = pairs.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [pairs[i], pairs[j]] = [pairs[j], pairs[i]]
  }

  cards.value = pairs.map(emoji => ({
    emoji,
    flipped: false,
    matched: false
  }))
}

const flipCard = (index) => {
  if (isGameOver.value) return
  if (cards.value[index].flipped || cards.value[index].matched) return
  if (flippedCards.value.length >= 2) return

  cards.value[index].flipped = true
  flippedCards.value.push(index)
  clickCount.value++

  if (flippedCards.value.length === 2) {
    setTimeout(() => {
      checkMatch()
    }, 500)
  }
}

const checkMatch = () => {
  const [first, second] = flippedCards.value
  const match = cards.value[first].emoji === cards.value[second].emoji

  if (match) {
    cards.value[first].matched = true
    cards.value[second].matched = true
    matchCount.value++

    if (matchCount.value === totalPairs.value) {
      isGameOver.value = true
      clearInterval(timerInterval.value)
    }
  } else {
    cards.value[first].flipped = false
    cards.value[second].flipped = false
  }

  flippedCards.value = []
}

const startTimer = () => {
  startTime.value = Date.now()
  timerInterval.value = setInterval(() => {
    timeElapsed.value = Math.floor((Date.now() - startTime.value) / 1000)
  }, 100)
}

const startGame = (level) => {
  difficulty.value = level
  gameStarted.value = true
  isGameOver.value = false
  matchCount.value = 0
  clickCount.value = 0
  flippedCards.value = []
  
  if (level === 'easy') totalPairs.value = 6
  else if (level === 'medium') totalPairs.value = 12
  else if (level === 'hard') totalPairs.value = 18

  initializeCards()
  startTimer()
}

const resetGame = () => {
  difficulty.value = null
  gameStarted.value = false
  isGameOver.value = false
  matchCount.value = 0
  clickCount.value = 0
  flippedCards.value = []
  cards.value = []
  timeElapsed.value = 0
  clearInterval(timerInterval.value)
}

const getMessageByClicks = () => {
  if (clickCount.value <= totalPairs.value + 2) {
    return '神級記憶力！你是天才！🌟'
  } else if (clickCount.value <= totalPairs.value + 5) {
    return '太棒了！你的記憶力很強！💪'
  } else {
    return '不錯喔！再練習一下會更好！💙'
  }
}

onBeforeUnmount(() => {
  clearInterval(timerInterval.value)
})
</script>

<style scoped>
.memory-game-screen {
  width: 100%;
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 30px 20px;
  display: flex;
  flex-direction: column;
  align-items: center;
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
  margin-bottom: 30px;
  flex-wrap: wrap;
  gap: 20px;
  width: 100%;
}

.score-info {
  display: flex;
  gap: 30px;
  background: rgba(255, 255, 255, 0.95);
  padding: 15px 30px;
  border-radius: 15px;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

.score-item {
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

.value {
  font-size: 1.3rem;
  font-weight: bold;
  color: #f5576c;
}

.restart-btn:hover {
  transform: scale(1.05);
}

.memory-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
  gap: 15px;
  max-width: 600px;
  margin: 0 auto;
  padding: 0 20px;
}

.card {
  aspect-ratio: 1;
  perspective: 1000px;
  cursor: pointer;
  position: relative;
  height: 100px;
}

.card-inner {
  position: relative;
  width: 100%;
  height: 100%;
  transition: transform 0.6s;
  transform-style: preserve-3d;
}

.card.flipped .card-inner,
.card.matched .card-inner {
  transform: rotateY(180deg);
}

.card-front,
.card-back {
  position: absolute;
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 15px;
  font-size: 2.5rem;
  backface-visibility: hidden;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
}

.card-front {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  font-weight: bold;
}

.card-back {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  transform: rotateY(180deg);
}

.card.matched .card-back {
  background: linear-gradient(135deg, #84fab0 0%, #8fd3f4 100%);
}

.game-over-screen {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
}

.congratulations {
  background: white;
  padding: 50px;
  border-radius: 30px;
  text-align: center;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  max-width: 500px;
}

.trophy {
  font-size: 5rem;
  margin-bottom: 20px;
  animation: bounce 1s ease-in-out infinite;
}

.congratulations h2 {
  color: #667eea;
  font-size: 2.5rem;
  margin: 20px 0;
}

.stats {
  color: #764ba2;
  font-size: 1.3rem;
  margin: 20px 0;
  font-weight: bold;
}

.message {
  color: #f5576c;
  font-size: 1.2rem;
  margin: 20px 0 40px 0;
}

.play-again-btn,
.menu-btn {
  padding: 15px 40px;
  font-size: 1.2rem;
  border: none;
  border-radius: 15px;
  cursor: pointer;
  font-weight: bold;
  margin: 10px;
  transition: all 0.3s ease;
}

.play-again-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.play-again-btn:hover {
  transform: scale(1.05);
  box-shadow: 0 8px 20px rgba(102, 126, 234, 0.3);
}

.menu-btn {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
}

.menu-btn:hover {
  transform: scale(1.05);
  box-shadow: 0 8px 20px rgba(245, 87, 108, 0.3);
}

@keyframes bounce {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-20px);
  }
}
</style>
