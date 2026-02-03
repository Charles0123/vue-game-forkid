<template>
  <div class="reaction-game-screen">
    <!-- 難度選擇 -->
    <div v-if="!gameStarted" class="difficulty-selector">
      <div class="title-section">
        <h2>⚡ 反應測驗</h2>
        <p class="subtitle">盡快點擊出現的目標</p>
      </div>
      <div class="difficulty-buttons">
        <button @click="startGame('easy')" class="difficulty-btn easy">
          ⭐ 簡單 (大目標、慢速)
        </button>
        <button @click="startGame('medium')" class="difficulty-btn medium">
          ⭐⭐ 中等 (中等目標、正常)
        </button>
        <button @click="startGame('hard')" class="difficulty-btn hard">
          ⭐⭐⭐ 困難 (小目標、快速)
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
          <span class="label">輪數:</span>
          <span class="round">{{ round }}/10</span>
        </div>
      </div>
    </div>

    <!-- 遊戲區域 -->
    <div v-if="gameStarted && !gameOver" class="game-area">
      <div class="instructions">
        <p v-if="!targetActive">⏳ 準備好了嗎？點擊當看到目標時...</p>
        <p v-else>💨 快點擊！！！</p>
      </div>

      <div class="game-container">
        <div
          v-if="targetActive"
          class="target"
          :style="{
            width: targetSize + 'px',
            height: targetSize + 'px',
            left: targetX + 'px',
            top: targetY + 'px'
          }"
          @click="hitTarget"
        >
          🎯
        </div>
        <div v-else class="waiting-area">
          <p>等待中...</p>
        </div>
      </div>

      <div v-if="reactionTime > 0" class="reaction-display">
        ⚡ 反應時間: {{ reactionTime }}ms
      </div>
    </div>

    <!-- 遊戲結束 -->
    <div v-else-if="gameOver" class="game-over-screen">
      <div class="result-card">
        <div class="emoji">⚡</div>
        <h2>{{ resultMessage }}</h2>
        <p class="average-time">
          平均反應時間: <strong>{{ averageTime }}ms</strong>
        </p>
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
  name: 'ReactionGame',
  emits: ['back'],
  data() {
    return {
      difficulty: null,
      gameStarted: false,
      gameOver: false,
      score: 0,
      round: 0,
      targetActive: false,
      targetX: 0,
      targetY: 0,
      targetSize: 80,
      reactionTime: 0,
      reactionTimes: [],
      startTime: 0,
      gameTimer: null,
      canClick: true,
      gameAreaWidth: 0,
      gameAreaHeight: 0
    }
  },
  computed: {
    difficultyText() {
      if (this.difficulty === 'easy') return '簡單'
      if (this.difficulty === 'medium') return '中等'
      if (this.difficulty === 'hard') return '困難'
      return ''
    },
    averageTime() {
      if (this.reactionTimes.length === 0) return 0
      const sum = this.reactionTimes.reduce((a, b) => a + b, 0)
      return Math.round(sum / this.reactionTimes.length)
    }
  },
  mounted() {
    this.updateGameAreaSize()
    window.addEventListener('resize', this.updateGameAreaSize)
  },
  beforeUnmount() {
    if (this.gameTimer) clearInterval(this.gameTimer)
    window.removeEventListener('resize', this.updateGameAreaSize)
  },
  methods: {
    updateGameAreaSize() {
      const area = document.querySelector('.game-container')
      if (area) {
        this.gameAreaWidth = area.offsetWidth
        this.gameAreaHeight = area.offsetHeight
      }
    },
    startGame(level) {
      this.difficulty = level
      this.gameStarted = true
      this.gameOver = false
      this.score = 0
      this.round = 0
      this.reactionTimes = []

      if (level === 'easy') {
        this.targetSize = 120
      } else if (level === 'medium') {
        this.targetSize = 80
      } else if (level === 'hard') {
        this.targetSize = 50
      }

      this.updateGameAreaSize()
      this.nextRound()
    },
    nextRound() {
      if (this.round >= 10) {
        this.gameOver = true
        return
      }

      this.round++
      this.targetActive = false
      this.reactionTime = 0

      const waitTime = this.difficulty === 'easy' ? 2000 : this.difficulty === 'medium' ? 1500 : 1000

      if (this.gameTimer) clearInterval(this.gameTimer)

      this.gameTimer = setTimeout(() => {
        this.showTarget()
      }, waitTime + Math.random() * 2000)
    },
    showTarget() {
      this.targetActive = true
      this.canClick = true
      this.reactionTime = 0
      this.startTime = Date.now()

      const reactionTimeout = this.difficulty === 'easy' ? 5000 : this.difficulty === 'medium' ? 4000 : 3000

      if (this.gameTimer) clearInterval(this.gameTimer)

      this.gameTimer = setTimeout(() => {
        if (this.targetActive) {
          this.targetActive = false
          setTimeout(() => {
            this.nextRound()
          }, 500)
        }
      }, reactionTimeout)

      this.randomizeTargetPosition()
    },
    randomizeTargetPosition() {
      this.targetX = Math.random() * (this.gameAreaWidth - this.targetSize)
      this.targetY = Math.random() * (this.gameAreaHeight - this.targetSize)
    },
    hitTarget() {
      if (!this.targetActive || !this.canClick) return

      this.reactionTime = Date.now() - this.startTime
      this.reactionTimes.push(this.reactionTime)

      if (this.reactionTime < 200) {
        this.score += 30
      } else if (this.reactionTime < 400) {
        this.score += 20
      } else {
        this.score += 10
      }

      this.targetActive = false
      this.canClick = false

      if (this.gameTimer) clearInterval(this.gameTimer)

      setTimeout(() => {
        this.nextRound()
      }, 500)
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
.reaction-game-screen {
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

.round {
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

.game-container {
  width: 100%;
  max-width: 600px;
  height: 400px;
  background: rgba(255, 255, 255, 0.1);
  border: 3px solid white;
  border-radius: 20px;
  position: relative;
  overflow: hidden;
}

.target {
  position: absolute;
  background: linear-gradient(135deg, #ffd700 0%, #ff8c00 100%);
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2.5rem;
  transition: all 0.1s ease;
  box-shadow: 0 5px 20px rgba(255, 215, 0, 0.5);
  animation: pulse 0.5s ease-in-out infinite;
}

.target:hover {
  transform: scale(1.1);
  box-shadow: 0 8px 25px rgba(255, 215, 0, 0.7);
}

.waiting-area {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 100%;
  color: rgba(255, 255, 255, 0.5);
  font-size: 1.5rem;
}

.reaction-display {
  color: white;
  font-size: 1.5rem;
  font-weight: bold;
  background: rgba(255, 255, 255, 0.2);
  padding: 20px 40px;
  border-radius: 15px;
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

.average-time {
  font-size: 1.3rem;
  color: #f093fb;
  margin: 15px 0;
  font-weight: bold;
}

.stats {
  font-size: 1.2rem;
  color: #f5576c;
  margin: 15px 0 30px 0;
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

@keyframes pulse {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.15);
  }
}
</style>
