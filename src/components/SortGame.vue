<template>
  <div class="sort-game-screen">
    <!-- 難度選擇 -->
    <div v-if="!gameStarted" class="difficulty-selector">
      <div class="title-section">
        <h2>🔢 數字排序</h2>
        <p class="subtitle">將數字按順序點擊排列</p>
      </div>
      <div class="difficulty-buttons">
        <button @click="startGame('easy')" class="difficulty-btn easy">
          ⭐ 簡單 (1-5)
        </button>
        <button @click="startGame('medium')" class="difficulty-btn medium">
          ⭐⭐ 中等 (1-10)
        </button>
        <button @click="startGame('hard')" class="difficulty-btn hard">
          ⭐⭐⭐ 困難 (1-15)
        </button>
      </div>
      <button class="back-btn" @click="$emit('back')">← 返回菜單</button>
    </div>

    <!-- 遊戲頭部 -->
    <div v-else class="game-header">
      <button class="back-btn" @click="$emit('back')">← 返回菜單</button>
      <div class="game-info">
        <div class="info-item">
          <span class="label">難度:</span>
          <span class="difficulty" :class="difficulty">{{ difficultyText }}</span>
        </div>
        <div class="info-item">
          <span class="label">分數:</span>
          <span class="score">{{ score }}</span>
        </div>
        <div class="info-item">
          <span class="label">下一個:</span>
          <span class="next-number">{{ nextNumber }}</span>
        </div>
      </div>
    </div>

    <!-- 遊戲區域 -->
    <div v-if="gameStarted && !gameOver" class="game-area">
      <div class="instructions">
        <p>💡 提示: 按順序點擊數字 {{ nextNumber }} 到 {{ maxNumber }}</p>
      </div>

      <div class="numbers-grid">
        <div
          v-for="num in scrambledNumbers"
          :key="num"
          class="number-card"
          @click="selectNumber(num)"
          :class="{ 
            correct: selectedNumbers.includes(num),
            disabled: selectedNumbers.includes(num)
          }"
        >
          {{ num }}
        </div>
      </div>

      <div class="progress-bar">
        <div class="progress-fill" :style="{ width: (selectedNumbers.length / maxNumber) * 100 + '%' }"></div>
      </div>

      <div v-if="errorMessage" class="error-message">
        {{ errorMessage }}
      </div>
    </div>

    <!-- 遊戲結束 -->
    <div v-else-if="gameOver" class="game-over-screen">
      <div class="result-card">
        <div class="emoji">🏆</div>
        <h2>{{ resultMessage }}</h2>
        <p class="stats">
          <strong>{{ difficultyText }}</strong> 級 | <strong>{{ score }}</strong> 分
        </p>

        <button class="restart-btn" @click="resetGame">
          🔄 重新開始
        </button>
        <button class="menu-btn" @click="$emit('back')">
          🏠 返回菜單
        </button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'SortGame',
  emits: ['back'],
  data() {
    return {
      difficulty: null,
      gameStarted: false,
      gameOver: false,
      score: 0,
      selectedNumbers: [],
      scrambledNumbers: [],
      maxNumber: 0,
      nextNumber: 1,
      errorMessage: '',
      errorTimer: null,
      canClick: true
    }
  },
  computed: {
    difficultyText() {
      if (this.difficulty === 'easy') return '簡單'
      if (this.difficulty === 'medium') return '中等'
      if (this.difficulty === 'hard') return '困難'
      return ''
    }
  },
  methods: {
    startGame(level) {
      this.difficulty = level
      this.gameStarted = true
      this.gameOver = false
      this.score = 0
      this.selectedNumbers = []
      this.nextNumber = 1
      this.errorMessage = ''

      let max = 0
      if (level === 'easy') max = 5
      else if (level === 'medium') max = 10
      else if (level === 'hard') max = 15

      this.maxNumber = max
      this.generateNumbers()
    },
    generateNumbers() {
      const numbers = []
      for (let i = 1; i <= this.maxNumber; i++) {
        numbers.push(i)
      }

      // 隨機打亂
      for (let i = numbers.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [numbers[i], numbers[j]] = [numbers[j], numbers[i]]
      }

      this.scrambledNumbers = numbers
    },
    selectNumber(num) {
      if (!this.canClick) return
      if (this.selectedNumbers.includes(num)) return

      if (num === this.nextNumber) {
        this.selectedNumbers.push(num)
        this.nextNumber++
        this.score += 10

        if (this.selectedNumbers.length === this.maxNumber) {
          this.gameOver = true
          this.score += 50
        }
      } else {
        this.errorMessage = `❌ 錯誤！應該是 ${this.nextNumber}，不是 ${num}`
        this.canClick = false

        if (this.errorTimer) clearTimeout(this.errorTimer)
        this.errorTimer = setTimeout(() => {
          this.errorMessage = ''
          this.canClick = true
        }, 1500)
      }
    },
    resetGame() {
      this.difficulty = null
      this.gameStarted = false
      this.gameOver = false
      this.errorMessage = ''
    }
  },
  beforeUnmount() {
    if (this.errorTimer) clearTimeout(this.errorTimer)
  }
}
</script>

<style scoped>
.sort-game-screen {
  width: 100%;
  min-height: 100vh;
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
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
  color: #00f2fe;
}

.game-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
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

.next-number {
  background: rgba(255, 255, 255, 0.2);
  padding: 5px 15px;
  border-radius: 20px;
  font-size: 1.3rem;
  font-weight: bold;
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
  gap: 30px;
}

.instructions {
  color: white;
  font-size: 1.2rem;
  font-weight: bold;
  text-align: center;
  background: rgba(255, 255, 255, 0.1);
  padding: 15px 30px;
  border-radius: 15px;
}

.numbers-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(70px, 1fr));
  gap: 12px;
  width: 100%;
  max-width: 500px;
}

.number-card {
  aspect-ratio: 1;
  background: white;
  border: 3px solid rgba(255, 255, 255, 0.5);
  border-radius: 15px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
  font-size: 1.8rem;
  font-weight: bold;
  color: #4facfe;
}

.number-card:hover:not(.disabled) {
  transform: scale(1.1);
  background: #4facfe;
  color: white;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2);
}

.number-card.correct {
  background: linear-gradient(135deg, #84fab0 0%, #8fd3f4 100%);
  color: white;
  border-color: #84fab0;
  animation: slideUp 0.3s ease;
}

.number-card.disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.progress-bar {
  width: 100%;
  max-width: 400px;
  height: 10px;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 10px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #4facfe 0%, #00f2fe 100%);
  transition: width 0.3s ease;
}

.error-message {
  color: white;
  font-size: 1.2rem;
  font-weight: bold;
  background: rgba(255, 107, 107, 0.3);
  padding: 15px 30px;
  border-radius: 15px;
  animation: slideUp 0.3s ease;
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
  color: #4facfe;
  margin: 20px 0;
}

.stats {
  font-size: 1.2rem;
  color: #00f2fe;
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
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  color: white;
}

.restart-btn:hover {
  transform: scale(1.05);
  box-shadow: 0 5px 15px rgba(79, 172, 254, 0.3);
}

.menu-btn {
  background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
  color: #4facfe;
}

.menu-btn:hover {
  transform: scale(1.05);
  box-shadow: 0 5px 15px rgba(168, 237, 234, 0.3);
}

@keyframes slideUp {
  from {
    transform: translateY(20px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}
</style>
