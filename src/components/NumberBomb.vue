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
        <p>⏰ 快點擊正確的數字：<strong>{{ targetNumber }}</strong></p>
        <div class="time-bar">
          <div class="time-fill" :style="{ width: timePercentage + '%' }"></div>
        </div>
      </div>

      <div class="numbers-grid">
        <button
          v-for="(num, index) in currentNumbers"
          :key="index"
          class="number-btn"
          @click="checkNumber(num)"
          :class="{ correct: selectedIndex === index && isCorrect }"
        >
          {{ num }}
        </button>
      </div>
    </div>

    <!-- 遊戲結束 -->
    <div v-else class="game-over-screen">
      <div class="result-card">
        <div v-if="wins >= 5" class="emoji">🏆</div>
        <div v-else-if="wins >= 3" class="emoji">🎉</div>
        <div v-else class="emoji">😊</div>

        <h2>{{ resultMessage }}</h2>
        <p class="final-score">最終分數: {{ score }}</p>
        <p class="stats">成功: {{ wins }} 次 | 失敗: {{ 3 - lives }} 次</p>

        <button class="restart-btn" @click="restartGame">
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
  name: 'NumberBomb',
  emits: ['back'],
  data() {
    return {
      currentNumbers: [],
      targetNumber: null,
      score: 0,
      lives: 3,
      gameOver: false,
      wins: 0,
      timeLeft: 3,
      timeTotal: 3,
      gameTimer: null,
      difficulty: null,
      difficultyLevel: 1,
      selectedIndex: -1,
      isCorrect: false,
      gameStarted: false
    }
  },
  computed: {
    timePercentage() {
      return (this.timeLeft / this.timeTotal) * 100
    },
    resultMessage() {
      if (this.wins >= 5) {
        return '太棒了！你是數字高手！🌟'
      } else if (this.wins >= 3) {
        return '很不錯！再加油！💪'
      } else {
        return '繼續練習喔！下次會更好！💙'
      }
    },
    difficultyText() {
      if (this.difficulty === 'easy') return '簡單'
      if (this.difficulty === 'medium') return '中等'
      if (this.difficulty === 'hard') return '困難'
      return ''
    }
  },
  mounted() {
    // 不自動開始遊戲，等待使用者選擇難度
  },
  beforeUnmount() {
    if (this.gameTimer) clearInterval(this.gameTimer)
  },
  methods: {
    startGame(level) {
      this.difficulty = level
      this.difficultyLevel = level === 'easy' ? 1 : level === 'medium' ? 2 : 3
      this.timeTotal = level === 'easy' ? 5 : level === 'medium' ? 3.5 : 2.5
      this.score = 0
      this.lives = 3
      this.wins = 0
      this.gameOver = false
      this.gameStarted = true
      this.generateRound()
      this.startTimer()
    },
    generateRound() {
      // 根據難度生成數字
      const count = 3 + Math.floor(this.difficultyLevel / 2)
      const range = 10 + this.difficultyLevel * 5
      const numbers = new Set()

      while (numbers.size < count) {
        numbers.add(Math.floor(Math.random() * range) + 1)
      }

      this.currentNumbers = Array.from(numbers).sort(() => Math.random() - 0.5)
      this.targetNumber = this.currentNumbers[Math.floor(Math.random() * this.currentNumbers.length)]
      this.timeLeft = this.timeTotal
      this.selectedIndex = -1
      this.isCorrect = false
    },
    startTimer() {
      if (this.gameTimer) clearInterval(this.gameTimer)

      this.gameTimer = setInterval(() => {
        this.timeLeft -= 0.05

        if (this.timeLeft <= 0) {
          clearInterval(this.gameTimer)
          this.loseLife()
        }
      }, 50)
    },
    checkNumber(num) {
      clearInterval(this.gameTimer)

      this.selectedIndex = this.currentNumbers.indexOf(num)

      if (num === this.targetNumber) {
        this.isCorrect = true
        this.score += Math.max(Math.floor(this.timeLeft * 10), 5)
        this.wins++
        this.difficulty += 0.5

        setTimeout(() => {
          if (this.lives > 0) {
            this.generateRound()
            this.startTimer()
          }
        }, 500)
      } else {
        this.loseLife()
      }
    },
    loseLife() {
      clearInterval(this.gameTimer)
      this.lives--

      if (this.lives <= 0) {
        this.gameOver = true
      } else {
        setTimeout(() => {
          this.generateRound()
          this.startTimer()
        }, 800)
      }
    },
    restartGame() {
      this.score = 0
      this.lives = 3
      this.gameOver = false
      this.wins = 0
      this.difficulty = 1
      this.startGame()
    }
  }
}
</script>

<style scoped>
.bomb-game-screen {
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
  font-size: 1.1rem;
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
  background: linear-gradient(135deg, #ff6b6b 0%, #ff8c42 100%);
}

.difficulty-btn:hover {
  transform: translateY(-3px);
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
  padding: 5px 15px;
  border-radius: 20px;
  font-weight: bold;
  color: white;
}

.difficulty.easy {
  background: linear-gradient(135deg, #84fab0 0%, #8fd3f4 100%);
}

.difficulty.medium {
  background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
}

.difficulty.hard {
  background: linear-gradient(135deg, #ff6b6b 0%, #ff8c42 100%);
}

.score {
  font-size: 1.5rem;
  font-weight: bold;
  color: #f5576c;
}

.hearts {
  display: flex;
  gap: 5px;
}

.heart {
  font-size: 1.5rem;
  opacity: 1;
  transition: all 0.3s ease;
}

.heart.lost {
  opacity: 0.3;
  filter: grayscale(100%);
}

.score {
  font-size: 1.5rem;
  font-weight: bold;
  color: #f5576c;
}

.bomb-game-area {
  max-width: 600px;
  margin: 0 auto;
}

.instructions {
  background: rgba(255, 255, 255, 0.95);
  padding: 30px;
  border-radius: 20px;
  margin-bottom: 40px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
  text-align: center;
}

.instructions p {
  font-size: 1.8rem;
  color: #667eea;
  margin-bottom: 20px;
  font-weight: bold;
}

.time-bar {
  width: 100%;
  height: 30px;
  background: #ddd;
  border-radius: 15px;
  overflow: hidden;
  border: 3px solid #667eea;
}

.time-fill {
  height: 100%;
  background: linear-gradient(90deg, #4facfe 0%, #00f2fe 100%);
  transition: width 0.05s linear;
}

.numbers-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
  margin-top: 30px;
}

.number-btn {
  padding: 30px;
  font-size: 2rem;
  font-weight: bold;
  border: none;
  border-radius: 20px;
  cursor: pointer;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  transition: all 0.2s ease;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2);
  border: 3px solid white;
}

.number-btn:hover {
  transform: scale(1.1);
}

.number-btn:active {
  transform: scale(0.95);
}

.number-btn.correct {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  box-shadow: 0 0 30px #4facfe;
  animation: correctBounce 0.4s ease;
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

.final-score {
  font-size: 1.5rem;
  color: #f5576c;
  font-weight: bold;
  margin-bottom: 10px;
}

.stats {
  font-size: 1.1rem;
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

@keyframes correctBounce {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.15);
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

@media (max-width: 600px) {
  .numbers-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .number-btn {
    padding: 20px;
    font-size: 1.5rem;
  }

  .instructions p {
    font-size: 1.4rem;
  }
}
</style>
