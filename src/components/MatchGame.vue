<template>
  <div class="match-game-screen">
    <!-- 難度選擇 -->
    <div v-if="!gameStarted" class="difficulty-selector">
      <div class="title-section">
        <h2>🎯 配對大師</h2>
        <p class="subtitle">找到相同的圖案組合</p>
      </div>
      <div class="difficulty-buttons">
        <button @click="startGame('easy')" class="difficulty-btn easy">
          ⭐ 簡單 (3組圖案)
        </button>
        <button @click="startGame('medium')" class="difficulty-btn medium">
          ⭐⭐ 中等 (5組圖案)
        </button>
        <button @click="startGame('hard')" class="difficulty-btn hard">
          ⭐⭐⭐ 困難 (7組圖案)
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
          <span class="label">進度:</span>
          <span class="progress-text">{{ matchedPairs }}/{{ totalPairs }}</span>
        </div>
      </div>
    </div>

    <!-- 遊戲區域 -->
    <div v-if="gameStarted && !gameOver" class="game-area">
      <div class="instructions">
        <p>💡 提示: 點擊兩個卡片，找出相同的圖案組合</p>
      </div>

      <div class="pairs-grid">
        <div
          v-for="(pair, index) in displayPairs"
          :key="index"
          class="pair-card"
          @click="selectPair(index)"
          :class="{ 
            selected: selectedPairs.includes(index),
            matched: matchedIndices.includes(index),
            disabled: matchedIndices.includes(index) || selectedPairs.length === 2
          }"
        >
          <div class="pair-content">
            <span v-if="selectedPairs.includes(index) || matchedIndices.includes(index)" class="pair-icon">
              {{ pair.icon }}
            </span>
            <span v-else class="pair-icon">?</span>
          </div>
        </div>
      </div>

      <div class="progress-bar">
        <div class="progress-fill" :style="{ width: (matchedPairs / totalPairs) * 100 + '%' }"></div>
      </div>
    </div>

    <!-- 遊戲結束 -->
    <div v-else-if="gameOver" class="game-over-screen">
      <div class="result-card">
        <div class="emoji">🎯</div>
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
  name: 'MatchGame',
  emits: ['back'],
  data() {
    return {
      difficulty: null,
      gameStarted: false,
      gameOver: false,
      score: 0,
      selectedPairs: [],
      matchedIndices: [],
      displayPairs: [],
      totalPairs: 0,
      matchedPairs: 0,
      pairIcons: ['🐶', '🐱', '🐻', '🐼', '🦁', '🐯', '🦊', '🐭'],
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
      this.selectedPairs = []
      this.matchedIndices = []
      this.matchedPairs = 0

      let pairCount = 0
      if (level === 'easy') pairCount = 3
      else if (level === 'medium') pairCount = 5
      else if (level === 'hard') pairCount = 7

      this.totalPairs = pairCount
      this.generatePairs(pairCount)
    },
    generatePairs(count) {
      const selectedIcons = this.pairIcons.slice(0, count)
      const pairs = []

      selectedIcons.forEach((icon, index) => {
        pairs.push({ id: index, icon, matched: false })
        pairs.push({ id: index, icon, matched: false })
      })

      // 隨機打亂
      for (let i = pairs.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [pairs[i], pairs[j]] = [pairs[j], pairs[i]]
      }

      this.displayPairs = pairs
    },
    selectPair(index) {
      if (!this.canClick) return
      if (this.selectedPairs.includes(index)) return
      if (this.matchedIndices.includes(index)) return

      this.selectedPairs.push(index)

      if (this.selectedPairs.length === 2) {
        this.canClick = false
        this.checkMatch()
      }
    },
    checkMatch() {
      const [first, second] = this.selectedPairs
      const firstIcon = this.displayPairs[first].icon
      const secondIcon = this.displayPairs[second].icon

      if (firstIcon === secondIcon) {
        this.matchedIndices.push(first, second)
        this.matchedPairs++
        this.score += 50

        if (this.matchedPairs === this.totalPairs) {
          setTimeout(() => {
            this.gameOver = true
          }, 500)
        }

        this.selectedPairs = []
        this.canClick = true
      } else {
        setTimeout(() => {
          this.selectedPairs = []
          this.canClick = true
        }, 800)
      }
    },
    resetGame() {
      this.difficulty = null
      this.gameStarted = false
      this.gameOver = false
    }
  }
}
</script>

<style scoped>
.match-game-screen {
  width: 100%;
  min-height: 100vh;
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
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
  color: #f5576c;
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

.progress-text {
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

.pairs-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
  gap: 15px;
  width: 100%;
  max-width: 600px;
}

.pair-card {
  aspect-ratio: 1;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: 3px solid white;
  border-radius: 15px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
  font-size: 2.5rem;
}

.pair-card:hover:not(.disabled) {
  transform: scale(1.05) rotateZ(-2deg);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.3);
}

.pair-card.selected {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  transform: scale(0.95) rotateZ(2deg);
}

.pair-card.matched {
  background: linear-gradient(135deg, #84fab0 0%, #8fd3f4 100%);
  border-color: #84fab0;
  animation: bounce 0.5s ease;
}

.pair-card.disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.pair-content {
  display: flex;
  align-items: center;
  justify-content: center;
}

.pair-icon {
  font-size: 3rem;
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
  color: #f5576c;
  margin: 20px 0;
}

.stats {
  font-size: 1.2rem;
  color: #667eea;
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
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
}

.restart-btn:hover {
  transform: scale(1.05);
  box-shadow: 0 5px 15px rgba(245, 87, 108, 0.3);
}

.menu-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.menu-btn:hover {
  transform: scale(1.05);
  box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
}

@keyframes bounce {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.1);
  }
}
</style>
